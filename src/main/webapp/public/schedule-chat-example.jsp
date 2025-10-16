<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>


<!--
    🚨 Controller에서 Model을 통해 전달된 JSON 문자열 변수만 사용합니다.
    (하드 코딩된 API Key를 제거)
    TEST에 설정파일 변환 존재 -->
<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>모임/채팅 예제</title>
<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
<script src="https://cdn.ably.io/lib/ably.min-1.js"></script>
</head>
<body>
<jsp:include page="/WEB-INF/include/header.jsp" />

<input type="hidden" id="postId" value="1">

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

<script>
const userId = $("#userId").val();
//Ably 설정
<%
String ablyConfigJson = (String) request.getAttribute("ablyConfigJson");
if (ablyConfigJson == null || ablyConfigJson.isEmpty()) {
	ablyConfigJson = "{}";
}
%>
//전역 변수
let ably = null;
try {
	var ablyConfig = null;
	ablyConfig = <%= ablyConfigJson %>;
	// 🚨 디버깅 로그
	console.log('[DEBUG] ablyConfig 객체:', ablyConfig);
	console.log('[DEBUG] pubKey:', ablyConfig.pubKey);

	// 필수 필드 검증
	if (!ablyConfig || !ablyConfig.pubKey) {
		throw new Error('ably 설정에 필수 필드가 누락되었습니다.');
	}

	console.log("✅ ably Config loaded dynamically.");

	// ably 초기화
		ably = new Ably.Realtime(
		{
			key: ablyConfig.pubKey,
			clientId: userId // 여기가 핵심!
		}
	);
	console.log("✅ Ably App initialized successfully.");

} catch (e) {
	console.error("❌ Ably 초기화 실패:", e.message);
	console.error("❌ 전체 에러:", e);
	
	// 채팅 참여 버튼 비활성화
	// document.getElementById('sendEmailBtn').disabled = true;
	// document.getElementById('email').disabled = true;
}
</script>
<script type="module" src="/js/chat.js"></script>
</body>
</html>
