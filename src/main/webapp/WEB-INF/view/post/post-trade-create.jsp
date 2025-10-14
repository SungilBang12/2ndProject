<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Editor Template</title>

    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    <link rel="stylesheet" href="./css/post-create-edit.css" />
    <link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">
    
    <!-- 카카오맵 API -->
    <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=70a909d37469228212bf0e0010b9d27e&libraries=services"></script>


</head>
<body>
	<jsp:include page="/WEB-INF/include/header.jsp" />
	<main class="main grid-14x5">
		<div class="slot-nav">
			<jsp:include page="/WEB-INF/include/nav.jsp" />
		</div>

		<div class="slot-board">
			<div class="title-block">
				<label for="postTitle">게시글 제목</label> 
				<input type="text" id="title" name="title" required>
			</div>
			<jsp:include page="/WEB-INF/include/post-trade-editor.jsp" />
		</div>

		<div class="slot-extra">
			<!-- 필요 시 우측 칼럼 -->
		</div>
		<main>
</body>
</html>