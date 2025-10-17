import { Node } from "https://esm.sh/@tiptap/core";
import { Plugin } from "https://esm.sh/prosemirror-state";

const userId = document.getElementById("userId")?.value || `guest-${Math.random().toString(36).substr(2,6)}`;

// ===================== 공용 요청 함수 (jQuery AJAX) =====================
function sendChatAction(postId, userId, action, callback) {
    if (!postId || !userId) return callback(null);

    $.ajax({
        url: "/chat/update",
        method: "POST",
        data: { postId, userId, action },
        success: function(res) { callback(res); },
        error: function(xhr, status, err) {
            console.error(`❌ ${action} 요청 실패:`, err);
            callback(null);
        }
    });
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
                    ${editMode ? '<button class="schedule-delete-btn btn-delete">삭제</button>' : ""}
                </div>
            `;

            const joinBtn = dom.querySelector(".schedule-join-btn");
            const deleteBtn = dom.querySelector(".schedule-delete-btn");
            const currentPeopleSpan = dom.querySelector(".currentPeople");

            const updateCurrentPeople = (count) => {
                currentPeople = count;
                currentPeopleSpan.textContent = currentPeople;
                if (joinBtn) joinBtn.disabled = joined || currentPeople >= maxPeople;
            };

            // 드래그 방지
            dom.addEventListener("dragstart", e => { e.preventDefault(); e.stopPropagation(); });
            dom.addEventListener("drop", e => { e.preventDefault(); e.stopPropagation(); });

            // 삭제 버튼 (editMode 전용)
            if (editMode && deleteBtn) {
                $(deleteBtn).on("click", (e) => {
                    e.stopPropagation();
                    if (!confirm("이 블록을 삭제하시겠습니까?")) return;
                    const pos = getPos();
                    if (pos != null) editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
                });
            }

            // 페이지 로드시 참가 상태 확인
            if (postId && !editMode) {
                sendChatAction(postId, userId, "check", (res) => {
                    if (res?.chatResult?.alreadyJoined) {
                        joined = true;
                        joinBtn.textContent = "참여중";
                        joinBtn.disabled = true;
                    }
                });
            }

            // 참가 버튼 클릭
            $(joinBtn).on("click", (e) => {
                e.stopPropagation();
                if (!postId || joined || currentPeople >= maxPeople) return;

                sendChatAction(postId, userId, "join", (res) => {
                    if (!res?.chatResult?.success) {
                        alert(res?.chatResult?.message || "참가 실패");
                        return;
                    }

                    joined = true;
                    joinBtn.textContent = "참여중";
                    joinBtn.disabled = true;

                    // 서버에서 currentPeople 갱신
                    $.getJSON(`/chat/participants?postId=${postId}`, (data) => {
                        if (data?.currentPeople != null) updateCurrentPeople(data.currentPeople);
                    });
                });
            });

            return { dom };
        };
    },
});

// ===================== postId 활성화 후 적용 =====================
export function activateScheduleBlockAbly(editor, postId) {
    editor.state.doc.descendants((node, pos) => {
        if (node.type.name === "scheduleBlock") {
            const tr = editor.state.tr.setNodeMarkup(pos, undefined, { ...node.attrs, postId });
            editor.view.dispatch(tr);
        }
    });
}
