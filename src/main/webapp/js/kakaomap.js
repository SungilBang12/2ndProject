/**
 * 카카오맵 모듈 (TipTap 에디터 통합)
 * - 키워드 검색 결과 리스트/마커 동시 표출
 * - 리스트 클릭/마커 클릭 → 선택 반영
 * - Kakao Places pagination 지원
 */
(function () {
  'use strict';

  // =========================
  // CSS 스타일 주입
  // =========================
  function injectModalStyles() {
    if (document.getElementById('kakaomap-modal-styles')) return;

    const style = document.createElement('style');
    style.id = 'kakaomap-modal-styles';
    style.textContent = `
      .kakaomap-modal{display:none;position:fixed;z-index:9999;left:0;top:0;width:100%;height:100%;overflow:auto;background-color:rgba(0,0,0,.5);animation:fadeIn .2s}
      @keyframes fadeIn{from{opacity:0}to{opacity:1}}
      .kakaomap-modal-content{position:relative;background:#fff;margin:5% auto;padding:0;border-radius:12px;width:90%;max-width:900px;box-shadow:0 4px 20px rgba(0,0,0,.3);animation:slideDown .3s}
      @keyframes slideDown{from{transform:translateY(-50px);opacity:0}to{transform:translateY(0);opacity:1}}
      .kakaomap-modal-header{display:flex;justify-content:space-between;align-items:center;padding:20px 24px;border-bottom:1px solid #e0e0e0}
      .kakaomap-modal-header h3{margin:0;font-size:20px;font-weight:600;color:#333}
      .kakaomap-close{background:none;border:none;font-size:32px;font-weight:300;color:#999;cursor:pointer;padding:0;width:32px;height:32px;display:flex;align-items:center;justify-content:center;transition:color .2s}
      .kakaomap-close:hover{color:#333}
      .kakaomap-modal-body{padding:16px 24px}
      .kakaomap-search-box{display:flex;gap:8px;margin-bottom:12px}
      .kakaomap-input{flex:1;padding:12px 16px;border:1px solid #ddd;border-radius:8px;font-size:14px;transition:border-color .2s}
      .kakaomap-input:focus{outline:none;border-color:#4CAF50}
      .kakaomap-search-btn{padding:12px 24px;background:#4CAF50;color:#fff;border:none;border-radius:8px;font-size:14px;font-weight:500;cursor:pointer;transition:background-color .2s;white-space:nowrap}
      .kakaomap-search-btn:hover{background:#45a049}
      .kakaomap-body-layout{display:grid;grid-template-columns:1.2fr .8fr;gap:12px;align-items:start}
      .kakaomap-container{width:100%;height:420px;border-radius:8px;overflow:hidden;border:1px solid #ddd}
      .kakaomap-right{display:flex;flex-direction:column;gap:8px;min-height:420px}
      .kakaomap-results{border:1px solid #ddd;border-radius:8px;overflow:hidden;flex:1;min-height:240px;background:#fff}
      .kakaomap-result-header{padding:10px 12px;border-bottom:1px solid #eee;font-size:13px;color:#555;background:#fafafa}
      .kakaomap-result-list{list-style:none;margin:0;padding:0;max-height:calc(420px - 40px - 44px);overflow:auto}
      .kakaomap-result-item{padding:10px 12px;border-bottom:1px solid #f2f2f2;cursor:pointer;transition:background .15s}
      .kakaomap-result-item:hover{background:#f7fbff}
      .kakaomap-result-title{font-size:14px;font-weight:600;color:#222;margin:0 0 4px}
      .kakaomap-result-addr{font-size:12px;color:#666;line-height:1.4}
      .kakaomap-pagination{display:flex;gap:6px;justify-content:center;align-items:center;padding:8px;border-top:1px solid #eee;background:#fafafa}
      .kakaomap-page-btn{border:1px solid #ddd;background:#fff;border-radius:6px;font-size:12px;padding:6px 10px;cursor:pointer}
      .kakaomap-page-btn[disabled]{opacity:.5;cursor:not-allowed}
      .kakaomap-selected-info{margin-top:8px;padding:12px 16px;background:#f5f5f5;border-radius:8px;font-size:14px;line-height:1.6;color:#333;min-height:60px}
      .kakaomap-modal-footer{display:flex;justify-content:flex-end;gap:12px;padding:16px 24px;border-top:1px solid #e0e0e0}
      .kakaomap-modal-footer button{padding:10px 20px;border:none;border-radius:8px;font-size:14px;font-weight:500;cursor:pointer;transition:all .2s}
      .kakaomap-btn-secondary{background:#f5f5f5;color:#666}
      .kakaomap-btn-secondary:hover{background:#e0e0e0}
      .kakaomap-btn-danger{background:#f44336;color:#fff}
      .kakaomap-btn-danger:hover{background:#d32f2f}
      .kakaomap-btn-primary{background:#2196F3;color:#fff}
      .kakaomap-btn-primary:hover{background:#1976D2}
      .kakaomap-btn-primary:disabled{background:#ccc;cursor:not-allowed}
      @media (max-width: 900px){
        .kakaomap-modal-content{width:95%;margin:2% auto}
        .kakaomap-body-layout{grid-template-columns:1fr}
        .kakaomap-container{height:360px}
      }
    `;
    document.head.appendChild(style);
  }

  // =========================
  // 메인 함수
  // =========================
  function openKakaoMapModal(editor) {
    injectModalStyles();

    // TipTap 문서에서 기존 kakaoMap 노드 탐색
    let existingMapNode = null;
    let existingMapPos = null;
    editor.state.doc.descendants((node, pos) => {
      if (node.type.name === 'kakaoMap') {
        existingMapNode = node;
        existingMapPos = pos;
        return false;
      }
    });

    // 모달 DOM 생성
    const modal = document.createElement('div');
    modal.className = 'kakaomap-modal';
    modal.innerHTML = `
      <div class="kakaomap-modal-content">
        <div class="kakaomap-modal-header">
          <h3>${existingMapNode ? '📍 지도 수정' : '📍 위치 선택'}</h3>
          <button type="button" class="kakaomap-close">&times;</button>
        </div>
        <div class="kakaomap-modal-body">
          <div class="kakaomap-search-box">
            <input type="text" id="kakaomap-search-input" class="kakaomap-input" placeholder="주소 또는 장소명 검색 (예: 한강공원, 남산타워)">
            <button type="button" id="kakaomap-search-btn" class="kakaomap-search-btn">🔍 검색</button>
          </div>

          <div class="kakaomap-body-layout">
            <div>
              <div id="kakaomap-container" class="kakaomap-container"></div>
              <div id="kakaomap-selected-info" class="kakaomap-selected-info">
                ${existingMapNode ? existingMapNode.attrs.label : '지도를 클릭하거나 주소/키워드를 검색하세요'}
              </div>
            </div>

            <div class="kakaomap-right">
              <div class="kakaomap-results">
                <div class="kakaomap-result-header">검색 결과</div>
                <ul id="kakaomap-result-list" class="kakaomap-result-list"></ul>
                <div class="kakaomap-pagination">
                  <button type="button" id="kakaomap-prev" class="kakaomap-page-btn" disabled>이전</button>
                  <span id="kakaomap-page-indicator" style="font-size:12px;color:#555;"></span>
                  <button type="button" id="kakaomap-next" class="kakaomap-page-btn" disabled>다음</button>
                </div>
              </div>
              <small style="color:#888;line-height:1.4;">💡 리스트에서 항목을 클릭하면 지도와 선택 정보가 업데이트 됩니다.</small>
            </div>
          </div>
        </div>

        <div class="kakaomap-modal-footer">
          <button type="button" id="kakaomap-cancel-btn" class="kakaomap-btn-secondary">취소</button>
          ${existingMapNode ? `<button type="button" id="kakaomap-delete-btn" class="kakaomap-btn-danger">삭제</button>` : ''}
          <button type="button" id="kakaomap-confirm-btn" class="kakaomap-btn-primary" ${existingMapNode ? '' : 'disabled'}>
            ${existingMapNode ? '수정 완료' : '선택 완료'}
          </button>
        </div>
      </div>
    `;
    document.body.appendChild(modal);
    modal.style.display = 'block';

    // Kakao 객체 준비
    const container = modal.querySelector('#kakaomap-container');
    const geocoder = new kakao.maps.services.Geocoder();
    const places = new kakao.maps.services.Places();

    // 지도 초기화
    const initialLat = existingMapNode ? existingMapNode.attrs.lat : 37.5665;
    const initialLng = existingMapNode ? existingMapNode.attrs.lng : 126.9780;

    const map = new kakao.maps.Map(container, {
      center: new kakao.maps.LatLng(initialLat, initialLng),
      level: 3
    });

    // 마커/인포윈도우/선택데이터
    let marker = null;
    let infowindow = null;
    let selectedData = existingMapNode
      ? { lat: existingMapNode.attrs.lat, lng: existingMapNode.attrs.lng, address: existingMapNode.attrs.label, roadAddress: '' }
      : null;

    // 검색결과용 마커/상태
    let searchMarkers = [];
    let currentPagination = null;
    let currentPage = 1;

    // 기존 마커 표시
    if (existingMapNode) {
      const latlng = new kakao.maps.LatLng(existingMapNode.attrs.lat, existingMapNode.attrs.lng);
      placeMarker(latlng, existingMapNode.attrs.label, '');
    }

    // 지도 리사이즈
    setTimeout(() => {
      kakao.maps.event.trigger(map, 'resize');
      map.setCenter(new kakao.maps.LatLng(initialLat, initialLng));
    }, 100);

    // =========================
    // 유틸
    // =========================
    function clearSearchMarkers() {
      searchMarkers.forEach(m => m.setMap(null));
      searchMarkers = [];
    }

    function clearResultList() {
      const ul = modal.querySelector('#kakaomap-result-list');
      ul.innerHTML = '';
      // 페이지 인디케이터/버튼 초기화
      modal.querySelector('#kakaomap-page-indicator').textContent = '';
      modal.querySelector('#kakaomap-prev').disabled = true;
      modal.querySelector('#kakaomap-next').disabled = true;
    }

    // =========================
    // 단일 선택 마커 배치
    // =========================
    function placeMarker(latlng, addressName, roadAddress) {
      if (marker) marker.setMap(null);
      if (infowindow) infowindow.close();

      marker = new kakao.maps.Marker({ position: latlng, map });
      const summaryAddress = addressName || roadAddress || '선택한 위치';
      infowindow = new kakao.maps.InfoWindow({
        content: `<div style="padding:8px 12px;font-size:12px;white-space:nowrap;max-width:200px;overflow:hidden;text-overflow:ellipsis;">${summaryAddress}</div>`
      });
      infowindow.open(map, marker);

      selectedData = {
        lat: latlng.getLat(),
        lng: latlng.getLng(),
        address: addressName || roadAddress || '선택한 위치',
        roadAddress: roadAddress || ''
      };
      updateSelectedInfo();
      modal.querySelector('#kakaomap-confirm-btn').disabled = false;
    }

    function updateSelectedInfo() {
      const infoDiv = modal.querySelector('#kakaomap-selected-info');
      if (selectedData) {
        infoDiv.innerHTML = `
          <strong>📍 선택된 위치:</strong><br>
          ${selectedData.address}
          ${selectedData.roadAddress && selectedData.roadAddress !== selectedData.address
            ? `<br><small style="color:#666;">${selectedData.roadAddress}</small>`
            : ''}
        `;
      }
    }

    // =========================
    // 주소 역/정방향 검색
    // =========================
    function searchDetailAddrFromCoords(coords, callback) {
      geocoder.coord2Address(coords.getLng(), coords.getLat(), callback);
    }

    function searchByAddress(addr) {
      geocoder.addressSearch(addr, (result, status) => {
        if (status === kakao.maps.services.Status.OK && result.length > 0) {
          const latlng = new kakao.maps.LatLng(result[0].y, result[0].x);
          map.setCenter(latlng);

          const addressName = result[0].address_name;
          const roadAddress = result[0].road_address ? result[0].road_address.address_name : '';
          placeMarker(latlng, addressName, roadAddress);
        } else {
          alert('검색 결과가 없습니다. 다른 키워드로 검색해보세요.');
        }
      });
    }

    // =========================
    // 키워드 검색 + 결과 리스트/마커/페이지
    // =========================
    function renderResults(list, pagination) {
      clearResultList();
      clearSearchMarkers();

      const ul = modal.querySelector('#kakaomap-result-list');
      const bounds = new kakao.maps.LatLngBounds();

      list.forEach((place, idx) => {
        const position = new kakao.maps.LatLng(place.y, place.x);

        // 마커 생성
        const sm = new kakao.maps.Marker({ position, map });
        searchMarkers.push(sm);
        bounds.extend(position);

        const title = place.place_name || '(이름 없음)';
        const road = place.road_address_name || '';
        const jibun = place.address_name || '';

        // 리스트 아이템
        const li = document.createElement('li');
        li.className = 'kakaomap-result-item';
        li.innerHTML = `
          <p class="kakaomap-result-title">${idx + 1}. ${title}</p>
          <div class="kakaomap-result-addr">
            ${road ? `도로명: ${road}<br>` : ''}
            ${jibun ? `지번: ${jibun}` : ''}
          </div>
        `;

        // 리스트 클릭 → 지도/선택 반영
        li.addEventListener('click', () => {
          map.setCenter(position);
          map.setLevel(3);
          const addressName = road || jibun || title;
          placeMarker(position, addressName, road);
        });

        // 마커 클릭 → 동일 동작
        kakao.maps.event.addListener(sm, 'click', () => {
          map.setCenter(position);
          map.setLevel(3);
          const addressName = road || jibun || title;
          placeMarker(position, addressName, road);
        });

        ul.appendChild(li);
      });

      if (list.length > 0) {
        map.setBounds(bounds);
      }

      // 페이지네이션 바인딩
      currentPagination = pagination || null;
      const prevBtn = modal.querySelector('#kakaomap-prev');
      const nextBtn = modal.querySelector('#kakaomap-next');
      const indicator = modal.querySelector('#kakaomap-page-indicator');

      if (currentPagination) {
        currentPage = currentPagination.current || 1;
        indicator.textContent = `${currentPage} / ${currentPagination.last}`;
        prevBtn.disabled = currentPage <= 1;
        nextBtn.disabled = currentPage >= currentPagination.last;

        prevBtn.onclick = () => {
          if (currentPage > 1) currentPagination.gotoPage(currentPage - 1);
        };
        nextBtn.onclick = () => {
          if (currentPage < currentPagination.last) currentPagination.gotoPage(currentPage + 1);
        };
      } else {
        indicator.textContent = '';
        prevBtn.disabled = true;
        nextBtn.disabled = true;
      }
    }

    function searchPlacesByKeyword(keyword) {
      places.keywordSearch(keyword, (data, status, pagination) => {
        if (status === kakao.maps.services.Status.OK && Array.isArray(data) && data.length > 0) {
          renderResults(data, pagination);
        } else if (status === kakao.maps.services.Status.ZERO_RESULT) {
          // 키워드 결과 없으면 주소로 재시도
          clearResultList();
          clearSearchMarkers();
          searchByAddress(keyword);
        } else {
          alert('검색 중 오류가 발생했습니다.');
        }
      });
    }

    // =========================
    // 이벤트
    // =========================
    map.addListener('click', (e) => {
      searchDetailAddrFromCoords(e.latLng, (result, status) => {
        if (status === kakao.maps.services.Status.OK && result.length > 0) {
          const d = result[0];
          const addr = d.address?.address_name || '';
          const road = d.road_address?.address_name || '';
          modal.querySelector('#kakaomap-search-input').value = road || addr || '';
          placeMarker(e.latLng, addr || '선택한 위치', road || '');
        } else {
          placeMarker(e.latLng, '선택한 위치', '');
        }
      });
    });

    modal.querySelector('#kakaomap-search-btn').onclick = () => {
      const keyword = modal.querySelector('#kakaomap-search-input').value.trim();
      if (!keyword) return alert('검색할 장소나 주소를 입력하세요.');
      searchPlacesByKeyword(keyword);
    };

    modal.querySelector('#kakaomap-search-input').onkeypress = (e) => {
      if (e.key === 'Enter') {
        e.preventDefault();
        modal.querySelector('#kakaomap-search-btn').click();
      }
    };

    modal.querySelector('.kakaomap-close').onclick = () => modal.remove();
    modal.querySelector('#kakaomap-cancel-btn').onclick = () => modal.remove();

    modal.querySelector('#kakaomap-confirm-btn').onclick = () => {
      if (!selectedData) return;
      if (existingMapNode && existingMapPos !== null) {
        editor
          .chain()
          .focus()
          .deleteRange({ from: existingMapPos, to: existingMapPos + existingMapNode.nodeSize })
          .insertContentAt(existingMapPos, {
            type: 'kakaoMap',
            attrs: {
              lat: selectedData.lat,
              lng: selectedData.lng,
              id: existingMapNode.attrs.id,
              label: selectedData.address
            }
          })
          .run();
      } else {
        const safeId = `map-${Date.now()}`;
        editor
          .chain()
          .focus()
          .insertContent({
            type: 'kakaoMap',
            attrs: {
              lat: selectedData.lat,
              lng: selectedData.lng,
              id: safeId,
              label: selectedData.address
            }
          })
          .run();
      }
      modal.remove();
    };

    const deleteBtn = modal.querySelector('#kakaomap-delete-btn');
    if (deleteBtn) {
      deleteBtn.onclick = () => {
        if (confirm('지도를 삭제하시겠습니까?')) {
          editor.chain().focus().deleteRange({ from: existingMapPos, to: existingMapPos + existingMapNode.nodeSize }).run();
          modal.remove();
        }
      };
    }

    modal.onclick = (e) => {
      if (e.target === modal) modal.remove();
    };

    setTimeout(() => modal.querySelector('#kakaomap-search-input').focus(), 100);
  }

  // 전역/모듈 노출
  window.openKakaoMapModal = openKakaoMapModal;
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = { openKakaoMapModal };
  }
})();
