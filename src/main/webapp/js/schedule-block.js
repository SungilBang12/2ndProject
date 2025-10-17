import { Node } from "https://esm.sh/@tiptap/core";
import { Plugin } from "https://esm.sh/prosemirror-state";

const userId = document.getElementById("userId")?.value || `guest-${Math.random().toString(36).substr(2,6)}`;

// ===================== 공용 요청 함수 =====================
async function sendChatAction(postId, userId, action) {
    if (!postId || !userId) return null;
    try {
        const res = await fetch("/chat/update", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
            body: new URLSearchParams({ postId: String(postId), userId, action }),
        });
        if (!res.ok) throw new Error(`서버 오류: ${res.status}`);
        return await res.json();
    } catch (err) {
        console.error(`❌ ${action} 요청 실패:`, err);
        return null;
    }
}

// ===================== Ably 설정 =====================
async function fetchAblyConfig(postId) {
    const res = await fetch(`/chat/init?postId=${postId}`);
    if (!res.ok) throw new Error("초기화 실패");
    const data = await res.json();
    if (!data.ablyConfig?.pubKey) throw new Error("Ably 키 미설정");
    return data.ablyConfig.pubKey;
}

async function setupAblyChannel(postId, userId) {
    const pubKey = await fetchAblyConfig(postId);
    const ably = new Ably.Realtime({ key: pubKey, clientId: userId });
    const channel = ably.channels.get(`channel-${postId}`);

    await new Promise((resolve, reject) => {
        const check = () => {
            if (ably.connection.state === "connected") resolve();
            else if (ably.connection.state === "failed") reject("Ably 연결 실패");
            else setTimeout(check, 150);
        };
        check();
    });

    return channel;
}

// ===================== ScheduleBlock Node =====================
export const ScheduleBlock = Node.create({
    name: "scheduleBlock",
    group: "block",
    atom: true,
    draggable: false,

    addAttributes() {
        return {
            title: { default: "" },
            meetDate: { default: "" },
            meetTime: { default: "" },
            currentPeople: { default: 0 },
            maxPeople: { default: 2 },
            editMode: { default: false },
            postId: { default: null },
        };
    },

    addProseMirrorPlugins() {
        return [
            new Plugin({
                props: {
                    handleKeyDown(view, event) {
                        const { $from } = view.state.selection;
                        const nodeAfter = $from.nodeAfter;
                        if (nodeAfter?.type.name === "scheduleBlock") {
                            if (event.key.startsWith("Arrow") || event.key === "Tab" || event.ctrlKey || event.metaKey) return false;
                            return true;
                        }
                        return false;
                    },
                    handleTextInput(view, from, to, text) {
                        const { $from } = view.state.selection;
                        const nodeAfter = $from.nodeAfter;
                        return nodeAfter?.type.name === "scheduleBlock";
                    },
                },
            }),
        ];
    },

    addNodeView() {
        return ({ node, getPos, editor }) => {
            const dom = document.createElement("div");
            dom.className = "schedule-block";
            dom.setAttribute("contenteditable", "false");

            const { title = "미정 모임", maxPeople, currentPeople: initPeople, editMode, postId } = node.attrs;
            let currentPeople = initPeople;
            let joined = false;

            dom.innerHTML = `
                <div class="schedule-title">📅 ${title}</div>
                <div class="schedule-date">🕐 ${node.attrs.meetDate} ${node.attrs.meetTime}</div>
                <div class="schedule-info-item">👥 <span class="currentPeople">${currentPeople}</span>/${maxPeople}명 모집</div>
                <div class="schedule-btns" style="display:flex; justify-content:space-between; margin-top:5px;">
                    <button class="schedule-join-btn" ${postId ? "" : "disabled"}>참가하기</button>
                    ${editMode ? '<button class="schedule-cancel-btn btn-cancel">삭제</button>' : ""}
                </div>
            `;

            const joinBtn = dom.querySelector(".schedule-join-btn");
            const cancelBtn = dom.querySelector(".schedule-cancel-btn");
            const currentPeopleSpan = dom.querySelector(".currentPeople");

            const updatePresenceCount = (membersLength) => {
                currentPeople = membersLength;
                currentPeopleSpan.textContent = currentPeople;
                if (joinBtn) joinBtn.disabled = joined || currentPeople >= maxPeople;
            };

            // ✅ 드래그 방지
            dom.addEventListener("dragstart", e => { e.preventDefault(); e.stopPropagation(); });
            dom.addEventListener("drop", e => { e.preventDefault(); e.stopPropagation(); });

            // ✅ 삭제 버튼 (수정 모드 전용)
            if (editMode && cancelBtn) {
                cancelBtn.addEventListener("click", (e) => {
                    e.stopPropagation();
                    if (!confirm("이 블록을 삭제하시겠습니까?")) return;
                    const pos = getPos();
                    if (pos != null) editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
                });
            }

            // ✅ 페이지 로드시 참가 상태 자동 확인
            (async () => {
                if (postId && !editMode) {
                    const checkData = await sendChatAction(postId, userId, "check");
                    if (checkData?.chatResult?.alreadyJoined) {
                        joined = true;
                        joinBtn.textContent = "참여중";
                        joinBtn.disabled = true;
                    }
                }
            })();

            // ✅ 참가 버튼 클릭 이벤트
            joinBtn?.addEventListener("click", async (e) => {
                e.stopPropagation();
                if (!node.attrs.postId) {
                    alert("게시글이 아직 저장되지 않아 참가할 수 없습니다.");
                    return;
                }
                if (joined || currentPeople >= maxPeople) return;

                // 참가 처리
                const joinData = await sendChatAction(node.attrs.postId, userId, "join");
                if (!joinData?.chatResult?.success) {
                    alert(joinData?.chatResult?.message || "참가 실패");
                    return;
                }

                try {
                    const channel = await setupAblyChannel(node.attrs.postId, userId);
                    await new Promise(resolve => channel.presence.enter({ user: userId }, resolve));

                    joined = true;
                    joinBtn.disabled = true;
                    joinBtn.textContent = "참여중";

                    // 현재 인원 수 반영
                    channel.presence.get((err, members) => {
                        if (!err) updatePresenceCount(members?.length || 0);
                    });

                    // 실시간 입퇴장 반영
                    channel.presence.subscribe(["enter", "leave"], () => {
                        channel.presence.get((err, members) => {
                            if (!err) updatePresenceCount(members?.length || 0);
                        });
                    });

                    alert(`${title} 모임에 참가했습니다!`);
                } catch (err) {
                    console.warn(err);
                    alert("참가 실패");
                }
            });

            return { dom };
        };
    },
});

// ===================== postId 활성화 후 Ably 연결 =====================
export function activateScheduleBlockAbly(editor, postId) {
    editor.state.doc.descendants((node, pos) => {
        if (node.type.name === "scheduleBlock") {
            const tr = editor.state.tr.setNodeMarkup(pos, undefined, { ...node.attrs, postId });
            editor.view.dispatch(tr);
        }
    });
}
