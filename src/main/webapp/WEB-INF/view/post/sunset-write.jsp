<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>노을 맛집 - 노을 글쓰기</title>

  <link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=5" />
  <link rel="stylesheet" href="<c:url value='/css/post-create-edit.css'/>?v=1" />
  <link rel="icon" href="<c:url value='/images/favicon.ico'/>?v=1">
</head>
<body>

<jsp:include page="/WEB-INF/include/header.jsp" />

<main class="main grid-14x5">
  <div class="slot-nav">
    <jsp:include page="/WEB-INF/include/nav.jsp">
      <jsp:param name="openAcc" value="acc-sunset"/>
    </jsp:include>
  </div>

  <div id="board" class="slot-board">
    <h1 style="margin:0 0 16px 0;">노을 글쓰기</h1>

    <c:if test="${not empty error}">
      <div style="margin-bottom:12px;padding:10px;border-radius:8px;background:#fff3f3;color:#b91c1c;">
        <c:out value="${error}"/>
      </div>
    </c:if>

    <form action="<c:url value='/post/create'/>" method="post" style="display:grid;gap:12px;">
 	    <input type="hidden" name="listId" value="<c:out value='${listId != null ? listId : 11}'/>" />

      <label>
        <div style="font-weight:600;margin-bottom:6px;">제목</div>
        <input type="text" name="title" required
               value="<c:out value='${title}'/>"
               style="width:100%;padding:10px;border:1px solid #e5e7eb;border-radius:8px;" />
      </label>

      <label>
        <div style="font-weight:600;margin-bottom:6px;">썸네일 이미지 URL (선택)</div>
        <input type="url" name="thumbUrl"
               placeholder="https:// …"
               value="<c:out value='${thumbUrl}'/>"
               style="width:100%;padding:10px;border:1px solid #e5e7eb;border-radius:8px;" />
        <div style="font-size:12px;color:#6b7280;margin-top:4px;">
          업로드 연동은 나중에 S3 업로더 붙이면 됨. 지금은 URL로 테스트 가능.
        </div>
      </label>

      <label>
        <div style="font-weight:600;margin-bottom:6px;">내용</div>
        <textarea name="content" rows="10"
                  style="width:100%;padding:10px;border:1px solid #e5e7eb;border-radius:8px;"><c:out value='${content}'/></textarea>
      </label>

      <div style="display:flex;gap:8px;justify-content:flex-end;">
        <a href="<c:url value='/sunset.jsp'/>"
           style="padding:10px 14px;border:1px solid #e5e7eb;border-radius:8px;text-decoration:none;color:#111;">취소</a>
        <button type="submit"
                style="padding:10px 14px;border:0;border-radius:8px;background:#9A5ABF;color:#fff;font-weight:600;">
          저장
        </button>
      </div>
    </form>
  </div>

  <div class="slot-extra"></div>
</main>

</body>
</html>
