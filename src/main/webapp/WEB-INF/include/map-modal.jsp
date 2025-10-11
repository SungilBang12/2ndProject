<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=c72248c25fcfe17e7a6934e08908d1f4&libraries=services"></script>
<button data-cmd="kakaoMap">📍 Kakao 지도</button>
<div id="mapModal" class="modal">
  <div class="modal-content">
    <span class="modal-close" id="mapModalClose">&times;</span>
    <h3>주소 검색 / 지도 선택</h3>
    <input type="text" id="mapSearchInput" placeholder="검색어 입력"/>
    <button id="mapSearchBtn">검색</button>
    <div id="mapModalMap" style="width:100%;height:400px;"></div>
    <button id="mapConfirmBtn">선택</button>
  </div>
</div>

<script type="module">
import * as MapModal from "./js/map-modal.js";
window.openKakaoMapModal = MapModal.openModal;
</script>