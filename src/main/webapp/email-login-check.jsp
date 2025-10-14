<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>노을 맛집 - 이메일 로그인 확인</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
<link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">

<style>
    .login-container {
        max-width: 600px;
        margin: 100px auto;
        padding: 40px;
        text-align: center;
        background: #f9f9f9;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .spinner {
        border: 4px solid #f3f3f3;
        border-top: 4px solid #3498db;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        animation: spin 1s linear infinite;
        margin: 20px auto;
    }
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    #message {
        margin-top: 20px;
        font-size: 16px;
    }
    .success { color: #27ae60; }
    .error { color: #e74c3c; }
    .email-input {
        margin: 20px 0;
    }
    .email-input input {
        padding: 10px;
        width: 300px;
        font-size: 14px;
        border: 1px solid #ddd;
        border-radius: 4px;
    }
    .email-input button {
        padding: 10px 20px;
        background: #3498db;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        margin-left: 10px;
    }
    .email-input button:hover {
        background: #2980b9;
    }
    .user-info {
        margin-top: 30px;
        padding: 20px;
        background: white;
        border-radius: 4px;
    }
</style>
</head>

<body>
<jsp:include page="/WEB-INF/include/header.jsp" />

<div class="login-container">
    <h1>이메일 인증 중...</h1>
    <div class="spinner" id="spinner"></div>
    <div id="message"></div>
    
    <!-- 이메일 입력 폼 (이메일이 저장되지 않았을 경우) -->
    <div id="emailInputSection" style="display: none;">
        <p>이메일을 다시 입력해주세요:</p>
        <div class="email-input">
            <input type="email" id="emailInput" placeholder="이메일 입력" required>
            <button id="confirmBtn">확인</button>
        </div>
    </div>

    <!-- 로그인 성공 시 사용자 정보 표시 -->
    <div id="userInfo" class="user-info" style="display: none;">
        <h2>로그인 성공!</h2>
        <p><strong>이메일:</strong> <span id="userEmail"></span></p>
        <p><strong>UID:</strong> <span id="userId"></span></p>
        <button onclick="location.href='${pageContext.request.contextPath}/index.jsp'" style="margin-top: 20px; padding: 10px 30px; background: #27ae60; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px;">
            메인으로 이동
        </button>
    </div>
</div>

<!-- Firebase SDK -->
<script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
    import { getAuth, isSignInWithEmailLink, signInWithEmailLink } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js";

    // Firebase 설정
    const firebaseConfig = {
  		apiKey: "AIzaSyDQZRVGrB2Qdzlw5kuUFcIAg724WomCJJ4",
        authDomain: "secondproject-91733.firebaseapp.com",
        projectId: "secondproject-91733",
        storageBucket: "secondproject-91733.firebasestorage.app",
        messagingSenderId: "1056914003",
        appId: "1:1056914003:web:a03605f898314c6feea4a6",
        measurementId: "G-V2QTFGRD4T"
    };

    // Firebase 초기화
    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);

    const messageDiv = document.getElementById('message');
    const spinner = document.getElementById('spinner');
    const emailInputSection = document.getElementById('emailInputSection');
    const userInfoSection = document.getElementById('userInfo');

    // 로그인 처리 함수
    async function completeSignIn(email) {
        try {
            // 이메일 링크로 로그인
            const result = await signInWithEmailLink(auth, email, window.location.href);
            const user = result.user;

            // 로컬 스토리지에서 이메일 제거
            window.localStorage.removeItem('emailForSignIn');

            // 성공 메시지 표시
            spinner.style.display = 'none';
            messageDiv.className = 'success';
            messageDiv.textContent = '이메일 인증이 완료되었습니다!';

            // 사용자 정보 표시
            document.getElementById('userEmail').textContent = user.email;
            document.getElementById('userId').textContent = user.uid;
            userInfoSection.style.display = 'block';

            // 여기서 서버에 사용자 정보를 저장하거나 세션을 생성할 수 있습니다
            // 예: 서버로 UID와 이메일을 전송
            saveUserToSession(user.uid, user.email);

        } catch (error) {
            spinner.style.display = 'none';
            messageDiv.className = 'error';
            
            if (error.code === 'auth/invalid-action-code') {
                messageDiv.textContent = '인증 링크가 만료되었거나 이미 사용되었습니다.';
            } else if (error.code === 'auth/invalid-email') {
                messageDiv.textContent = '유효하지 않은 이메일 주소입니다.';
            } else {
                messageDiv.textContent = '로그인 실패: ' + error.message;
            }
            console.error('로그인 오류:', error);
        }
    }

    // 서버에 사용자 정보 저장 (AJAX)
    async function saveUserToSession(uid, email) {
        try {
            const response = await fetch('${pageContext.request.contextPath}/saveUserSession', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    uid: uid,
                    email: email
                })
            });

            if (response.ok) {
                console.log('세션 저장 성공');
            }
        } catch (error) {
            console.error('세션 저장 오류:', error);
        }
    }

    // 페이지 로드 시 자동 실행
    window.addEventListener('load', async () => {
        // URL이 로그인 링크인지 확인
        if (isSignInWithEmailLink(auth, window.location.href)) {
            
            // 로컬 스토리지에서 이메일 가져오기
            let email = window.localStorage.getItem('emailForSignIn');

            if (!email) {
                // 이메일이 없으면 사용자에게 입력 요청
                spinner.style.display = 'none';
                messageDiv.className = '';
                messageDiv.textContent = '인증을 완료하려면 이메일을 입력해주세요.';
                emailInputSection.style.display = 'block';
            } else {
                // 이메일이 있으면 바로 로그인 진행
                await completeSignIn(email);
            }
        } else {
            // 유효한 로그인 링크가 아님
            spinner.style.display = 'none';
            messageDiv.className = 'error';
            messageDiv.textContent = '유효하지 않은 로그인 링크입니다.';
        }
    });

    // 이메일 입력 후 확인 버튼 클릭
    document.getElementById('confirmBtn').addEventListener('click', async () => {
        const email = document.getElementById('emailInput').value.trim();
        
        if (!email) {
            alert('이메일을 입력해주세요.');
            return;
        }

        // 이메일 유효성 검사
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            alert('유효한 이메일 주소를 입력해주세요.');
            return;
        }

        emailInputSection.style.display = 'none';
        spinner.style.display = 'block';
        messageDiv.textContent = '';

        await completeSignIn(email);
    });
</script>
</body>
</html>