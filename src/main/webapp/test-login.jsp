<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.Users" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>테스트 로그인</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 400px;
            margin: 50px auto;
            padding: 20px;
        }
        .login-box {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        button {
            width: 100%;
            padding: 12px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        button:hover {
            background-color: #0056b3;
        }
        .current-session {
            margin-top: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 4px;
        }
        .logout-btn {
            background-color: #dc3545;
            margin-top: 10px;
        }
        .logout-btn:hover {
            background-color: #c82333;
        }
        .quick-login {
            margin-top: 20px;
        }
        .quick-login button {
            margin-top: 5px;
            background-color: #28a745;
        }
        .quick-login button:hover {
            background-color: #218838;
        }
        .admin-btn {
            background-color: #ffc107 !important;
        }
        .admin-btn:hover {
            background-color: #e0a800 !important;
        }
        .role-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            margin-left: 8px;
        }
        .role-user {
            background-color: #28a745;
            color: white;
        }
        .role-admin {
            background-color: #ffc107;
            color: #333;
        }
    </style>
</head>
<body>
    <div class="login-box">
        <h2>🔐 테스트 로그인</h2>
        
        <!-- 현재 세션 정보 표시 -->
        <%
            Users user = (Users) session.getAttribute("user");
            if (user != null) {
        %>
        <div class="current-session">
            <strong>현재 로그인:</strong> <%= user.getUserId() %>
            <% if ("ADMIN".equalsIgnoreCase(user.getROLE())) { %>
                <span class="role-badge role-admin">ADMIN</span>
            <% } else { %>
                <span class="role-badge role-user">USER</span>
            <% } %>
        </div>
        <% } else { %>
        <div class="current-session">
            <strong>로그인 상태:</strong> 로그아웃
        </div>
        <% } %>
        
        <!-- 로그인 폼 -->
        <form method="post" action="test-login.jsp">
            <div class="form-group">
                <label for="userId">사용자 ID:</label>
                <input type="text" id="userId" name="userId" placeholder="user001" required>
            </div>
            <div class="form-group">
                <label for="role">권한 선택:</label>
                <select id="role" name="role" required>
                    <option value="USER">USER (일반 사용자)</option>
                    <option value="ADMIN">ADMIN (관리자)</option>
                </select>
            </div>
            <button type="submit">로그인</button>
        </form>
        
        <!-- 빠른 로그인 버튼 -->
        <div class="quick-login">
            <p><strong>빠른 로그인:</strong></p>
            <form method="post" action="test-login.jsp" style="display:inline;">
                <input type="hidden" name="userId" value="user001">
                <input type="hidden" name="role" value="USER">
                <button type="submit">user001 (USER)</button>
            </form>
            <form method="post" action="test-login.jsp" style="display:inline;">
                <input type="hidden" name="userId" value="user002">
                <input type="hidden" name="role" value="ADMIN">
                <button type="submit" class="admin-btn">user002 (ADMIN)</button>
            </form>
        </div>
        
        <!-- 로그아웃 버튼 -->
        <% if (user != null) { %>
        <form method="post" action="test-login.jsp">
            <input type="hidden" name="action" value="logout">
            <button type="submit" class="logout-btn">로그아웃</button>
        </form>
        <% } %>
    </div>
    
    <%
        // 로그인 처리
        String action = request.getParameter("action");
        String userId = request.getParameter("userId");
        String role = request.getParameter("role");
        
        if ("logout".equals(action)) {
            session.invalidate();
            response.sendRedirect("test-login.jsp");
        } else if (userId != null && !userId.trim().isEmpty() && role != null && !role.trim().isEmpty()) {
            // ★ Users 객체 생성 및 세션에 저장
            Users user = new Users();
            user.setUserId(userId.trim());
            user.setROLE(role.trim().toUpperCase()); // ROLE을 대문자로 설정
            
            // ★ EncodingFilter가 확인하는 세션 키 이름: "user"
            session.setAttribute("user", user);
            
            // 기존 호환성을 위해 userId도 저장 (선택사항)
            session.setAttribute("userId", userId.trim());
            
            out.println("<script>alert('로그인 성공\\nID: " + userId + "\\nROLE: " + role + "'); location.href='test-login.jsp';</script>");
        }
    %>
</body>
</html>