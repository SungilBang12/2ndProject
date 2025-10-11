<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<button data-cmd="schedule">🗓️ 일정</button>
<div id="scheduleModal" class="modal">
  <div class="modal-content">
    <span class="modal-close" id="scheduleModalClose">&times;</span>
    <h3>일정 추가</h3>
    <label>제목: <input type="text" id="scheduleTitle"/></label><br/>
    <label>일시: <input type="date" id="scheduleDate"/> 
                   <input type="time" id="scheduleTime"/></label><br/>
    <label>참가 인원: <input type="number" id="schedulePeople" min="1" value="1"/></label><br/>
    <div id="scheduleMapContainer" style="width:100%;height:300px;"></div>
    <button id="scheduleConfirmBtn">삽입</button>
  </div>
</div>

<script type="module">
import * as ScheduleModal from "./js/schedule-modal.js";
window.openScheduleModal = ScheduleModal.openModal;
</script>
