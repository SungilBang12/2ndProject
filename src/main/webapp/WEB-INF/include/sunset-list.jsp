<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>

<!-- posts(6개), pageno, pageCount, totalCount, pageSize 가 전달됨 -->
<div class="board-head" style="display:flex;align-items:center;gap:12px;margin-bottom:12px;">
  <h1 style="margin:0;font-size:20px;font-weight:700;">노을 앨범</h1>
  <div style="margin-left:auto;">
    <a href="<c:url value='/SunsetWrite.do'/>"
       class="btn-primary"
       style="display:inline-flex;align-items:center;gap:8px;padding:8px 12px;border-radius:8px;background:#9A5ABF;color:#fff;text-decoration:none;font-weight:600;">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="#fff" aria-hidden="true">
        <path d="M3 17.25V21h3.75l11.06-11.06-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02
                 0-1.41l-2.34-2.34a.9959.9959 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
      </svg>
      글쓰기
    </a>
  </div>
</div>

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
              <img
                src="<c:out value='${empty p.thumbnailUrl ? pageContext.request.contextPath.concat("/images/favicon.svg") : p.thumbnailUrl}'/>"
                alt="썸네일"
                loading="lazy" />
            </div>
            <div class="post-card__meta">
              <div class="post-card__title">
                <c:out value="${empty p.title ? '제목 없음' : p.title}"/>
              </div>
              <div class="post-card__date">
                <c:out value="${p.createdAt}"/>
              </div>
            </div>
          </a>
        </li>
      </c:forEach>
    </ul>

    <!-- 간단 페이저 -->
    <c:if test="${pageCount > 1}">
      <nav class="pager" style="display:flex;gap:6px;justify-content:center;margin-top:16px;">
        <c:if test="${pageno > 1}">
          <a href="<c:url value='/sunset.jsp'/>?pageno=${pageno-1}"
             style="padding:6px 10px;border:1px solid #e5e7eb;border-radius:8px;text-decoration:none;color:#111;">이전</a>
        </c:if>

        <c:forEach var="i" begin="1" end="${pageCount}">
          <a href="<c:url value='/sunset.jsp'/>?pageno=${i}"
             style="padding:6px 10px;border:1px solid #e5e7eb;border-radius:8px;text-decoration:none;
                    <c:if test='${i==pageno}'>background:#9A5ABF;color:#fff;border-color:#9A5ABF;</c:if>">
            ${i}
          </a>
        </c:forEach>

        <c:if test="${pageno < pageCount}">
          <a href="<c:url value='/sunset.jsp'/>?pageno=${pageno+1}"
             style="padding:6px 10px;border:1px solid #e5e7eb;border-radius:8px;text-decoration:none;color:#111;">다음</a>
        </c:if>
      </nav>
    </c:if>
  </c:otherwise>
</c:choose>
