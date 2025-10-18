<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%-- 
    🚨 KISA 시큐어 코딩 가이드 준수 (하드 코딩된 비밀번호 등 정보)
    실제 운영 환경에서는 서버 측 Java 코드(Controller 등)에서 환경 변수/설정 파일을 읽어 
    request.setAttribute("firebaseConfigJson", "...") 형태로 값을 설정하고,
    아래 JSTL 태그를 통해 동적으로 주입해야 합니다.
--%>
<%-- 
    🚨 Controller에서 Model을 통해 전달된 JSON 문자열 변수만 사용합니다.
    (하드 코딩된 API Key를 제거)
--%>
<c:set var="firebaseConfigJson" value='${firebaseConfigJson}' />

<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>회원가입</title>
<link rel="stylesheet" href='/css/login-join-form-style.css' />
<link rel="stylesheet" href='/css/users.css' />
<link rel="stylesheet" href='/css/style.css' />


<!-- Firebase SDK 복원 -->
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>

<!-- jQuery 추가 (AJAX 사용) -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<style>
/* =========================
   ⬇️ 중앙 정렬을 위한 레이아웃 보정 (동작/데이터 흐름 변경 없음)
   ========================= */
html, body {
  height: 100%;
}
body {
  min-height: 100vh;
  display: flex;
  flex-direction: column;  /* header 포함 레이아웃 */
}

/* 기존 .main.grid-14x5가 grid여도 강제로 중앙 정렬 플렉스 적용 */
.main.grid-14x5 {
  flex: 1 0 auto;                 /* header 제외 영역을 꽉 채움 */
  display: flex !important;       /* 중앙 정렬을 위해 flex 강제 */
  align-items: center;            /* 수직 중앙 */
  justify-content: center;        /* 수평 중앙 */
  padding: 24px;                  /* 가장자리 여백 */
  box-sizing: border-box;
}

/* 좌측 네비 영역이 레이아웃을 밀지 않도록 숨김(필요시 주석처리 가능) */
.slot-nav {
  display: none;
}

/* 보드 래퍼는 내용 폭 제한에 맞춰 가운데 정렬 */
.slot-board {
  width: 100%;
  max-width: 960px;               /* 페이지 전체의 최대 폭 (선호에 맞게 조절) */
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 카드 자체를 가운데 정렬 + 적절한 최대 폭 지정 */
.form-card {
  width: 100%;
  max-width: 560px;               /* 폼 카드 너비 */
  margin: 0 auto;                 /* 수평 가운데 */
}

/* 반응형에서 조금 넓혀 쓰고 싶다면 */
@media (min-width: 768px) {
  .form-card { max-width: 640px; }
}
/* =========================
   ⬆️ 중앙 정렬 보정 끝
   ========================= */

/* 기존 CSS 유지 (필요 시 프로젝트 공통 변수 색상 사용) */

</style>
</head>
<body>


	<main class="main grid-14x5">
		<div class="slot-nav"></div>

		<div class="slot-board">
			<div class="form-card">
				<h2 class="card-title">회원가입</h2>

				<!-- 서버에서 넘어온 오류 메시지 출력 (XSS 방지) -->
				<c:if test="${not empty error}">
					<p class="error-message">
						<c:out value="${error}" escapeXml="true" />
					</p>
				</c:if>

				<!-- 💡 action="join"으로 설정됨 -->
				<form action="join" method="post" id="joinForm">
					<!-- 1. 아이디 입력 및 비동기 중복 확인 (서버 DB 사용) -->
					<div class="form-group" id="userIdGroup">
						<label for="userId" class="form-label">아이디</label>
						<div class="form-input-container">
							<input type="text" id="userId" name="userId" class="form-input"
								placeholder="5~20자 영문/숫자" required maxlength="20"
								oninput="checkIdAvailability();">
							<span class="input-icon clear-icon"
								onclick="document.getElementById('userId').value=''; checkIdAvailability();">
								<svg xmlns="http://www.w3.org/2000/svg" fill="none"
									viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M6 18L18 6M6 6l12 12" />
								</svg>
							</span>
						</div>
						<p id="idCheckMessage" class="input-message">아이디를 입력해 주세요.</p>
					</div>

					<!-- 2. 비밀번호 -->
					<div class="form-group" id="passwordGroup">
						<label for="password" class="form-label">비밀번호</label>
						<input type="password" id="password" name="password" class="form-input"
							placeholder="8자 이상, 대소문자/숫자/특수문자 포함" required
							oninput="validatePassword();">
						<p id="passwordMessage" class="input-message">8자 이상, 영문 대소문자, 숫자, 특수문자를 모두 포함해야 합니다.</p>
					</div>

					<!-- 3. 비밀번호 확인 -->
					<div class="form-group" id="passwordConfirmGroup">
						<label for="passwordConfirm" class="form-label">비밀번호 확인</label>
						<input type="password" id="passwordConfirm" name="passwordConfirm"
							class="form-input" placeholder="비밀번호 재확인" required
							oninput="validatePasswordConfirm();">
						<p id="passwordConfirmMessage" class="input-message">비밀번호가 일치해야 합니다.</p>
					</div>

					<!-- 4. 이름 (닉네임) -->
					<div class="form-group">
						<label for="username" class="form-label">닉네임</label>
						<input type="text" id="username" name="username" class="form-input"
							placeholder="사용하실 닉네임을 입력해 주세요" required maxlength="10">
						<p class="input-message">다른 사용자에게 보여질 이름입니다.</p>
					</div>

					<!-- 5. 이메일 입력 및 인증 기능 (Firebase 사용) -->
					<div class="form-group" id="emailGroup">
						<label for="email" class="form-label">이메일</label>
						<div class="email-action-container">
							<input type="email" id="email" name="email" class="form-input"
								placeholder="인증 가능한 이메일 주소" required
								oninput="checkEmailAvailability();">
							<button type="button" id="sendEmailBtn" disabled>인증 요청</button>
							<button type="button" id="cancelEmailBtn" style="display: none;">인증 취소</button>
						</div>
						<p id="emailMessage" class="input-message">유효한 이메일을 입력하면 인증 요청 버튼이 활성화됩니다.</p>
					</div>

					<!-- Hidden: 이메일 인증 상태 서버 전달 -->
					<input type="hidden" id="isEmailVerifiedHidden" name="isEmailVerified" value="false">
					<div class="action-buttons">
					<button type="button" id="resetBtn">입력 초기화</button>
					<button type="submit" id="submitBtn" class="form-button" disabled>회원가입 완료</button>
					<button type="button" id="cancelJoinBtn">가입 취소</button>
				</div>
				</form>

				<!-- 하단 액션 -->
				
			</div>
		</div>
	</main>

<script>
// ----------------------------------------------------
// Firebase 설정 및 초기화 (동일)
// ----------------------------------------------------
<%
  String firebaseJson = (String) request.getAttribute("firebaseConfigJson");
  if (firebaseJson == null || firebaseJson.isEmpty()) {
    firebaseJson = "{}";
  }
%>
let firebaseConfig = null;
let app = null;
let auth = null;

try {
  firebaseConfig = <%= firebaseJson %>;
  console.log('[DEBUG] firebaseConfig 객체:', firebaseConfig);
  console.log('[DEBUG] apiKey:', firebaseConfig.apiKey);

  if (!firebaseConfig || !firebaseConfig.apiKey || !firebaseConfig.authDomain || !firebaseConfig.projectId) {
    throw new Error('Firebase 설정에 필수 필드가 누락되었습니다.');
  }
  console.log("✅ Firebase Config loaded dynamically.");

  app = firebase.initializeApp(firebaseConfig);
  auth = firebase.auth();
  console.log("✅ Firebase App initialized successfully.");
} catch (e) {
  console.error("❌ Firebase 초기화 실패:", e.message);
  console.error("❌ 전체 에러:", e);
  const emailGroup = document.getElementById('emailGroup');
  if (emailGroup) {
    const errorMsg = document.createElement('p');
    errorMsg.className = 'error-message';
    errorMsg.style.color = 'var(--error-color)';
    errorMsg.textContent = '⚠️ Firebase 서비스 초기화 실패. 이메일 인증 기능을 사용할 수 없습니다. 관리자에게 문의하세요.';
    emailGroup.appendChild(errorMsg);
  }
  document.getElementById('sendEmailBtn').disabled = true;
  document.getElementById('email').disabled = true;
}

// ----------------------------------------------------
// 전역 상태
// ----------------------------------------------------
let isIdChecked = false;
let isIdAvailable = false;
let isPasswordValid = false;
let isPasswordMatch = false;
let isEmailChecked = false;
let isEmailAvailable = false;
let isEmailVerified = false;

let authCheckInterval = null;
let tempUserEmail = null;
let tempUserPassword = null;

// ----------------------------------------------------
// 헬퍼
// ----------------------------------------------------
function checkAllValidity() {
  const finalValid = isIdChecked && isIdAvailable &&
                     isPasswordValid && isPasswordMatch &&
                     isEmailChecked && isEmailAvailable && isEmailVerified;
  $('#submitBtn').prop('disabled', !finalValid);
  $('#isEmailVerifiedHidden').val(isEmailVerified);
}
function updateMessage(elementId, inputId, message, isError) {
  const msgElement = $('#' + elementId);
  const inputElement = $('#' + inputId);
  msgElement.html(message).css('color', isError ? 'var(--error-color)' : 'green');
  inputElement.toggleClass('is-error', isError);
}

// ----------------------------------------------------
// 1. ID 중복 확인 (AJAX)
// ----------------------------------------------------
function checkIdAvailability() {
  const userId = $('#userId').val().trim();
  isIdChecked = false;
  isIdAvailable = false;
  $('#userId').removeClass('is-error');

  if (userId.length < 5 || userId.length > 20 || !userId.match(/^[a-zA-Z0-9]{5,20}$/)) {
    updateMessage('idCheckMessage', 'userId', '🚨 아이디는 5~20자 이내의 영문/숫자만 가능합니다.', true);
    checkAllValidity();
    return;
  }

  $.ajax({
    url: 'ajax/checkId',
    type: 'GET',
    data: { userId: userId },
    dataType: 'json',
    success: function(response) {
      isIdChecked = true;
      if (response.isAvailable) {
        isIdAvailable = true;
        updateMessage('idCheckMessage', 'userId', '✅ 사용 가능한 아이디입니다.', false);
      } else {
        isIdAvailable = false;
        updateMessage('idCheckMessage', 'userId', '❌ 이미 존재하는 아이디입니다.', true);
      }
    },
    error: function() {
      updateMessage('idCheckMessage', 'userId', 'ID 체크 중 오류 발생.', true);
      isIdChecked = false;
      isIdAvailable = false;
    },
    complete: checkAllValidity
  });
}

// ----------------------------------------------------
// 2. 비밀번호 유효성 & 확인
// ----------------------------------------------------
function validatePassword() {
  const password = $('#password').val();
  if (authCheckInterval && tempUserPassword && password !== tempUserPassword) {
    updateMessage('passwordMessage', 'password', '⚠️ 비밀번호가 변경되었습니다. 이메일 인증을 다시 시작해야 합니다.', true);
    updateMessage('emailMessage', 'email', '⚠️ 비밀번호 변경으로 인증이 취소되었습니다. "인증 취소" 버튼을 눌러주세요.', true);
    return;
  }

  const hasLowerCase = /[a-z]/.test(password);
  const hasUpperCase = /[A-Z]/.test(password);
  const hasNumber    = /[0-9]/.test(password);
  const hasSpecial   = /[!@#$%^&*(),.?":{}|<>]/.test(password);
  const isLength     = password.length >= 8;

  isPasswordValid = isLength && hasLowerCase && hasUpperCase && hasNumber && hasSpecial;

  if (password.length === 0) {
    updateMessage('passwordMessage', 'password', '비밀번호를 입력해 주세요.', false);
  } else if (!isLength) {
    updateMessage('passwordMessage', 'password', '🚨 비밀번호는 최소 8자 이상이어야 합니다.', true);
  } else if (!hasLowerCase) {
    updateMessage('passwordMessage', 'password', '🚨 영문 소문자를 포함해야 합니다.', true);
  } else if (!hasUpperCase) {
    updateMessage('passwordMessage', 'password', '🚨 영문 대문자를 포함해야 합니다.', true);
  } else if (!hasNumber) {
    updateMessage('passwordMessage', 'password', '🚨 숫자를 포함해야 합니다.', true);
  } else if (!hasSpecial) {
    updateMessage('passwordMessage', 'password', '🚨 특수문자(!@#$%^&* 등)를 포함해야 합니다.', true);
  } else {
    updateMessage('passwordMessage', 'password', '✅ 안전한 비밀번호입니다.', false);
  }
  validatePasswordConfirm();
  checkAllValidity();
}
function validatePasswordConfirm() {
  const password = $('#password').val();
  const confirm  = $('#passwordConfirm').val();
  isPasswordMatch = (password === confirm && password.length > 0);

  if (password.length === 0) {
    updateMessage('passwordConfirmMessage', 'passwordConfirm', '비밀번호를 다시 한 번 입력해 주세요.', false);
  } else if (isPasswordMatch) {
    updateMessage('passwordConfirmMessage', 'passwordConfirm', '✅ 비밀번호가 일치합니다.', false);
  } else {
    updateMessage('passwordConfirmMessage', 'passwordConfirm', '❌ 비밀번호가 일치하지 않습니다.', true);
  }
  checkAllValidity();
}

// ----------------------------------------------------
// 3. 이메일 중복 체크
// ----------------------------------------------------
function checkEmailAvailability() {
  const email = $('#email').val().trim();
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
  const sendBtn = $('#sendEmailBtn');

  if (authCheckInterval && tempUserEmail && email !== tempUserEmail) {
    console.log('이메일 변경 감지: 인증 자동 취소');
    cancelEmailVerification();
  }

  isEmailChecked = false;
  isEmailAvailable = false;
  isEmailVerified = false;

  if (authCheckInterval) {
    clearInterval(authCheckInterval);
    authCheckInterval = null;
  }

  $('#cancelEmailBtn').hide();
  sendBtn.prop('disabled', true).text('인증 요청');
  $('#emailMessage').html('유효한 이메일을 입력하면 인증 요청 버튼이 활성화됩니다.').css('color', '');

  if (!emailRegex.test(email)) {
    updateMessage('emailMessage', 'email', '🚨 유효한 이메일 형식으로 입력해 주세요.', true);
    checkAllValidity();
    return;
  }

  $.ajax({
    url: 'ajax/checkEmail',
    type: 'GET',
    data: { email: email },
    dataType: 'json',
    success: function(response) {
      isEmailChecked = true;
      if (response.isAvailable) {
        isEmailAvailable = true;
        updateMessage('emailMessage', 'email', '✅ 사용 가능한 이메일입니다. 인증을 진행해 주세요.', false);
        sendBtn.prop('disabled', false);
      } else {
        isEmailAvailable = false;
        updateMessage('emailMessage', 'email', '❌ 이미 가입된 이메일입니다.', true);
      }
    },
    error: function() {
      updateMessage('emailMessage', 'email', '❌ 이메일 체크 중 오류 발생. 재시도해 주세요.', true);
      isEmailChecked = false;
      isEmailAvailable = false;
    },
    complete: checkAllValidity
  });
}

// ----------------------------------------------------
// 4. 이메일 인증 요청 (Firebase)
// ----------------------------------------------------
$('#sendEmailBtn').on('click', async function() {
  if (!auth) {
    updateMessage('emailMessage', 'email', '🚨 Firebase 서비스가 초기화되지 않았습니다. 관리자에게 문의하세요.', true);
    return;
  }
  const email = $('#email').val().trim();
  const password = $('#password').val();
  const sendBtn = $('#sendEmailBtn');

  if (!isEmailAvailable || !isPasswordValid || !isPasswordMatch) {
    updateMessage('emailMessage', 'email', '🚨 이메일 중복 확인, 비밀번호 형식 및 일치 여부를 모두 완료해주세요.', true);
    return;
  }

  tempUserEmail = email;
  tempUserPassword = password;

  sendBtn.prop('disabled', true).text('발송 중...');
  $('#emailMessage').html('📧 Firebase 인증 링크를 발송했습니다. 메일함을 확인해 주세요.').css('color', 'var(--primary-color)');

  try {
    let userCredential;
    let user;
    try {
      userCredential = await auth.createUserWithEmailAndPassword(email, password);
      user = userCredential.user;
      console.log('새 Firebase 계정 생성 성공.');
    } catch (e) {
      if (e.code === 'auth/email-already-in-use') {
        console.warn('Firebase 계정 이미 존재. 로그인 시도 중...');
        userCredential = await auth.signInWithEmailAndPassword(email, password);
        user = userCredential.user;
        if (user.emailVerified) {
          isEmailVerified = true;
          updateMessage('emailMessage', 'email', '🎉 이메일이 이미 인증되어 있습니다! 가입을 진행해 주세요.', false);
          sendBtn.prop('disabled', true).text('인증 완료');
          $('#email, #password, #userId, #username, #passwordConfirm').prop('readonly', true);
          auth.signOut();
          checkAllValidity();
          return;
        }
      } else { throw e; }
    }

    await user.sendEmailVerification();
    updateMessage('emailMessage', 'email', '✅ 인증 메일이 발송되었습니다. 메일함에서 링크를 클릭해주세요.', false);
    sendBtn.text('재전송').prop('disabled', true);
    $('#cancelEmailBtn').show();
    $('#email, #password, #userId, #username, #passwordConfirm').prop('readonly', true);
    startFirebaseAuthStatusCheck();

  } catch (error) {
    let msg = 'Firebase 인증 요청 중 오류가 발생했습니다.';
    if (error.code === 'auth/weak-password') msg = '❌ 비밀번호가 너무 약합니다. (Firebase 자체 검사)';
    else if (error.code === 'auth/invalid-email') msg = '❌ 유효하지 않은 이메일 형식입니다.';
    else if (error.code === 'auth/invalid-login-credentials' || error.code === 'auth/wrong-password') msg = '❌ 비밀번호가 일치하지 않아 계정 상태를 확인할 수 없습니다.';
    else msg = '❌ 인증 요청 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';

    updateMessage('emailMessage', 'email', msg, true);
    sendBtn.text('인증 요청').prop('disabled', false);
    $('#cancelEmailBtn').hide();
    $('#email, #password, #userId, #username, #passwordConfirm').prop('readonly', false);
    console.error("Firebase Error:", error.code, error.message);
  }
});

// ----------------------------------------------------
// 5. 인증 상태 Polling
// ----------------------------------------------------
function startFirebaseAuthStatusCheck() {
  const checkStatus = async () => {
    let user = auth.currentUser;
    try {
      if (!tempUserEmail || !tempUserPassword) {
        clearInterval(authCheckInterval); authCheckInterval = null; return;
      }
      const currentPassword = $('#password').val();
      if (currentPassword !== tempUserPassword) {
        clearInterval(authCheckInterval); authCheckInterval = null;
        updateMessage('emailMessage', 'email', '⚠️ 비밀번호가 변경되어 인증이 중단되었습니다. 인증 취소 후 다시 시작해주세요.', true);
        $('#sendEmailBtn').prop('disabled', true).text('인증 취소 필요');
        return;
      }
      if (!user) {
        const cred = await auth.signInWithEmailAndPassword(tempUserEmail, tempUserPassword);
        user = cred.user;
      }
      await user.reload();
      if (user.emailVerified) {
        isEmailVerified = true;
        updateMessage('emailMessage', 'email', '🎉 Firebase 이메일 인증이 완료되었습니다! 가입을 진행해 주세요.', false);
        clearInterval(authCheckInterval); authCheckInterval = null;
        $('#sendEmailBtn').prop('disabled', true).text('인증 완료');
        $('#cancelEmailBtn').hide();
        auth.signOut();
        tempUserEmail = null; tempUserPassword = null;
      } else {
        $('#emailMessage').html('📧 **인증 링크 클릭 대기 중**입니다. 메일함 확인 후 링크를 클릭해 주세요.').css('color', 'var(--primary-color)');
        $('#sendEmailBtn').prop('disabled', false).text('재전송');
      }
    } catch (error) {
      console.error('Firebase 인증 상태 확인 중 오류:', error);
      if (error.code === 'auth/invalid-login-credentials' || error.code === 'auth/wrong-password') {
        updateMessage('emailMessage', 'email', '❌ 비밀번호 불일치로 인증 확인 실패. 인증을 취소하고 다시 시작해주세요.', true);
        clearInterval(authCheckInterval); authCheckInterval = null;
        $('#sendEmailBtn').prop('disabled', true).text('인증 취소 필요');
      } else {
        updateMessage('emailMessage', 'email', '❌ 인증 상태 확인 중 알 수 없는 오류 발생. 재전송을 시도해 주세요.', true);
        clearInterval(authCheckInterval); authCheckInterval = null;
        $('#sendEmailBtn').prop('disabled', false).text('재전송');
      }
      isEmailVerified = false;
    } finally { checkAllValidity(); }
  };

  if (authCheckInterval) clearInterval(authCheckInterval);
  authCheckInterval = setInterval(checkStatus, 5000);
  checkStatus();
}

// ----------------------------------------------------
// 6. 추가 액션 (취소/리셋)
// ----------------------------------------------------
async function cancelEmailVerification() {
  if (authCheckInterval) { clearInterval(authCheckInterval); authCheckInterval = null; }
  $('#email, #password, #userId, #username, #passwordConfirm').prop('readonly', false);

  const user = auth.currentUser;
  if (user) {
    try { await user.delete(); }
    catch (e) {
      if (e.code === 'auth/requires-recent-login' && tempUserEmail && tempUserPassword) {
        try { await auth.signInWithEmailAndPassword(tempUserEmail, tempUserPassword); await auth.currentUser.delete(); }
        catch (re) {
          updateMessage('emailMessage', 'email', '❌ 인증 취소 실패. 재로그인에 실패했습니다. (비밀번호 오류)', true);
          $('#cancelEmailBtn').hide();
          return;
        }
      }
    }
    auth.signOut();
  }

  isEmailVerified = false;
  tempUserEmail = null;
  tempUserPassword = null;
  $('#sendEmailBtn').prop('disabled', false).text('인증 요청');
  $('#cancelEmailBtn').hide();
  updateMessage('emailMessage', 'email', '📧 인증이 취소되었습니다. 이메일/비밀번호를 수정하고 다시 요청해주세요.', false);
  checkAllValidity();
}
function resetForm() {
  $('#joinForm')[0].reset();
  cancelEmailVerification();
  isIdChecked = false; isIdAvailable = false;
  isPasswordValid = false; isPasswordMatch = false;
  isEmailChecked = false; isEmailAvailable = false; isEmailVerified = false;
  updateMessage('idCheckMessage', 'userId', '아이디를 입력해 주세요.', false);
  updateMessage('passwordMessage', 'password', '8자 이상, 영문 대소문자, 숫자, 특수문자를 모두 포함해야 합니다.', false);
  updateMessage('passwordConfirmMessage', 'passwordConfirm', '비밀번호가 일치해야 합니다.', false);
  updateMessage('emailMessage', 'email', '유효한 이메일을 입력하면 인증 요청 버튼이 활성화됩니다.', false);
  $('#userId, #password, #passwordConfirm, #email').removeClass('is-error');
  checkAllValidity();
}
function cancelJoin() {
  cancelEmailVerification();
  window.location.href = '${pageContext.request.contextPath}/users/login';
}

// ----------------------------------------------------
// 7. 이벤트 바인딩
// ----------------------------------------------------
$('#joinForm').on('submit', function(e) {
  if (!validateForm()) {
    e.preventDefault();
    if (isEmailAvailable && !isEmailVerified) {
      updateMessage('emailMessage', 'email', '🚨 **Firebase 이메일 인증이 완료되지 않았습니다.** 메일함을 확인하고 링크를 클릭해주세요.', true);
    } else {
      $('#submitBtn').text('필수 조건 미충족').addClass('is-error');
      setTimeout(() => {
        $('#submitBtn').text('회원가입 완료').removeClass('is-error');
        checkAllValidity();
      }, 1500);
    }
    return;
  }
  if (authCheckInterval) { clearInterval(authCheckInterval); authCheckInterval = null; }
});
$('#cancelEmailBtn').on('click', cancelEmailVerification);
$('#resetBtn').on('click', resetForm);
$('#cancelJoinBtn').on('click', cancelJoin);

function validateForm() {
  return isIdChecked && isIdAvailable &&
         isPasswordValid && isPasswordMatch &&
         isEmailChecked && isEmailAvailable && isEmailVerified;
}

$(function() {
  validatePassword();
  validatePasswordConfirm();
  checkAllValidity();
});
</script>
</body>
</html>
