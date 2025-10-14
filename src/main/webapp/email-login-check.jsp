<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>회원가입</title>
<link rel="stylesheet" href='/css/form-style.css' />
<link rel="stylesheet" href='/css/users.css' />
<!-- jQuery for AJAX -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- Firebase SDK -->
<script
	src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script
	src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
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

				<!-- 이메일 인증 상태에 따라 UI를 변경할 메인 폼 컨테이너 -->
				<div id="joinFormContainer">
					<form action="join" method="post" id="joinForm">

						<!-- 1. 아이디 입력 및 비동기 중복 확인 -->
						<div class="form-group" id="userIdGroup">
							<label for="userId" class="form-label">아이디</label>
							<div class="form-input-container">
								<input type="text" id="userId" name="userId" class="form-input"
									placeholder="아이디 입력" required> <span
									class="input-icon clear-icon"
									onclick="document.getElementById('userId').value=''; checkIdAvailability();">
									<svg xmlns="http://www.w3.org/2000/svg" fill="none"
										viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
<path stroke-linecap="round" stroke-linejoin="round"
											d="M6 18L18 6M6 6l12 12" />
</svg>
								</span>
							</div>
							<p id="idCheckMessage" class="message"></p>
						</div>

						<!-- 2. 사용자 이름 -->
						<div class="form-group">
							<label for="username" class="form-label">이름</label> <input
								type="text" id="username" name="username" class="form-input"
								placeholder="이름 입력" required>
						</div>

						<!-- 3. 비밀번호 입력 및 확인 -->
						<div class="form-group" id="passwordGroup">
							<label for="password" class="form-label">비밀번호</label> <input
								type="password" id="password" name="password" class="form-input"
								placeholder="비밀번호 (8자 이상, 영문, 숫자, 특수문자 포함)" required>
							<p id="passwordMessage" class="message"></p>
						</div>
						<div class="form-group" id="passwordCheckGroup">
							<label for="passwordCheck" class="form-label">비밀번호 확인</label> <input
								type="password" id="passwordCheck" name="passwordCheck"
								class="form-input" placeholder="비밀번호 확인" required>
							<p id="passwordCheckMessage" class="message"></p>
						</div>

						<!-- 4. 이메일 입력 (서버 제출 필드는 hidden으로 유지하고, Firebase 인증 이메일만 사용) -->
						<input type="hidden" name="email" id="hiddenEmail">

						<!-- 5. 최종 제출 버튼 -->
						<button type="submit" id="submitBtn" class="button primary"
							disabled>회원가입</button>
					</form>

					<!-- 6. 이메일 인증 섹션 (회원가입 버튼 대신 먼저 활성화) -->
					<div class="divider">
						<span>AND</span>
					</div>
					<div class="form-group" id="emailAuthGroup">
						<label for="email" class="form-label">이메일 인증</label>
						<div class="form-input-container">
							<input type="email" id="email" class="form-input"
								placeholder="이메일 입력 (인증용)" required>
							<button type="button" id="sendLinkBtn"
								class="button secondary small">인증 링크 전송</button>
						</div>
						<p id="emailMessage" class="message"></p>
					</div>
				</div>

				<!-- 이메일 전송 후 표시될 대기 메시지 -->
				<div id="pendingMessage" class="info-card" style="display: none;">
					<h3 class="card-title">메일 전송 완료: 인증 대기 중...</h3>
					<p>
						입력하신 이메일 주소로 **인증 링크**를 전송했습니다. <span id="sentEmailDisplay"
							class="font-bold text-blue-600"></span>
					</p>
					<p>메일함을 확인하시고 링크를 클릭하여 인증을 완료해주세요.</p>
					<p class="mt-4 text-sm text-gray-500">인증이 완료되면 이 페이지가 **자동으로
						업데이트**됩니다.</p>
					<button type="button" id="resendLinkBtn"
						class="button secondary small mt-4">링크 재전송</button>
				</div>

			</div>
		</div>
		<div class="slot-aside"></div>
	</main>
	<jsp:include page="/WEB-INF/include/footer.jsp" />


	<script>
    // 🚨 시큐어 코딩 (KISA): 민감한 정보 노출 방지 위반!
    // 실제 배포 시에는 반드시 서버(Controller/JSP)에서 동적으로 값을 주입해야 합니다.
    const firebaseConfig = {
    		//이메일 인증 기반 로그인 구현을 위한 APP 키( 현재 미사용 )
    }; 
    
    // 이메일 인증 확인 완료 여부
    let isEmailVerified = false;
    let isIdChecked = false;
    let isIdAvailable = false;
    let isPasswordValid = false;
    let currentEmailForVerification = '';

    // Firebase 초기화
    const app = firebase.initializeApp(firebaseConfig);
    const auth = app.auth();

    // ----------------------------------------------------
    // Firebase 이메일 링크 설정
    // ----------------------------------------------------
    const actionCodeSettings = {
        // 인증 성공 후 이동할 페이지
        url: '${pageContext.request.contextPath}/email-login-check.jsp', 
        handleCodeInApp: true,
    };

    // ID 중복 확인 (기존 AJAX)
    function checkIdAvailability() {
        const userId = $('#userId').val().trim();
        const msgElement = $('#idCheckMessage');
        const inputElement = $('#userId');
        
        // 🚨 시큐어 코딩: 클라이언트 측 입력값 제한
        if (userId.length < 5) {
            msgElement.text('아이디는 5자 이상이어야 합니다.').css('color', 'var(--error-color)');
            inputElement.addClass('is-error');
            isIdChecked = false;
            checkAllValidity();
            return;
        }

        $.ajax({
            url: 'ajax/checkId',
            type: 'GET', // UsersAjaxController에서 GET으로 처리하도록 변경됨
            data: { userId: userId },
            dataType: 'json',
            success: function(response) {
                isIdChecked = true;
                // UsersAjaxController에서 'exists'를 반환함
                isIdAvailable = !response.exists; 
                
                if (isIdAvailable) {
                    msgElement.text('사용 가능한 아이디입니다.').css('color', 'green');
                    inputElement.removeClass('is-error');
                } else {
                    msgElement.text('이미 존재하는 아이디입니다.').css('color', 'var(--error-color)');
                    inputElement.addClass('is-error');
                }
                checkAllValidity();
            },
            error: function() {
                msgElement.text('ID 체크 중 오류 발생. 다시 시도해 주세요.');
                inputElement.addClass('is-error');
                isIdChecked = false;
                isIdAvailable = false;
                checkAllValidity();
            }
        });
    }

    // 비밀번호 유효성 검사 및 일치 확인
    function checkPassword() {
        const password = $('#password').val();
        const passwordCheck = $('#passwordCheck').val();
        const pwMsg = $('#passwordMessage');
        const pwCheckMsg = $('#passwordCheckMessage');
        // 8자 이상, 영문, 숫자, 특수문자 포함
        const passwordRegex = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]).{8,}$/;
        
        isPasswordValid = false;

        if (!passwordRegex.test(password)) {
            pwMsg.text('비밀번호는 8자 이상, 영문, 숫자, 특수문자를 포함해야 합니다.').css('color', 'var(--error-color)');
            $('#password').addClass('is-error');
        } else {
            pwMsg.text('유효한 형식입니다.').css('color', 'green');
            $('#password').removeClass('is-error');
            isPasswordValid = true;
        }

        // 비밀번호 확인
        if (password && passwordCheck) {
            if (password === passwordCheck) {
                pwCheckMsg.text('비밀번호가 일치합니다.').css('color', 'green');
                $('#passwordCheck').removeClass('is-error');
            } else {
                pwCheckMsg.text('비밀번호가 일치하지 않습니다.').css('color', 'var(--error-color)');
                $('#passwordCheck').addClass('is-error');
                isPasswordValid = false; 
            }
        } else {
            pwCheckMsg.text('');
        }
        
        checkAllValidity();
    }
    
    function checkAllValidity() {
        const isFormValid = isIdChecked && isIdAvailable && isPasswordValid && isEmailVerified;
        $('#submitBtn').prop('disabled', !isFormValid);
    }
    // ----------------------------------------------------
    // Firebase 이메일 인증 로직
    // ----------------------------------------------------
    
    /**
     * 이메일 인증 링크 전송 처리
     * @param {string} email 전송할 이메일 주소
     */
    async function sendVerificationLink(email) {
        const btn = $('#sendLinkBtn');
        const msgElement = $('#emailMessage');
        
        // 클라이언트 측 이메일 형식 검사
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            msgElement.html('❌ 유효한 이메일 주소를 입력해주세요.').css('color', 'var(--error-color)');
            return;
        }

        btn.prop('disabled', true).text('전송 중...');
        msgElement.html('링크 전송 중입니다. 잠시만 기다려 주세요...');

        try {
            // 1. Firebase 인증 링크 전송
            await auth.sendSignInLinkToEmail(email, actionCodeSettings);

            // 2. 이메일 정보를 **LocalStorage**에 저장 (새 탭에서 접근하기 위해 필요)
            window.localStorage.setItem('emailForSignIn', email);
            currentEmailForVerification = email;
            
            // 3. UI 업데이트: 대기 메시지 표시 및 폼 숨김
            $('#joinFormContainer').hide();
            $('#sentEmailDisplay').text(email);
            $('#pendingMessage').show();
            msgElement.html('').css('color', ''); // 이전 메시지 정리
            
            // 4. 서버 제출용 hidden 필드에 이메일 저장
            $('#hiddenEmail').val(email);
            
            // 링크 재전송 버튼 활성화
            $('#resendLinkBtn').prop('disabled', false).text('링크 재전송');


        } catch (error) {
            // 🚨 시큐어 코딩: alert() 대신 메시지 표시 및 콘솔 로깅 (KISA: 사용자 인터페이스 통제)
            let errorMessage = '❌ 인증 링크 전송 실패: ' + error.message;
            if (error.code === 'auth/invalid-email') {
                errorMessage = '❌ 유효하지 않은 이메일 주소입니다.';
            } else if (error.code === 'auth/operation-not-allowed') {
                 errorMessage = '❌ 이메일 링크 로그인이 활성화되지 않았습니다. Firebase 콘솔을 확인해주세요.';
            }

            msgElement.html(errorMessage).css('color', 'var(--error-color)');
            console.error('인증 링크 전송 오류:', error);
            
            // 실패 시 버튼 다시 활성화
            btn.prop('disabled', false).text('인증 링크 전송');
        }
    }


    // ----------------------------------------------------
    // 페이지 로드 및 이벤트 리스너
    // ----------------------------------------------------

    $(document).ready(function() {
        // 초기 유효성 검사
        checkAllValidity();

        // 1. ID 입력 변경 및 포커스 해제 시 중복 확인
        $('#userId').on('blur', checkIdAvailability).on('input', function() {
            // ID를 변경하면 다시 중복 확인 필요
            isIdChecked = false;
            $('#idCheckMessage').text('아이디 중복 확인이 필요합니다.').css('color', 'gray');
            $('#userId').removeClass('is-error');
            checkAllValidity();
        });

        // 2. 비밀번호 입력 변경 시 유효성 확인
        $('#password, #passwordCheck').on('input', checkPassword);
        
        // 3. 이메일 인증 링크 전송 버튼
        $('#sendLinkBtn').on('click', function() {
            const email = $('#email').val().trim();
            sendVerificationLink(email);
        });
        
        // 4. 링크 재전송 버튼
        $('#resendLinkBtn').on('click', function() {
            // LocalStorage에서 이메일 가져오기
            currentEmailForVerification = window.localStorage.getItem('emailForSignIn'); 
            
            if (currentEmailForVerification) {
                $('#resendLinkBtn').prop('disabled', true).text('재전송 중...');
                sendVerificationLink(currentEmailForVerification); // 저장된 이메일로 다시 전송
            }
        });


        // 5. 서버 폼 제출 처리 (최종)
        $('#joinForm').on('submit', function(e) {
            if (!isEmailVerified) {
                e.preventDefault();
                $('#emailAuthGroup').append('<p class="error-message">🚨 **이메일 인증이 완료되지 않았습니다.** 메일함을 확인하고 인증 링크를 클릭해주세요.</p>');
                checkAllValidity();
                return;
            }
            
            // 최종 유효성 검사 (ID/PW 등)
            if (!validateForm()) {
                e.preventDefault();
                $('#submitBtn').text('입력 정보를 다시 확인해 주세요.').addClass('button-error');
                setTimeout(() => {
                    $('#submitBtn').text('회원가입').removeClass('button-error');
                }, 3000);
                return;
            }
        });


        // 6. 페이지 로드 시 Firebase 인증 상태 실시간 감지
        auth.onAuthStateChanged((user) => {
            if (user && user.emailVerified) {
                const verifiedEmail = user.email;
                isEmailVerified = true;
                currentEmailForVerification = verifiedEmail;
                
                // 폼의 hidden 필드에 최종 인증된 이메일 저장
                $('#hiddenEmail').val(verifiedEmail); 
                
                // UI 업데이트: 대기 메시지를 숨기고 폼을 보여줌
                $('#pendingMessage').hide();
                $('#joinFormContainer').show();
                
                // 이메일 인증 섹션 업데이트
                $('#emailAuthGroup').html(`
                    <label class="form-label text-green-600">이메일 인증 완료</label>
                    <p class="text-sm">✅ **${verifiedEmail}** 주소의 인증이 완료되었습니다.</p>
                `).css('border', '1px solid #4CAF50').css('padding', '10px').css('border-radius', '4px');

                // 최종 유효성 재검사 및 버튼 활성화
                checkAllValidity();
                
                // 사용자에게 최종 회원가입 버튼 클릭 유도
                $('#submitBtn').focus();
            } else if (!isEmailVerified) {
                 // 이전에 이메일 전송 상태였다면 pendingMessage를 유지
                if (window.localStorage.getItem('emailForSignIn')) { // localStorage 확인
                     $('#joinFormContainer').hide();
                     $('#sentEmailDisplay').text(window.localStorage.getItem('emailForSignIn'));
                     $('#pendingMessage').show();
                }
            }
        });
        
    });
</script>
</body>
</html>
