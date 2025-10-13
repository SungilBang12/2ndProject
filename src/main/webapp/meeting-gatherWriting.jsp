<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>노을 맛집 - '해'쳐 모여 게시판 작성</title>
    
    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    <link rel="stylesheet" href="./css/post-create-edit.css" />
    <link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">
    
    <!-- 카카오맵 API -->
    <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=70a909d37469228212bf0e0010b9d27e&libraries=services"></script>
 
    <!-- 작성 페이지 전용 CSS -->
    <style>
        /* 기본 레이아웃 */
        body {
            margin: 0;
        }
        
        .write-container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        /* 페이지 헤더 */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #333;
        }
        
        .page-title {
            font-size: 24px;
            font-weight: bold;
            margin: 0;
            color: #333;
        }
        
        /* 폼 스타일 */
        .write-form {
            width: 100%;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
            font-size: 14px;
        }
        
        .form-group .required {
            color: #dc3545;
        }
        
        .form-control {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 0 3px rgba(0,123,255,0.1);
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 200px;
            line-height: 1.6;
        }
        
        .form-help {
            margin-top: 5px;
            font-size: 12px;
            color: #666;
        }
        
        /* 버튼 그룹 */
        .button-group {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
        }
        
        .btn {
            padding: 12px 24px;
            border: 1px solid #ddd;
            background-color: white;
            cursor: pointer;
            border-radius: 4px;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            color: #333;
            font-weight: 500;
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
        
        .btn-secondary {
            background-color: #6c757d;
            color: white;
            border-color: #6c757d;
        }
        
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        
        /* 안내 메시지 */
        .info-message {
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .info-message p {
            margin: 0;
            color: #856404;
            font-size: 14px;
        }
        
        /* 삽입된 장소 정보 스타일 */
        .place-info {
            padding: 15px;
            margin: 10px 0;
            border: 2px solid #007bff;
            border-radius: 8px;
            background-color: #f0f8ff;
        }
        
        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .write-container {
                padding: 20px;
            }
            
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .button-group {
                flex-direction: column;
                gap: 10px;
            }
            
            .btn {
                width: 100%;
                text-align: center;
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
    
    <div class="slot-board">
        <div class="container">
            <!-- 메인 컨텐츠 영역 -->
            <div class="write-container">
                <!-- 페이지 헤더 -->
                <div class="page-header">
                    <h1 class="page-title">게시글 작성</h1>
                    <a href="${pageContext.request.contextPath}/meeting-gather.jsp" class="btn">목록으로</a>
                </div>
                
                <!-- 안내 메시지 -->
                <div class="info-message">
                    <p>📍 툴바의 '지도' 버튼을 클릭하여 모임 장소를 검색하고 선택해보세요!</p>
                </div>
                
                <!-- 작성 폼 -->
                <form id="write-form" class="write-form">
                    <!-- 제목 -->
                    <div class="form-group">
                        <label for="post-title">
                            제목 <span class="required">*</span>
                        </label>
                        <input 
                            type="text" 
                            id="post-title" 
                            name="title" 
                            class="form-control" 
                            placeholder="제목을 입력하세요"
                            required 
                            maxlength="100">
                        <div class="form-help">최대 100자까지 입력 가능합니다.</div>
                    </div>
                    
                    <!-- 툴바 -->
                    <div id="toolbar" class="toolbar">
                        <button type="button" data-cmd="bold">
                            <strong>B</strong>
                        </button>
                        <button type="button" data-cmd="italic">
                            <i>I</i>
                        </button>
                        <button type="button" data-cmd="strike">
                            <s>S</s>
                        </button>
                        <button type="button" data-cmd="underline">U</button>
                        <jsp:include page="WEB-INF/template/text-style-btn.jsp" />
                
                        <button type="button" data-cmd="heading1">H1</button>
                        <button type="button" data-cmd="heading2">H2</button>
                        <button type="button" data-cmd="heading3">H3</button>
                
                        <button type="button" data-cmd="bulletList">● List</button>
                        <button type="button" data-cmd="orderedList">1. List</button>
                        
                        <jsp:include page="/WEB-INF/include/schedule-modal.jsp" />
                        <jsp:include page="/WEB-INF/include/emoji-picker.jsp" />
                        
                        <!-- 카카오맵 버튼 추가 -->
                        <jsp:include page="/WEB-INF/include/map-modal-content.jsp" />
                    </div>
            
                    <!-- 에디터 영역 -->
                    <div id="board" class="board"></div>
                           
                    <!-- 버튼 그룹 -->
                    <div class="button-group">
                        <a href="${pageContext.request.contextPath}/meeting-gather.jsp" class="btn btn-secondary">취소</a>
                        <button type="submit" class="btn btn-primary">등록하기</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<!-- 카카오맵 JavaScript -->
<script src="${pageContext.request.contextPath}/js/kakaomap.js"></script>

<!-- 게시글 작성 JavaScript -->
<script>
    /**
     * 게시글 작성 페이지 스크립트
     * localStorage를 사용한 클라이언트 사이드 데이터 관리
     */
    
    // JSP contextPath를 JavaScript 변수로 전달
    var contextPath = '${pageContext.request.contextPath}';
    
    // 전역 변수
    let posts = [];
    
    /**
     * 페이지 로드 시 초기화
     */
    function init() {
        // 데이터 로드
        loadPostsFromStorage();
        
        // 이벤트 리스너 등록
        setupEventListeners();
        
        console.log('✅ 게시글 작성 페이지 초기화 완료');
        console.log('현재 저장된 게시글 수:', posts.length);
    }
    
    /**
     * localStorage에서 게시글 목록 불러오기
     */
    function loadPostsFromStorage() {
        const storedPosts = localStorage.getItem('posts');
        posts = storedPosts ? JSON.parse(storedPosts) : [];
    }
    
    /**
     * localStorage에 게시글 저장
     */
    function savePostsToStorage() {
        localStorage.setItem('posts', JSON.stringify(posts));
    }
    
    /**
     * 폼 제출 처리
     */
    function handleSubmit(e) {
        e.preventDefault();
        
        // 폼 데이터 가져오기
        const title = document.getElementById('post-title').value.trim();
        const content = document.getElementById('board').innerHTML;
        
        // 유효성 검사
        if (!validateForm(title, content)) {
            return;
        }
        
        // 게시글 작성
        createPost(title, content);
    }
    
    /**
     * 폼 유효성 검사
     */
    function validateForm(title, content) {
        if (!title) {
            alert('제목을 입력해주세요.');
            document.getElementById('post-title').focus();
            return false;
        }
        
        if (title.length > 100) {
            alert('제목은 100자 이내로 입력해주세요.');
            document.getElementById('post-title').focus();
            return false;
        }
        
        if (!content || content.trim() === '') {
            alert('내용을 입력해주세요.');
            return false;
        }
        
        return true;
    }
    
    /**
     * 새 게시글 생성
     */
    function createPost(title, content) {
        // 게시글 객체 생성
        const post = {
            id: Date.now(),
            title: title,
            author: '작성자', // TODO: 실제 로그인 사용자 정보로 대체
            content: content,
            date: new Date().toLocaleString()
        };
        
        console.log('새 게시글 생성:', post);
        
        // 게시글 목록에 추가
        posts.push(post);
        
        // localStorage에 저장
        savePostsToStorage();
        
        console.log('저장된 전체 게시글:', posts);
        
        alert('게시글이 등록되었습니다.');
        
        // 목록 페이지로 이동
        location.href = contextPath + '/meeting-gather.jsp';
    }
    
    /**
     * 이벤트 리스너 설정
     */
    function setupEventListeners() {
        // 폼 제출 이벤트
        document.getElementById('write-form').addEventListener('submit', handleSubmit);
        
        // 뒤로가기 경고
        let isSubmitting = false;
        
        document.getElementById('write-form').addEventListener('submit', function() {
            isSubmitting = true;
        });
        
        window.addEventListener('beforeunload', function(e) {
            if (!isSubmitting) {
                const title = document.getElementById('post-title').value.trim();
                const content = document.getElementById('board').innerHTML;
                
                if (title || (content && content.trim() !== '')) {
                    e.preventDefault();
                    e.returnValue = '';
                }
            }
        });
    }
    
    // 페이지 로드 완료 시 초기화 실행
    window.onload = init;
</script>

<!-- TipTap 에디터 JavaScript -->
<script type="module">
    import { initEditor } from "./js/editor-init.js";
    
    // 에디터 초기화
    const editor = initEditor(
        document.getElementById("board"),
        document.getElementById("toolbar")
    );
    
    // 이모지 기능
    import * as EmojiModule from "./js/emoji.js";
    window.openEmojiPicker = EmojiModule.openPicker;
    EmojiModule.setupEmojiSuggestion(editor);
</script>
</body>
</html>