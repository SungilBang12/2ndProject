<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>노을 맛집 - '해'쳐 모여 게시판 상세보기</title>
    
    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    <link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">
    
    <!-- 카카오맵 API -->
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=YOUR_APP_KEY&libraries=services"></script>
    
    <!-- 상세보기 전용 CSS -->
    <style>
        /* 기본 레이아웃 */
        body {
            margin: 0;
        }
        
        .detail-container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        /* 상단 액션 버튼 */
        .header-actions {
            margin-bottom: 30px;
        }
        
        /* 게시글 상세 정보 */
        .post-header {
            border-bottom: 2px solid #333;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        
        .post-title {
            font-size: 28px;
            font-weight: bold;
            margin: 0 0 15px 0;
            color: #333;
        }
        
        .post-meta {
            color: #666;
            font-size: 14px;
        }
        
        .post-meta-item {
            display: inline-block;
            margin-right: 20px;
        }
        
        .post-meta-item strong {
            color: #333;
        }
        
        /* 게시글 본문 */
        .post-content {
            line-height: 1.8;
            font-size: 16px;
            color: #333;
            min-height: 100px;
            padding: 20px 0;
            margin-bottom: 30px;
        }
        
        /* 장소 정보 섹션 */
        .place-section {
            margin: 30px 0;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
        }
        
        .place-section h3 {
            font-size: 18px;
            margin: 0 0 15px 0;
            color: #333;
        }
        
        .place-info {
            margin-bottom: 15px;
        }
        
        .place-info-item {
            padding: 8px 0;
            color: #333;
            font-size: 14px;
        }
        
        .place-info-item strong {
            display: inline-block;
            width: 80px;
            color: #666;
        }
        
        /* 카카오맵 */
        #place-map {
            width: 100%;
            height: 400px;
            border: 2px solid #ddd;
            border-radius: 8px;
            margin-top: 15px;
        }
        
        /* 액션 버튼 그룹 */
        .action-buttons {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
            padding: 20px 0;
            border-top: 1px solid #ddd;
            border-bottom: 1px solid #ddd;
        }
        
        .btn-group {
            display: flex;
            gap: 10px;
        }
        
        .btn {
            padding: 10px 20px;
            border: 1px solid #ddd;
            background-color: white;
            cursor: pointer;
            border-radius: 4px;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            color: #333;
        }
        
        .btn:hover {
            background-color: #f8f9fa;
        }
        
        .btn-primary {
            background-color: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        .btn-primary:hover {
            background-color: #0056b3;
        }
        
        .btn-danger {
            background-color: #dc3545;
            color: white;
            border-color: #dc3545;
        }
        
        .btn-danger:hover {
            background-color: #c82333;
        }
        
        /* 댓글 섹션 */
        .comment-section {
            margin-top: 40px;
            padding-top: 30px;
            border-top: 2px solid #333;
        }
        
        .comment-section h2 {
            font-size: 20px;
            margin-bottom: 20px;
        }
        
        .comment-list {
            margin-bottom: 30px;
        }
        
        .comment-item {
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        
        .comment-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        
        .comment-author {
            font-weight: bold;
            color: #333;
        }
        
        .comment-date {
            color: #666;
            font-size: 12px;
        }
        
        .comment-content {
            color: #333;
            line-height: 1.6;
        }
        
        .comment-actions {
            margin-top: 10px;
            text-align: right;
        }
        
        .comment-actions button {
            padding: 4px 10px;
            font-size: 12px;
            margin-left: 5px;
        }
        
        /* 댓글 작성 폼 */
        .comment-form {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 4px;
        }
        
        .comment-form h3 {
            font-size: 16px;
            margin: 0 0 15px 0;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }
        
        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        .form-group textarea {
            resize: vertical;
        }
        
        .empty-comments {
            text-align: center;
            padding: 40px 20px;
            color: #666;
            background-color: #f8f9fa;
            border-radius: 4px;
        }
        
        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .detail-container {
                padding: 20px;
            }
            
            .post-title {
                font-size: 22px;
            }
            
            .action-buttons {
                flex-direction: column;
                gap: 10px;
            }
            
            .btn-group {
                justify-content: flex-start;
            }
            
            .post-meta-item {
                display: block;
                margin-bottom: 5px;
            }
            
            #place-map {
                height: 300px;
            }
            
            .place-info-item strong {
                display: block;
                margin-bottom: 5px;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/include/header.jsp" />
<main class="main grid-14x5">
    <!-- 좌측 1열: nav(그리드 안) -->
    <div class="slot-nav">
        <jsp:include page="/WEB-INF/include/nav.jsp">
            <jsp:param name="openAcc" value="acc-equipment"/>
        </jsp:include>
    </div>

    <!-- 메인 컨텐츠 영역 -->
    <div class="detail-container">
        <!-- 목록으로 돌아가기 버튼 -->
        <div class="header-actions">
            <a href="${pageContext.request.contextPath}/meeting-gatherList.jsp" class="btn">← 목록으로</a>
        </div>
        
        <!-- 게시글 상세 정보 -->
        <div class="post-header">
            <h1 class="post-title" id="post-title">게시글 제목</h1>
            <div class="post-meta">
                <span class="post-meta-item">
                    <strong>작성자:</strong> <span id="post-author">-</span>
                </span>
                <span class="post-meta-item">
                    <strong>작성일:</strong> <span id="post-date">-</span>
                </span>
            </div>
        </div>
        
        <!-- 게시글 본문 -->
        <div class="post-content" id="post-content">
            게시글 내용을 불러오는 중...
        </div>
        
        <!-- 장소 정보 섹션 -->
        <div class="place-section" id="place-section" style="display: none;">
            <h3>📍 노을 촬영 장소</h3>
            <div class="place-info">
                <div class="place-info-item">
                    <strong>장소명:</strong>
                    <span id="place-name">-</span>
                </div>
                <div class="place-info-item">
                    <strong>주소:</strong>
                    <span id="place-address">-</span>
                </div>
                <div class="place-info-item" id="place-phone-container" style="display: none;">
                    <strong>전화번호:</strong>
                    <span id="place-phone">-</span>
                </div>
            </div>
            
            <!-- 카카오맵 -->
            <div id="place-map"></div>
        </div>
        
        <!-- 액션 버튼 -->
        <div class="action-buttons">
            <div class="btn-group">
                <a href="${pageContext.request.contextPath}/meeting-gatherList.jsp" class="btn">목록</a>
                <button onclick="editPost()" class="btn btn-primary">수정</button>
            </div>
            <div class="btn-group">
                <button onclick="deletePost()" class="btn btn-danger">삭제</button>
            </div>
        </div>
        
        <!-- 댓글 섹션 -->
        <div class="comment-section">
            <h2>댓글 <span id="comment-count">(0)</span></h2>
            
            <!-- 댓글 목록 -->
            <div class="comment-list" id="comment-list">
                <!-- JavaScript로 동적 생성 -->
            </div>
            
            <!-- 댓글 작성 폼 -->
            <div class="comment-form">
                <h3>댓글 작성</h3>
                <form id="comment-form">
                    <div class="form-group">
                        <label for="comment-author">작성자</label>
                        <input type="text" id="comment-author" name="author" required placeholder="작성자명을 입력하세요">
                    </div>
                    <div class="form-group">
                        <label for="comment-content">내용</label>
                        <textarea id="comment-content" name="content" rows="4" required placeholder="댓글 내용을 입력하세요"></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">댓글 작성</button>
                </form>
            </div>
        </div>
    </div>
</main>

    <script>
        /**
         * 게시글 상세보기 및 댓글 관리 스크립트 (카카오맵 연동)
         * localStorage를 사용한 클라이언트 사이드 데이터 관리
         * TODO: 추후 서버 사이드 API로 전환 필요
         */
        
        // ============================================
        // 전역 변수
        // ============================================
        let currentPostId = null;  // 현재 게시글 ID
        let posts = [];            // 게시글 목록
        let comments = [];         // 댓글 목록
        let placeMap = null;       // 장소 지도 객체
        
        
        // ============================================
        // 초기화 함수
        // ============================================
        
        /**
         * 페이지 로드 시 초기화
         */
        function init() {
            // URL에서 게시글 ID 가져오기
            currentPostId = getPostIdFromUrl();
            
            if (!currentPostId) {
                alert('잘못된 접근입니다.');
                location.href = '${pageContext.request.contextPath}/meeting-gatherList.jsp';
                return;
            }
            
            // 데이터 로드
            loadPostsFromStorage();
            loadCommentsFromStorage();
            
            // 게시글 및 댓글 렌더링
            renderPostDetail();
            renderComments();
            
            // 이벤트 리스너 등록
            setupEventListeners();
        }
        
        
        // ============================================
        // 카카오맵 관련 함수
        // ============================================
        
        /**
         * 장소 지도 표시
         * @param {Object} place - 장소 정보
         */
        function displayPlaceMap(place) {
            if (!place || !place.lat || !place.lng) {
                return;
            }
            
            // 장소 정보 섹션 표시
            document.getElementById('place-section').style.display = 'block';
            
            // 장소 정보 표시
            document.getElementById('place-name').textContent = place.name;
            document.getElementById('place-address').textContent = place.address;
            
            if (place.phone) {
                document.getElementById('place-phone-container').style.display = 'block';
                document.getElementById('place-phone').textContent = place.phone;
            }
            
            // 지도 생성
            const mapContainer = document.getElementById('place-map');
            const mapOption = {
                center: new kakao.maps.LatLng(place.lat, place.lng),
                level: 3
            };
            
            placeMap = new kakao.maps.Map(mapContainer, mapOption);
            
            // 마커 생성
            const marker = new kakao.maps.Marker({
                position: new kakao.maps.LatLng(place.lat, place.lng),
                map: placeMap
            });
            
            // 인포윈도우 생성 및 표시
            const infowindow = new kakao.maps.InfoWindow({
                content: `<div style="padding: 10px; font-size: 14px; font-weight: bold;">${place.name}</div>`
            });
            
            infowindow.open(placeMap, marker);
        }
        
        
        // ============================================
        // 데이터 관리 함수
        // ============================================
        
        /**
         * localStorage에서 게시글 목록 불러오기
         */
        function loadPostsFromStorage() {
            const storedPosts = localStorage.getItem('posts');
            posts = storedPosts ? JSON.parse(storedPosts) : [];
        }
        
        /**
         * localStorage에서 댓글 목록 불러오기
         */
        function loadCommentsFromStorage() {
            const storedComments = localStorage.getItem('comments');
            comments = storedComments ? JSON.parse(storedComments) : [];
        }
        
        /**
         * localStorage에 게시글 저장
         */
        function savePostsToStorage() {
            localStorage.setItem('posts', JSON.stringify(posts));
        }
        
        /**
         * localStorage에 댓글 저장
         */
        function saveCommentsToStorage() {
            localStorage.setItem('comments', JSON.stringify(comments));
        }
        
        
        // ============================================
        // 렌더링 함수
        // ============================================
        
        /**
         * 게시글 상세 정보 렌더링
         */
        function renderPostDetail() {
            const post = posts.find(p => p.id === currentPostId);
            
            if (!post) {
                alert('게시글을 찾을 수 없습니다.');
                location.href = '${pageContext.request.contextPath}/meeting-gatherList.jsp';
                return;
            }
            
            // 게시글 정보 표시
            document.getElementById('post-title').textContent = post.title;
            document.getElementById('post-author').textContent = post.author || '익명';
            document.getElementById('post-date').textContent = post.date || '-';
            document.getElementById('post-content').innerHTML = escapeHtml(post.content).replace(/\n/g, '<br>');
            
            // 장소 정보가 있으면 지도 표시
            if (post.place) {
                displayPlaceMap(post.place);
            }
        }
        
        /**
         * 댓글 목록 렌더링
         */
        function renderComments() {
            const commentList = document.getElementById('comment-list');
            
            // 현재 게시글의 댓글만 필터링
            const postComments = comments.filter(c => c.postId === currentPostId);
            
            // 댓글 수 업데이트
            document.getElementById('comment-count').textContent = `(${postComments.length})`;
            
            // 댓글이 없는 경우
            if (postComments.length === 0) {
                commentList.innerHTML = `
                    <div class="empty-comments">
                        첫 댓글을 작성해보세요!
                    </div>
                `;
                return;
            }
            
            // 댓글 목록 렌더링 (최신순)
            let html = '';
            postComments
                .sort((a, b) => b.id - a.id)
                .forEach(comment => {
                    html += `
                        <div class="comment-item">
                            <div class="comment-header">
                                <span class="comment-author">${escapeHtml(comment.author)}</span>
                                <span class="comment-date">${comment.date}</span>
                            </div>
                            <div class="comment-content">
                                ${escapeHtml(comment.content).replace(/\n/g, '<br>')}
                            </div>
                            <div class="comment-actions">
                                <button onclick="deleteComment(${comment.id})" class="btn btn-danger">삭제</button>
                            </div>
                        </div>
                    `;
                });
            
            commentList.innerHTML = html;
        }
        
        
        // ============================================
        // 게시글 관련 함수
        // ============================================
        
        /**
         * 게시글 수정 페이지로 이동
         */
        function editPost() {
            location.href = '${pageContext.request.contextPath}/meeting-gatherEdit.jsp?id=' + currentPostId;
        }
        
        /**
         * 게시글 삭제
         */
        function deletePost() {
            if (!confirm('정말 삭제하시겠습니까?')) {
                return;
            }
            
            // 게시글 삭제
            posts = posts.filter(p => p.id !== currentPostId);
            savePostsToStorage();
            
            // 해당 게시글의 댓글도 모두 삭제
            comments = comments.filter(c => c.postId !== currentPostId);
            saveCommentsToStorage();
            
            alert('게시글이 삭제되었습니다.');
            location.href = '${pageContext.request.contextPath}/meeting-gatherList.jsp';
        }
        
        
        // ============================================
        // 댓글 관련 함수
        // ============================================
        
        /**
         * 댓글 작성
         * @param {Event} e - Form submit 이벤트
         */
        function submitComment(e) {
            e.preventDefault();
            
            const author = document.getElementById('comment-author').value.trim();
            const content = document.getElementById('comment-content').value.trim();
            
            if (!author) {
                alert('작성자를 입력해주세요.');
                return;
            }
            
            if (!content) {
                alert('댓글 내용을 입력해주세요.');
                return;
            }
            
            // 댓글 객체 생성
            const comment = {
                id: Date.now(),
                postId: currentPostId,
                author: author,
                content: content,
                date: new Date().toLocaleString()
            };
            
            // 댓글 추가 및 저장
            comments.push(comment);
            saveCommentsToStorage();
            
            // 폼 초기화 및 재렌더링
            document.getElementById('comment-form').reset();
            renderComments();
            
            alert('댓글이 작성되었습니다.');
        }
        
        /**
         * 댓글 삭제
         * @param {number} commentId - 삭제할 댓글 ID
         */
        function deleteComment(commentId) {
            if (!confirm('댓글을 삭제하시겠습니까?')) {
                return;
            }
            
            comments = comments.filter(c => c.id !== commentId);
            saveCommentsToStorage();
            renderComments();
        }
        
        
        // ============================================
        // 유틸리티 함수
        // ============================================
        
        /**
         * URL에서 게시글 ID 추출
         * @return {number|null} 게시글 ID
         */
        function getPostIdFromUrl() {
            const urlParams = new URLSearchParams(window.location.search);
            const id = urlParams.get('id');
            return id ? parseInt(id) : null;
        }
        
        /**
         * HTML 특수문자 이스케이프 (XSS 방지)
         * @param {string} text - 이스케이프할 텍스트
         * @return {string} 이스케이프된 텍스트
         */
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        /**
         * 이벤트 리스너 설정
         */
        function setupEventListeners() {
            document.getElementById('comment-form').addEventListener('submit', submitComment);
        }
        
        
        // ============================================
        // 이벤트 리스너 및 초기 실행
        // ============================================
        
        // 페이지 로드 완료 시 초기화 실행
        window.onload = init;
    </script>
</body>
</html>