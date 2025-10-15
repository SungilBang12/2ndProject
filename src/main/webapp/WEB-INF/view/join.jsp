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

<!-- Firebase SDK 복원 -->
<script
	src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script
	src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>

<!-- jQuery 추가 (AJAX 사용) -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<style>
/* 기존 CSS 스타일 유지 */

</style>
</head>
<body>

	<jsp:include page="/WEB-INF/include/header.jsp" />
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
								oninput="checkIdAvailability();"> <span
								class="input-icon clear-icon"
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
						<label for="password" class="form-label">비밀번호</label> <input
							type="password" id="password" name="password" class="form-input"
							placeholder="8자 이상, 대소문자/숫자/특수문자 포함" required
							oninput="validatePassword();">
						<p id="passwordMessage" class="input-message">8자 이상, 영문 대소문자, 숫자, 특수문자를 모두 포함해야 합니다.</p>
					</div>

					<!-- 3. 비밀번호 확인 -->
					<div class="form-group" id="passwordConfirmGroup">
						<label for="passwordConfirm" class="form-label">비밀번호 확인</label> <input
							type="password" id="passwordConfirm" name="passwordConfirm"
							class="form-input" placeholder="비밀번호 재확인" required
							oninput="validatePasswordConfirm();">
						<p id="passwordConfirmMessage" class="input-message">비밀번호가
							일치해야 합니다.</p>
					</div>

					<!-- 4. 이름 (닉네임) -->
					<div class="form-group">
						<label for="username" class="form-label">닉네임</label> <input
							type="text" id="username" name="username" class="form-input"
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
							<!-- 새로 추가된 인증 취소 버튼 -->
							<button type="button" id="cancelEmailBtn" style="display: none;">인증 취소</button>
						</div>
						<p id="emailMessage" class="input-message">유효한 이메일을 입력하면 인증 요청
							버튼이 활성화됩니다.</p>
					</div>

					<!-- Hidden 필드는 이메일 인증 상태를 서버로 전달하기 위해 사용 -->
					<input type="hidden" id="isEmailVerifiedHidden"
						name="isEmailVerified" value="false">

					<button type="submit" id="submitBtn" class="form-button" disabled>회원가입
						완료</button>
				</form>

				<!-- 새로 추가된 하단 액션 버튼 그룹 -->
				<div class="action-buttons">
					<button type="button" id="resetBtn">입력 초기화</button>
					<button type="button" id="cancelJoinBtn">가입 취소</button>
				</div>
			</div>
		</div>
	</main>

	<script>
	// ----------------------------------------------------
	// Firebase 설정 및 초기화
	// ----------------------------------------------------
	// 🚨 JSP Scriptlet으로 안전하게 JSON 문자열 출력
	<%
		String firebaseJson = (String) request.getAttribute("firebaseConfigJson");
		if (firebaseJson == null || firebaseJson.isEmpty()) {
			firebaseJson = "{}";
		}
	%>
	
	// 🚨 JSON을 직접 JavaScript 객체로 파싱 (문자열 이스케이프 문제 완전 우회)
	let firebaseConfig = null;
	let app = null;
	let auth = null;
	
	try {
		// JSP에서 직접 JavaScript 객체로 출력
		firebaseConfig = <%= firebaseJson %>;
		
		// 🚨 디버깅 로그
		console.log('[DEBUG] firebaseConfig 객체:', firebaseConfig);
		console.log('[DEBUG] apiKey:', firebaseConfig.apiKey);
		
		// 필수 필드 검증
		if (!firebaseConfig || !firebaseConfig.apiKey || !firebaseConfig.authDomain || !firebaseConfig.projectId) {
			throw new Error('Firebase 설정에 필수 필드가 누락되었습니다.');
		}
		
		console.log("✅ Firebase Config loaded dynamically.");
		
		// Firebase 초기화
		app = firebase.initializeApp(firebaseConfig);
		auth = firebase.auth();
		console.log("✅ Firebase App initialized successfully.");
		
	} catch (e) {
		console.error("❌ Firebase 초기화 실패:", e.message);
		console.error("❌ 전체 에러:", e);
		
		// 사용자에게 알림
		const emailGroup = document.getElementById('emailGroup');
		if (emailGroup) {
			const errorMsg = document.createElement('p');
			errorMsg.className = 'error-message';
			errorMsg.style.color = 'var(--error-color)';
			errorMsg.textContent = '⚠️ Firebase 서비스 초기화 실패. 이메일 인증 기능을 사용할 수 없습니다. 관리자에게 문의하세요.';
			emailGroup.appendChild(errorMsg);
		}
		
		// 이메일 인증 관련 UI 비활성화
		document.getElementById('sendEmailBtn').disabled = true;
		document.getElementById('email').disabled = true;
	}

	// ----------------------------------------------------
	// 전역 상태 변수
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
	// 헬퍼 함수
	// ----------------------------------------------------

	/**
	 * 모든 유효성 검사 상태를 확인하고 최종 가입 버튼 활성화/비활성화를 결정합니다.
	 */
	function checkAllValidity() {
	    const finalValid = isIdChecked && isIdAvailable && 
	                       isPasswordValid && isPasswordMatch &&
	                       isEmailChecked && isEmailAvailable && isEmailVerified;
	    
	    $('#submitBtn').prop('disabled', !finalValid);
		$('#isEmailVerifiedHidden').val(isEmailVerified);
	}

	/**
	 * 메시지 출력 및 스타일 업데이트 함수
	 */
	function updateMessage(elementId, inputId, message, isError) {
		const msgElement = $('#' + elementId);
		const inputElement = $('#' + inputId);
		
		msgElement.html(message).css('color', isError ? 'var(--error-color)' : 'green');
		inputElement.toggleClass('is-error', isError);
	}
	
	// ----------------------------------------------------
	// 1. ID 중복 확인 (AJAX - 서버 DB 사용)
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
	        error: function(xhr) {
	            let errorMessage = 'ID 체크 중 오류 발생.';
	            updateMessage('idCheckMessage', 'userId', errorMessage, true);
	            isIdChecked = false;
	            isIdAvailable = false;
	        },
			complete: checkAllValidity
	    });
	}

	// ----------------------------------------------------
	// 2. 비밀번호 유효성 검사
	// ----------------------------------------------------
	function validatePassword() {
		const password = $('#password').val();
		
		// 🚨 비밀번호 변경 감지: 인증 진행 중이면 경고
		if (authCheckInterval && tempUserPassword && password !== tempUserPassword) {
			// 인증 진행 중인데 비밀번호가 변경됨
			updateMessage('passwordMessage', 'password', '⚠️ 비밀번호가 변경되었습니다. 이메일 인증을 다시 시작해야 합니다.', true);
			updateMessage('emailMessage', 'email', '⚠️ 비밀번호 변경으로 인증이 취소되었습니다. "인증 취소" 버튼을 눌러주세요.', true);
			
			// 자동으로 인증 취소 (선택사항)
			// cancelEmailVerification();
			return;
		}
		
		// 🚨 강화된 비밀번호 검증: 대소문자, 숫자, 특수문자 각각 필수
		const hasLowerCase = /[a-z]/.test(password);
		const hasUpperCase = /[A-Z]/.test(password);
		const hasNumber = /[0-9]/.test(password);
		const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);
		const isLengthValid = password.length >= 8;
		
		const isValidFormat = isLengthValid && hasLowerCase && hasUpperCase && hasNumber && hasSpecialChar;

		isPasswordValid = isValidFormat;
		
		if (password.length === 0) {
			updateMessage('passwordMessage', 'password', '비밀번호를 입력해 주세요.', false);
		} else if (!isLengthValid) {
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
		checkAllValidity();
	}
	
	function validatePasswordConfirm() {
		const password = $('#password').val();
		const confirm = $('#passwordConfirm').val();
		
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
	// 3. 이메일 중복 체크 (AJAX - 서버 DB 중복 확인)
	// ----------------------------------------------------
	function checkEmailAvailability() {
		const email = $('#email').val().trim();
		const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
		const sendBtn = $('#sendEmailBtn');

		// 🚨 이메일 변경 감지: 인증 진행 중이면 자동 취소
		if (authCheckInterval && tempUserEmail && email !== tempUserEmail) {
			console.log('이메일 변경 감지: 인증 자동 취소');
			cancelEmailVerification();
		}

		isEmailChecked = false;
		isEmailAvailable = false;
		isEmailVerified = false;
		
		// 인증 상태 확인 중이었다면 중지
		if (authCheckInterval) {
			clearInterval(authCheckInterval);
			authCheckInterval = null;
		}

		// UI 초기화
		$('#cancelEmailBtn').hide(); 
		sendBtn.prop('disabled', true).text('인증 요청');
		$('#emailMessage').html('유효한 이메일을 입력하면 인증 요청 버튼이 활성화됩니다.').css('color', '');

		if (!emailRegex.test(email)) {
			updateMessage('emailMessage', 'email', '🚨 유효한 이메일 형식으로 입력해 주세요.', true);
			checkAllValidity();
			return;
		}

		// 1. 서버 DB에 해당 이메일이 이미 가입되어 있는지 확인
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
					sendBtn.prop('disabled', false); // 중복이 없으면 버튼 활성화
	            } else {
					isEmailAvailable = false;
	                updateMessage('emailMessage', 'email', '❌ 이미 가입된 이메일입니다.', true);
	            }
	        },
	        error: function(xhr) {
	            updateMessage('emailMessage', 'email', '❌ 이메일 체크 중 오류 발생. 재시도해 주세요.', true);
	            isEmailChecked = false;
	            isEmailAvailable = false;
	        },
			complete: checkAllValidity
	    });
	}
	
	// ----------------------------------------------------
	// 4. 이메일 인증 요청 (Firebase Authentication 사용)
	// ----------------------------------------------------
	$('#sendEmailBtn').on('click', async function() {
		// 🚨 Firebase 초기화 확인
		if (!auth) {
			updateMessage('emailMessage', 'email', '🚨 Firebase 서비스가 초기화되지 않았습니다. 관리자에게 문의하세요.', true);
			return;
		}

		const email = $('#email').val().trim();
		const password = $('#password').val();
		const sendBtn = $('#sendEmailBtn');
		
		if (!isEmailAvailable || !isPasswordValid || !isPasswordMatch) {
			console.error('인증 요청 전 필수 유효성 검사 실패.');
			updateMessage('emailMessage', 'email', '🚨 이메일 중복 확인, 비밀번호 형식 및 일치 여부를 모두 완료해주세요.', true);
			return;
		}

		// 재로그인에 사용할 정보 저장
		tempUserEmail = email; 
		tempUserPassword = password; 

		sendBtn.prop('disabled', true).text('발송 중...');
		$('#emailMessage').html('📧 Firebase 인증 링크를 발송했습니다. 메일함을 확인해 주세요.').css('color', 'var(--primary-color)');
		
		try {
			let userCredential;
			let user;
			
			// A. 임시 사용자 생성 시도 (대부분의 신규 가입)
			try {
				userCredential = await auth.createUserWithEmailAndPassword(email, password);
				user = userCredential.user;
				console.log('새 Firebase 계정 생성 성공.');
			} catch (e) {
				if (e.code === 'auth/email-already-in-use') {
					// B. 이미 계정이 있다면, 로그인하여 기존 사용자 객체 확보 (재전송 목적)
					console.warn('Firebase 계정 이미 존재. 로그인 시도 중...');
					userCredential = await auth.signInWithEmailAndPassword(email, password);
					user = userCredential.user;
					// 이미 인증이 완료된 계정이라면 바로 처리
					if (user.emailVerified) {
						isEmailVerified = true;
						updateMessage('emailMessage', 'email', '🎉 이메일이 이미 인증되어 있습니다! 가입을 진행해 주세요.', false);
						sendBtn.prop('disabled', true).text('인증 완료');
						$('#email, #password, #userId, #username, #passwordConfirm').prop('readonly', true);
						auth.signOut();
						checkAllValidity();
						return;
					}
				} else {
					// 비밀번호 약함 등 다른 오류 발생 시 예외 던짐
					throw e; 
				}
			}
			
			// C. 이메일 인증 링크 발송
			await user.sendEmailVerification();
			
			updateMessage('emailMessage', 'email', '✅ 인증 메일이 발송되었습니다. 메일함에서 링크를 클릭해주세요.', false);
			sendBtn.text('재전송');
			sendBtn.prop('disabled', true); // 재전송 버튼은 상태 확인 중에는 비활성화
			$('#cancelEmailBtn').show(); // 인증 취소 버튼 활성화
			
			// 모든 입력 필드 잠금 (인증 상태를 꼬이지 않게 하기 위함)
			$('#email, #password, #userId, #username, #passwordConfirm').prop('readonly', true);
			
			// D. 인증 상태 주기적 확인 시작
			startFirebaseAuthStatusCheck();
			
		} catch (error) {
			let errorMsg = 'Firebase 인증 요청 중 오류가 발생했습니다.';
			
			if (error.code === 'auth/weak-password') {
				errorMsg = '❌ 비밀번호가 너무 약합니다. (Firebase 자체 검사)';
			} else if (error.code === 'auth/invalid-email') {
				errorMsg = '❌ 유효하지 않은 이메일 형식입니다.';
			} else if (error.code === 'auth/invalid-login-credentials' || error.code === 'auth/wrong-password') {
				errorMsg = '❌ 비밀번호가 일치하지 않아 계정 상태를 확인할 수 없습니다. 비밀번호를 정확히 입력해주세요.';
			} else {
				errorMsg = '❌ 인증 요청 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
			}
			
			updateMessage('emailMessage', 'email', errorMsg, true);
			sendBtn.text('인증 요청').prop('disabled', false);
			$('#cancelEmailBtn').hide();
			$('#email, #password, #userId, #username, #passwordConfirm').prop('readonly', false);
			console.error("Firebase Error:", error.code, error.message);
		}
	});

	// ----------------------------------------------------
	// 5. Firebase 이메일 인증 상태 주기적 확인
	// ----------------------------------------------------
	function startFirebaseAuthStatusCheck() {
		const checkStatus = async () => {
			let user = auth.currentUser;
			
			try {
				if (!tempUserEmail || !tempUserPassword) {
					console.warn('임시 사용자 정보가 없습니다. Polling 중단.');
					clearInterval(authCheckInterval);
					authCheckInterval = null;
					return;
				}

				// 🚨 비밀번호 변경 감지: 현재 입력된 비밀번호와 저장된 비밀번호 비교
				const currentPassword = $('#password').val();
				if (currentPassword !== tempUserPassword) {
					console.warn('비밀번호가 변경되었습니다. Polling 중단.');
					clearInterval(authCheckInterval);
					authCheckInterval = null;
					updateMessage('emailMessage', 'email', '⚠️ 비밀번호가 변경되어 인증이 중단되었습니다. 인증 취소 후 다시 시작해주세요.', true);
					$('#sendEmailBtn').prop('disabled', true).text('인증 취소 필요');
					return;
				}

				if (!user) {
					// 세션이 끊어졌다면, 다시 로그인 시도
					const userCredential = await auth.signInWithEmailAndPassword(tempUserEmail, tempUserPassword);
					user = userCredential.user;
					console.log('세션 재확보 성공.');
				}
				
				// 🚨 최신 상태 로드
				await user.reload();
				
				const isVerifiedNow = user.emailVerified;
				
				if (isVerifiedNow) {
					isEmailVerified = true;
					updateMessage('emailMessage', 'email', '🎉 Firebase 이메일 인증이 완료되었습니다! 가입을 진행해 주세요.', false);
					
					clearInterval(authCheckInterval); 
					authCheckInterval = null; 

					$('#sendEmailBtn').prop('disabled', true).text('인증 완료');
					$('#cancelEmailBtn').hide(); // 인증 완료 시 취소 버튼 제거
					
					// Firebase 임시 로그아웃 (서버 DB 가입 전 정리)
					auth.signOut();
					
					// 재로그인에 사용했던 임시 정보 제거
					tempUserEmail = null;
					tempUserPassword = null;

				} else {
					// 아직 인증되지 않음
					$('#emailMessage').html('📧 **인증 링크 클릭 대기 중**입니다. 메일함 확인 후 링크를 클릭해 주세요.').css('color', 'var(--primary-color)');
					// 재전송 기회 부여
					$('#sendEmailBtn').prop('disabled', false).text('재전송'); 
				}
			} catch (error) {
				console.error('Firebase 인증 상태 확인 중 오류 발생:', error);
				
				if (error.code === 'auth/invalid-login-credentials' || error.code === 'auth/wrong-password') {
					updateMessage('emailMessage', 'email', '❌ 비밀번호 불일치로 인증 확인 실패. 인증을 취소하고 다시 시작해주세요.', true);
					// 비밀번호 불일치 시 Polling 중단
					clearInterval(authCheckInterval);
					authCheckInterval = null;
					$('#sendEmailBtn').prop('disabled', true).text('인증 취소 필요');
				} else {
					updateMessage('emailMessage', 'email', '❌ 인증 상태 확인 중 알 수 없는 오류 발생. 재전송을 시도해 주세요.', true);
					clearInterval(authCheckInterval);
					authCheckInterval = null;
					$('#sendEmailBtn').prop('disabled', false).text('재전송');
				}
				isEmailVerified = false;

			} finally {
				checkAllValidity();
			}
		};

		if (authCheckInterval) {
			clearInterval(authCheckInterval);
		}
		
		// 5초마다 인증 상태 확인 시작
		authCheckInterval = setInterval(checkStatus, 5000); 
		checkStatus(); // 즉시 1회 실행
	}
	
	// ----------------------------------------------------
	// 6. 추가된 사용자 액션 함수
	// ----------------------------------------------------

	/**
	 * [요청 1] 이메일 인증을 취소하고 Firebase 임시 계정을 삭제하며 폼 잠금을 해제합니다.
	 */
	async function cancelEmailVerification() {
		// 1. 상태 확인 주기 중단
		if (authCheckInterval) {
			clearInterval(authCheckInterval);
			authCheckInterval = null;
		}

		// 2. 입력 필드 잠금 해제
		$('#email, #password, #userId, #username, #passwordConfirm').prop('readonly', false);
		
		// 3. Firebase 임시 계정 삭제
		const user = auth.currentUser;
		if (user) {
			try {
				await user.delete();
				console.log('Firebase 임시 계정 삭제 성공:', user.email);
			} catch (e) {
				// 재로그인이 필요한 경우 (세션 만료)
				if (e.code === 'auth/requires-recent-login' && tempUserEmail && tempUserPassword) {
					try {
						await auth.signInWithEmailAndPassword(tempUserEmail, tempUserPassword);
						await auth.currentUser.delete();
						console.log('Firebase 임시 계정 재로그인 후 삭제 성공.');
					} catch (reAuthError) {
						console.error('Firebase 계정 재로그인 및 삭제 실패:', reAuthError);
						updateMessage('emailMessage', 'email', '❌ 인증 취소 실패. 재로그인에 실패했습니다. (비밀번호 오류)', true);
						$('#cancelEmailBtn').hide();
						return; 
					}
				} else {
					console.error('Firebase 계정 삭제 실패:', e);
				}
			}
			// 삭제 후 로그아웃
			auth.signOut();
		}
		
		// 4. UI 상태 초기화
		isEmailVerified = false;
		tempUserEmail = null;
		tempUserPassword = null;
		$('#sendEmailBtn').prop('disabled', false).text('인증 요청');
		$('#cancelEmailBtn').hide();
		updateMessage('emailMessage', 'email', '📧 인증이 취소되었습니다. 이메일/비밀번호를 수정하고 다시 요청해주세요.', false);
		
		checkAllValidity();
	}
	
	/**
	 * [요청 2] 폼의 모든 입력 필드를 초기 상태로 되돌립니다.
	 */
	function resetForm() {
		$('#joinForm')[0].reset(); // 폼 초기화
		
		// Firebase 상태도 취소
		cancelEmailVerification(); // 이메일 인증 취소 로직 재사용
		
		// 전역 상태 변수 초기화
		isIdChecked = false; 
		isIdAvailable = false; 
		isPasswordValid = false; 
		isPasswordMatch = false; 
		isEmailChecked = false; 
		isEmailAvailable = false; 
		isEmailVerified = false; 
		
		// 메시지 초기화
		updateMessage('idCheckMessage', 'userId', '아이디를 입력해 주세요.', false);
		updateMessage('passwordMessage', 'password', '8자 이상, 영문 대소문자, 숫자, 특수문자를 모두 포함해야 합니다.', false);
		updateMessage('passwordConfirmMessage', 'passwordConfirm', '비밀번호가 일치해야 합니다.', false);
		updateMessage('emailMessage', 'email', '유효한 이메일을 입력하면 인증 요청 버튼이 활성화됩니다.', false);
		
		// UI 초기화
		$('#userId').removeClass('is-error');
		$('#password').removeClass('is-error');
		$('#passwordConfirm').removeClass('is-error');
		$('#email').removeClass('is-error');

		// 최종 검사
		checkAllValidity();
	}
	
	/**
	 * [요청 3] 회원가입을 취소하고 로그인 페이지로 이동합니다.
	 */
	function cancelJoin() {
		// 회원가입 페이지를 떠나기 전에 Firebase 임시 계정 정리
		cancelEmailVerification();
		
		// 로그인 페이지로 이동
		window.location.href = '${pageContext.request.contextPath}/users/login';
	}


	// ----------------------------------------------------
	// 7. 이벤트 리스너 및 초기화
	// ----------------------------------------------------
	
	// 폼 제출 시 최종 유효성 검사
	$('#joinForm').on('submit', function(e) {
		
		if (!validateForm()) {
			e.preventDefault();
			
			console.error('폼 제출 실패: 필수 조건 미충족');
			
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
		
		if (authCheckInterval) {
			clearInterval(authCheckInterval);
			authCheckInterval = null; 
		}
	});
	
	// '인증 취소' 버튼 클릭 이벤트 연결
	$('#cancelEmailBtn').on('click', cancelEmailVerification);
	
	// '입력 초기화' 버튼 클릭 이벤트 연결
	$('#resetBtn').on('click', resetForm);
	
	// '가입 취소' 버튼 클릭 이벤트 연결
	$('#cancelJoinBtn').on('click', cancelJoin);
	
	// 폼 제출 시 최종 유효성 검사 함수
    function validateForm() {
        return isIdChecked && isIdAvailable && 
               isPasswordValid && isPasswordMatch && 
               isEmailChecked && isEmailAvailable && isEmailVerified;
    }

	// 페이지 로드 시 초기화
	$(function() {
		validatePassword();
		validatePasswordConfirm();
		checkAllValidity();
	});

</script>
</body>
</html>