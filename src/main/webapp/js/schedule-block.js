import { Node, mergeAttributes } from "https://esm.sh/@tiptap/core";

export const ScheduleBlock = Node.create({
  name: "scheduleBlock",
  group: "block",
  atom: true, // 내부 편집 불가
  draggable: true,

  addAttributes() {
    return {
      title: { default: "" },
      date: { default: "" },
      time: { default: "" },
      location: { default: "" },
      people: { default: 0 },
    };
  },

  parseHTML() {
    return [{ tag: 'div[data-type="schedule-block"]' }];
  },

  
  // SSR 혹은 HTML 초기 렌더링때 renderHTML()만 씀
  renderHTML({ node, HTMLAttributes }) {
    const attrs = mergeAttributes(
      HTMLAttributes,
      { "data-type": "schedule-block" }
    );

    return [
      "div",
      attrs,
      [
        "div",
        { class: "schedule-header" },
        [
          "h3",
          { class: "schedule-title" },
          `📅 ${node.attrs.title}`,
        ],
        [
          "div",
          { class: "schedule-date" },
          `🕐 ${node.attrs.date}${node.attrs.time ? " " + node.attrs.time : ""}`,
        ],
      ],
      [
        "div",
        { class: "schedule-info" },
        node.attrs.location
          ? ["div", { class: "schedule-info-item" }, `📍 ${node.attrs.location}`]
          : null,
        ["div", { class: "schedule-info-item" }, `👥 ${node.attrs.people}명 모집`],
      ],
      [
        "button",
        { class: "schedule-join-btn" },
        "참가하기",
      ],
    ];
  },


  /*
  addNodeView() {
    return ({ node }) => {
      const dom = document.createElement("div");
      dom.className = "schedule-block";
      dom.dataset.type = "schedule-block";

      dom.innerHTML = `
        <div class="schedule-header">
          <h3 class="schedule-title">📅 ${node.attrs.title}</h3>
          <div class="schedule-date">
            🕐 ${node.attrs.date}${node.attrs.time ? " " + node.attrs.time : ""}
          </div>
        </div>
        <div class="schedule-info">
          ${node.attrs.location ? `<div class="schedule-info-item">📍 ${node.attrs.location}</div>` : ""}
          <div class="schedule-info-item">👥 ${node.attrs.people}명 모집</div>
        </div>
        <button class="schedule-join-btn">참가하기</button>
      `;

      const joinBtn = dom.querySelector(".schedule-join-btn");
      joinBtn.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        alert("참가 신청이 완료되었습니다!");
      });

      return { dom };
    };
	
  },
  */
});
