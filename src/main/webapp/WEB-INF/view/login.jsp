<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>로그인</title>

<link rel="stylesheet" href='/css/form-style.css' />
<link rel="stylesheet" href='/css/users.css' />
</head>
<body>

	<jsp:include page="/WEB-INF/include/header.jsp" />
	<main class="main grid-14x5">
		<div class="slot-nav"></div>

		<div class="slot-board">

			<div class="form-card">
				<form action="login" method="post">
					<div class="form-group">
						<label for="userId" class="form-label">아이디</label>
						<div class="form-input-container">
							<input type="text" id="userId" name="userId" class="form-input"
								placeholder="아이디 입력" required autocomplete="username">
							<!-- 이미지에서 본 아이디 입력창의 X 아이콘 (입력 값 지우기) -->
							<span class="input-icon clear-icon"
								onclick="document.getElementById('userId').value='';"> <svg
									xmlns="http://www.w3.org/2000/svg" fill="none"
									viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
<path stroke-linecap="round" stroke-linejoin="round"
										d="M6 18L18 6M6 6l12 12" />
</svg>
							</span>
						</div>
					</div>

					<div class="form-group">
						<label for="password" class="form-label">비밀번호</label>
						<div class="form-input-container">
							<input type="password" id="password" name="password"
								class="form-input <c:if test="${loginFailed}">is-error</c:if>
                   placeholder="
								비밀번호 입력" required autocomplete="current-password">
							<!-- 이미지에서 본 에러 아이콘 -->
							<c:if test="${loginFailed}">
								<span class="input-icon error-icon"> <svg
										xmlns="http://www.w3.org/2000/svg" fill="none"
										viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                        <path stroke-linecap="round"
											stroke-linejoin="round"
											d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
                    </svg>
								</span>
							</c:if>
						</div>
						<c:if test="${error != null}">
							<p class="error-message">${error}</p>
						</c:if>
					</div>

					<div class="button-container">
						<button type="submit" class="btn btn-primary">로그인</button>
						<a href="join" class="btn btn-secondary" role="button">회원가입</a>
					</div>
				</form>

			</div>
		</div>

		<div class="slot-extra">
			<!-- 필요 시 우측 칼럼 -->
		</div>
	</main>
	<footer></footer>
</body>
</html>
