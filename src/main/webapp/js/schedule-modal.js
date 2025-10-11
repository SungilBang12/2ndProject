import { ScheduleBlock } from "./schedule-block.js";

export function openModal(editor) {
  const modal = document.createElement("div");
  modal.className = "modal";
  modal.innerHTML = `
    <div class="modal-content">
      <span class="modal-close">&times;</span>
      <h3>모임 일정 추가</h3>

      <label>모임 이름</label>
      <input type="text" id="scheduleTitle" placeholder="예: 노을 사진 촬영 모임">

      <label>날짜</label>
      <input type="date" id="scheduleDate">

      <label>시간</label>
      <input type="time" id="scheduleTime">

      <label>장소</label>
      <input type="text" id="scheduleLocation" placeholder="예: 한강 공원">

      <label>모집 인원</label>
      <input type="number" id="schedulePeople" min="1" value="10">

      <button id="scheduleConfirm" class="btn-primary">추가</button>
    </div>
  `;
  document.body.appendChild(modal);
  modal.style.display = "block";

  modal.querySelector(".modal-close").onclick = () => modal.remove();

  modal.querySelector("#scheduleConfirm").onclick = () => {
    const title = modal.querySelector("#scheduleTitle").value.trim();
    const date = modal.querySelector("#scheduleDate").value.trim();
    const time = modal.querySelector("#scheduleTime").value.trim();
    const location = modal.querySelector("#scheduleLocation").value.trim();
    const people = modal.querySelector("#schedulePeople").value.trim();

    if (!title || !date) {
      alert("모임 이름과 날짜는 필수입니다.");
      return;
    }

    // 날짜 포맷팅
    const dateObj = new Date(date);
    const formattedDate = `${dateObj.getFullYear()}년 ${dateObj.getMonth() + 1}월 ${dateObj.getDate()}일`;

    // 커스텀 노드 삽입
    editor.chain().focus().insertContent({
      type: "scheduleBlock",
      attrs: {
        title,
        date: formattedDate,
        time,
        location,
        people,
      },
    }).run();

    modal.remove();
  };
}
