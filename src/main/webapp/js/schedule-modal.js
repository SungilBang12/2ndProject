export function openScheduleModal(editor, node = null, pos = null, mode = "create") {
  window.currentEditor = editor;

  const modal = document.createElement("div");
  modal.className = "modal";
  modal.innerHTML = `
    <div class="modal-content">
      <span class="modal-close">&times;</span>
      <h3>${mode === "edit" ? "모임 일정 수정" : "모임 일정 추가"}</h3>

      <label>모임 이름</label>
      <input type="text" id="scheduleTitle" value="${node?.attrs.title ?? ""}" placeholder="예: 노을 사진 촬영 모임">

      <label>날짜</label>
      <input type="date" id="scheduleDate" value="${extractDate(node?.attrs.date) ?? ""}">

      <label>시간</label>
      <input type="time" id="scheduleTime" value="${node?.attrs.time ?? ""}">

      <label>모집 인원</label>
      <input type="number" id="schedulePeople" min="1" value="${node?.attrs.people ?? 10}">

      <div class="modal-buttons">
        <button id="scheduleConfirm" class="btn-primary">${mode === "edit" ? "수정" : "추가"}</button>
        ${mode === "edit" ? '<button id="scheduleDelete" class="btn-danger">취소</button>' : ""}
      </div>
    </div>
  `;

  document.body.appendChild(modal);
  modal.style.display = "block";

  const closeModal = () => modal.remove();
  modal.querySelector(".modal-close").onclick = closeModal;

  modal.querySelector("#scheduleConfirm").onclick = () => {
    const title = modal.querySelector("#scheduleTitle").value.trim();
    const date = modal.querySelector("#scheduleDate").value.trim();
    const time = modal.querySelector("#scheduleTime").value.trim();
    const people = modal.querySelector("#schedulePeople").value.trim();

    if (!title || !date) {
      alert("모임 이름과 날짜는 필수입니다.");
      return;
    }

    const formattedDate = formatDate(date);

    // 🔹 한 개만 허용
    const hasSchedule = editor.state.doc.content.content.some(n => n.type.name === "scheduleBlock");
    if (mode === "create" && hasSchedule) {
      alert("이미 일정이 존재합니다. 하나만 추가할 수 있습니다.");
      closeModal();
      return;
    }

    if (mode === "edit" && node && pos != null) {
      editor.chain().focus().command(({ tr }) => {
        tr.setNodeMarkup(pos, null, { title, date: formattedDate, time, people });
        return true;
      }).run();
    } else {
      // 항상 최상단(0)에 삽입
      editor.chain().focus().insertContentAt(0, {
        type: "scheduleBlock",
        attrs: { title, date: formattedDate, time, people },
      }).run();
    }

    closeModal();
  };

  if (mode === "edit") {
    modal.querySelector("#scheduleDelete").onclick = () => {
      if (confirm("이 스케줄 블록을 삭제하시겠습니까?")) {
        editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
        closeModal();
      }
    };
  }
}

function formatDate(raw) {
  const d = new Date(raw);
  return `${d.getFullYear()}년 ${d.getMonth() + 1}월 ${d.getDate()}일`;
}

function extractDate(str) {
  if (!str) return "";
  const m = str.match(/(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일/);
  if (!m) return "";
  const [, y, mo, da] = m;
  return `${y}-${mo.padStart(2, "0")}-${da.padStart(2, "0")}`;
}
