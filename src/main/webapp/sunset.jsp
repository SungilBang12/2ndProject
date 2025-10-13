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

  <!-- 기본 스타일 -->
  <link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=5" />
  <!-- 카드형(앨범) 보드용 -->
  <link rel="stylesheet" href="<c:url value='/css/post-grid.css'/>?v=1" />
  <link rel="icon" href="<c:url value='/images/favicon.ico'/>?v=1">
</head>
<body>

<jsp:include page="/WEB-INF/include/header.jsp" />

<main class="main grid-14x5">
  <!-- 좌측 2칸: 사이드바(그리드 안) -->
  <div class="slot-nav">
    <jsp:include page="/WEB-INF/include/nav.jsp">
      <jsp:param name="openAcc" value="acc-sunset"/>
    </jsp:include>
  </div>

  <!-- 가운데 10칸: 보드 -->
  <div id="board" class="slot-board">
    <!-- ✅ 서버 사이드 인클lude: AjaxController의 /SunsetList.async 가 부분뷰로 forward -->
    <c:import url="/SunsetList.async">
  		<c:param name="pageno" value="${empty param.pageno ? '1' : param.pageno}" />
	</c:import>

    <%-- (선택) 아래는 안전망용 폴백. 컨트롤러가 posts 안 주면 최소 레이아웃만 유지 --%>
    <%
      @SuppressWarnings("unchecked")
      List<Post> posts = (List<Post>) request.getAttribute("posts");
      if (posts == null) {
        try {
          PostDao dao = new PostDao();
          posts = dao.getAllPosts();
        } catch (Exception e) {
          posts = new ArrayList<>();
        }
      }
      request.setAttribute("posts", posts);
    %>

    <!-- 보드 헤더: 제목 + 글쓰기 -->
    <div class="board-head" style="display:flex; align-items:center; gap:12px; margin-bottom:12px;">
      <h1 style="margin:0; font-size:20px; font-weight:700;">노을 앨범</h1>

      <div style="margin-left:auto;">
        <a href="<c:url value='/post/write?sunset=1'/>"
           class="btn-primary"
           style="display:inline-flex; align-items:center; gap:8px; padding:8px 12px; border-radius:8px;
                  background:#9A5ABF; color:#fff; text-decoration:none; font-weight:600;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="#fff" aria-hidden="true">
            <path d="M3 17.25V21h3.75l11.06-11.06-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02
                     0-1.41l-2.34-2.34a.9959.9959 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
          </svg>
          글쓰기
        </a>
      </div>
    </div>

    <!-- 앨범 그리드 (폴백) -->
    <c:choose>
      <c:when test="${empty posts}">
        <div style="padding:24px;border:1px dashed #e5e7eb;border-radius:12px;background:#fafafa;">
          노을 앨범에 게시물이 없습니다.
        </div>
      </c:when>
      <c:otherwise>
        <ul class="post-grid">
          <c:forEach var="p" items="${posts}">
            <li class="post-card">
              <a class="post-card__link" href="<c:out value='${p.link != null ? p.link : "#"}'/>">
                <div class="post-card__thumb">
                  <img src="<c:url value='/images/favicon.svg'/>" alt="썸네일" loading="lazy" />
                </div>
                <div class="post-card__meta">
                  <div class="post-card__title">
                    <c:out value="${p.title != null ? p.title : '제목 없음'}"/>
                  </div>
                  <div class="post-card__date">
                    <c:out value="${p.createdAt != null ? p.createdAt : ''}"/>
                  </div>
                </div>
              </a>
            </li>
          </c:forEach>
        </ul>
      </c:otherwise>
    </c:choose>

  </div>

  <!-- 우측 2칸 -->
  <div class="slot-extra"><!-- 비움 --></div>
</main>

</body>
</html>
