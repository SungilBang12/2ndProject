<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
/* ========== Sunset Schedule Modal - Clean Layout ========== */
:root {
  --bg-modal: #fff;
  --text-main: #222;
  --text-sub: #666;
  --border-color: rgba(0, 0, 0, 0.12);
  --accent: linear-gradient(135deg, #ff6b6b 0%, #ffa45c 50%, #ff6b9d 100%);
}

/* ───────── Overlay ───────── */
#scheduleModal.modal {
  display: none;
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: rgba(0, 0, 0, 0.45);
  backdrop-filter: blur(4px);
  animation: fadeIn 0.25s ease;
}
#scheduleModal.modal.show {
  display: flex;
  align-items: center;
  justify-content: center;
}

/* ───────── Modal Container ───────── */
#scheduleModal .modal-content {
  position: relative;
  width: 500px;
  max-width: 90%;
  border-radius: 10px;
  background: var(--bg-modal);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25);
  animation: slideUp 0.25s ease;
  overflow: hidden;
}

/* ───────── Header ───────── */
#scheduleModal .modal-content h3 {
  margin: 0;
  padding: 14px 20px;
  font-size: 1.1rem;
  font-weight: 700;
  background: var(--accent);
  color: #fff;
  display: flex;
  align-items: center;
  gap: 8px;
}
#scheduleModal .modal-content h3::before {
  content: "🗓️";
}

/* ───────── Close Button ───────── */
#scheduleModal .modal-close {
  position: absolute;
  right: 14px;
  top: 12px;
  font-size: 20px;
  color: #fff;
  background: rgba(0, 0, 0, 0.25);
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: 0.2s;
}
#scheduleModal .modal-close:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: rotate(90deg);
}

/* ───────── Body Form ───────── */
#scheduleModal .modal-content label {
  display: block;
  margin: 16px 20px 6px;
  font-weight: 600;
  color: var(--text-main);
  font-size: 0.9rem;
}
#scheduleModal .modal-content input[type="text"],
#scheduleModal .modal-content input[type="date"],
#scheduleModal .modal-content input[type="time"],
#scheduleModal .modal-content input[type="number"] {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  font-size: 0.9rem;
  color: var(--text-main);
  background: #fff;
  transition: 0.2s;
}
#scheduleModal .modal-content input:focus {
  outline: none;
  border-color: #ff6b6b;
  box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.15);
}

/* ───────── Inline Row (이름 + 날짜 + 시간 + 인원) ───────── */
#scheduleModal .modal-content label:has(#scheduleDate) > div {
  display: grid;
  grid-template-columns: 1fr auto 1fr auto 0.7fr;
  gap: 8px;
  align-items: center;
  margin: 0 20px;
}
#scheduleModal .modal-content label:has(#scheduleDate) > div::before {
  content: "날짜";
  color: var(--text-sub);
  font-size: 0.8rem;
  grid-column: 1;
  justify-self: start;
}
#scheduleModal .modal-content label:has(#scheduleDate) > div::after {
  content: "시간";
  color: var(--text-sub);
  font-size: 0.8rem;
  grid-column: 3;
  justify-self: start;
}
#scheduleModal .modal-content input[type="date"],
#scheduleModal .modal-content input[type="time"] {
  margin: 0;
}

/* ───────── Date ~ Time Separator ───────── */
#scheduleModal .modal-content label:has(input[type="date"]) > div {
  position: relative;
}
#scheduleModal .modal-content label:has(input[type="date"]) > div::between {
  content: "~";
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  color: var(--text-sub);
  font-weight: 600;
}

/* ───────── Map Container ───────── */
#scheduleMapContainer {
  width: calc(100% - 40px) !important;
  height: 220px !important;
  margin: 18px 20px;
  border-radius: 8px;
  border: 1px solid var(--border-color);
  background: #f9f9f9;
}

/* ───────── Button ───────── */
#scheduleConfirmBtn {
  display: block;
  margin: 20px auto 24px;
  width: 90%;
  max-width: 300px;
  padding: 12px 0;
  border: none;
  border-radius: 8px;
  background: var(--accent);
  color: #fff;
  font-weight: 700;
  font-size: 0.95rem;
  cursor: pointer;
  transition: 0.25s;
  text-align: center;
}
#scheduleConfirmBtn:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 18px rgba(255, 107, 107, 0.3);
}

/* ───────── Animation ───────── */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
@keyframes slideUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

/* ───────── Responsive ───────── */
@media (max-width: 600px) {
  #scheduleModal .modal-content {
    width: 90%;
  }
  #scheduleModal .modal-content label:has(#scheduleDate) > div {
    grid-template-columns: 1fr;
  }
}


</style>


<button data-cmd="schedule">🗓️ 일정</button>

<div id="scheduleModal" class="modal">
  <div class="modal-content">
    <span class="modal-close" id="scheduleModalClose">&times;</span>
    <h3>일정 추가</h3>
    
    <label>
      제목
      <input type="text" id="scheduleTitle" placeholder="일정 제목을 입력하세요"/>
    </label>
    
    <label>
      일시
      <div>
        <input type="date" id="scheduleDate"/>
        <input type="time" id="scheduleTime"/>
      </div>
    </label>
    
    <label>
      참가 인원
      <input type="number" id="schedulePeople" min="1" value="1" placeholder="참가 인원"/>
    </label>
    
    <div id="scheduleMapContainer"></div>
    
    <button id="scheduleConfirmBtn">일정 삽입</button>
  </div>
</div>

<script src="https://cdn.ably.io/lib/ably.min-1.js"></script>
<script type="module">
  import * as ScheduleModal from "./js/schedule-modal.js";
  window.openScheduleModal = ScheduleModal.openModal;
</script>