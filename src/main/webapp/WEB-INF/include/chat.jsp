<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
// Controller에서 Model을 통해 전달된 Ably 설정 JSON 문자열을 가져옵니다.
// JSP 스크립틀릿을 사용하되, JSON 문자열 자체를 변수에 담습니다.
String ablyConfigJson = (String) request.getAttribute("ablyConfigJson");
if (ablyConfigJson == null || ablyConfigJson.isEmpty()) {
ablyConfigJson = "{}";
}
// 사용자 ID는 세션 등에서 가져오거나, JSP EL을 통해 변수로 미리 선언되어 있어야 합니다.
// 여기서는 JSTL/EL을 사용하는 것으로 가정합니다.
%>

<!--
채팅 모듈: slot-extra에 배치될 구성 요소
postId는 예시로 '1'을 사용했습니다.
userId는 JSTL/EL을 통해 동적으로 삽입되어야 합니다. (예: ${sessionScope.userId})
🚨 보안 고려: JSON 데이터는 data-* 속성을 통해 안전하게 전달합니다.
-->

<div id="chatModule" class="chat-container"
data-post-id="1"
data-user-id="${sessionScope.currentUserId}"
data-ably-config='<%= ablyConfigJson.replace("'", "&#39;") %>'
data-max-people="5"
>
<!-- 참가 정보 및 버튼 -->
<div class="chat-header">
<h3 class="post-title">모임 제목</h3>
<p class="participant-info">
참가자: <span id="participantCount">0/5</span>
</p>
<button id="joinBtn" class="join-btn">참가하기</button>
</div>

<!-- 채팅 모달 (여기서는 고정된 채팅창으로 사용) -->
<div id="chatPanel" class="chat-panel">
    <div id="chatMessages" class="chat-messages">
        <!-- 메시지 수신 영역 -->
        <div class="system-message">챗방에 참가해 보세요.</div>
    </div>
    <div class="chat-input-area">
        <input type="text" id="chatInput" class="chat-input" placeholder="메시지 입력"/>
        <button id="sendBtn" class="send-btn" disabled>전송</button>
    </div>
</div>


</div>

<!-- 필요한 CSS 스타일 -->

<style>
.chat-container {
background-color: #ffffff;
border-radius: 12px;
box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
padding: 16px;
display: flex;
flex-direction: column;
height: 100%; /* slot-extra 높이에 맞춤 /
min-height: 400px;
}
.chat-header {
border-bottom: 1px solid #e0e0e0;
padding-bottom: 10px;
margin-bottom: 10px;
}
.post-title {
margin: 0;
font-size: 1.1rem;
color: #333;
}
.participant-info {
font-size: 0.9rem;
color: #777;
margin-top: 5px;
}
.join-btn {
width: 100%;
padding: 8px;
margin-top: 10px;
background-color: #4CAF50;
color: white;
border: none;
border-radius: 6px;
cursor: pointer;
transition: background-color 0.3s;
}
.join-btn:hover:not(:disabled) {
background-color: #45a049;
}
.join-btn:disabled {
background-color: #9e9e9e;
cursor: not-allowed;
}
.chat-panel {
display: flex;
flex-direction: column;
flex-grow: 1;
overflow: hidden;
margin-top: 10px;
}
.chat-messages {
flex-grow: 1;
height: 100px; / 유연한 높이를 위해 최소값 설정 */
overflow-y: auto;
padding: 8px;
border: 1px solid #f0f0f0;
border-radius: 6px;
margin-bottom: 8px;
background-color: #f9f9f9;
}
.chat-input-area {
display: flex;
gap: 8px;
}
.chat-input {
flex-grow: 1;
padding: 8px;
border: 1px solid #ccc;
border-radius: 6px;
}
.send-btn {
padding: 8px 12px;
background-color: #2196F3;
color: white;
border: none;
border-radius: 6px;
cursor: pointer;
}
</style>

<!-- Ably 라이브러리 및 chat.js 로드 -->

<script src="https://www.google.com/search?q=https://cdn.ably.com/lib/ably.min-1.2.46.js"></script>

<script type="module" src="/js/chat.js"></script>