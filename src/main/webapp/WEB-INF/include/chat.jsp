<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div id="chatModule"
     class="chat-container"
     data-post-id="${param.postId}"
     data-user-id="${sessionScope.user.userId}"
     data-max-people="5">

    <!-- 리스트 영역 -->
    <div id="chatListPanel" class="chat-list-panel">
        <h3>참여 가능한 채팅방</h3>
        <ul id="chatList" class="chat-list"></ul>
    </div>

    <!-- 단일 채팅방 -->
    <div id="chatPanel" class="chat-panel">
        <div class="chat-header">
            <h3 class="post-title">채팅방</h3>
            <p class="participant-info">참가자: <span id="participantCount">0/0</span></p>
            <button id="joinBtn" class="join-btn">참가하기</button>
        </div>
        <div id="chatMessages" class="chat-messages"></div>
        <div class="chat-input-area">
            <input type="text" id="chatInput" class="chat-input" placeholder="메시지 입력" />
            <button id="sendBtn" class="send-btn" disabled>전송</button>
        </div>
    </div>
</div>

<style>
.chat-container {
    background-color: #fff;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    padding: 16px;
    display: flex;
    flex-direction: column;
    min-height: 400px;
}
.chat-header { border-bottom: 1px solid #e0e0e0; padding-bottom: 10px; margin-bottom: 10px; }
.post-title { margin: 0; font-size: 1.1rem; color: #333; }
.participant-info { font-size: 0.9rem; color: #777; margin-top: 5px; }
.join-btn {
    width: 100%; padding: 8px; margin-top: 10px;
    background-color: #4CAF50; color: white;
    border: none; border-radius: 6px; cursor: pointer;
}
.join-btn:disabled { background-color: #9e9e9e; cursor: not-allowed; }
.chat-panel { flex-grow: 1; overflow: hidden; margin-top: 10px; display: flex; flex-direction: column; }
.chat-messages {
    flex-grow: 1; overflow-y: auto; padding: 8px;
    border: 1px solid #f0f0f0; border-radius: 6px;
    background-color: #f9f9f9; margin-bottom: 8px;
}
.chat-input-area { display: flex; gap: 8px; }
.chat-input { flex-grow: 1; padding: 8px; border: 1px solid #ccc; border-radius: 6px; }
.send-btn { padding: 8px 12px; background-color: #2196F3; color: white; border: none; border-radius: 6px; cursor: pointer; }

.chat-list-panel { padding: 10px; background-color: #fafafa; border-radius: 8px; }
.chat-list { list-style: none; padding: 0; }
.chat-list li {
    padding: 8px; border-bottom: 1px solid #ddd; cursor: pointer;
}
.chat-list li:hover { background-color: #f0f0f0; }
</style>

<!-- Ably 라이브러리 -->
<script src="https://cdn.ably.com/lib/ably.min-1.2.46.js"></script>
<script type="module" src="/js/chat.js"></script>

