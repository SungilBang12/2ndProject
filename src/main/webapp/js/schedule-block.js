import { Node, mergeAttributes } from "https://esm.sh/@tiptap/core";
import { Plugin } from "https://esm.sh/prosemirror-state";

/* ===================================================== 🟢 전역 Ably 대기 ===================================================== */
function waitForAbly() {
  return new Promise((resolve, reject) => {
    const check = () => {
      if (window.ably && window.ably.connection?.state === "connected") {
        resolve(window.ably);
      } else if (window.ably && window.ably.connection?.state === "failed") {
        reject("Ably 연결 실패");
      } else {
        setTimeout(check, 150);
      }
    };
    check();
  });
}

const generateBlockId = (title) => `schedule-${encodeURIComponent(title)}`;

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
    };
  },
  parseHTML() {
    return [{ tag: "div.schedule-block" }];
  },
  renderHTML({ HTMLAttributes }) {
    return ["div", mergeAttributes(HTMLAttributes, { class: "schedule-block" })];
  },
  addProseMirrorPlugins() {
    return [
      new Plugin({
        props: {
          handleKeyDown(view, event) {
            const { $from } = view.state.selection;
            const nodeAfter = $from.nodeAfter;
            const isBeforeBlock = nodeAfter?.type.name === "scheduleBlock" || $from.parentOffset === 0;
            if (isBeforeBlock) {
              if (event.key.startsWith("Arrow") || event.key === "Tab" || event.ctrlKey || event.metaKey) return false;
              return true;
            }
            return false;
          },
        },
      }),
    ];
  },
  addNodeView() {
    return ({ node, getPos, editor }) => {
      const dom = document.createElement("div");
      dom.className = "schedule-block";
      dom.dataset.type = "schedule-block";
      dom.setAttribute("contenteditable", "false");

      const title = node.attrs.title || "미정 모임";
      const maxPeople = node.attrs.maxPeople;
      let currentPeople = node.attrs.currentPeople;
      const editMode = node.attrs.editMode === true;
      const blockId = generateBlockId(title);

      dom.innerHTML = `
        <div class="schedule-title">📅 ${title}</div>
        <div class="schedule-date">🕐 ${node.attrs.meetDate} ${node.attrs.meetTime}</div>
        <div class="schedule-info-item">
          👥 <span class="currentPeople">${currentPeople}</span>/${maxPeople}명 모집
        </div>
        <div class="schedule-btns" style="display:flex; justify-content: ${
          editMode ? "flex-end" : "space-between"
        }; margin-top:5px;">
          ${!editMode ? '<button class="schedule-join-btn">참가하기</button>' : ""}
          ${editMode ? '<button class="schedule-cancel-btn btn-cancel">취소</button>' : ""}
        </div>
      `;
	  // 채팅 모달 dataset에도 반영
	  document.getElementById("chatModule").dataset.maxPeople = maxPeople;

      const joinBtn = dom.querySelector(".schedule-join-btn");
      const cancelBtn = dom.querySelector(".schedule-cancel-btn");
      const currentPeopleSpan = dom.querySelector(".currentPeople");
      let joined = false;

      const userId = window.userId || "guest-" + Math.random().toString(36).substring(2, 9);

      setTimeout(async () => {
        let ably;
        try {
          ably = await waitForAbly();
        } catch (err) {
          console.warn("❌ Ably 초기화 실패:", err);
          return;
        }

        // ✅ 통합 채널(postId 기반)
        const channelName = window.chatChannelName || `channel-${window.postId}`;
        const channel = ably.channels.get(channelName);
        window.chatChannelName = channelName; // 전역 저장

        const updatePresenceCount = () => {
          channel.presence.get((err, members) => {
            if (err) return console.error("Presence 오류:", err);
            currentPeople = members.length;
            currentPeopleSpan.textContent = currentPeople;

            // 채팅창에도 반영
            document.dispatchEvent(
              new CustomEvent("schedulePresenceUpdate", { detail: { postId: window.postId, currentPeople } })
            );

            if (!editMode) {
              if (currentPeople >= maxPeople) joinBtn?.setAttribute("disabled", true);
              else joinBtn?.removeAttribute("disabled");
            }
          });
        };

        // 초기 인원 반영
        updatePresenceCount();

        // 실시간 인원 변화
        channel.presence.subscribe(["enter", "leave"], updatePresenceCount);

        // 편집 모드 자동 참가
        if (editMode && !joined) {
          channel.presence.enter({ user: userId });
          joined = true;
          updatePresenceCount();
        }

        // 참가 버튼
        joinBtn?.addEventListener("click", (e) => {
          e.stopPropagation();
          if (joined || currentPeople >= maxPeople) return;
          channel.presence.enter({ user: userId });
          joined = true;
          updatePresenceCount();
          alert(`${title} 모임에 참가했습니다!`);
        });

        // 취소 버튼
        cancelBtn?.addEventListener("click", (e) => {
          e.stopPropagation();
          const reallyDelete = confirm("이 블록을 삭제하시겠습니까?");
          if (!reallyDelete) return;
          const pos = getPos();
          if (pos != null) editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
          if (joined) {
            channel.presence.leave();
            joined = false;
            updatePresenceCount();
          }
        });
      }, 0);

      return { dom };
    };
  },
});
