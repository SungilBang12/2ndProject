import { Node, mergeAttributes } from "https://esm.sh/@tiptap/core";
import { Plugin } from "https://esm.sh/prosemirror-state";

/* =====================================================
 🟢 전역 Ably 대기
===================================================== */
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
    };
  },

  addKeyboardShortcuts() {
    return {
      Backspace: ({ editor }) => {
        const { $from } = editor.state.selection;
        return $from.nodeAfter?.type.name === "scheduleBlock";
      },
      Delete: ({ editor }) => {
        const { $from } = editor.state.selection;
        return $from.nodeBefore?.type.name === "scheduleBlock";
      },
    };
  },

  addProseMirrorPlugins() {
    return [
      new Plugin({
        props: {
			handleKeyDown(view, event) {
			  const { $from } = view.state.selection;

			  // 블록 바로 앞일 때만 차단
			  const nodeAfter = $from.nodeAfter;
			  const isBeforeBlock = nodeAfter?.type.name === "scheduleBlock";

			  if (isBeforeBlock) {
			    if (
			      event.key.startsWith("Arrow") ||
			      event.key === "Tab" ||
			      event.ctrlKey ||
			      event.metaKey
			    )
			      return false;
			    return true; // 나머지 키 차단
			  }

			  return false; // 일반 입력 정상
			},

			handleTextInput(view, from, to, text) {
			  const { $from } = view.state.selection;
			  const nodeAfter = $from.nodeAfter;
			  const isBeforeBlock = nodeAfter?.type.name === "scheduleBlock";

			  return isBeforeBlock; // 블록 바로 앞에서만 입력 차단
			},
        },
      }),
    ];
  },

  parseHTML() {
    return [{ tag: "div.schedule-block" }];
  },

  renderHTML({ HTMLAttributes }) {
    return ["div", mergeAttributes(HTMLAttributes, { class: "schedule-block" }), 0];
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

      // DOM 구성
      const titleDiv = document.createElement("div");
      titleDiv.className = "schedule-title";
      titleDiv.textContent = `📅 ${title}`;

      const dateDiv = document.createElement("div");
      dateDiv.className = "schedule-date";
      dateDiv.textContent = `🕐 ${node.attrs.meetDate} ${node.attrs.meetTime}`;

      const infoDiv = document.createElement("div");
      infoDiv.className = "schedule-info-item";
      const peopleSpan = document.createElement("span");
      peopleSpan.className = "currentPeople";
      peopleSpan.textContent = currentPeople;
      infoDiv.append(`👥 `, peopleSpan, `/${maxPeople}명 모집`);

      const btnContainer = document.createElement("div");
      btnContainer.className = "schedule-btns";
      btnContainer.style.display = "flex";
      btnContainer.style.justifyContent = editMode ? "flex-end" : "space-between";
      btnContainer.style.marginTop = "5px";

      const joinBtn = document.createElement("button");
      joinBtn.className = "schedule-join-btn";
      joinBtn.textContent = "참가하기";
      if (!editMode) btnContainer.appendChild(joinBtn);

      const cancelBtn = document.createElement("button");
      cancelBtn.className = "schedule-cancel-btn";
      cancelBtn.textContent = "취소";
      btnContainer.appendChild(cancelBtn);

      dom.append(titleDiv, dateDiv, infoDiv, btnContainer);

      let joined = false;
      const userId = window.userId || "guest-" + Math.random().toString(36).substring(2, 9);

      // 드래그/드롭/키보드 이벤트 차단
      dom.addEventListener("dragstart", e => { e.preventDefault(); e.stopPropagation(); });
      dom.addEventListener("drop", e => { e.preventDefault(); e.stopPropagation(); });
      dom.addEventListener("keydown", e => e.stopPropagation());

      setTimeout(async () => {
        let ably;
        try {
          ably = await waitForAbly();
        } catch (err) {
          console.warn("❌ Ably 초기화 실패:", err);
          return;
        }

        const channel = ably.channels.get(blockId);

        const updatePresence = () => {
          channel.presence.get((err, members) => {
            if (err) return console.error(err);
            currentPeople = members.length;
            peopleSpan.textContent = currentPeople;
            if (!editMode) joinBtn.disabled = currentPeople >= maxPeople;
          });
        };

        updatePresence();
        channel.presence.subscribe(["enter", "leave"], updatePresence);

        if (editMode && !joined) {
          channel.presence.enter({ user: userId });
          joined = true;
          updatePresence();
        }

        // 참가 버튼
        joinBtn.addEventListener("click", e => {
          e.stopPropagation();
          if (joined || currentPeople >= maxPeople) return;
          channel.presence.enter({ user: userId });
          joined = true;
          updatePresence();
          alert(`'${title}' 모임에 참가했습니다!`);
        });

        // 취소 버튼
        cancelBtn.addEventListener("click", e => {
          e.stopPropagation();
          const reallyDelete = currentPeople > 1
            ? confirm("참가자가 1명입니다. 정말 삭제하시겠습니까?") && confirm("정말로 삭제하시겠습니까?")
            : confirm("블록을 삭제하시겠습니까?");
          if (!reallyDelete) return;
          const pos = getPos();
          if (pos != null) editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
          if (joined) {
            channel.presence.leave();
            joined = false;
            updatePresence();
          }
        });

      }, 0);

      return { dom, contentDOM: null };
    };
  },
});
