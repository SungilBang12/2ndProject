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
    <title>노을 맛집 - '해'쳐 모여 게시판 작성</title>
    
    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    <link rel="stylesheet" href="./css/post-create-edit.css" />
    <link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">
    
    
    
</head>

<script>
    // Import the functions you need from the SDKs you need
        import { initializeApp } from "firebase/app";
        import { getAnalytics } from "firebase/analytics";
        // TODO: Add SDKs for Firebase products that you want to use
        // https://firebase.google.com/docs/web/setup#available-libraries

        // Your web app's Firebase configuration
        // For Firebase JS SDK v7.20.0 and later, measurementId is optional
        const firebaseConfig = {
        apiKey: "AIzaSyDQZRVGrB2Qdzlw5kuUFcIAg724WomCJJ4",
        authDomain: "secondproject-91733.firebaseapp.com",
        projectId: "secondproject-91733",
        storageBucket: "secondproject-91733.firebasestorage.app",
        messagingSenderId: "1056914003",
        appId: "1:1056914003:web:a03605f898314c6feea4a6",
        measurementId: "G-V2QTFGRD4T"
        };

        // Initialize Firebase
        const app = initializeApp(firebaseConfig);
        const analytics = getAnalytics(app);

        const actionCodeSettings = {
        // URL you want to redirect back to. The domain (www.example.com) for this
        // URL must be in the authorized domains list in the Firebase Console.
        url: 'http://localhost:8080/secondproject/email-login.jsp',
        // This must be true.
        handleCodeInApp: true,
        iOS: {
            bundleId: 'com.example.ios'
        },
        android: {
            packageName: 'com.example.android',
            installApp: true,
            minimumVersion: '12'
        },
        // The domain must be configured in Firebase Hosting and owned by the project.
        linkDomain: 'localhost:8080'
        };


        import { getAuth, sendSignInLinkToEmail } from "firebase/auth";

        const auth = getAuth();
        sendSignInLinkToEmail(auth, email, actionCodeSettings)
        .then(() => {
            // The link was successfully sent. Inform the user.
            // Save the email locally so you don't need to ask the user for it again
            // if they open the link on the same device.
            window.localStorage.setItem('emailForSignIn', email);
            // ...
        })
        .catch((error) => {
            const errorCode = error.code;
            const errorMessage = error.message;
            // ...
        });


</script>


<body>
<jsp:include page="/WEB-INF/include/header.jsp" />
<main class="main grid-14x5">
    <!-- 좌측 1열: nav(그리드 안) -->
    <div class="slot-nav">
        <jsp:include page="/WEB-INF/include/nav.jsp">
            <jsp:param name="openAcc" value="acc-equipment"/>
        </jsp:include>
    </div>
    
    <div class="slot-board">
        <div class="container">
    <form action="email-login.jsp" method="post">
        <input type="email" name="email" placeholder="Email">
        <input type="submit" value="Login">
    </form>
    </div>
        
    </div>
</main>
</body>
</html>