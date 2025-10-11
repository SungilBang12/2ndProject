<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Editor Template</title>
<link rel="stylesheet" href="./css/post-create-edit.css" />
<!-- Kakao 지도 SDK -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=c72248c25fcfe17e7a6934e08908d1f4&libraries=services"></script>
</head>
<body>
	<jsp:include page="/WEB-INF/include/header.jsp" />
	<main class="main grid-14x5">
		<div class="slot-nav">
			<jsp:include page="/WEB-INF/include/nav.jsp" />
		</div>

		<div class="slot-board">
			<jsp:include page= "/WEB-INF/template/editor-template.jsp" />
		</div>

		<div class="slot-extra">
			<!-- 필요 시 우측 칼럼 -->
		</div>
		<main>
</body>
</html>