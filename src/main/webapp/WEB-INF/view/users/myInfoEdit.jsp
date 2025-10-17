<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%-- 로그인 확인 --%>
<c:if test="${empty user}">
	<c:redirect url="/users/login" />
</c:if>

<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>내 정보 수정</title>
<link rel="stylesheet" href='${pageContext.request.contextPath}/css/app.css?v=2' />
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>

	<jsp:include page="/WEB-INF/include/header.jsp" />
	
	<main class="main grid-14x5">
		<div class="slot-nav"></div>

		<div class="slot-board">
			<div class="form-card">
				<h2 class="card-title">내 정보 수정</h2>

				<!-- 서버에서 넘어온 오류 메시지 출력 -->
				<c:if test="${not empty error}">
					<p class="error-message">
						<c:out value="${error}" escapeXml="true" />
					</p>
				</c:if>

				<!-- 성공 메시지 -->
				<c:if test="${not empty success}">
					<p class="success-message">
						<c:out value="${success}" escapeXml="true" />
					</p>
				</c:if>

				<form action="${pageContext.request.contextPath}/users/updateInfo" method="post" id="updateForm">

					<!-- 아이디 (수정 불가) -->
					<div class="form-group">
						<label for="userId" class="form-label">아이디</label>
						<input type="text" id="userId" name="userId" class="form-input" 
							value="<c:out value='${user.userId}' />" readonly style="background-color: #f0f0f0;">
						<p class="input-message">아이디는 변경할 수 없습니다.</p>
					</div>

					<!-- 닉네임 -->
					<div class="form-group">
						<label for="username" class="form-label">닉네임</label>
						<input type="text" id="username" name="username" class="form-input" 
							value="<c:out value='${user.userName}' />" 
							placeholder="사용하실 닉네임을 입력해 주세요" required maxlength="10">
						<p class="input-message">다른 사용자에게 보여질 이름입니다.</p>
					</div>

					<!-- 이메일 (수정 불가 - 인증된 이메일) -->
					<div class="form-group">
						<label for="email" class="form-label">이메일</label>
						<input type="email" id="email" name="email" class="form-input" 
							value="<c:out value='${user.email}' />" readonly style="background-color: #f0f0f0;">
						<p class="input-message">이메일은 변경할 수 없습니다.</p>
					</div>

					<!-- 현재 비밀번호 (필수) -->
					<div class="form-group" id="currentPasswordGroup">
						<label for="currentPassword" class="form-label">현재 비밀번호 <span style="color: var(--error-color);">*</span></label>
						<input type="password" id="currentPassword" name="currentPassword" class="form-input" 
							placeholder="본인 확인을 위해 현재 비밀번호를 입력해주세요" required>
						<p id="currentPasswordMessage" class="input-message">정보 수정을 위해 현재 비밀번호가 필요합니다.</p>
					</div>

					<!-- 새 비밀번호 (선택) -->
					<div class="form-group" id="passwordGroup">
						<label for="password" class="form-label">새 비밀번호 (선택)</label>
						<input type="password" id="password" name="password" class="form-input" 
							placeholder="변경하지 않으려면 비워두세요" oninput="validatePassword();">
						<p id="passwordMessage" class="input-message">8자 이상, 영문 대소문자, 숫자, 특수문자를 모두 포함해야 합니다.</p>
					</div>

					<!-- 새 비밀번호 확인 -->
					<div class="form-group" id="passwordConfirmGroup">
						<label for="passwordConfirm" class="form-label">새 비밀번호 확인</label>
						<input type="password" id="passwordConfirm" name="passwordConfirm" class="form-input" 
							placeholder="새 비밀번호를 다시 입력해주세요" oninput="validatePasswordConfirm();">
						<p id="passwordConfirmMessage" class="input-message">새 비밀번호와 일치해야 합니다.</p>
					</div>

					<button type="submit" id="submitBtn" class="form-button">정보 수정</button>
				</form>

				<!-- 액션 버튼 -->
				<div class="action-buttons">
					<button type="button" id="cancelBtn" onclick="location.href='${pageContext.request.contextPath}/users/myInfo'">취소</button>
				</div>
			</div>
		</div>
	</main>

	<script>
	// 전역 상태 변수
	let isPasswordValid = true; // 비밀번호를 변경하지 않으면 유효한 것으로 간주
	let isPasswordMatch = true;
	
	// 메시지 출력 및 스타일 업데이트 함수
	function updateMessage(elementId, inputId, message, isError) {
		const msgElement = $('#' + elementId);
		const inputElement = $('#' + inputId);
		
		msgElement.html(message).css('color', isError ? 'var(--error-color)' : 'green');
		inputElement.toggleClass('is-error', isError);
	}

	// 새 비밀번호 유효성 검사
	function validatePassword() {
		const password = $('#password').val();
		
		// 비밀번호가 비어있으면 (변경하지 않음) 유효한 것으로 처리
		if (password.length === 0) {
			isPasswordValid = true;
			updateMessage('passwordMessage', 'password', '비밀번호를 변경하지 않으려면 비워두세요.', false);
			validatePasswordConfirm();
			return;
		}
		
		// 강화된 비밀번호 검증
		const hasLowerCase = /[a-z]/.test(password);
		const hasUpperCase = /[A-Z]/.test(password);
		const hasNumber = /[0-9]/.test(password);
		const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);
		const isLengthValid = password.length >= 8;
		
		const isValidFormat = isLengthValid && hasLowerCase && hasUpperCase && hasNumber && hasSpecialChar;

		isPasswordValid = isValidFormat;
		
		if (!isLengthValid) {
			updateMessage('passwordMessage', 'password', '🚨 비밀번호는 최소 8자 이상이어야 합니다.', true);
		} else if (!hasLowerCase) {
			updateMessage('passwordMessage', 'password', '🚨 영문 소문자를 포함해야 합니다.', true);
		} else if (!hasUpperCase) {
			updateMessage('passwordMessage', 'password', '🚨 영문 대문자를 포함해야 합니다.', true);
		} else if (!hasNumber) {
			updateMessage('passwordMessage', 'password', '🚨 숫자를 포함해야 합니다.', true);
		} else if (!hasSpecialChar) {
			updateMessage('passwordMessage', 'password', '🚨 특수문자(!@#$%^&* 등)를 포함해야 합니다.', true);
		} else {
			updateMessage('passwordMessage', 'password', '✅ 안전한 비밀번호입니다.', false);
		}
		
		validatePasswordConfirm();
	}

	// 새 비밀번호 확인 유효성 검사
	function validatePasswordConfirm() {
		const password = $('#password').val();
		const confirm = $('#passwordConfirm').val();
		
		// 새 비밀번호가 비어있으면 확인도 비어있어야 함
		if (password.length === 0) {
			isPasswordMatch = (confirm.length === 0);
			
			if (confirm.length > 0) {
				updateMessage('passwordConfirmMessage', 'passwordConfirm', '❌ 새 비밀번호를 먼저 입력해주세요.', true);
			} else {
				updateMessage('passwordConfirmMessage', 'passwordConfirm', '비밀번호를 변경하지 않습니다.', false);
			}
			return;
		}
		
		// 새 비밀번호가 있으면 확인 필드도 일치해야 함
		isPasswordMatch = (password === confirm && confirm.length > 0);
		
		if (confirm.length === 0) {
			updateMessage('passwordConfirmMessage', 'passwordConfirm', '새 비밀번호를 다시 입력해주세요.', false);
		} else if (isPasswordMatch) {
			updateMessage('passwordConfirmMessage', 'passwordConfirm', '✅ 비밀번호가 일치합니다.', false);
		} else {
			updateMessage('passwordConfirmMessage', 'passwordConfirm', '❌ 비밀번호가 일치하지 않습니다.', true);
		}
	}

	// 폼 제출 시 최종 유효성 검사
	$('#updateForm').on('submit', function(e) {
		const currentPassword = $('#currentPassword').val().trim();
		
		if (!currentPassword) {
			e.preventDefault();
			updateMessage('currentPasswordMessage', 'currentPassword', '❌ 현재 비밀번호를 입력해주세요.', true);
			return false;
		}
		
		if (!isPasswordValid || !isPasswordMatch) {
			e.preventDefault();
			alert('입력하신 정보를 다시 확인해주세요.');
			return false;
		}
		
		return true;
	});

	// 페이지 로드 시 초기화
	$(function() {
		validatePassword();
		validatePasswordConfirm();
	});
	</script>

	<style>
	.success-message {
		background-color: #d4edda;
		border: 1px solid #c3e6cb;
		color: #155724;
		padding: 12px;
		border-radius: 4px;
		margin-bottom: 1rem;
	}
	</style>
</body>
</html>