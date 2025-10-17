<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="chatModule" class="chat-container"
	data-post-id="${param.postId}"
	data-user-id="${sessionScope.user.userId}" 
	data-max-people="${param.maxPeople != null ? param.maxPeople : 200}">

	<!-- 리스트 영역 -->
	<div id="chatListPanel" class="chat-list-panel">
		<h3>참여 가능한 채팅방</h3>
		<ul id="chatList" class="chat-list"></ul>
	</div>

	<!-- 단일 채팅방 -->
	<div id="chatPanel" class="chat-panel">
		<div class="chat-header">
			<h3 class="post-title">채팅방</h3>
			<p class="participant-info">
				참가자: <span id="participantCount">0/${param.maxPeople != null ? param.maxPeople : 5}</span>
			</p>
			<button id="joinBtn" class="join-btn" disabled>참가하기</button>
			<button id="leaveBtn" class="leave-btn" style="display: none;">나가기</button>
		</div>
		<div id="chatMessages" class="chat-messages"></div>
		<div class="chat-input-area">
			<input type="text" id="chatInput" class="chat-input"
				placeholder="메시지 입력" />
			<button id="sendBtn" class="send-btn" disabled>전송</button>
		</div>
	</div>
</div>

<!-- 스타일 그대로 유지 -->
<style>
/* 기존 스타일 그대로 유지 */
</style>

<!-- Firebase App -->
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-database-compat.js"></script>
<!-- Ably -->
<script src="https://cdn.ably.com/lib/ably.min-1.2.46.js"></script>
<!-- Chat JS -->
<script type="module" src="/js/chat.js"></script>
