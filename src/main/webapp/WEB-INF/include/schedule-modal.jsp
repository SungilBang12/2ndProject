<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
/* ========== Sunset Theme - Schedule Modal ========== */
:root {
  --bg-primary: #1a1a2e;
  --bg-secondary: #16213e;
  --bg-tertiary: #0f1624;
  --text-primary: #e8e8f0;
  --text-secondary: #a8a8b8;
  --text-tertiary: #7a7a8a;
  --accent-coral: #ff6b6b;
  --accent-orange: #ffa45c;
  --accent-pink: #ff6b9d;
  --gradient-sunset: linear-gradient(135deg, #ff6b6b 0%, #ffa45c 50%, #ff6b9d 100%);
  --shadow-soft: 0 8px 32px rgba(255, 107, 107, 0.15);
  --shadow-modal: 0 20px 60px rgba(0, 0, 0, 0.5);
  --border-color: rgba(255, 107, 107, 0.2);
}

/* ========== Schedule Button ========== */
button[data-cmd="schedule"] {
  padding: 8px 14px;
  background: rgba(255, 107, 107, 0.1);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 700;
  color: var(--text-secondary);
  transition: all 0.2s ease;
  min-width: 38px;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

button[data-cmd="schedule"]:hover {
  background: rgba(255, 107, 107, 0.2);
  border-color: var(--accent-coral);
  color: var(--accent-coral);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
}

/* ========== Modal Overlay ========== */
#scheduleModal.modal {
  display: none;
  position: fixed;
  z-index: 9999;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  overflow: auto;
  background-color: rgba(15, 22, 36, 0.85);
  backdrop-filter: blur(8px);
  animation: fadeIn 0.3s ease;
}

#scheduleModal.modal.show {
  display: flex;
  align-items: center;
  justify-content: center;
}

/* ========== Modal Content ========== */
#scheduleModal .modal-content {
  background: var(--bg-secondary);
  background-image: var(--gradient-dark);
  margin: auto;
  padding: 0;
  border: 2px solid var(--border-color);
  border-radius: 20px;
  width: 90%;
  max-width: 600px;
  box-shadow: var(--shadow-modal);
  animation: slideUp 0.3s ease;
  overflow: hidden;
}

/* ========== Modal Header ========== */
#scheduleModal .modal-content h3 {
  margin: 0;
  padding: 24px 28px;
  background: var(--gradient-sunset);
  color: white;
  font-size: 1.5em;
  font-weight: 700;
  border-bottom: 2px solid var(--border-color);
  display: flex;
  align-items: center;
  gap: 10px;
}

#scheduleModal .modal-content h3::before {
  content: "🗓️";
  font-size: 1.2em;
}

/* ========== Close Button ========== */
#scheduleModal .modal-close {
  position: absolute;
  right: 20px;
  top: 20px;
  color: white;
  font-size: 32px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  z-index: 1;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.2);
}

#scheduleModal .modal-close:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: rotate(90deg);
}

/* ========== Form Container ========== */
#scheduleModal .modal-content > div,
#scheduleModal .modal-content > label,
#scheduleModal .modal-content > br {
  padding: 0 28px;
}

#scheduleModal .modal-content label {
  display: block;
  margin: 20px 0 8px;
  font-weight: 700;
  font-size: 14px;
  color: var(--text-primary);
  padding: 0 28px;
}

#scheduleModal .modal-content label:first-of-type {
  margin-top: 28px;
}

/* ========== Input Fields ========== */
#scheduleModal .modal-content input[type="text"],
#scheduleModal .modal-content input[type="date"],
#scheduleModal .modal-content input[type="time"],
#scheduleModal .modal-content input[type="number"] {
  width: 100%;
  padding: 12px 16px;
  margin-top: 6px;
  border: 2px solid var(--border-color);
  border-radius: 10px;
  background: rgba(26, 26, 46, 0.6);
  color: var(--text-primary);
  font-size: 14px;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

#scheduleModal .modal-content input:focus {
  outline: none;
  border-color: var(--accent-coral);
  box-shadow: 0 0 0 4px rgba(255, 107, 107, 0.15);
  background: rgba(26, 26, 46, 0.8);
}

#scheduleModal .modal-content input::placeholder {
  color: var(--text-tertiary);
}

/* 날짜/시간 입력 그룹 */
#scheduleModal .modal-content label:has(input[type="date"]) {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

#scheduleModal .modal-content label:has(input[type="date"]) > div {
  display: flex;
  gap: 12px;
}

#scheduleModal .modal-content input[type="date"],
#scheduleModal .modal-content input[type="time"] {
  flex: 1;
  margin-top: 0;
}

/* ========== Map Container ========== */
#scheduleMapContainer {
  width: calc(100% - 56px) !important;
  height: 300px !important;
  margin: 20px 28px;
  border-radius: 12px;
  overflow: hidden;
  border: 2px solid var(--border-color);
  box-shadow: var(--shadow-soft);
}

/* ========== Confirm Button ========== */
#scheduleConfirmBtn {
  margin: 20px 28px 28px;
  padding: 14px 32px;
  width: calc(100% - 56px);
  background: var(--gradient-sunset);
  color: white;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-size: 15px;
  font-weight: 700;
  transition: all 0.3s ease;
  box-shadow: var(--shadow-soft);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

#scheduleConfirmBtn:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 32px rgba(255, 107, 107, 0.4);
}

#scheduleConfirmBtn:active {
  transform: translateY(-1px);
}

/* ========== Animations ========== */
@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(50px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ========== Responsive Design ========== */
@media (max-width: 768px) {
  #scheduleModal .modal-content {
    width: 95%;
    border-radius: 16px;
  }

  #scheduleModal .modal-content h3 {
    padding: 20px 24px;
    font-size: 1.3em;
  }

  #scheduleModal .modal-close {
    right: 16px;
    top: 16px;
    font-size: 28px;
    width: 32px;
    height: 32px;
  }

  #scheduleModal .modal-content > div,
  #scheduleModal .modal-content > label {
    padding: 0 24px;
  }

  #scheduleModal .modal-content label {
    font-size: 13px;
  }

  #scheduleModal .modal-content input {
    padding: 10px 14px;
    font-size: 13px;
  }

  #scheduleMapContainer {
    width: calc(100% - 48px) !important;
    height: 250px !important;
    margin: 16px 24px;
  }

  #scheduleConfirmBtn {
    margin: 16px 24px 24px;
    width: calc(100% - 48px);
    padding: 12px 24px;
    font-size: 14px;
  }

  #scheduleModal .modal-content label:has(input[type="date"]) > div {
    flex-direction: column;
  }
}

/* ========== Color Picker (if needed) ========== */
input[type="color"] {
  width: 60px;
  height: 40px;
  border: 2px solid var(--border-color);
  border-radius: 8px;
  cursor: pointer;
  background: transparent;
}

input[type="color"]::-webkit-color-swatch-wrapper {
  padding: 2px;
}

input[type="color"]::-webkit-color-swatch {
  border: none;
  border-radius: 6px;
}

/* ========== Number Input Styling ========== */
input[type="number"]::-webkit-inner-spin-button,
input[type="number"]::-webkit-outer-spin-button {
  opacity: 1;
  height: 40px;
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