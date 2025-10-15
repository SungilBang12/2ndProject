<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:if test="${sessionScope.user == null}">
	<c:redirect url="/users/login?error=로그인이 필요합니다" />
</c:if>

<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>내가 단 댓글 보기</title>
<link rel="stylesheet" href="<c:url value='/css/style.css'/>" />
</head>
<body>

	<jsp:include page="/WEB-INF/include/header.jsp" />
	<main class="main grid-14x5">
		<div class="slot-nav">
			<jsp:include page="/WEB-INF/include/nav.jsp" />
		</div>

		<div class="slot-board">
			<div class="form-card">
				<h2 class="card-title">
					<c:out value="${sessionScope.user.userName}" />
					님이 작성한 댓글
				</h2>
				<!-- TODO: 여기에 사용자 댓글 목록을 불러와 표시하는 로직을 구현합니다. -->
				<p class="guide-text">댓글 목록을 불러올 준비가 되었습니다.</p>
				<ul class="comment-list">
					<li>[예시] 첫 번째 댓글 내용입니다.</li>
					<li>[예시] 두 번째 댓글 내용입니다.</li>
				</ul>
			</div>
		</div>

		<div class="slot-extra"></div>
	</main>
	<footer></footer>
</body>
</html>
