/**
 * 카카오맵 모듈 (TipTap 에디터 통합)
 * map-modal.js 스타일 + 키워드 검색 기능
 */

// IIFE로 전역 스코프 오염 방지하면서 export 문제 해결
(function() {
  'use strict';
  
  // CSS 스타일 동적 생성 및 삽입
  function injectModalStyles() {
    // 이미 스타일이 존재하면 추가하지 않음
    if (document.getElementById('kakaomap-modal-styles')) return;
    
    const style = document.createElement('style');
    style.id = 'kakaomap-modal-styles';
    style.textContent = `
      /* 모달 오버레이 (화면 전체를 덮는 반투명 배경) */
      .kakaomap-modal {
        display: none;
        position: fixed;
        z-index: 9999;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        overflow: auto;
        background-color: rgba(0, 0, 0, 0.5);
        animation: fadeIn 0.2s;
      }
      
      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }
      
      /* 모달 콘텐츠 박스 (중앙 배치) */
      .kakaomap-modal-content {
        position: relative;
        background-color: #fff;
        margin: 5% auto;
        padding: 0;
        border-radius: 12px;
        width: 90%;
        max-width: 700px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
        animation: slideDown 0.3s;
      }
      
      @keyframes slideDown {
        from {
          transform: translateY(-50px);
          opacity: 0;
        }
        to {
          transform: translateY(0);
          opacity: 1;
        }
      }
      
      /* 헤더 */
      .kakaomap-modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px 24px;
        border-bottom: 1px solid #e0e0e0;
      }
      
      .kakaomap-modal-header h3 {
        margin: 0;
        font-size: 20px;
        font-weight: 600;
        color: #333;
      }
      
      .kakaomap-close {
        background: none;
        border: none;
        font-size: 32px;
        font-weight: 300;
        color: #999;
        cursor: pointer;
        padding: 0;
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: color 0.2s;
      }
      
      .kakaomap-close:hover {
        color: #333;
      }
      
      /* 바디 */
      .kakaomap-modal-body {
        padding: 24px;
      }
      
      /* 검색 박스 */
      .kakaomap-search-box {
        display: flex;
        gap: 8px;
        margin-bottom: 16px;
      }
      
      .kakaomap-input {
        flex: 1;
        padding: 12px 16px;
        border: 1px solid #ddd;
        border-radius: 8px;
        font-size: 14px;
        transition: border-color 0.2s;
      }
      
      .kakaomap-input:focus {
        outline: none;
        border-color: #4CAF50;
      }
      
      .kakaomap-search-btn {
        padding: 12px 24px;
        background-color: #4CAF50;
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: background-color 0.2s;
        white-space: nowrap;
      }
      
      .kakaomap-search-btn:hover {
        background-color: #45a049;
      }
      
      /* 지도 컨테이너 */
      .kakaomap-container {
        width: 100%;
        height: 400px;
        border-radius: 8px;
        overflow: hidden;
        border: 1px solid #ddd;
      }
      
      /* 선택된 정보 */
      .kakaomap-selected-info {
        margin-top: 16px;
        padding: 12px 16px;
        background-color: #f5f5f5;
        border-radius: 8px;
        font-size: 14px;
        line-height: 1.6;
        color: #333;
        min-height: 60px;
      }
      
      /* 푸터 */
      .kakaomap-modal-footer {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        padding: 20px 24px;
        border-top: 1px solid #e0e0e0;
      }
      
      /* 버튼 공통 스타일 */
      .kakaomap-modal-footer button {
        padding: 10px 20px;
        border: none;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
      }
      
      .kakaomap-btn-secondary {
        background-color: #f5f5f5;
        color: #666;
      }
      
      .kakaomap-btn-secondary:hover {
        background-color: #e0e0e0;
      }
      
      .kakaomap-btn-danger {
        background-color: #f44336;
        color: white;
      }
      
      .kakaomap-btn-danger:hover {
        background-color: #d32f2f;
      }
      
      .kakaomap-btn-primary {
        background-color: #2196F3;
        color: white;
      }
      
      .kakaomap-btn-primary:hover {
        background-color: #1976D2;
      }
      
      .kakaomap-btn-primary:disabled {
        background-color: #ccc;
        cursor: not-allowed;
      }
      
      /* 반응형 디자인 */
      @media (max-width: 768px) {
        .kakaomap-modal-content {
          width: 95%;
          margin: 2% auto;
        }
        
        .kakaomap-container {
          height: 300px;
        }
        
        .kakaomap-search-box {
          flex-direction: column;
        }
        
        .kakaomap-search-btn {
          width: 100%;
        }
      }
    `;
    
    document.head.appendChild(style);
  }
  
  /**
   * 카카오맵 모달 열기
   * @param {Editor} editor - TipTap 에디터 인스턴스
   */
  function openKakaoMapModal(editor) {
    // CSS 스타일 주입
    injectModalStyles();
    
    // 에디터에서 기존 kakaoMap 노드 찾기
    let existingMapNode = null;
    let existingMapPos = null;

    editor.state.doc.descendants((node, pos) => {
      if (node.type.name === 'kakaoMap') {
        existingMapNode = node;
        existingMapPos = pos;
        return false; // 첫 번째 지도만 찾음
      }
    });

    // 모달 생성
    const modal = document.createElement("div");
    modal.className = "kakaomap-modal";
    modal.innerHTML = `
      <div class="kakaomap-modal-content">
        <div class="kakaomap-modal-header">
          <h3>${existingMapNode ? '📍 지도 수정' : '📍 위치 선택'}</h3>
          <button type="button" class="kakaomap-close">&times;</button>
        </div>
        
        <div class="kakaomap-modal-body">
          <div class="kakaomap-search-box">
            <input 
              type="text" 
              id="kakaomap-search-input" 
              class="kakaomap-input" 
              placeholder="주소 또는 장소명 검색 (예: 한강공원, 남산타워)">
            <button type="button" id="kakaomap-search-btn" class="kakaomap-search-btn">
              🔍 검색
            </button>
          </div>
          
          <div id="kakaomap-container" class="kakaomap-container"></div>
          
          <div id="kakaomap-selected-info" class="kakaomap-selected-info">
            ${existingMapNode ? existingMapNode.attrs.label : '지도를 클릭하거나 주소를 검색하세요'}
          </div>
        </div>
        
        <div class="kakaomap-modal-footer">
          <button type="button" id="kakaomap-cancel-btn" class="kakaomap-btn-secondary">
            취소
          </button>
          ${existingMapNode ? `
            <button type="button" id="kakaomap-delete-btn" class="kakaomap-btn-danger">
              삭제
            </button>
          ` : ''}
          <button 
            type="button" 
            id="kakaomap-confirm-btn" 
            class="kakaomap-btn-primary" 
            ${existingMapNode ? '' : 'disabled'}>
            ${existingMapNode ? '수정 완료' : '선택 완료'}
          </button>
        </div>
      </div>
    `;
    
    document.body.appendChild(modal);
    modal.style.display = "block";

    // 카카오맵 초기화
    const container = modal.querySelector("#kakaomap-container");
    const geocoder = new kakao.maps.services.Geocoder();
    const places = new kakao.maps.services.Places();
    
    // 기존 지도가 있으면 해당 위치로, 없으면 서울로
    const initialLat = existingMapNode ? existingMapNode.attrs.lat : 37.5665;
    const initialLng = existingMapNode ? existingMapNode.attrs.lng : 126.9780;
    
    const map = new kakao.maps.Map(container, { 
      center: new kakao.maps.LatLng(initialLat, initialLng), 
      level: 3
    });
    
    let marker = null;
    let infowindow = null;
    let selectedData = existingMapNode ? {
      lat: existingMapNode.attrs.lat,
      lng: existingMapNode.attrs.lng,
      address: existingMapNode.attrs.label,
      roadAddress: ""
    } : null;

    // 기존 마커가 있으면 표시
    if (existingMapNode) {
      const latlng = new kakao.maps.LatLng(existingMapNode.attrs.lat, existingMapNode.attrs.lng);
      placeMarker(latlng, existingMapNode.attrs.label, "");
    }

    // 모달 크기 재조정 (카카오맵 렌더링)
    setTimeout(() => {
      kakao.maps.event.trigger(map, 'resize');
      map.setCenter(new kakao.maps.LatLng(initialLat, initialLng));
    }, 100);

    // ============================================
    // 마커 생성 및 관리
    // ============================================
    
    /**
     * 마커와 인포윈도우 생성
     * 항상 하나의 마커만 유지 (기존 마커 자동 제거)
     */
    function placeMarker(latlng, addressName, roadAddress) {
      // 기존 마커와 인포윈도우 제거 (하나의 위치만 선택 가능)
      if (marker) marker.setMap(null);
      if (infowindow) infowindow.close();
      
      // 새 마커 생성
      marker = new kakao.maps.Marker({ 
        position: latlng, 
        map: map 
      });
      
      // 주소 요약 정보 (지번 주소 우선, 장소명도 가능)
      const summaryAddress = addressName || roadAddress || "선택한 위치";
      
      // 인포윈도우 생성
      infowindow = new kakao.maps.InfoWindow({
        content: `<div style="padding:8px 12px;font-size:12px;white-space:nowrap;max-width:200px;overflow:hidden;text-overflow:ellipsis;">${summaryAddress}</div>`
      });
      infowindow.open(map, marker);
      
      // 선택된 주소 정보 업데이트
      selectedData = {
        lat: latlng.getLat(),
        lng: latlng.getLng(),
        address: addressName || roadAddress || "선택한 위치",
        roadAddress: roadAddress || ""
      };
      
      updateSelectedInfo();
      modal.querySelector("#kakaomap-confirm-btn").disabled = false;
    }

    /**
     * 선택된 주소 정보 표시 업데이트
     */
    function updateSelectedInfo() {
      const infoDiv = modal.querySelector("#kakaomap-selected-info");
      if (selectedData) {
        infoDiv.innerHTML = `
          <strong>📍 선택된 위치:</strong><br>
          ${selectedData.address}
          ${selectedData.roadAddress && selectedData.roadAddress !== selectedData.address ? 
            `<br><small style="color:#666;">${selectedData.roadAddress}</small>` : ''}
        `;
      }
    }

    // ============================================
    // 검색 기능 (키워드 검색 + 주소 검색)
    // ============================================
    
    /**
     * 좌표로 주소 검색
     */
    function searchDetailAddrFromCoords(coords, callback) {
      geocoder.coord2Address(coords.getLng(), coords.getLat(), callback);
    }

    /**
     * 키워드로 장소 검색 (한강공원, 남산타워 등)
     */
    function searchPlacesByKeyword(keyword) {
      places.keywordSearch(keyword, (result, status) => {
        if (status === kakao.maps.services.Status.OK) {
          // 검색 결과가 있으면 첫 번째 결과로 이동
          if (result.length > 0) {
            const place = result[0];
            const latlng = new kakao.maps.LatLng(place.y, place.x);
            
            map.setCenter(latlng);
            
            const addressName = place.address_name;
            const roadAddress = place.road_address_name || "";
            const placeName = place.place_name;
            
            // 장소명이 있으면 장소명 우선, 없으면 주소
            const displayName = placeName || addressName;
            
            placeMarker(latlng, displayName, roadAddress);
          }
        } else if (status === kakao.maps.services.Status.ZERO_RESULT) {
          // Places 검색 실패 시 주소 검색 시도
          searchByAddress(keyword);
        } else {
          alert("검색 중 오류가 발생했습니다.");
        }
      });
    }

    /**
     * 주소로 검색 (Places 검색이 실패했을 때 자동 실행)
     */
    function searchByAddress(addr) {
      geocoder.addressSearch(addr, (result, status) => {
        if (status === kakao.maps.services.Status.OK) {
          const latlng = new kakao.maps.LatLng(result[0].y, result[0].x);
          map.setCenter(latlng);
          
          const addressName = result[0].address_name;
          const roadAddress = result[0].road_address ? result[0].road_address.address_name : "";
          
          placeMarker(latlng, addressName, roadAddress);
        } else {
          alert("검색 결과가 없습니다. 다른 키워드로 검색해보세요.");
        }
      });
    }

    // ============================================
    // 이벤트 리스너
    // ============================================
    
    /**
     * 지도 클릭 이벤트 (클릭한 위치 선택 가능)
     */
    map.addListener("click", (e) => {
      searchDetailAddrFromCoords(e.latLng, (result, status) => {
        if (status === kakao.maps.services.Status.OK) {
          const detailAddr = result[0];
          const addressName = detailAddr.address.address_name;
          const roadAddress = detailAddr.road_address ? detailAddr.road_address.address_name : "";
          
          // 검색창에 주소 표시
          modal.querySelector("#kakaomap-search-input").value = roadAddress || addressName;
          
          placeMarker(e.latLng, addressName, roadAddress);
        } else {
          placeMarker(e.latLng, "선택한 위치", "");
        }
      });
    });

    /**
     * 검색 버튼 클릭
     */
    modal.querySelector("#kakaomap-search-btn").onclick = () => {
      const keyword = modal.querySelector("#kakaomap-search-input").value.trim();
      if (!keyword) {
        alert("검색할 장소나 주소를 입력하세요.");
        return;
      }

      // 키워드로 장소 검색 (실패 시 자동으로 주소 검색)
      searchPlacesByKeyword(keyword);
    };

    /**
     * 검색 입력창 Enter 키
     */
    modal.querySelector("#kakaomap-search-input").onkeypress = (e) => {
      if (e.key === 'Enter') {
        e.preventDefault();
        modal.querySelector("#kakaomap-search-btn").click();
      }
    };

    /**
     * 모달 닫기 버튼
     */
    modal.querySelector(".kakaomap-close").onclick = () => {
      modal.remove();
    };

    /**
     * 취소 버튼
     */
    modal.querySelector("#kakaomap-cancel-btn").onclick = () => {
      modal.remove();
    };

    /**
     * 선택/수정 완료 버튼
     */
    modal.querySelector("#kakaomap-confirm-btn").onclick = () => {
      if (selectedData) {
        if (existingMapNode && existingMapPos !== null) {
          // 기존 지도 수정 (같은 위치에 새로운 정보로 교체)
          editor.chain()
            .focus()
            .deleteRange({ from: existingMapPos, to: existingMapPos + existingMapNode.nodeSize })
            .insertContentAt(existingMapPos, {
              type: "kakaoMap",
              attrs: {
                lat: selectedData.lat,
                lng: selectedData.lng,
                id: existingMapNode.attrs.id, // 기존 ID 유지
                label: selectedData.address
              }
            })
            .run();
        } else {
          // 새 지도 삽입
          const safeId = `map-${Date.now()}`;
          editor.chain().focus().insertContent({
            type: "kakaoMap",
            attrs: {
              lat: selectedData.lat,
              lng: selectedData.lng,
              id: safeId,
              label: selectedData.address
            }
          }).run();
        }
        modal.remove();
      }
    };

    /**
     * 삭제 버튼 (기존 지도가 있을 때만 표시)
     */
    const deleteBtn = modal.querySelector("#kakaomap-delete-btn");
    if (deleteBtn) {
      deleteBtn.onclick = () => {
        if (confirm("지도를 삭제하시겠습니까?")) {
          editor.chain()
            .focus()
            .deleteRange({ from: existingMapPos, to: existingMapPos + existingMapNode.nodeSize })
            .run();
          modal.remove();
        }
      };
    }

    /**
     * 모달 외부 클릭 시 닫기
     */
    modal.onclick = (e) => {
      if (e.target === modal) {
        modal.remove();
      }
    };

    // 검색창에 포커스
    setTimeout(() => {
      modal.querySelector("#kakaomap-search-input").focus();
    }, 100);
  }

  // 전역 함수로 등록 (window 객체에 직접 할당)
  window.openKakaoMapModal = openKakaoMapModal;
  
  // ES6 모듈로도 사용 가능하도록 export (type="module"일 때)
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = { openKakaoMapModal };
  }
  
})();