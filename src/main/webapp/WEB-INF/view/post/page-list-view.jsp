<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=6">
  <link rel="stylesheet" href="<c:url value='/css/post-list.css'/>?v=2">
<title>게시판 목록</title>
</head>

<body>
<jsp:include page="/WEB-INF/include/header.jsp" />

<main class="main grid-14x5">
<div class="slot-nav">
<jsp:include page="/WEB-INF/include/nav.jsp" />
</div>

<div class="slot-board">
<jsp:include page="/WEB-INF/include/post-list-view.jsp"></jsp:include>
</div>

<div class="slot-extra">
<!-- 추가 기능 영역 -->
<jsp:include page="/WEB-INF/include/chat.jsp"></jsp:include>

</div>
</main>
</body>
</html>