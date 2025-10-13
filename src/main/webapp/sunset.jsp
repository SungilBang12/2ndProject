<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>노을 맛집 - 노을 게시판</title>

<!-- 기존 전역 스타일 -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
<!-- 카드 그리드 전용 스타일 -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/post-grid.css?v=2">

<link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">
</head>

<%-- DEV ONLY: DB 미연결 시 목데이터 --%>
<%
if (request.getAttribute("posts") == null) {
  java.util.List<java.util.Map<String,Object>> mock = new java.util.ArrayList<>();
  for (int i = 1; i <= 28; i++) { // 페이지네이션 테스트용으로 28개
    java.util.Map<String,Object> m = new java.util.HashMap<>();
    m.put("id", i);
    m.put("title", "노을 맛집 테스트 " + i);
    m.put("coverImageUrl", "https://picsum.photos/seed/sunset"+i+"/800/534");
    mock.add(m);
  }
  request.setAttribute("posts", mock);
}
%>

<%-- 페이지네이션 계산 (정수 계산을 위해 스크립틀릿 사용) --%>
<%
java.util.List<java.util.Map<String,Object>> postsList =
    (java.util.List<java.util.Map<String,Object>>) request.getAttribute("posts");

int pageSize = 6;
int total = (postsList != null) ? postsList.size() : 0;
int totalPages = (total == 0) ? 0 : ((total + pageSize - 1) / pageSize);

int pageNo = 1;
try {
  String p = request.getParameter("page");
  if (p != null && p.matches("\\d+")) pageNo = Integer.parseInt(p);
} catch (Exception ignore) {}

if (pageNo < 1) pageNo = 1;
if (totalPages > 0 && pageNo > totalPages) pageNo = totalPages;

int begin = (pageNo - 1) * pageSize;
int end   = Math.min(begin + pageSize, total) - 1;

int blockSize  = 10;
int blockStart = ((pageNo - 1) / blockSize) * blockSize + 1;
int blockEnd   = (totalPages == 0) ? 0 : Math.min(blockStart + blockSize - 1, totalPages);

boolean hasPrev      = (pageNo > 1);
boolean hasNext      = (totalPages > 0 && pageNo < totalPages);
boolean hasPrevBlock = (blockStart > 1);
boolean hasNextBlock = (blockEnd < totalPages);

int prevPage      = Math.max(1, pageNo - 1);
int nextPage      = (totalPages == 0) ? 1 : Math.min(totalPages, pageNo + 1);
int prevBlockPage = Math.max(1, blockStart - 1);
int nextBlockPage = (totalPages == 0) ? 1 : Math.min(totalPages, blockEnd + 1);

String ctx  = request.getContextPath();   // 예: /myapp
String self = request.getRequestURI();    // 예: /myapp/board/sunset
if (self.startsWith(ctx)) {
  self = self.substring(ctx.length());    // 예: /board/sunset
}

/* 뷰에서 쓸 값 바인딩 */
request.setAttribute("pageSize", pageSize);
request.setAttribute("total", total);
request.setAttribute("totalPages", totalPages);
request.setAttribute("pageNo", pageNo);
request.setAttribute("begin", begin);
request.setAttribute("end", end);
request.setAttribute("blockStart", blockStart);
request.setAttribute("blockEnd", blockEnd);
request.setAttribute("hasPrev", hasPrev);
request.setAttribute("hasNext", hasNext);
request.setAttribute("hasPrevBlock", hasPrevBlock);
request.setAttribute("hasNextBlock", hasNextBlock);
request.setAttribute("prevPage", prevPage);
request.setAttribute("nextPage", nextPage);
request.setAttribute("prevBlockPage", prevBlockPage);
request.setAttribute("nextBlockPage", nextBlockPage);
request.setAttribute("self", self);
%>


<body>
<jsp:include page="/WEB-INF/include/header.jsp" />

<main class="main grid-14x5">
  <!-- 좌측 1열: nav(그리드 안) -->
  <div class="slot-nav">
    <jsp:include page="/WEB-INF/include/nav.jsp">
      <jsp:param name="openAcc" value="acc-sunset"/>
    </jsp:include>
  </div>

  <!-- 메인 보드 영역 -->
  <div id="board" class="slot-board">
  	<div class="pg-scope"><!-- ★ 스코프 추가 -->
    	<div class="pg-toolbar">
      		<h1 class="pg-h1">노을 게시판</h1>
      		<a class="pg-write-btn" href="${pageContext.request.contextPath}/post/write">글쓰기</a>
  		</div>

    <c:choose>
      <c:when test="${total > 0}">
        <!-- 게시글 카드 6개만 슬라이스 -->
        <section class="pg-grid">
          <c:forEach var="post" items="${posts}" begin="${begin}" end="${end}">
            <c:url var="postUrl" value="/post/view">
              <c:param name="id" value="${post.id}" />
            </c:url>

            <article class="pg-card">
              <a class="pg-thumb" href="${postUrl}" aria-label="${fn:escapeXml(post.title)}">
                <c:choose>
                  <c:when test="${not empty post.coverImageUrl}">
                    <img src="${fn:escapeXml(post.coverImageUrl)}"
                         alt="${fn:escapeXml(post.title)}"
                         loading="lazy" decoding="async" class="pg-img"/>
                  </c:when>
                  <c:otherwise>
                    <div class="pg-img pg-img--ph" role="img" aria-label="No image"></div>
                  </c:otherwise>
                </c:choose>
              </a>
              <h3 class="pg-title">
                <a href="${postUrl}">${fn:escapeXml(post.title)}</a>
              </h3>
            </article>
          </c:forEach>
        </section>

        <!-- 페이지네이션 -->
        <nav class="pg-pagination" aria-label="게시물 페이지네이션">
          <ul class="pg-pages">

            <!-- 이전 -->
            <li class="pg-prev ${hasPrev ? '' : 'is-disabled'}">
              <c:choose>
                <c:when test="${hasPrev}">
                  <c:url var="prevUrl" value="${self}"><c:param name="page" value="${prevPage}"/></c:url>
                  <a href="${prevUrl}" aria-label="이전 페이지">이전</a>
                </c:when>
                <c:otherwise><span aria-disabled="true">이전</span></c:otherwise>
              </c:choose>
            </li>

            <!-- 이전 10 -->
            <c:if test="${hasPrevBlock}">
              <li class="pg-prev-block">
                <c:url var="prevBlockUrl" value="${self}"><c:param name="page" value="${prevBlockPage}"/></c:url>
                <a href="${prevBlockUrl}" aria-label="이전 10페이지">« 10</a>
              </li>
            </c:if>

            <!-- 1~10 페이지 블록 -->
            <c:forEach var="p" begin="${blockStart}" end="${blockEnd}">
              <li class="${p == page ? 'is-active' : ''}">
                <c:choose>
                  <c:when test="${p == page}">
                    <span aria-current="page">${p}</span>
                  </c:when>
                  <c:otherwise>
                    <c:url var="pageUrl" value="${self}"><c:param name="page" value="${p}"/></c:url>
                    <a href="${pageUrl}">${p}</a>
                  </c:otherwise>
                </c:choose>
              </li>
            </c:forEach>

            <!-- 다음 10 -->
            <c:if test="${hasNextBlock}">
              <li class="pg-next-block">
                <c:url var="nextBlockUrl" value="${self}"><c:param name="page" value="${nextBlockPage}"/></c:url>
                <a href="${nextBlockUrl}" aria-label="다음 10페이지">10 »</a>
              </li>
            </c:if>

            <!-- 다음 -->
            <li class="pg-next ${hasNext ? '' : 'is-disabled'}">
              <c:choose>
                <c:when test="${hasNext}">
                  <c:url var="nextUrl" value="${self}"><c:param name="page" value="${nextPage}"/></c:url>
                  <a href="${nextUrl}" aria-label="다음 페이지">다음</a>
                </c:when>
                <c:otherwise><span aria-disabled="true">다음</span></c:otherwise>
              </c:choose>
            </li>

          </ul>
        </nav>
      </c:when>

      <c:otherwise>
        <!-- 빈 상태 -->
        <div class="pg-empty">
          <p>아직 게시물이 없습니다. 첫 글을 작성해보세요!</p>
          <a class="pg-write-btn" href="${pageContext.request.contextPath}/post/write">글쓰기</a>
        </div>
      </c:otherwise>
    </c:choose>
    </div>
  </div>
</main>
</body>
</html>
