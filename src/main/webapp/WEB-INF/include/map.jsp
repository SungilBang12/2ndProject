<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
    <!-- Kakao Map API -->
    <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=70a909d37469228212bf0e0010b9d27e&libraries=services"></script>
    <script src="${pageContext.request.contextPath}/js/kakaomap.js"></script>

    <button data-cmd="Map">📍지도</button>
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


    <!-- Kakao Map 모듈 로드 -->

    <!-- TipTap 에디터 초기화 스크립트 -->
    <script type="module">
 
        
        // Kakao 지도 버튼 이벤트 연결
        document.addEventListener('DOMContentLoaded', function() {
            const mapButton = document.querySelector('button[data-cmd="Map"]');
            
            if (mapButton && window.openKakaoMapModal) {
                mapButton.addEventListener('click', function(e) {
                    e.preventDefault();
                    
                    // editor 변수가 정의되어 있어야 합니다
                    if (typeof editor !== 'undefined') {
                        window.openKakaoMapModal(editor);
                    } else {
                        console.error('TipTap editor 인스턴스를 찾을 수 없습니다.');
                    }
                });
            }
        });
    </script>
</body>
</html>