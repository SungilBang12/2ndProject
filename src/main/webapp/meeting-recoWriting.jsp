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
    <link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">
    
    <!-- 카카오맵 API -->
 <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=e&libraries=services"></script>
 
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
            .write-container {
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
    <div class="slot-board">
        <div class="write-container">
        <!-- 페이지 헤더 -->
        <div class="page-header">
            <h1 class="page-title">게시글 작성</h1>
            <a href="${pageContext.request.contextPath}/meeting-reco.jsp" class="btn">목록으로</a>
        </div>
        
        <!-- 안내 메시지 -->
        <div class="info-message">
            <p>📍 우리가 모일 장소를 지도에서 검색하고 선택해주세요!</p>
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
            
            <!-- 작성자 -->
            <div class="form-group">
                <label for="post-author">
                    작성자 <span class="required">*</span>
                </label>
                <input 
                    type="text" 
                    id="post-author" 
                    name="author" 
                    class="form-control" 
                    placeholder="작성자명을 입력하세요"
                    required 
                    maxlength="50">
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
                    placeholder="내용을 입력하세요&#10;&#10;예시:&#10;- 모임 날짜 및 시간&#10;- 노을 촬영 팁&#10;- 준비물&#10;- 기타 안내사항"
                    required></textarea>
                <div class="form-help">모임에 대한 상세 정보를 작성해주세요.</div>
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
                
                <div class="form-help">지도에서 마커를 클릭하여 장소를 선택하세요.</div>
            </div>
            
            <!-- 버튼 그룹 -->
            <div class="button-group">
                <a href="${pageContext.request.contextPath}/meeting-reco.jsp" class="btn btn-secondary">취소</a>
                <button type="submit" class="btn btn-primary">등록하기</button>
            </div>
        </form>
        </div>
    </div>
</main>

    <script>
        /**
         * 게시글 작성 페이지 스크립트 (카카오맵 연동)
         * localStorage를 사용한 클라이언트 사이드 데이터 관리
         * TODO: 추후 서버 사이드 API로 전환 필요
         */
        
        // JSP contextPath를 JavaScript 변수로 전달
        var contextPath = '${pageContext.request.contextPath}';
        
        // ============================================
        // 전역 변수
        // ============================================
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
            // 데이터 로드
            loadPostsFromStorage();
            
            // 디버깅: 현재 저장된 게시글 확인
            console.log('=== 페이지 로드 시 저장된 게시글 ===');
            console.log('게시글 개수:', posts.length);
            console.log('게시글 목록:', posts);
            console.log('localStorage raw data:', localStorage.getItem('posts'));
            
            // 카카오맵 초기화
            initKakaoMap();
            
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
            // 카카오맵 API가 로드되지 않았을 때 안전하게 처리
            if (typeof kakao === 'undefined' || !kakao.maps) {
                console.warn('⚠️ 카카오맵 API가 로드되지 않았습니다.');
                var mapContainer = document.getElementById('map');
                if (mapContainer) {
                    mapContainer.innerHTML = '<div style="padding:40px;text-align:center;color:#666;background:#f8f9fa;border-radius:8px;">' +
                        '📍 카카오맵을 사용하려면 API 키가 필요합니다.<br>' +
                        '<small style="color:#999;margin-top:8px;display:block;">장소 선택 없이도 게시글 작성은 가능합니다.</small>' +
                        '</div>';
                }
                return;
            }
            
            try {
                const mapContainer = document.getElementById('map');
                const mapOption = {
                    center: new kakao.maps.LatLng(37.566826, 126.9786567), // 서울 중심
                    level: 5
                };
                
                // 지도 생성
                map = new kakao.maps.Map(mapContainer, mapOption);
                
                // 장소 검색 객체 생성
                ps = new kakao.maps.services.Places();
                
                // 인포윈도우 생성
                infowindow = new kakao.maps.InfoWindow({ zIndex: 1 });
                
                console.log('✅ 카카오맵 초기화 완료');
            } catch (error) {
                console.error('카카오맵 초기화 실패:', error);
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
            
            // 카카오맵 API가 로드되지 않았을 때
            if (typeof kakao === 'undefined' || !kakao.maps || !ps) {
                alert('카카오맵 API가 로드되지 않아 장소 검색을 사용할 수 없습니다.\n장소 없이 게시글을 작성하거나, API 키를 설정해주세요.');
                return;
            }
            
            // 카카오 장소 검색 실행
            ps.keywordSearch(keyword, handleSearchCallback);
        }
        
        /**
         * 장소 검색 결과 콜백 함수
         * @param {Array} data - 검색 결과 데이터
         * @param {string} status - 검색 상태
         * @param {Object} pagination - 페이지네이션 정보
         */
        function handleSearchCallback(data, status, pagination) {
            if (status === kakao.maps.services.Status.OK) {
                // 검색 성공 - 결과 표시
                displaySearchResults(data);
            } else if (status === kakao.maps.services.Status.ZERO_RESULT) {
                alert('검색 결과가 없습니다. 다른 키워드로 검색해보세요.');
            } else if (status === kakao.maps.services.Status.ERROR) {
                alert('검색 중 오류가 발생했습니다.');
            }
        }
        
        /**
         * 검색 결과를 지도에 표시
         * @param {Array} places - 검색된 장소 목록
         */
        function displaySearchResults(places) {
            // 기존 마커 제거
            removeAllMarkers();
            
            // 검색 결과 범위를 담을 객체
            const bounds = new kakao.maps.LatLngBounds();
            
            // 각 장소에 대해 마커 생성
            places.forEach((place, index) => {
                const position = new kakao.maps.LatLng(place.y, place.x);
                const marker = createMarker(position, place, index);
                
                bounds.extend(position);
            });
            
            // 검색된 장소들이 모두 보이도록 지도 범위 재설정
            map.setBounds(bounds);
        }
        
        /**
         * 마커 생성 및 이벤트 등록
         * @param {Object} position - 마커 위치
         * @param {Object} place - 장소 정보
         * @param {number} index - 마커 인덱스
         * @return {Object} 생성된 마커
         */
        function createMarker(position, place, index) {
            // 마커 이미지 설정
            const imageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_number_blue.png';
            const imageSize = new kakao.maps.Size(36, 37);
            const imgOptions = {
                spriteSize: new kakao.maps.Size(36, 691),
                spriteOrigin: new kakao.maps.Point(0, (index * 46) + 10),
                offset: new kakao.maps.Point(13, 37)
            };
            const markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imgOptions);
            
            // 마커 생성
            const marker = new kakao.maps.Marker({
                position: position,
                image: markerImage,
                map: map
            });
            
            // 마커 클릭 이벤트
            kakao.maps.event.addListener(marker, 'click', function() {
                showPlaceInfo(marker, place);
            });
            
            // 마커 배열에 추가
            markers.push(marker);
            
            return marker;
        }
        
        /**
         * 장소 정보 인포윈도우 표시
         * @param {Object} marker - 마커 객체
         * @param {Object} place - 장소 정보
         */
        function showPlaceInfo(marker, place) {
            // 템플릿 리터럴 대신 문자열 연결 사용
            var phoneHtml = place.phone ? '<div style="font-size: 12px; color: #666; margin-bottom: 8px;">☎ ' + place.phone + '</div>' : '';
            
            var content = '<div style="padding: 10px; min-width: 200px;">' +
                '<div style="font-weight: bold; margin-bottom: 5px;">' + place.place_name + '</div>' +
                '<div style="font-size: 12px; color: #666; margin-bottom: 5px;">' +
                    (place.road_address_name || place.address_name) +
                '</div>' +
                phoneHtml +
                '<button onclick="selectPlace(\'' + escapeQuotes(place.place_name) + '\', ' + place.y + ', ' + place.x + ', ' +
                    '\'' + escapeQuotes(place.road_address_name || place.address_name) + '\', \'' + escapeQuotes(place.phone || '') + '\')" ' +
                    'style="width: 100%; padding: 6px; background: #007bff; color: white; ' +
                    'border: none; border-radius: 4px; cursor: pointer; font-size: 13px;">' +
                    '선택하기' +
                '</button>' +
            '</div>';
            
            infowindow.setContent(content);
            infowindow.open(map, marker);
        }
        
        /**
         * 따옴표 이스케이프 처리
         */
        function escapeQuotes(str) {
            return str.replace(/'/g, "\\'").replace(/"/g, '\\"');
        }
        
        /**
         * 장소 선택 처리
         * @param {string} name - 장소명
         * @param {number} lat - 위도
         * @param {number} lng - 경도
         * @param {string} address - 주소
         * @param {string} phone - 전화번호
         */
        function selectPlace(name, lat, lng, address, phone) {
            // 선택된 장소 정보 저장
            selectedPlace = {
                name: name,
                lat: parseFloat(lat),
                lng: parseFloat(lng),
                address: address,
                phone: phone,
                keyword: document.getElementById('keyword').value.trim()
            };
            
            // 선택된 장소 표시
            document.getElementById('selected-place').style.display = 'block';
            document.getElementById('selected-place-name').textContent = 
                name + ' (' + address + ')';
            
            // 인포윈도우 닫기
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
            const storedPosts = localStorage.getItem('postsreco');
            posts = storedPosts ? JSON.parse(storedPosts) : [];
        }
        
        /**
         * localStorage에 게시글 저장
         */
        function savePostsToStorage() {
            localStorage.setItem('postsreco', JSON.stringify(posts));
        }
        
        
        // ============================================
        // 폼 관리 함수
        // ============================================
        
        /**
         * 폼 제출 처리
         * @param {Event} e - Form submit 이벤트
         */
        function handleSubmit(e) {
            e.preventDefault();
            
            // 폼 데이터 가져오기
            const title = document.getElementById('post-title').value.trim();
            const author = document.getElementById('post-author').value.trim();
            const content = document.getElementById('post-content').value.trim();
            
            // 유효성 검사
            if (!validateForm(title, author, content)) {
                return;
            }
            
            // 게시글 작성
            createPost(title, author, content);
        }
        
        /**
         * 폼 유효성 검사
         * @param {string} title - 제목
         * @param {string} author - 작성자
         * @param {string} content - 내용
         * @return {boolean} 유효성 검사 결과
         */
        function validateForm(title, author, content) {
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
            
            if (!author) {
                alert('작성자를 입력해주세요.');
                document.getElementById('post-author').focus();
                return false;
            }
            
            if (author.length > 50) {
                alert('작성자명은 50자 이내로 입력해주세요.');
                document.getElementById('post-author').focus();
                return false;
            }
            
            if (!content) {
                alert('내용을 입력해주세요.');
                document.getElementById('post-content').focus();
                return false;
            }
            
            // 장소는 선택사항으로 변경 (카카오맵 API 없을 때 대비)
            if (!selectedPlace) {
                var confirmResult = confirm('장소를 선택하지 않았습니다.\n장소 없이 게시글을 등록하시겠습니까?');
                if (!confirmResult) {
                    document.getElementById('keyword').focus();
                    return false;
                }
            }
            
            return true;
        }
        
        
        // ============================================
        // 게시글 관리 함수
        // ============================================
        
        /**
         * 새 게시글 생성
         * @param {string} title - 제목
         * @param {string} author - 작성자
         * @param {string} content - 내용
         */
        function createPost(title, author, content) {
            // 게시글 객체 생성 (장소 정보 포함)
            const post = {
                id: Date.now(),
                title: title,
                author: author,
                content: content,
                place: selectedPlace,  // 선택된 장소 정보 저장
                date: new Date().toLocaleString()
            };
            
            console.log('새 게시글 생성:', post);
            
            // 게시글 목록에 추가
            posts.push(post);
            
            // localStorage에 저장
            savePostsToStorage();
            
            // 저장 확인
            console.log('저장된 전체 게시글:', posts);
            console.log('localStorage 확인:', localStorage.getItem('postsreco'));
            
            alert('게시글이 등록되었습니다.');
            
            // 목록 페이지로 이동
            location.href = contextPath + '/meeting-reco.jsp';
        }
        
        
        // ============================================
        // 유틸리티 함수
        // ============================================
        
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
                    const author = document.getElementById('post-author').value.trim();
                    const content = document.getElementById('post-content').value.trim();
                    
                    if (title || author || content || selectedPlace) {
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