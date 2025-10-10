<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="board-results">
  <h1>검색 결과</h1>

  <c:choose>
    <c:when test="${not empty param.q}">
      <p>
        <strong>'${fn:escapeXml(param.q)}'</strong> 에 대한 결과가 아직 없습니다.
        (데이터 연동되면 목록 렌더링)
      </p>
    </c:when>
    <c:otherwise>
      <p>검색어를 입력해 주세요.</p>
    </c:otherwise>
  </c:choose>

  <!-- TODO: 데이터 붙이면 여기서 루프 렌더링 -->
  <ul>
    <!-- <c:forEach var="post" items="${posts}">
         <li><a href="<c:url value='/post/${post.id}'/>">${fn:escapeXml(post.title)}</a></li>
       </c:forEach> -->
  </ul>
</div>
