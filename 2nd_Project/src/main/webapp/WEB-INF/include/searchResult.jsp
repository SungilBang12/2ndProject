<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="board-results">
  <c:choose>
    <c:when test="${empty q}">
      <h1>최근 게시물</h1>
    </c:when>
    <c:otherwise>
      <h1>검색 결과: <c:out value="${q}"/></h1>
      <p style="color:#666;margin-top:-4px;">
        총 <strong><c:out value="${fn:length(results)}"/></strong>건
      </p>
    </c:otherwise>
  </c:choose>

  <c:if test="${empty results}">
    <div style="padding:24px;border:1px dashed #e5e7eb;border-radius:12px;background:#fafafa;">
      '<c:out value="${q}"/>'에 대한 결과가 없습니다.
    </div>
  </c:if>

  <c:if test="${not empty results}">
    <ul style="list-style:none;padding:0;margin:16px 0 0;">
      <c:forEach var="p" items="${results}">
        <li style="padding:12px 10px;border-bottom:1px solid #f1f5f9;">
          <a href="${p.url}" style="font-weight:600;text-decoration:none;color:#111;">
            <c:out value="${p.title}"/>
          </a>
          <div style="font-size:12px;color:#6b7280;margin-top:4px;">
            <c:out value="${p.date}"/>
          </div>
        </li>
      </c:forEach>
    </ul>
  </c:if>
</div>
