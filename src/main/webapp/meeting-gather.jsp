<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>노을 맛집 - '해'쳐 모여 게시판</title>
    
    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    <link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">
    
    <!-- 게시판 전용 CSS -->
    <style>
        /* 추가 스타일 */
        .list-container {
            background-color: white;
            border-radius: 8px;
        }
        
        /* 게시판 헤더 */
        .board-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .board-title {
            margin: 0;
            font-size: 24px;
            font-weight: bold;
            color: #333;
        }
        
        .board-actions {
            display: flex;
            gap: 10px;
        }
        
        /* 게시판 테이블 */
        .board-table {
            width: 100%;
            border-collapse: collapse;
            border: 1px solid #ddd;
        }
        
        .board-table th,
        .board-table td {
            padding: 12px 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        
        .board-table th {
            background-color: #f8f9fa;
            font-weight: bold;
        }
        
        .board-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        /* 제목 링크 */
        .post-title-link {
            color: #333;
            text-decoration: none;
        }
        
        .post-title-link:hover {
            color: #007bff;
            text-decoration: underline;
        }
        
        /* 버튼 스타일 */
        .btn {
            padding: 8px 16px;
            margin: 0;
            border: 1px solid #ddd;
            background-color: #fff;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            border-radius: 4px;
            font-size: 14px;
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
        
        /* 빈 게시판 안내 */
        .empty-board {
            text-align: center;
            padding: 40px 20px;
            color: #666;
        }
        
        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .board-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .board-table {
                font-size: 14px;
            }
            
            .board-table th,
            .board-table td {
                padding: 8px 4px;
            }
            
            /* 모바일에서 번호 열 최소화 */
            .board-table th:nth-child(1),
            .board-table td:nth-child(1) {
                width: 40px;
            }
            
            /* 모바일에서 작성자, 작성일 숨김 */
            .board-table th:nth-child(3),
            .board-table td:nth-child(3),
            .board-table th:nth-child(4),
            .board-table td:nth-child(4) {
                display: none;
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
    <div class="slot-board list-container">
        <!-- 게시판 헤더 -->
        <div class="board-header">
            <h1 class="board-title">'해'쳐 모여 게시판</h1>
            <div class="board-actions">
                <a href="${pageContext.request.contextPath}/meeting-gatherWriting.jsp" class="btn btn-primary">글쓰기</a>
            </div>
        </div>
        
        <!-- 게시판 테이블 -->
        <table class="board-table">
            <thead>
                <tr>
                    <th>번호</th>
                    <th>제목</th>
                    <th>작성자</th>
                    <th>작성일</th>
                </tr>
            </thead>
            <tbody id="post-list">
                <!-- JavaScript로 동적 생성 -->
            </tbody>
        </table>
    </div>
</main>

    <script>
        /**
         * 게시판 리스트 관리 스크립트
         * localStorage를 사용한 클라이언트 사이드 데이터 관리
         * TODO: 추후 서버 사이드 API로 전환 필요
         */
        
        // ============================================
        // 전역 변수
        // ============================================
        let posts = []; // 게시글 목록 저장 배열
        
        // JSP 컨텍스트 패스를 JavaScript 변수로 저장
        var contextPath = '${pageContext.request.contextPath}';
        
        
        // ============================================
        // 초기화 함수
        // ============================================
        
        /**
         * 페이지 로드 시 초기화
         */
        function init() {
            console.log('=== 게시판 페이지 로드 ===');
            console.log('contextPath:', contextPath);
            
            loadPostsFromStorage();
            renderPostList();
            
            console.log('로드된 게시글 수:', posts.length);
            console.log('게시글 목록:', posts);
        }
        
        
        // ============================================
        // 데이터 관리 함수
        // ============================================
        
        /**
         * localStorage에서 게시글 목록 불러오기
         */
        function loadPostsFromStorage() {
            try {
                var storedPosts = localStorage.getItem('posts');
                console.log('localStorage raw data:', storedPosts);
                
                posts = storedPosts ? JSON.parse(storedPosts) : [];
                console.log('파싱된 게시글:', posts);
            } catch (e) {
                console.error('localStorage 읽기 실패:', e);
                posts = [];
            }
        }
        
        
        // ============================================
        // 렌더링 함수
        // ============================================
        
        /**
         * 게시글 목록을 테이블에 렌더링
         */
        function renderPostList() {
            var tbody = document.getElementById('post-list');
            
            // 기존 내용 초기화
            tbody.innerHTML = '';
            
            // 게시글이 없는 경우
            if (posts.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" class="empty-board">등록된 게시글이 없습니다.</td></tr>';
                console.log('게시글이 없습니다.');
                return;
            }
            
            console.log('게시글 렌더링 시작...');
            
            // 게시글 목록을 최신순으로 정렬하여 렌더링
            posts
                .sort(function(a, b) { return b.id - a.id; }) // 최신글이 위로
                .forEach(function(post, index) {
                    var tr = document.createElement('tr');
                    var displayNumber = posts.length - index; // 표시 번호 (역순)
                    
                    // 문자열 연결 사용 (JSP EL 충돌 방지)
                    var detailUrl = getDetailPageUrl(post.id);
                    var titleText = escapeHtml(post.title);
                    var authorText = escapeHtml(post.author || '익명');
                    
                    console.log('게시글 #' + post.id + ' 렌더링:', {
                        title: titleText,
                        url: detailUrl
                    });
                    
                    tr.innerHTML = 
                        '<td>' + displayNumber + '</td>' +
                        '<td><a href="' + detailUrl + '" class="post-title-link">' + titleText + '</a></td>' +
                        '<td>' + authorText + '</td>' +
                        '<td>' + (post.date || '-') + '</td>';
                    
                    tbody.appendChild(tr);
                });
            
            console.log('게시글 렌더링 완료!');
        }
        
        
        // ============================================
        // 유틸리티 함수
        // ============================================
        
        /**
         * 게시글 상세 페이지 URL 생성
         * @param {number} postId - 게시글 ID
         * @return {string} 상세 페이지 URL
         */
        function getDetailPageUrl(postId) {
            return contextPath + '/meeting-gatherDetail.jsp?id=' + postId;
        }
        
        /**
         * HTML 특수문자 이스케이프 (XSS 방지)
         * @param {string} text - 이스케이프할 텍스트
         * @return {string} 이스케이프된 텍스트
         */
        function escapeHtml(text) {
            if (!text) return '';
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        
        // ============================================
        // 이벤트 리스너 및 초기 실행
        // ============================================
        
        // 페이지 로드 완료 시 초기화 실행
        document.addEventListener('DOMContentLoaded', init);
    </script>
</body>
</html>