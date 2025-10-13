/**
 * 카카오맵 모듈
 * 장소 검색 및 선택 기능
 */

// ============================================
// 전역 변수
// ============================================
let kakaoMap = null;              // 카카오맵 객체
let kakaoPs = null;               // 장소 검색 객체
let kakaoInfowindow = null;       // 인포윈도우 객체
let kakaoMarkers = [];            // 마커 배열
let kakaoSelectedPlace = null;    // 선택된 장소 정보

// ============================================
// 초기화 함수
// ============================================

/**
 * 카카오맵 초기화
 */
function initKakaoMap() {
    // 카카오맵 API가 로드되지 않았을 때 안전하게 처리
    if (typeof kakao === 'undefined' || !kakao.maps) {
        console.warn('⚠️ 카카오맵 API가 로드되지 않았습니다.');
        const mapContainer = document.getElementById('kakaomap-container');
        if (mapContainer) {
            mapContainer.innerHTML = '<div style="padding:40px;text-align:center;color:#666;background:#f8f9fa;border-radius:8px;">' +
                '📍 카카오맵을 사용하려면 API 키가 필요합니다.<br>' +
                '<small style="color:#999;margin-top:8px;display:block;">장소 선택 없이도 게시글 작성은 가능합니다.</small>' +
                '</div>';
        }
        return false;
    }
    
    try {
        const mapContainer = document.getElementById('kakaomap-container');
        const mapOption = {
            center: new kakao.maps.LatLng(37.566826, 126.9786567), // 서울 중심
            level: 5
        };
        
        // 지도 생성
        kakaoMap = new kakao.maps.Map(mapContainer, mapOption);
        
        // 장소 검색 객체 생성
        kakaoPs = new kakao.maps.services.Places();
        
        // 인포윈도우 생성
        kakaoInfowindow = new kakao.maps.InfoWindow({ zIndex: 1 });
        
        console.log('✅ 카카오맵 초기화 완료');
        return true;
    } catch (error) {
        console.error('카카오맵 초기화 실패:', error);
        return false;
    }
}

// ============================================
// 모달 제어 함수
// ============================================

/**
 * 카카오맵 모달 열기
 */
function openKakaoMapModal() {
    const modal = document.getElementById('kakaomap-modal');
    modal.style.display = 'block';
    
    // 모달이 열릴 때 지도 초기화 (아직 초기화되지 않았을 경우)
    if (!kakaoMap) {
        setTimeout(() => {
            if (initKakaoMap()) {
                // 지도 크기 재조정 (모달 내부에서 올바르게 표시되도록)
                kakao.maps.event.trigger(kakaoMap, 'resize');
                kakaoMap.setCenter(new kakao.maps.LatLng(37.566826, 126.9786567));
            }
        }, 100);
    } else {
        // 이미 초기화된 경우 지도 크기 재조정
        setTimeout(() => {
            kakao.maps.event.trigger(kakaoMap, 'resize');
            kakaoMap.setCenter(new kakao.maps.LatLng(37.566826, 126.9786567));
        }, 100);
    }
    
    // 키워드 입력 필드에 포커스
    document.getElementById('kakaomap-keyword').focus();
}

/**
 * 카카오맵 모달 닫기
 */
function closeKakaoMapModal() {
    const modal = document.getElementById('kakaomap-modal');
    modal.style.display = 'none';
    
    // 선택 정보 초기화 (선택 취소)
    resetKakaoSelection();
}

/**
 * 선택 정보 초기화
 */
function resetKakaoSelection() {
    kakaoSelectedPlace = null;
    document.getElementById('kakaomap-selected-place').style.display = 'none';
    document.getElementById('kakaomap-selected-place-name').textContent = '';
    document.getElementById('kakaomap-keyword').value = '';
    removeAllKakaoMarkers();
}

// ============================================
// 장소 검색 함수
// ============================================

/**
 * 장소 검색 실행
 */
function searchKakaoPlaces() {
    const keyword = document.getElementById('kakaomap-keyword').value.trim();
    
    if (!keyword) {
        alert('검색할 장소를 입력해주세요!');
        document.getElementById('kakaomap-keyword').focus();
        return;
    }
    
    // 카카오맵 API가 로드되지 않았을 때
    if (typeof kakao === 'undefined' || !kakao.maps || !kakaoPs) {
        alert('카카오맵 API가 로드되지 않아 장소 검색을 사용할 수 없습니다.');
        return;
    }
    
    // 카카오 장소 검색 실행
    kakaoPs.keywordSearch(keyword, handleKakaoSearchCallback);
}

/**
 * 장소 검색 결과 콜백 함수
 */
function handleKakaoSearchCallback(data, status, pagination) {
    if (status === kakao.maps.services.Status.OK) {
        // 검색 성공 - 결과 표시
        displayKakaoSearchResults(data);
    } else if (status === kakao.maps.services.Status.ZERO_RESULT) {
        alert('검색 결과가 없습니다. 다른 키워드로 검색해보세요.');
    } else if (status === kakao.maps.services.Status.ERROR) {
        alert('검색 중 오류가 발생했습니다.');
    }
}

/**
 * 검색 결과를 지도에 표시
 */
function displayKakaoSearchResults(places) {
    // 기존 마커 제거
    removeAllKakaoMarkers();
    
    // 검색 결과 범위를 담을 객체
    const bounds = new kakao.maps.LatLngBounds();
    
    // 각 장소에 대해 마커 생성
    places.forEach((place, index) => {
        const position = new kakao.maps.LatLng(place.y, place.x);
        const marker = createKakaoMarker(position, place, index);
        
        bounds.extend(position);
    });
    
    // 검색된 장소들이 모두 보이도록 지도 범위 재설정
    kakaoMap.setBounds(bounds);
}

// ============================================
// 마커 관리 함수
// ============================================

/**
 * 마커 생성 및 이벤트 등록
 */
function createKakaoMarker(position, place, index) {
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
        map: kakaoMap
    });
    
    // 마커 클릭 이벤트
    kakao.maps.event.addListener(marker, 'click', function() {
        showKakaoPlaceInfo(marker, place);
    });
    
    // 마커 배열에 추가
    kakaoMarkers.push(marker);
    
    return marker;
}

/**
 * 장소 정보 인포윈도우 표시
 */
function showKakaoPlaceInfo(marker, place) {
    const phoneHtml = place.phone ? '<div style="font-size: 12px; color: #666; margin-bottom: 8px;">☎ ' + place.phone + '</div>' : '';
    
    const content = '<div style="padding: 10px; min-width: 200px;">' +
        '<div style="font-weight: bold; margin-bottom: 5px;">' + place.place_name + '</div>' +
        '<div style="font-size: 12px; color: #666; margin-bottom: 5px;">' +
            (place.road_address_name || place.address_name) +
        '</div>' +
        phoneHtml +
        '<button onclick="selectKakaoPlace(\'' + escapeQuotes(place.place_name) + '\', ' + place.y + ', ' + place.x + ', ' +
            '\'' + escapeQuotes(place.road_address_name || place.address_name) + '\', \'' + escapeQuotes(place.phone || '') + '\')" ' +
            'style="width: 100%; padding: 6px; background: #007bff; color: white; ' +
            'border: none; border-radius: 4px; cursor: pointer; font-size: 13px;">' +
            '선택하기' +
        '</button>' +
    '</div>';
    
    kakaoInfowindow.setContent(content);
    kakaoInfowindow.open(kakaoMap, marker);
}

/**
 * 모든 마커 제거
 */
function removeAllKakaoMarkers() {
    kakaoMarkers.forEach(marker => marker.setMap(null));
    kakaoMarkers = [];
}

// ============================================
// 장소 선택 함수
// ============================================

/**
 * 장소 선택 처리
 */
function selectKakaoPlace(name, lat, lng, address, phone) {
    // 선택된 장소 정보 저장
    kakaoSelectedPlace = {
        name: name,
        lat: parseFloat(lat),
        lng: parseFloat(lng),
        address: address,
        phone: phone,
        keyword: document.getElementById('kakaomap-keyword').value.trim()
    };
    
    // 선택된 장소 표시
    document.getElementById('kakaomap-selected-place').style.display = 'block';
    document.getElementById('kakaomap-selected-place-name').textContent = 
        name + ' (' + address + ')';
    
    // 인포윈도우 닫기
    kakaoInfowindow.close();
    
    console.log('장소 선택됨:', kakaoSelectedPlace);
}

/**
 * 선택된 장소를 에디터에 삽입
 */
function insertKakaoPlaceToEditor() {
    if (!kakaoSelectedPlace) {
        alert('장소를 먼저 선택해주세요!');
        return;
    }
    
    // 에디터에 장소 정보 삽입
    const placeHtml = `
<div class="place-info" style="padding: 15px; margin: 10px 0; border: 2px solid #007bff; border-radius: 8px; background-color: #f0f8ff;">
    <div style="display: flex; align-items: center; margin-bottom: 8px;">
        <span style="font-size: 20px; margin-right: 8px;">📍</span>
        <strong style="font-size: 16px; color: #007bff;">${kakaoSelectedPlace.name}</strong>
    </div>
    <div style="font-size: 14px; color: #333; margin-bottom: 5px;">
        📌 ${kakaoSelectedPlace.address}
    </div>
    ${kakaoSelectedPlace.phone ? '<div style="font-size: 13px; color: #666;">☎ ' + kakaoSelectedPlace.phone + '</div>' : ''}
    <div style="margin-top: 10px; padding-top: 10px; border-top: 1px solid #e0e0e0;">
        <a href="https://map.kakao.com/link/map/${encodeURIComponent(kakaoSelectedPlace.name)},${kakaoSelectedPlace.lat},${kakaoSelectedPlace.lng}" 
           target="_blank" 
           style="color: #007bff; text-decoration: none; font-size: 13px; margin-right: 10px;">
           🗺️ 지도보기
        </a>
        <a href="https://map.kakao.com/link/to/${encodeURIComponent(kakaoSelectedPlace.name)},${kakaoSelectedPlace.lat},${kakaoSelectedPlace.lng}" 
           target="_blank" 
           style="color: #007bff; text-decoration: none; font-size: 13px;">
           🚗 길찾기
        </a>
    </div>
</div>
    `.trim();
    
    // board 영역에 HTML 삽입
    const board = document.getElementById('board');
    if (board) {
        board.insertAdjacentHTML('beforeend', placeHtml);
        
        // 스크롤을 삽입된 위치로 이동
        board.scrollTop = board.scrollHeight;
    }
    
    // 모달 닫기
    closeKakaoMapModal();
    
    alert('장소가 에디터에 삽입되었습니다! ✅');
}

// ============================================
// 유틸리티 함수
// ============================================

/**
 * 따옴표 이스케이프 처리
 */
function escapeQuotes(str) {
    return str.replace(/'/g, "\\'").replace(/"/g, '\\"');
}

/**
 * 모달 외부 클릭 시 닫기
 */
window.onclick = function(event) {
    const modal = document.getElementById('kakaomap-modal');
    if (event.target === modal) {
        closeKakaoMapModal();
    }
};

// ============================================
// 초기화
// ============================================

/**
 * 카카오맵 버튼 이벤트 리스너 등록
 */
document.addEventListener('DOMContentLoaded', function() {
    const kakaoBtn = document.getElementById('kakaomap-btn');
    if (kakaoBtn) {
        kakaoBtn.addEventListener('click', openKakaoMapModal);
    }
});

// 전역 함수로 export (JSP에서 onclick으로 호출 가능하도록)
window.openKakaoMapModal = openKakaoMapModal;
window.closeKakaoMapModal = closeKakaoMapModal;
window.searchKakaoPlaces = searchKakaoPlaces;
window.selectKakaoPlace = selectKakaoPlace;
window.insertKakaoPlaceToEditor = insertKakaoPlaceToEditor;