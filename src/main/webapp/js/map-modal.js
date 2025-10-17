// map-modal.js
export function openModal(editor) {
  // 에디터에서 기존 지도 찾기
  let existingMapNode = null;
  let existingMapPos = null;

  editor.state.doc.descendants((node, pos) => {
    if (node.type.name === 'kakaoMap') {
      existingMapNode = node;
      existingMapPos = pos;
      return false; // 첫 번째 지도만 찾음
    }
  });

  const modal = document.createElement("div");
  modal.className = "modal";
  modal.innerHTML = `
    <div class="modal-content">
      <span class="modal-close">&times;</span>
      <h3>${existingMapNode ? '지도 수정' : '위치 선택'}</h3>
      <div style="display:flex;gap:8px;margin-bottom:12px;">
        <input type="text" id="mapSearchInput" placeholder="주소 검색">
        <button id="mapSearchBtn" class="btn-secondary">검색</button>
      </div>
      <div id="mapContainer" style="width:100%;height:400px;margin-bottom:12px;border-radius:8px;"></div>
      <div id="selectedAddress" style="padding:8px;background:#f5f5f5;border-radius:4px;margin-bottom:12px;min-height:24px;">
        ${existingMapNode ? existingMapNode.attrs.label : '지도를 클릭하거나 주소를 검색하세요'}
      </div>
      <div style="display:flex;gap:8px;">
        <button id="mapConfirmBtn" class="btn-primary" style="flex:1;" ${existingMapNode ? '' : 'disabled'}>
          ${existingMapNode ? '수정 완료' : '선택 완료'}
        </button>
        ${existingMapNode ? '<button id="mapDeleteBtn" class="btn-danger" style="flex:1;">삭제</button>' : ''}
      </div>
    </div>
  `;
  document.body.appendChild(modal);
  modal.style.display = "block";

  const container = modal.querySelector("#mapContainer");
  const geocoder = new kakao.maps.services.Geocoder();
  
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

  modal.querySelector(".modal-close").onclick = () => modal.remove();

  // 마커와 인포윈도우 생성
  function placeMarker(latlng, addressName, roadAddress) {
    // 기존 마커와 인포윈도우 제거
    if (marker) marker.setMap(null);
    if (infowindow) infowindow.close();
    
    // 새 마커 생성
    marker = new kakao.maps.Marker({ 
      position: latlng, 
      map: map 
    });
    
    // 주소 요약 정보 (지번 주소 우선)
    const summaryAddress = addressName || roadAddress || "선택한 위치";
    
    // 인포윈도우 생성
    infowindow = new kakao.maps.InfoWindow({
      content: `<div style="padding:8px 12px;font-size:12px;white-space:nowrap;">${summaryAddress}</div>`
    });
    infowindow.open(map, marker);
    
    // 선택된 주소 정보 업데이트
    selectedData = {
      lat: latlng.getLat(),
      lng: latlng.getLng(),
      address: addressName || roadAddress || "선택한 위치",
      roadAddress: roadAddress || ""
    };
    
    updateSelectedAddress();
    modal.querySelector("#mapConfirmBtn").disabled = false;
  }

  // 선택된 주소 표시 업데이트
  function updateSelectedAddress() {
    const addressDiv = modal.querySelector("#selectedAddress");
    if (selectedData) {
      addressDiv.innerHTML = `
        <strong>선택된 위치:</strong><br>
        ${selectedData.address}
        ${selectedData.roadAddress ? `<br><small style="color:#666;">${selectedData.roadAddress}</small>` : ''}
      `;
    }
  }

  // 좌표로 주소 검색
  function searchDetailAddrFromCoords(coords, callback) {
    geocoder.coord2Address(coords.getLng(), coords.getLat(), callback);
  }

  // 지도 클릭 이벤트
  map.addListener("click", (e) => {
    searchDetailAddrFromCoords(e.latLng, (result, status) => {
      if (status === kakao.maps.services.Status.OK) {
        const detailAddr = result[0];
        const addressName = detailAddr.address.address_name;
        const roadAddress = detailAddr.road_address ? detailAddr.road_address.address_name : "";
        
        // 검색창에 주소 표시
        modal.querySelector("#mapSearchInput").value = roadAddress || addressName;
        
        placeMarker(e.latLng, addressName, roadAddress);
      } else {
        placeMarker(e.latLng, "선택한 위치", "");
      }
    });
  });

  // 주소 검색 버튼
  modal.querySelector("#mapSearchBtn").onclick = () => {
    const addr = modal.querySelector("#mapSearchInput").value;
    if (!addr.trim()) {
      alert("주소를 입력하세요.");
      return;
    }

    geocoder.addressSearch(addr, (result, status) => {
      if (status === kakao.maps.services.Status.OK) {
        const latlng = new kakao.maps.LatLng(result[0].y, result[0].x);
        map.setCenter(latlng);
        
        const addressName = result[0].address_name;
        const roadAddress = result[0].road_address ? result[0].road_address.address_name : "";
        
        placeMarker(latlng, addressName, roadAddress);
      } else {
        alert("주소를 찾을 수 없습니다. 다시 시도해주세요.");
      }
    });
  };

  // 선택/수정 완료 버튼
  modal.querySelector("#mapConfirmBtn").onclick = () => {
    if (selectedData) {
      if (existingMapNode && existingMapPos !== null) {
        // 기존 지도 수정
        editor.chain()
          .focus()
          .deleteRange({ from: existingMapPos, to: existingMapPos + existingMapNode.nodeSize })
          .insertContentAt(existingMapPos, {
            type: "kakaoMap",
            attrs: {
              lat: selectedData.lat,
              lng: selectedData.lng,
              id: existingMapNode.attrs.id,
              label: selectedData.address
            }
          })
          .run();
      } else {
        // ✅ 새 지도 삽입 - 현재 커서 위치 또는 문서 끝에 삽입
        const safeId = `map-${Date.now()}`;
        const { from } = editor.state.selection;
        const docSize = editor.state.doc.content.size;
        
        // 커서 위치가 유효하면 그 위치에, 아니면 문서 끝에 삽입
        const insertPos = from > 0 && from < docSize ? from : docSize - 1;
        
        editor.chain()
          .insertContentAt(insertPos, {
            type: "kakaoMap",
            attrs: {
              lat: selectedData.lat,
              lng: selectedData.lng,
              id: safeId,
              label: selectedData.address
            }
          })
          .focus(insertPos + 1)
          .run();
      }
      modal.remove();
    }
  };

  // 삭제 버튼 (기존 지도가 있을 때만)
  const deleteBtn = modal.querySelector("#mapDeleteBtn");
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
}