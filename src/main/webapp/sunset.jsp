<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.PostDao" %>
<%@ page import="dto.Post" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>노을 맛집 - 노을 앨범</title>

  <link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=5" />
  <link rel="stylesheet" href="<c:url value='/css/post-grid.css'/>?v=1" />
  <link rel="icon" href="<c:url value='/images/favicon.ico'/>?v=1">
</head>
<body>

<jsp:include page="/WEB-INF/include/header.jsp" />

<main class="main grid-14x5">
  <!-- 좌측 2칸: 사이드바 -->
  <div class="slot-nav">
    <jsp:include page="/WEB-INF/include/nav.jsp">
      <jsp:param name="openAcc" value="acc-sunset"/>
    </jsp:include>
  </div>

  <!-- 가운데 10칸: 보드 -->
  <div id="board" class="slot-board">
      <div class="board-head" style="display:flex; align-items:center; gap:12px; margin-bottom:12px;">
        <h1 style="margin:0; font-size:20px; font-weight:700;">노을 앨범</h1>
        <div style="margin-left:auto;">
          <a href="<c:url value='ssp.post'/>"
             class="btn-primary"
             style="display:inline-flex; align-items:center; gap:8px; padding:8px 12px; border-radius:8px;
                    background:#9A5ABF; color:#fff; text-decoration:none; font-weight:600;">
            글쓰기
          </a>
        </div>
      </div>
      <div style="padding:24px;border:1px dashed #e5e7eb;border-radius:12px;background:#fafafa;">
        목록을 불러오는 중 오류가 발생했습니다.
      </div>
  </div>

  <!-- 우측 2칸 -->
  <div class="slot-extra"></div>
</main>

</body>
</html>