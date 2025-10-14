<%@page import="java.sql.Connection"%>
<%@page import="javax.sql.DataSource"%>
<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.naming.Context"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>노을 맛집 - 이메일 인증</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
<link rel="stylesheet" href="./css/post-create-edit.css" />
<link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">

<style>
    .email-auth-container {
        max-width: 500px;
        margin: 50px auto;
        padding: 30px;
        background: white;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .email-auth-container h1 {
        text-align: center;
        color: #333;
        margin-bottom: 30px;
    }
    .email-auth-container form {
        display: flex;
        flex-direction: column;
        gap: 15px;
    }
    .email-auth-container input[type="email"] {
        padding: 12px;
        font-size: 16px;
        border: 1px solid #ddd;
        border-radius: 4px;
        transition: border-color 0.3s;
    }
    .email-auth-container input[type="email"]:focus {
        outline: none;
        border-color: #3498db;
    }
    .email-auth-container button {
        padding: 12px;
        font-size: 16px;
        background: #3498db;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: background 0.3s;
    }
    .email-auth-container button:hover {
        background: #2980b9;
    }
    .email-auth-container button:disabled {
        background: #95a5a6;
        cursor: not-allowed;
    }
    #message {
        padding: 12px;
        border-radius: 4px;
        text-align: center;
        margin-top: 15px;
        display: none;
    }
    #message.success {
        background: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
        display: block;
    }
    #message.error {
        background: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
        display: block;
    }
    .info-text {
        font-size: 14px;
        color: #666;
        text-align: center;
        margin-top: 20px;
        line-height: 1.6;
    }
    .spinner {
        display: inline-block;
        width: 16px;
        height: 16px;
        border: 2px solid #ffffff;
        border-top: 2px solid transparent;
        border-radius: 50%;
        animation: spin 0.8s linear infinite;
        margin-left: 8px;
        vertical-align: middle;
    }
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
</style>
</head>

<body>
<jsp:include page="/WEB-INF/include/header.jsp" />
<main class="main grid-14x5">
    <div class="slot-nav">
        <jsp:include page="/WEB-INF/include/nav.jsp">
            <jsp:param name="openAcc" value="acc-equipment"/>
        </jsp:include>
    </div>

    <div class="slot-board">
        <div class="email-auth-container">
            <h1>이메일 인증</h1>
            <form id="emailForm">
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    placeholder="이메일을 입력하세요" 
                    required
                    autocomplete="email">
                <button type="submit" id="submitBtn">
                    <span id="btnText">인증 링크 전송</span>
                </button>
            </form>
            <div id="message"></div>
            <div class="info-text">
                입력하신 이메일 주소로 인증 링크가 전송됩니다.<br>
                이메일을 확인하고 링크를 클릭하여 인증을 완료해주세요.
            </div>
        </div>
    </div>
</main>

<!-- Firebase SDK -->
<script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
    import { getAuth, sendSignInLinkToEmail } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js";

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

    // 이메일 링크 설정 - email-login.jsp로 리다이렉트
    const actionCodeSettings = {
    url: window.location.origin + '${pageContext.request.contextPath}' + '/email-login-check.jsp',
    handleCodeInApp: true
};

    // 폼 요소들
    const emailForm = document.getElementById('emailForm');
    const emailInput = document.getElementById('email');
    const submitBtn = document.getElementById('submitBtn');
    const btnText = document.getElementById('btnText');
    const messageDiv = document.getElementById('message');

    // 폼 제출 이벤트 처리
    emailForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const email = emailInput.value.trim();

        // 버튼 비활성화 및 로딩 표시
        submitBtn.disabled = true;
        btnText.innerHTML = '전송 중<span class="spinner"></span>';
        messageDiv.style.display = 'none';
        messageDiv.className = '';

        try {
            // Firebase로 인증 링크 전송
            await sendSignInLinkToEmail(auth, email, actionCodeSettings);

            // 이메일을 로컬 스토리지에 저장 (email-login.jsp에서 사용)
            window.localStorage.setItem('emailForSignIn', email);

            // 성공 메시지 표시
            messageDiv.className = 'success';
            messageDiv.textContent = '✅ 인증 링크가 이메일로 전송되었습니다! 이메일을 확인해주세요.';
            
            // 폼 초기화
            emailForm.reset();

        } catch (error) {
            // 에러 메시지 표시
            messageDiv.className = 'error';
            
            // 에러 타입별 메시지
            switch(error.code) {
                case 'auth/invalid-email':
                    messageDiv.textContent = '❌ 유효하지 않은 이메일 주소입니다.';
                    break;
                case 'auth/missing-email':
                    messageDiv.textContent = '❌ 이메일 주소를 입력해주세요.';
                    break;
                case 'auth/unauthorized-domain':
                    messageDiv.textContent = '❌ 이 도메인은 인증되지 않았습니다. Firebase 콘솔에서 도메인을 추가해주세요.';
                    break;
                case 'auth/operation-not-allowed':
                    messageDiv.textContent = '❌ 이메일 링크 로그인이 활성화되지 않았습니다. Firebase 콘솔을 확인해주세요.';
                    break;
                default:
                    messageDiv.textContent = '❌ 오류 발생: ' + error.message;
            }
            
            console.error('이메일 전송 오류:', error);
        } finally {
            // 버튼 활성화
            submitBtn.disabled = false;
            btnText.textContent = '인증 링크 전송';
        }
    });

    // 페이지 로드 시 이미 로그인되어 있는지 확인
    auth.onAuthStateChanged((user) => {
        if (user) {
            // 이미 로그인된 상태
            console.log('이미 로그인됨:', user.email);
            messageDiv.className = 'success';
            messageDiv.textContent = '✅ 이미 로그인되어 있습니다: ' + user.email;
            emailInput.disabled = true;
            submitBtn.disabled = true;
        }
    });
</script>
</body>
</html>