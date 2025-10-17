import { Node } from "https://esm.sh/@tiptap/core";
import { Plugin } from "https://esm.sh/prosemirror-state";

/* ========================================================================
   전역 변수
   ======================================================================== */
const userId = document.getElementById("userId")?.value || `guest-${Math.random().toString(36).substr(2,6)}`;

/* ========================================================================
   공용 AJAX 요청 (채팅 참가/퇴장/체크)
   ======================================================================== */
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

/* ========================================================================
   ScheduleBlock Node 정의
   ======================================================================== */
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

            const { title = "미정 모임", maxPeople: initMaxPeople, currentPeople: initPeople, editMode, postId } = node.attrs;
            let currentPeople = initPeople;
            let maxPeople = initMaxPeople;
            let joined = false;

            // ✅ data-post-id 속성 추가 (chat.js에서 선택자로 찾을 수 있도록)
            if (postId) {
                dom.setAttribute("data-post-id", postId);
            }

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

            /* ========================================================================
               참가자 수/최대 인원 업데이트 함수
               ======================================================================== */
            const updateCurrentPeople = (count, max) => {
                currentPeople = count;
                currentPeopleSpan.textContent = currentPeople;
                
                if (max !== undefined) {
                    maxPeople = max;
                    maxPeopleSpan.textContent = maxPeople;
                }

                // 참가 버튼 상태 업데이트
                if (joinBtn) {
                    joinBtn.disabled = joined || currentPeople >= maxPeople;
                }
            };

            /* ========================================================================
               chat.js CustomEvent 구독 (실시간 동기화)
               ======================================================================== */
            const handleParticipantUpdate = (e) => {
                if (e.detail.postId === postId) {
                    console.log(`✅ [schedule-block] 참가자 업데이트: ${e.detail.currentPeople}/${e.detail.maxPeople}`);
                    updateCurrentPeople(e.detail.currentPeople, e.detail.maxPeople);
                }
            };

            document.addEventListener("chatParticipantUpdate", handleParticipantUpdate);

            /* ========================================================================
               드래그 방지
               ======================================================================== */
            dom.addEventListener("dragstart", e => { e.preventDefault(); e.stopPropagation(); });
            dom.addEventListener("drop", e => { e.preventDefault(); e.stopPropagation(); });

            /* ========================================================================
               삭제 버튼 (editMode 전용)
               ======================================================================== */
            if (editMode && deleteBtn) {
                $(deleteBtn).on("click", (e) => {
                    e.stopPropagation();
                    if (!confirm("이 블록을 삭제하시겠습니까?")) return;
                    
                    const pos = getPos();
                    if (pos != null) {
                        editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
                    }

                    // 이벤트 리스너 정리
                    document.removeEventListener("chatParticipantUpdate", handleParticipantUpdate);
                });
            }

            /* ========================================================================
               페이지 로드시 참가 상태 확인 + 실시간 참가자 수 가져오기
               ======================================================================== */
            if (postId && !editMode) {
                // 1. 참가 상태 확인
                sendChatAction(postId, userId, "check", (res) => {
                    if (res?.chatResult?.alreadyJoined) {
                        joined = true;
                        joinBtn.textContent = "참여중";
                        joinBtn.disabled = true;
                        joinBtn.classList.add("joined");
                    }
                });

                // 2. 실시간 참가자 수 가져오기
                $.getJSON(`/chat/participants?postId=${postId}`, (data) => {
                    if (data?.currentPeople != null) {
                        updateCurrentPeople(data.currentPeople, data.maxPeople);
                    }
                }).fail((err) => {
                    console.warn("⚠️ 참가자 수 로드 실패:", err);
                });
            }

            /* ========================================================================
               참가 버튼 클릭
               ======================================================================== */
            $(joinBtn).on("click", (e) => {
                e.stopPropagation();
                
                if (!postId || joined || currentPeople >= maxPeople) {
                    if (currentPeople >= maxPeople) {
                        alert("참가 인원이 가득 찼습니다.");
                    }
                    return;
                }

                // 참가 요청
                sendChatAction(postId, userId, "join", (res) => {
                    if (!res?.chatResult?.success) {
                        alert(res?.chatResult?.message || "참가 실패");
                        return;
                    }

                    // 참가 성공
                    joined = true;
                    joinBtn.textContent = "참여중";
                    joinBtn.disabled = true;
                    joinBtn.classList.add("joined");

                    // ✅ chat.js의 전역 함수 호출 (실시간 동기화)
                    if (typeof window.chatUpdateParticipantCount === "function") {
                        window.chatUpdateParticipantCount(postId);
                    } else {
                        // chat.js가 없으면 직접 조회
                        $.getJSON(`/chat/participants?postId=${postId}`, (data) => {
                            if (data?.currentPeople != null) {
                                updateCurrentPeople(data.currentPeople, data.maxPeople);
                            }
                        });
                    }

                    // 성공 메시지
                    alert(`${title} 모임에 참가했습니다!`);
                });
            });

            /* ========================================================================
               정리 함수 (destroy)
               ======================================================================== */
            return {
                dom,
                destroy: () => {
                    // 이벤트 리스너 제거
                    document.removeEventListener("chatParticipantUpdate", handleParticipantUpdate);
                }
            };
        };
    },
});

/* ========================================================================
   postId 활성화 후 Ably/채팅 연동 적용
   (게시글 생성 후 호출)
   ======================================================================== */
export function activateScheduleBlockAbly(editor, postId) {
    editor.state.doc.descendants((node, pos) => {
        if (node.type.name === "scheduleBlock") {
            const tr = editor.state.tr.setNodeMarkup(pos, undefined, { 
                ...node.attrs, 
                postId 
            });
            editor.view.dispatch(tr);
        }
    });
}