<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>게시글 작성 - '해'쳐 모여</title>

    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/post-create-edit.css">
    <link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- 카카오맵 API -->
    <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=70a909d37469228212bf0e0010b9d27e&libraries=services"></script>
    
    <!-- 카카오맵 Enhanced 모듈 -->
    <script src="${pageContext.request.contextPath}/js/kakaomap.js"></script>
</head>
<body>
    <!-- 헤더 -->
    <jsp:include page="/WEB-INF/include/header.jsp" />
    
    <!-- 메인 컨텐츠 -->
    <main class="main grid-14x5">
        <!-- 좌측 네비게이션 -->
        <div class="slot-nav">
            <jsp:include page="/WEB-INF/include/nav.jsp">
                <jsp:param name="openAcc" value="acc-equipment"/>
            </jsp:include>
        </div>

        <!-- 메인 에디터 영역 -->
        <div class="slot-board">
            <!-- 페이지 헤더 -->
            <div class="page-header">
                <h1 class="page-title">게시글 수정</h1>
    			<button onclick="history.back()" class="btn">← 뒤로가기</button>
            </div>

            <!-- 에디터 Include -->
            <jsp:include page="/WEB-INF/include/post-trade-update-editor.jsp" />
        </div>

        <!-- 우측 여유 공간 -->
        <div class="slot-extra">
            <!-- 필요 시 우측 칼럼 컨텐츠 -->
        </div>
    </main>
</body>
</html>