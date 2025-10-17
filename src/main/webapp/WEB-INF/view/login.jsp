<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>로그인</title>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

  <style>
  @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700&display=swap');

  /* ✅ 헤더 공간 제거 */
  html[data-fixed-header] body::before,
  body::before { display:none !important; height:0 !important; content:none !important; }
  html[data-fixed-header]{ scroll-padding-top:0 !important; }

  body {
    background: linear-gradient(to bottom, #0f0d0c, #1a1614);
    color: #fff;
    font-family: 'Noto Sans KR', sans-serif;
    margin: 0;
    padding: 0;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }

  main {
    flex: 1;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 40px 16px;
  }

  /* 로그인 카드 */
  .form-card {
    background: linear-gradient(145deg, rgba(30,24,22,0.85), rgba(20,16,14,0.85));
    border: 1px solid rgba(255,139,122,0.25);
    border-radius: 20px;
    padding: 48px 40px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.4);
    backdrop-filter: blur(8px);
    max-width: 400px;
    width: 100%;
  }

  .form-card h1 {
    text-align: center;
    color: #FB9062;
    font-size: 1.8rem;
    margin-bottom: 32px;
    font-weight: 700;
    letter-spacing: -0.02em;
  }

  .form-group {
    margin-bottom: 24px;
    position: relative;
  }

  .form-label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    font-size: 0.95rem;
    color: rgba(255,255,255,0.8);
  }

  .form-input-container {
    position: relative;
  }

  .form-input {
    width: 100%;
    padding: 12px 44px 12px 14px;
    border-radius: 10px;
    border: 1px solid rgba(255,139,122,0.25);
    background: rgba(255,255,255,0.05);
    color: #fff;
    font-size: 1rem;
    transition: border-color .25s, box-shadow .25s;
  }

  .form-input:focus {
    border-color: rgba(255,139,122,0.5);
    box-shadow: 0 0 8px rgba(255,139,122,0.3);
    outline: none;
  }

  .form-input.is-error {
    border-color: #EE5D6C;
    box-shadow: 0 0 8px rgba(238,93,108,0.4);
  }

  /* 아이콘 */
  .input-icon {
    position: absolute;
    top: 50%;
    right: 12px;
    transform: translateY(-50%);
    width: 22px;
    height: 22px;
    color: rgba(255,255,255,0.6);
    cursor: pointer;
  }

  .input-icon svg {
    width: 100%;
    height: 100%;
  }

  .input-icon:hover { color: #FB9062; }

  .error-message {
    color: #EE5D6C;
    font-size: 0.85rem;
    margin-top: 6px;
  }

  /* 버튼 */
  .button-container {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-top: 30px;
  }

  .btn {
    display: inline-block;
    text-align: center;
    border-radius: 10px;
    font-weight: 700;
    padding: 12px;
    cursor: pointer;
    border: none;
    font-size: 1rem;
    transition: all .25s;
  }

  .btn-primary {
    background: linear-gradient(135deg, #EE5D6C, #FB9062);
    color: #fff;
  }
  .btn-primary:hover {
    filter: brightness(1.15);
  }

  .btn-secondary {
    background: rgba(255,255,255,0.08);
    border: 1px solid rgba(255,139,122,0.25);
    color: #fff;
  }
  .btn-secondary:hover {
    background: rgba(255,139,122,0.18);
    border-color: rgba(255,139,122,0.45);
  }

  footer {
    text-align: center;
    padding: 16px 0;
    font-size: 0.9rem;
    color: rgba(255,255,255,0.45);
  }

  /* 반응형 */
  @media (max-width:480px) {
    .form-card { padding: 36px 24px; }
  }
  </style>
</head>

<body>
  <jsp:include page="/WEB-INF/include/header.jsp" />

  <main>
    <div class="form-card">
      <h1>로그인</h1>
      <form action="login" method="post">
        <div class="form-group">
          <label for="userId" class="form-label">아이디</label>
          <div class="form-input-container">
            <input type="text" id="userId" name="userId" class="form-input"
                   placeholder="아이디 입력" required autocomplete="username">
            <span class="input-icon clear-icon"
                  onclick="document.getElementById('userId').value='';">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none"
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
                   class="form-input <c:if test='${loginFailed}'>is-error</c:if>"
                   placeholder="비밀번호 입력" required autocomplete="current-password">
            <c:if test="${loginFailed}">
              <span class="input-icon error-icon">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none"
                     viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round"
                        d="M12 9v3.75m9-.75a9 9 0 11-18 0
                           9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
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
  </main>

  <footer>© 노을 맞집 커뮤니티</footer>
</body>
</html>
