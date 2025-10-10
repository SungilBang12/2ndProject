<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>노을 맛집 - 맛집 후기 게시판</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
<link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">
</head>
<body>
<jsp:include page="/WEB-INF/include/header.jsp" />
<main class="main grid-14x5">
  <!-- 좌측 1열: nav(그리드 안) -->
  <div class="slot-nav">
    <jsp:include page="/WEB-INF/include/nav.jsp">
    	<jsp:param name="openAcc" value="acc-sunset"/>
	</jsp:include>
  </div>
  <div id="board" class="slot-board">
     <h1>맛집 후기 게시판</h1>
 	 <p>맛집 후기 관련 글 목록…</p>
  </div>
</main>
</body>
</html>