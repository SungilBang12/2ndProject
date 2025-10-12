<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>노을 맛집 - '해'쳐 모여 게시판 수정</title>
    
    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    <link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">
    
    <!-- 카카오맵 API -->
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=YOUR_APP_KEY&libraries=services"></script>
    
    <!-- 수정 페이지 전용 CSS -->
    <style>
        /* 기본 레이아웃 */
        body {
            margin: 0;
        }
        
        .edit-container {
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
        .edit-form {
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
        
        .form-control.readonly {
            background-color: #f8f9fa;
            cursor: not-allowed;
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
        
        /* 장소 검색 영역 */
        .search-box {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
        }
        
        .search-box .form-control {
            flex: 1;
        }
        
        .search-box .btn {
            padding: 12px 24px;
            white-space: nowrap;
        }
        
        /* 카카오맵 */
        #map {
            width: 100%;
            height: 400px;
            border: 2px solid #ddd;
            border-radius: 8px;
            margin-top: 15px;
        }
        
        /* 선택된 장소 표시 */
        .selected-place {
            margin-top: 15px;
            padding: 15px;
            background-color: #e7f3ff;
            border-left: 4px solid #007bff;
            border-radius: 4px;
        }
        
        .selected-place strong {
            color: #004085;
            display: block;
            margin-bottom: 5px;
        }
        
        .selected-place p {
            margin: 0;
            color: #004085;
            font-size: 14px;
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
        
        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .edit-container {
                padding: 20px;
            }
            
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .search-box {
                flex-direction: column;
            }
            
            .search-box .btn {
                width: 100%;
            }
            
            #map {
                height: 300px;
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

    <!-- 메인 컨텐츠 영역 -->
    <div class="edit-container">
        <!-- 페이지 헤더 -->
        <div class="page-header">
            <h1 class="page-title">게시글 수정</h1>
            <a href="${pageContext.request.contextPath}/meeting-gatherList.jsp" class="btn">목록으로</a>
        </div>
        
        <!-- 안내 메시지 -->
        <div class="info-message">
            <p>게시글의 정보를 수정할 수 있습니다. 장소를 변경하려면 새로 검색해주세요.</p>
        </div>
        
        <!-- 수정 폼 -->
        <form id="edit-form" class="edit-form">
            <!-- 숨김 필드: 게시글 ID -->
            <input type="hidden" id="post-id" name="id">
            
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
            </div>
            
            <!-- 작성자 (읽기 전용) -->
            <div class="form-group">
                <label for="post-author">작성자</label>
                <input 
                    type="text" 
                    id="post-author" 
                    name="author" 
                    class="form-control readonly" 
                    readonly>
            </div>
            
            <!-- 작성일 (읽기 전용) -->
            <div class="form-group">
                <label for="post-date">작성일</label>
                <input 
                    type="text" 
                    id="post-date" 
                    class="form-control readonly" 
                    readonly>
            </div>
            
            <!-- 내용 -->
            <div class="form-group">
                <label for="post-content">
                    내용 <span class="required">*</span>
                </label>
                <textarea 
                    id="post-content" 
                    name="content" 
                    class="form-control" 
                    placeholder="내용을 입력하세요"
                    required></textarea>
            </div>
            
            <!-- 장소 검색 -->
            <div class="form-group">
                <label for="keyword">
                    노을 촬영 장소 <span class="required">*</span>
                </label>
                <div class="search-box">
                    <input 
                        type="text" 
                        id="keyword" 
                        class="form-control" 
                        placeholder="예: 한강공원, 남산타워, 마포대교"
                        onkeypress="if(event.key === 'Enter') { event.preventDefault(); searchPlaces(); }">
                    <button type="button" class="btn btn-primary" onclick="searchPlaces()">🔍 검색</button>
                </div>
                
                <!-- 카카오맵 -->
                <div id="map"></div>
                
                <!-- 선택된 장소 표시 -->
                <div id="selected-place" class="selected-place" style="display: none;">
                    <strong>✓ 선택된 장소</strong>
                    <p id="selected-place-name"></p>
                </div>
                
                <div class="form-help">장소를 변경하려면 새로 검색하여 선택하세요.</div>
            </div>
            
            <!-- 버튼 그룹 -->
            <div class="button-group">
                <a href="${pageContext.request.contextPath}/meeting-gatherList.jsp" class="btn btn-secondary">취소</a>
                <button type="submit" class="btn btn-primary">수정 완료</button>
            </div>
        </form>
    </div>
</main>

    <script>
        /**
         * 게시글 수정 페이지 스크립트 (카카오맵 연동)
         * localStorage를 사용한 클라이언트 사이드 데이터 관리
         * TODO: 추후 서버 사이드 API로 전환 필요
         */
        
        // ============================================
        // 전역 변수
        // ============================================
        let currentPostId = null;    // 현재 수정 중인 게시글 ID
        let posts = [];              // 게시글 목록
        let map = null;              // 카카오맵 객체
        let ps = null;               // 장소 검색 객체
        let infowindow = null;       // 인포윈도우 객체
        let markers = [];            // 마커 배열
        let selectedPlace = null;    // 선택된 장소 정보
        
        
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
            
            // 카카오맵 초기화
            initKakaoMap();
            
            // 게시글 정보 폼에 채우기
            loadPostToForm();
            
            // 이벤트 리스너 등록
            setupEventListeners();
        }
        
        
        // ============================================
        // 카카오맵 관련 함수
        // ============================================
        
        /**
         * 카카오맵 초기화
         */
        function initKakaoMap() {
            const mapContainer = document.getElementById('map');
            const mapOption = {
                center: new kakao.maps.LatLng(37.566826, 126.9786567),
                level: 5
            };
            
            map = new kakao.maps.Map(mapContainer, mapOption);
            ps = new kakao.maps.services.Places();
            infowindow = new kakao.maps.InfoWindow({ zIndex: 1 });
        }
        
        /**
         * 기존 장소를 지도에 표시
         * @param {Object} place - 장소 정보
         */
        function displayExistingPlace(place) {
            if (!place || !place.lat || !place.lng) {
                return;
            }
            
            // 지도 중심을 해당 장소로 이동
            const position = new kakao.maps.LatLng(place.lat, place.lng);
            map.setCenter(position);
            map.setLevel(3);
            
            // 마커 생성
            const marker = new kakao.maps.Marker({
                position: position,
                map: map
            });
            
            markers.push(marker);
            
            // 인포윈도우 표시
            const content = `<div style="padding: 10px; font-weight: bold;">${place.name}</div>`;
            infowindow.setContent(content);
            infowindow.open(map, marker);
            
            // 선택된 장소로 설정
            selectedPlace = place;
            document.getElementById('selected-place').style.display = 'block';
            document.getElementById('selected-place-name').textContent = 
                `${place.name} (${place.address})`;
            
            // 검색 키워드 입력
            if (place.keyword) {
                document.getElementById('keyword').value = place.keyword;
            }
        }
        
        /**
         * 장소 검색 실행
         */
        function searchPlaces() {
            const keyword = document.getElementById('keyword').value.trim();
            
            if (!keyword) {
                alert('검색할 장소를 입력해주세요!');
                document.getElementById('keyword').focus();
                return;
            }
            
            ps.keywordSearch(keyword, handleSearchCallback);
        }
        
        /**
         * 장소 검색 결과 콜백 함수
         */
        function handleSearchCallback(data, status, pagination) {
            if (status === kakao.maps.services.Status.OK) {
                displaySearchResults(data);
            } else if (status === kakao.maps.services.Status.ZERO_RESULT) {
                alert('검색 결과가 없습니다. 다른 키워드로 검색해보세요.');
            } else if (status === kakao.maps.services.Status.ERROR) {
                alert('검색 중 오류가 발생했습니다.');
            }
        }
        
        /**
         * 검색 결과를 지도에 표시
         */
        function displaySearchResults(places) {
            removeAllMarkers();
            
            const bounds = new kakao.maps.LatLngBounds();
            
            places.forEach((place, index) => {
                const position = new kakao.maps.LatLng(place.y, place.x);
                const marker = createMarker(position, place, index);
                bounds.extend(position);
            });
            
            map.setBounds(bounds);
        }
        
        /**
         * 마커 생성 및 이벤트 등록
         */
        function createMarker(position, place, index) {
            const imageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_number_blue.png';
            const imageSize = new kakao.maps.Size(36, 37);
            const imgOptions = {
                spriteSize: new kakao.maps.Size(36, 691),
                spriteOrigin: new kakao.maps.Point(0, (index * 46) + 10),
                offset: new kakao.maps.Point(13, 37)
            };
            const markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imgOptions);
            
            const marker = new kakao.maps.Marker({
                position: position,
                image: markerImage,
                map: map
            });
            
            kakao.maps.event.addListener(marker, 'click', function() {
                showPlaceInfo(marker, place);
            });
            
            markers.push(marker);
            return marker;
        }
        
        /**
         * 장소 정보 인포윈도우 표시
         */
        function showPlaceInfo(marker, place) {
            const content = `
                <div style="padding: 10px; min-width: 200px;">
                    <div style="font-weight: bold; margin-bottom: 5px;">${place.place_name}</div>
                    <div style="font-size: 12px; color: #666; margin-bottom: 5px;">
                        ${place.road_address_name || place.address_name}
                    </div>
                    ${place.phone ? '<div style="font-size: 12px; color: #666; margin-bottom: 8px;">☎ ' + place.phone + '</div>' : ''}
                    <button onclick="selectPlace('${place.place_name}', ${place.y}, ${place.x}, 
                        '${place.road_address_name || place.address_name}', '${place.phone || ''}')" 
                        style="width: 100%; padding: 6px; background: #007bff; color: white; 
                        border: none; border-radius: 4px; cursor: pointer; font-size: 13px;">
                        선택하기
                    </button>
                </div>
            `;
            
            infowindow.setContent(content);
            infowindow.open(map, marker);
        }
        
        /**
         * 장소 선택 처리
         */
        function selectPlace(name, lat, lng, address, phone) {
            selectedPlace = {
                name: name,
                lat: parseFloat(lat),
                lng: parseFloat(lng),
                address: address,
                phone: phone,
                keyword: document.getElementById('keyword').value.trim()
            };
            
            document.getElementById('selected-place').style.display = 'block';
            document.getElementById('selected-place-name').textContent = 
                `${name} (${address})`;
            
            infowindow.close();
        }
        
        /**
         * 모든 마커 제거
         */
        function removeAllMarkers() {
            markers.forEach(marker => marker.setMap(null));
            markers = [];
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
         * localStorage에 게시글 저장
         */
        function savePostsToStorage() {
            localStorage.setItem('posts', JSON.stringify(posts));
        }
        
        
        // ============================================
        // 폼 관리 함수
        // ============================================
        
        /**
         * 수정할 게시글 정보를 폼에 로드
         */
        function loadPostToForm() {
            const post = posts.find(p => p.id === currentPostId);
            
            if (!post) {
                alert('게시글을 찾을 수 없습니다.');
                location.href = '${pageContext.request.contextPath}/meeting-gatherList.jsp';
                return;
            }
            
            // 폼 필드에 값 채우기
            document.getElementById('post-id').value = post.id;
            document.getElementById('post-title').value = post.title || '';
            document.getElementById('post-author').value = post.author || '익명';
            document.getElementById('post-date').value = post.date || '-';
            document.getElementById('post-content').value = post.content || '';
            
            // 장소 정보가 있으면 지도에 표시
            if (post.place) {
                displayExistingPlace(post.place);
            }
        }
        
        /**
         * 폼 제출 처리
         */
        function handleSubmit(e) {
            e.preventDefault();
            
            const title = document.getElementById('post-title').value.trim();
            const content = document.getElementById('post-content').value.trim();
            
            if (!validateForm(title, content)) {
                return;
            }
            
            updatePost(title, content);
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
            
            if (!content) {
                alert('내용을 입력해주세요.');
                document.getElementById('post-content').focus();
                return false;
            }
            
            if (!selectedPlace) {
                alert('노을 촬영 장소를 선택해주세요.');
                document.getElementById('keyword').focus();
                return false;
            }
            
            return true;
        }
        
        
        // ============================================
        // 게시글 관리 함수
        // ============================================
        
        /**
         * 게시글 정보 업데이트
         */
        function updatePost(title, content) {
            const post = posts.find(p => p.id === currentPostId);
            
            if (!post) {
                alert('게시글을 찾을 수 없습니다.');
                return;
            }
            
            // 게시글 정보 업데이트
            post.title = title;
            post.content = content;
            post.place = selectedPlace;  // 장소 정보도 업데이트
            post.updatedAt = new Date().toLocaleString();
            
            savePostsToStorage();
            
            alert('게시글이 수정되었습니다.');
            location.href = '${pageContext.request.contextPath}/meeting-gatherDetail.jsp?id=' + currentPostId;
        }
        
        
        // ============================================
        // 유틸리티 함수
        // ============================================
        
        /**
         * URL에서 게시글 ID 추출
         */
        function getPostIdFromUrl() {
            const urlParams = new URLSearchParams(window.location.search);
            const id = urlParams.get('id');
            return id ? parseInt(id) : null;
        }
        
        /**
         * 이벤트 리스너 설정
         */
        function setupEventListeners() {
            document.getElementById('edit-form').addEventListener('submit', handleSubmit);
            
            let isSubmitting = false;
            
            document.getElementById('edit-form').addEventListener('submit', function() {
                isSubmitting = true;
            });
            
            window.addEventListener('beforeunload', function(e) {
                if (!isSubmitting) {
                    const title = document.getElementById('post-title').value.trim();
                    const content = document.getElementById('post-content').value.trim();
                    
                    if (title || content) {
                        e.preventDefault();
                        e.returnValue = '';
                    }
                }
            });
        }
        
        
        // ============================================
        // 이벤트 리스너 및 초기 실행
        // ============================================
        
        // 페이지 로드 완료 시 초기화 실행
        window.onload = init;
    </script>
</body>
</html>