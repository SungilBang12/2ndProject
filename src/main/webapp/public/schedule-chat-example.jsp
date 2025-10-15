<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>모임/채팅 예제</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.ably.io/lib/ably.min-1.js"></script>
</head>
<body>

<!-- 게시글 정보 -->
<input type="hidden" id="postId" value="123">
<input type="hidden" id="userId" value="trump">

<h2 id="postTitle">모임 제목</h2>
<p>참가자: <span id="participantCount">0/5</span></p>
<button id="joinBtn">참가하기</button>

<!-- 채팅 모달 -->
<div id="chatModal" style="display:none; border:1px solid #ccc; padding:10px;">
  <h3>채팅방</h3>
  <div id="chatMessages" style="height:200px; overflow-y:auto; border:1px solid #eee; padding:5px;"></div>
  <input type="text" id="chatInput" placeholder="메시지 입력"/>
  <button id="sendBtn">전송</button>
  <button id="closeModalBtn">닫기</button>
</div>

<script type="module" src="./js/chat.js"></script>
</body>
</html>
