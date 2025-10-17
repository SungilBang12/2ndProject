export function openScheduleModal(editor, node = null, pos = null, mode = "create") {
	window.currentEditor = editor;

	const modal = document.createElement("div");
	modal.className = "modal";
	modal.innerHTML = `
    <div class="modal-content">
      <span class="modal-close">&times;</span>
      <h3>${mode === "edit" ? "모임 일정 수정" : "모임 일정 추가"}</h3>

      <label>모임 이름</label>
      <input type="text" id="scheduleTitle" 
             value="${node?.attrs.title ?? ""}" 
             placeholder="예: 노을 사진 촬영 모임"
             maxlength="100">

      <label>날짜</label>
      <input type="date" id="scheduleDate" 
             value="${extractDate(node?.attrs.meetDate) ?? ""}"
             min="${formatDateInput(new Date())}"
             max="${formatDateInput(new Date(new Date().setFullYear(new Date().getFullYear() + 3)))}">

      <label>시간</label>
      <input type="time" id="scheduleTime" value="${node?.attrs.meetTime ?? ""}">

	  <label>현재 참가자</label>
	  <input type="number" id="currentPeople" value="${node?.attrs.currentPeople ?? 0}" readonly disabled>

      <label>최대 참가자</label>
      <input type="number" id="maxPeople" min="2" value="${node?.attrs.maxPeople ?? 2}">

      <div class="modal-buttons">
        <button id="scheduleConfirm" class="btn-primary">
          ${mode === "edit" ? "수정" : "추가"}
        </button>
        ${mode === "edit" ? '<button id="scheduleDelete" class="btn-danger">삭제</button>' : ""}
      </div>
    </div>
  `;

	document.body.appendChild(modal);
	modal.style.display = "block";

	const closeModal = () => modal.remove();
	modal.querySelector(".modal-close").onclick = closeModal;

	modal.querySelector("#scheduleConfirm").onclick = () => {
		let title = modal.querySelector("#scheduleTitle").value.trim();
		const meetDate = modal.querySelector("#scheduleDate").value;
		const meetTime = modal.querySelector("#scheduleTime").value;
		let currentPeople = parseInt(modal.querySelector("#currentPeople").value, 10);
		let maxPeople = parseInt(modal.querySelector("#maxPeople").value, 10);

		// 제목 공백 체크
		if (!title) {
			alert("모임 이름은 필수입니다.");
			return;
		}

		// SQL/특수문자 간단 필터
		title = title.replace(/['";-]/g, "");

		// 최소값 강제
		currentPeople = Math.max(0, currentPeople);
		maxPeople = Math.max(2, maxPeople);

		if (mode === "create") {
			const hasSchedule = editor.state.doc.content.content.some(n => n.type.name === "scheduleBlock");
			if (hasSchedule) {
				alert("이미 일정이 존재합니다. 하나만 추가할 수 있습니다.");
				closeModal();
				return;
			}
		}
		let postId = window.getPostIdFromUrl;
		const attrs = { title, meetDate, meetTime, currentPeople, maxPeople , postId};

		if (mode === "edit" && node && pos != null) {
			editor.chain().focus().command(({ tr }) => {
				tr.setNodeMarkup(pos, null, attrs);
				return true;
			}).run();
		} else {
			editor.chain().focus().insertContentAt(0, {
				type: "scheduleBlock",
				attrs
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
function formatDateInput(date) {
	const yyyy = date.getFullYear();
	const mm = String(date.getMonth() + 1).padStart(2, "0");
	const dd = String(date.getDate()).padStart(2, "0");
	return `${yyyy}-${mm}-${dd}`;
}

function extractDate(str) {
	if (!str) return "";
	const m = str.match(/(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일/);
	if (!m) return "";
	const [, y, mo, da] = m;
	return `${y}-${mo.padStart(2, "0")}-${da.padStart(2, "0")}`;
}
