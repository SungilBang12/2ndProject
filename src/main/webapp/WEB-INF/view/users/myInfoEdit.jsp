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

<style>
  /* ====== 전역 폰트 ====== */
  @import url('https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@400;600;700&family=Noto+Sans+KR:wght@300;400;500;600&display=swap');

  /* ====== 메인 그리드 조정 ====== */
  .main.grid-14x5 {
    grid-template-columns: 1fr;
    max-width: 800px;
    margin: 0 auto;
    padding: 24px;
  }

  .slot-nav:empty {
    display: none;
  }

  /* ====== 폼 카드 ====== */
  .form-card {
    background: linear-gradient(135deg, 
      rgba(42, 31, 26, 0.6) 0%, 
      rgba(26, 22, 20, 0.6) 100%
    );
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 16px;
    padding: 40px;
    box-shadow: 
      0 8px 32px rgba(0, 0, 0, 0.3),
      inset 0 1px 0 rgba(255, 255, 255, 0.05);
  }

  .card-title {
    margin: 0 0 32px 0;
    font-family: 'Noto Serif KR', serif;
    font-size: clamp(1.75rem, 3vw, 2.25rem);
    font-weight: 700;
    color: #FF8B7A;
    letter-spacing: -0.02em;
    text-align: center;
    padding-bottom: 20px;
    border-bottom: 2px solid rgba(255, 139, 122, 0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
  }

  .card-title::before {
    content: "✏️";
    font-size: 1.3em;
  }

  /* ====== 메시지 (에러/성공) ====== */
  .error-message,
  .success-message {
    padding: 16px 20px;
    border-radius: 12px;
    margin-bottom: 24px;
    font-size: 15px;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 10px;
    animation: slideIn 0.3s ease-out;
  }

  @keyframes slideIn {
    from {
      opacity: 0;
      transform: translateY(-10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .error-message {
    background: linear-gradient(135deg, 
      rgba(229, 62, 62, 0.15) 0%, 
      rgba(229, 62, 62, 0.1) 100%
    );
    border: 1px solid rgba(229, 62, 62, 0.3);
    color: #FC8181;
  }

  .error-message::before {
    content: "⚠️";
    font-size: 1.2em;
  }

  .success-message {
    background: linear-gradient(135deg, 
      rgba(72, 187, 120, 0.15) 0%, 
      rgba(72, 187, 120, 0.1) 100%
    );
    border: 1px solid rgba(72, 187, 120, 0.3);
    color: #68D391;
  }

  .success-message::before {
    content: "✅";
    font-size: 1.2em;
  }

  /* ====== 폼 그룹 ====== */
  .form-group {
    margin-bottom: 28px;
  }

  .form-label {
    display: block;
    margin-bottom: 10px;
    color: #e5e5e5;
    font-size: 15px;
    font-weight: 600;
    letter-spacing: -0.01em;
  }

  .form-label span[style*="color"] {
    color: #FF6B6B !important;
  }

  /* ====== 입력 필드 ====== */
  .form-input {
    width: 100%;
    padding: 14px 18px;
    background: rgba(26, 22, 20, 0.6);
    border: 2px solid rgba(255, 139, 122, 0.2);
    border-radius: 10px;
    color: #e5e5e5;
    font-size: 15px;
    transition: all 0.3s ease;
    outline: none;
    box-sizing: border-box;
  }

  .form-input::placeholder {
    color: rgba(229, 229, 229, 0.4);
  }

  .form-input:focus {
    background: rgba(26, 22, 20, 0.8);
    border-color: #FF8B7A;
    box-shadow: 0 0 0 3px rgba(255, 139, 122, 0.1);
  }

  /* 읽기 전용 필드 */
  .form-input[readonly] {
    background: rgba(26, 22, 20, 0.4) !important;
    border-color: rgba(255, 139, 122, 0.1) !important;
    color: rgba(229, 229, 229, 0.6) !important;
    cursor: not-allowed;
  }

  /* 에러 상태 */
  .form-input.is-error {
    border-color: #E53E3E;
    background: rgba(229, 62, 62, 0.05);
  }

  .form-input.is-error:focus {
    border-color: #E53E3E;
    box-shadow: 0 0 0 3px rgba(229, 62, 62, 0.1);
  }

  /* ====== 입력 메시지 ====== */
  .input-message {
    margin: 8px 0 0 4px;
    font-size: 13px;
    color: rgba(229, 229, 229, 0.6);
    line-height: 1.5;
    transition: color 0.3s ease;
  }

  /* ====== 제출 버튼 ====== */
  .form-button {
    width: 100%;
    padding: 16px 24px;
    margin-top: 32px;
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    color: #fff;
    border: none;
    border-radius: 12px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
    position: relative;
    overflow: hidden;
  }

  .form-button::before {
    content: "💾";
    margin-right: 8px;
  }

  .form-button::after {
    content: "";
    position: absolute;
    inset: 0;
    background: linear-gradient(135deg, 
      rgba(255, 255, 255, 0.2) 0%, 
      transparent 100%
    );
    opacity: 0;
    transition: opacity 0.3s ease;
  }

  .form-button:hover {
    background: linear-gradient(135deg, #FF8B7A 0%, #FFA07A 100%);
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(255, 107, 107, 0.5);
  }

  .form-button:hover::after {
    opacity: 1;
  }

  .form-button:active {
    transform: translateY(0);
  }

  .form-button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none !important;
  }

  /* ====== 액션 버튼 ====== */
  .action-buttons {
    display: flex;
    gap: 12px;
    margin-top: 20px;
  }

  .action-buttons button {
    flex: 1;
    padding: 14px 24px;
    background: rgba(42, 31, 26, 0.6);
    color: #e5e5e5;
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 10px;
    font-size: 15px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s ease;
  }

  .action-buttons button::before {
    content: "❌";
    margin-right: 6px;
  }

  .action-buttons button:hover {
    background: rgba(42, 31, 26, 0.8);
    border-color: rgba(255, 139, 122, 0.4);
    color: #FF8B7A;
    transform: translateY(-2px);
  }

  /* ====== 반응형 ====== */
  @media (max-width: 768px) {
    .form-card {
      padding: 28px 24px;
    }

    .card-title {
      font-size: 1.5rem;
      margin-bottom: 24px;
    }

    .form-group {
      margin-bottom: 24px;
    }

    .form-input {
      padding: 12px 16px;
    }

    .form-button {
      padding: 14px 20px;
      font-size: 15px;
    }

    .main.grid-14x5 {
      padding: 16px;
    }
  }

  /* ====== 포커스 애니메이션 ====== */
  @keyframes focusGlow {
    0%, 100% {
      box-shadow: 0 0 0 3px rgba(255, 139, 122, 0.1);
    }
    50% {
      box-shadow: 0 0 0 5px rgba(255, 139, 122, 0.15);
    }
  }

  .form-input:focus {
    animation: focusGlow 2s ease-in-out infinite;
  }

  /* ====== 필수 표시 강조 ====== */
  .form-label span {
    font-size: 1.1em;
    margin-left: 4px;
  }
</style>
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
						<label for="userId" class="form-label">🔒 아이디</label>
						<input type="text" id="userId" name="userId" class="form-input" 
							value="<c:out value='${user.userId}' />" readonly>
						<p class="input-message">아이디는 변경할 수 없습니다.</p>
					</div>

					<!-- 닉네임 -->
					<div class="form-group">
						<label for="username" class="form-label">👤 닉네임</label>
						<input type="text" id="username" name="username" class="form-input" 
							value="<c:out value='${user.userName}' />" 
							placeholder="사용하실 닉네임을 입력해 주세요" required maxlength="10">
						<p class="input-message">다른 사용자에게 보여질 이름입니다.</p>
					</div>

					<!-- 이메일 (수정 불가 - 인증된 이메일) -->
					<div class="form-group">
						<label for="email" class="form-label">✉️ 이메일</label>
						<input type="email" id="email" name="email" class="form-input" 
							value="<c:out value='${user.email}' />" readonly>
						<p class="input-message">이메일은 변경할 수 없습니다.</p>
					</div>

					<!-- 현재 비밀번호 (필수) -->
					<div class="form-group" id="currentPasswordGroup">
						<label for="currentPassword" class="form-label">
							🔑 현재 비밀번호 <span style="color: #FF6B6B;">*</span>
						</label>
						<input type="password" id="currentPassword" name="currentPassword" class="form-input" 
							placeholder="본인 확인을 위해 현재 비밀번호를 입력해주세요" required>
						<p id="currentPasswordMessage" class="input-message">정보 수정을 위해 현재 비밀번호가 필요합니다.</p>
					</div>

					<!-- 새 비밀번호 (선택) -->
					<div class="form-group" id="passwordGroup">
						<label for="password" class="form-label">🆕 새 비밀번호 (선택)</label>
						<input type="password" id="password" name="password" class="form-input" 
							placeholder="변경하지 않으려면 비워두세요" oninput="validatePassword();">
						<p id="passwordMessage" class="input-message">8자 이상, 영문 대소문자, 숫자, 특수문자를 모두 포함해야 합니다.</p>
					</div>

					<!-- 새 비밀번호 확인 -->
					<div class="form-group" id="passwordConfirmGroup">
						<label for="passwordConfirm" class="form-label">✔️ 새 비밀번호 확인</label>
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
		
		// 아이콘 추가
		let icon = '';
		if (message.includes('✅')) {
			icon = '';
		} else if (message.includes('🚨') || message.includes('❌')) {
			icon = '';
		}
		
		msgElement.html(icon + message).css('color', isError ? '#FC8181' : '#68D391');
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
			$('#currentPassword').focus();
			return false;
		}
		
		if (!isPasswordValid || !isPasswordMatch) {
			e.preventDefault();
			alert('⚠️ 입력하신 정보를 다시 확인해주세요.');
			return false;
		}
		
		// 제출 중 버튼 비활성화
		$('#submitBtn').prop('disabled', true).text('⏳ 처리 중...');
		
		return true;
	});

	// 페이지 로드 시 초기화
	$(function() {
		validatePassword();
		validatePasswordConfirm();
		
		// 자동 소멸 메시지
		setTimeout(() => {
			$('.success-message, .error-message').fadeOut(500);
		}, 5000);
	});
	</script>
</body>
</html>