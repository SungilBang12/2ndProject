<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>${post.title}</title>
</head>

<body>
	<jsp:include page="/WEB-INF/include/header.jsp" />

	<main class="main grid-14x5">
		<div class="slot-nav">
			<jsp:include page="/WEB-INF/include/nav.jsp" />
		</div>

		<div class="slot-board">

			
			<jsp:include page="/WEB-INF/include/post-view.jsp"></jsp:include>

			<!-- 댓글 폼 인클루드 -->
			<jsp:include page="/WEB-INF/include/post-comment.jsp"></jsp:include>

		</div>

		<div class="slot-extra">
			<jsp:include page="/WEB-INF/include/chat.jsp"></jsp:include>
		</div>
	</main>
</body>
</html>



