import { Node } from "https://esm.sh/@tiptap/core";
import { Plugin } from "https://esm.sh/prosemirror-state";

const userId = document.getElementById("userId")?.value || `guest-${Math.random().toString(36).substr(2,6)}`;

function sendChatAction(postId, userId, action, callback) {
    if (!postId || !userId) return callback(null);
    $.ajax({
        url: "/chat/update",
        method: "POST",
        data: { postId, userId, action },
        success: res => callback(res),
        error: (xhr, status, err) => {
            console.error(`❌ ${action} 요청 실패:`, err);
            callback(null);
        }
    });
}

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
                        return $from.nodeAfter?.type.name === "scheduleBlock";
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

            const { title = "미정 모임", maxPeople: initMaxPeople, currentPeople: initPeople, editMode, postId } = node.attrs;
            let currentPeople = initPeople;
            let maxPeople = initMaxPeople;
            let joined = false;

            if (postId) dom.setAttribute("data-post-id", postId);

            dom.innerHTML = `
                <div class="schedule-title">📅 ${title}</div>
                <div class="schedule-date">🕐 ${node.attrs.meetDate} ${node.attrs.meetTime}</div>
                <div class="schedule-info-item">
                    👥 <span class="currentPeople">${currentPeople}</span>/<span class="maxPeople">${maxPeople}</span>명 모집
                </div>
                <div class="schedule-btns" style="display:flex; justify-content:space-between; margin-top:5px;">
                    <button class="schedule-join-btn" ${postId ? "" : "disabled"}>참가하기</button>
                    ${editMode ? '<button class="schedule-delete-btn btn-delete">삭제</button>' : ""}
                </div>
            `;

            const joinBtn = dom.querySelector(".schedule-join-btn");
            const deleteBtn = dom.querySelector(".schedule-delete-btn");
            const currentPeopleSpan = dom.querySelector(".currentPeople");
            const maxPeopleSpan = dom.querySelector(".maxPeople");

            const updateCurrentPeople = (count, max) => {
                currentPeople = count;
                currentPeopleSpan.textContent = currentPeople;
                if (max !== undefined) {
                    maxPeople = max;
                    maxPeopleSpan.textContent = maxPeople;
                }
                if (joinBtn) joinBtn.disabled = joined || currentPeople >= maxPeople;
            };

            const handleParticipantUpdate = (e) => {
                if (e.detail.postId === postId) updateCurrentPeople(e.detail.currentPeople, e.detail.maxPeople);
            };

            document.addEventListener("chatParticipantUpdate", handleParticipantUpdate);

            // 삭제 버튼 (editMode 전용)
            if (editMode && deleteBtn) {
                $(deleteBtn).on("click", e => {
                    e.stopPropagation();
                    if (!confirm("이 블록을 삭제하시겠습니까?")) return;
                    const pos = getPos();
                    if (pos != null) editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
                    document.removeEventListener("chatParticipantUpdate", handleParticipantUpdate);
                });
            }

            // 페이지 로드 시 참가 상태 확인 + 참가자 수 가져오기
            if (postId && !editMode) {
                sendChatAction(postId, userId, "check", res => {
                    if (res?.chatResult?.alreadyJoined) {
                        joined = true;
                        joinBtn.textContent = "참가중";
                        joinBtn.disabled = true;
                        joinBtn.classList.add("joined");
                    }
                });

                $.getJSON(`/chat/participants?postId=${postId}`, data => {
                    if (data?.currentPeople != null) updateCurrentPeople(data.currentPeople, data.maxPeople);
                }).fail(err => console.warn("⚠️ 참가자 수 로드 실패:", err));
            }

            // 참가 버튼 클릭
            $(joinBtn).on("click", e => {
                e.stopPropagation();
                if (!postId || joined || currentPeople >= maxPeople) {
                    if (currentPeople >= maxPeople) alert("참가 인원이 가득 찼습니다.");
                    return;
                }
                sendChatAction(postId, userId, "join", res => {
                    if (!res?.chatResult?.success) return alert(res?.chatResult?.message || "참가 실패");
                    joined = true;
                    joinBtn.textContent = "참가중";
                    joinBtn.disabled = true;
                    joinBtn.classList.add("joined");
                    if (typeof window.chatUpdateParticipantCount === "function") window.chatUpdateParticipantCount(postId);
                    alert(`${title} 모임에 참가했습니다!`);
                });
            });

            // 드래그 방지
            dom.addEventListener("dragstart", e => e.preventDefault());
            dom.addEventListener("drop", e => e.preventDefault());

            return { dom, destroy: () => document.removeEventListener("chatParticipantUpdate", handleParticipantUpdate) };
        };
    },
});

export function activateScheduleBlockAbly(editor, postId) {
    editor.state.doc.descendants((node, pos) => {
        if (node.type.name === "scheduleBlock") {
            const tr = editor.state.tr.setNodeMarkup(pos, undefined, { ...node.attrs, postId });
            editor.view.dispatch(tr);
        }
    });
}
