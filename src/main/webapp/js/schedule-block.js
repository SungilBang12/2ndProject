import { Node, mergeAttributes } from "https://esm.sh/@tiptap/core";
import { Plugin } from "https://esm.sh/prosemirror-state";

function waitForAbly() {
  return new Promise((resolve, reject) => {
    const check = () => {
      if (window.ably && window.ably.connection?.state === "connected") resolve(window.ably);
      else if (window.ably && window.ably.connection?.state === "failed") reject("Ably 연결 실패");
      else setTimeout(check, 150);
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
      postId: { default: null },
    };
  },
  addNodeView() {
    return ({ node, getPos, editor }) => {
      const dom = document.createElement("div");
      dom.className = "schedule-block";
      dom.setAttribute("contenteditable", "false");

      const title = node.attrs.title || "미정 모임";
      const maxPeople = node.attrs.maxPeople;
      let currentPeople = node.attrs.currentPeople;
      const editMode = node.attrs.editMode === true;
      const postId = node.attrs.postId;
      const blockId = generateBlockId(title);

      dom.innerHTML = `
        <div class="schedule-title">📅 ${title}</div>
        <div class="schedule-date">🕐 ${node.attrs.meetDate} ${node.attrs.meetTime}</div>
        <div class="schedule-info-item">👥 <span class="currentPeople">${currentPeople}</span>/${maxPeople}명 모집</div>
        <div class="schedule-btns" style="display:flex; justify-content:${editMode ? "flex-end" : "space-between"}; margin-top:5px;">
          ${!editMode ? '<button class="schedule-join-btn">참가하기</button>' : ""}
          ${editMode ? '<button class="schedule-cancel-btn btn-cancel">취소</button>' : ""}
        </div>
      `;

      const joinBtn = dom.querySelector(".schedule-join-btn");
      const cancelBtn = dom.querySelector(".schedule-cancel-btn");
      const currentPeopleSpan = dom.querySelector(".currentPeople");
      let joined = false;

      const userId = window.userId || "guest-" + Math.random().toString(36).substring(2, 9);

      // 채팅 모달 maxPeople 동기화
      const chatModule = document.getElementById("chatModule");
      if (chatModule) chatModule.dataset.maxPeople = maxPeople;

      setTimeout(async () => {
        let ably;
        try { ably = await waitForAbly(); } catch(e){ console.warn(e); return; }

        const channelName = window.chatChannelName || `channel-${postId}`;
        const channel = ably.channels.get(channelName);
        window.chatChannelName = channelName;

        const updatePresenceCount = async () => {
          try {
            // Ably presence
            channel.presence.get((err, members) => {
              if (err) console.error(err);
              currentPeople = members?.length || 0;
              currentPeopleSpan.textContent = currentPeople;
              document.dispatchEvent(new CustomEvent("schedulePresenceUpdate", { detail: { postId, currentPeople } }));
              if (!editMode) {
                if (currentPeople >= maxPeople) joinBtn?.setAttribute("disabled", true);
                else joinBtn?.removeAttribute("disabled");
              }
            });
          } catch(err){ console.error(err); }
        };

        // 초기 갱신 + 실시간
        updatePresenceCount();
        channel.presence.subscribe(["enter","leave"], updatePresenceCount);

        if (editMode && !joined) {
          channel.presence.enter({ user: userId });
          joined = true;
          updatePresenceCount();
        }

        joinBtn?.addEventListener("click", async (e) => {
          e.stopPropagation();
          if (joined || currentPeople >= maxPeople) return;
          channel.presence.enter({ user: userId });
          joined = true;
          updatePresenceCount();
          alert(`${title} 모임에 참가했습니다!`);
        });

        cancelBtn?.addEventListener("click", async (e) => {
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
