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
<title>내 정보 수정</title>
<link rel="stylesheet" href="<c:url value='/css/form-style.css'/>" />
</head>
<body>

	<jsp:include page="/WEB-INF/include/header.jsp" />
	<main class="main grid-14x5">
		<div class="slot-nav">
			<jsp:include page="/WEB-INF/include/nav.jsp" />
		</div>

		<div class="slot-board">
			<div class="form-card">
				<h2 class="card-title">내 정보 수정</h2>
				<p class="guide-text">
					현재 로그인된 사용자:
					<c:out value="${sessionScope.user.userName}" />
					(
					<c:out value="${sessionScope.user.userEmail}" />
					)
				</p>
				<!-- TODO: 여기에 실제 정보 수정 폼을 구현합니다. -->
				<form action="myInfo" method="post">
					<!-- 예시: 이름 수정 필드 -->
					<div class="form-group">
						<label for="username" class="form-label">이름</label> <input
							type="text" id="username" name="username" class="form-input"
							value="<c:out value="${sessionScope.user.userName}"/>" required>
					</div>
					<!-- 예시: 비밀번호 변경 버튼 -->
					<button type="button" class="form-button secondary-button">비밀번호
						변경</button>
					<div class="divider"></div>
					<button type="submit" class="form-button primary-button">정보
						저장</button>
				</form>
			</div>
		</div>

		<div class="slot-extra"></div>
	</main>
	<footer></footer>
</body>
</html>
