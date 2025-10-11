<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>노을 맛집 - 홈</title>
</head>
<body>

<jsp:include page="/WEB-INF/include/header.jsp" />
<main class="main grid-14x5">
  <div class="slot-nav">
    <jsp:include page="/WEB-INF/include/nav.jsp" />
  </div>

  <div class="slot-board">
    <h1>Home</h1>
    <p>여기는 홈입니다.</p>
  </div>

  <div class="slot-extra">
    <!-- 필요 시 우측 칼럼 -->
  </div>
</main>
</body>
</html>
