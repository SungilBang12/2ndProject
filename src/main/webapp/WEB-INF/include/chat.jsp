<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- CSS -->
<link rel="stylesheet" href="/css/chat-widget.css">

<!-- 채팅 모듈 데이터 -->
<div id="chatModule" style="display:none;"
    data-post-id="${param.postId}"
    data-user-id="${sessionScope.user.userId}" 
    data-max-people="${param.maxPeople != null ? param.maxPeople : 200}">
</div>

<!-- 채팅 토글 버튼 (우측 하단 고정) -->
<button id="chatToggleBtn" title="채팅">
    💬
</button>

<!-- 채팅 위젯 -->
<div id="chatWidget" style="display:none;">
    <!-- 헤더 -->
    <div class="chat-header">
        <div>
            <h3 id="chatTitle">채팅</h3>
            <p class="participant-info">
                참가자: <span id="participantCount">0/${param.maxPeople != null ? param.maxPeople : 5}</span>
            </p>
        </div>
        <div class="chat-header-buttons">
            <button id="backToListBtn" title="리스트로 돌아가기" style="display:none;">📋</button>
            <button id="minimizeBtn" title="최소화">➖</button>
        </div>
    </div>

    <!-- 채팅 리스트 패널 -->
    <div id="chatListPanel" style="display:none;">
        <h3>참여 중인 채팅방</h3>
        <ul id="chatList" class="chat-list"></ul>
    </div>

    <!-- 채팅 패널 -->
    <div id="chatPanel" style="display:none;">
        <!-- 메시지 영역 -->
        <div id="chatMessages"></div>

        <!-- 액션 버튼 (참가/나가기) -->
        <div class="chat-action-buttons">
            <button id="joinBtn" disabled>참가하기</button>
            <button id="leaveBtn" style="display:none;">나가기</button>
        </div>

        <!-- 입력 영역 -->
        <div class="chat-input-area">
            <input type="text" id="chatInput" class="chat-input" placeholder="메시지 입력..." />
            <button id="sendBtn" class="send-btn" disabled>전송</button>
        </div>
    </div>
</div>
<!-- Firebase App -->
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-database-compat.js"></script>

<!-- Ably -->
<script src="https://cdn.ably.com/lib/ably.min-1.2.46.js"></script>

<!-- jQuery (이미 로드되어 있다고 가정) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Chat JS -->
<script type="" src="${pageContext.request.contextPath}/js/chat.js"></script>