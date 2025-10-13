<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- 카카오맵 버튼 -->
<button type="button" id="kakaomap-btn" class="toolbar-btn" title="장소 검색">
    📍 지도
</button>

<!-- 카카오맵 모달 -->
<div id="kakaomap-modal" class="kakaomap-modal" style="display: none;">
    <div class="kakaomap-modal-content">
        <!-- 모달 헤더 -->
        <div class="kakaomap-modal-header">
            <h3>📍 장소 검색</h3>
            <button type="button" class="kakaomap-close" onclick="closeKakaoMapModal()">&times;</button>
        </div>
        
        <!-- 모달 바디 -->
        <div class="kakaomap-modal-body">
            <!-- 검색 박스 -->
            <div class="kakaomap-search-box">
                <input 
                    type="text" 
                    id="kakaomap-keyword" 
                    class="kakaomap-input" 
                    placeholder="예: 한강공원, 남산타워, 마포대교"
                    onkeypress="if(event.key === 'Enter') { event.preventDefault(); searchKakaoPlaces(); }">
                <button type="button" class="kakaomap-search-btn" onclick="searchKakaoPlaces()">
                    🔍 검색
                </button>
            </div>
            
            <!-- 지도 영역 -->
            <div id="kakaomap-container"></div>
            
            <!-- 선택된 장소 표시 -->
            <div id="kakaomap-selected-place" class="kakaomap-selected-place" style="display: none;">
                <strong>✓ 선택된 장소</strong>
                <p id="kakaomap-selected-place-name"></p>
            </div>
            
            <div class="kakaomap-help">지도에서 마커를 클릭하여 장소를 선택하세요.</div>
        </div>
        
        <!-- 모달 푸터 -->
        <div class="kakaomap-modal-footer">
            <button type="button" class="kakaomap-btn-secondary" onclick="closeKakaoMapModal()">취소</button>
            <button type="button" class="kakaomap-btn-primary" onclick="insertKakaoPlaceToEditor()">삽입</button>
        </div>
    </div>
</div>

<!-- 카카오맵 모달 스타일 -->
<style>
/* 모달 오버레이 */
.kakaomap-modal {
    display: none;
    position: fixed;
    z-index: 10000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    animation: fadeIn 0.3s;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

/* 모달 컨텐츠 */
.kakaomap-modal-content {
    position: relative;
    background-color: white;
    margin: 50px auto;
    padding: 0;
    width: 90%;
    max-width: 800px;
    border-radius: 8px;
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

/* 모달 헤더 */
.kakaomap-modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 24px;
    border-bottom: 1px solid #e0e0e0;
}

.kakaomap-modal-header h3 {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
    color: #333;
}

.kakaomap-close {
    background: none;
    border: none;
    font-size: 28px;
    font-weight: bold;
    color: #999;
    cursor: pointer;
    padding: 0;
    width: 30px;
    height: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 4px;
    transition: all 0.2s;
}

.kakaomap-close:hover {
    background-color: #f5f5f5;
    color: #333;
}

/* 모달 바디 */
.kakaomap-modal-body {
    padding: 24px;
}

/* 검색 박스 */
.kakaomap-search-box {
    display: flex;
    gap: 10px;
    margin-bottom: 15px;
}

.kakaomap-input {
    flex: 1;
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
}

.kakaomap-input:focus {
    outline: none;
    border-color: #007bff;
    box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
}

.kakaomap-search-btn {
    padding: 12px 24px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    white-space: nowrap;
    transition: background-color 0.2s;
}

.kakaomap-search-btn:hover {
    background-color: #0056b3;
}

/* 지도 컨테이너 */
#kakaomap-container {
    width: 100%;
    height: 400px;
    border: 2px solid #ddd;
    border-radius: 8px;
    background-color: #f5f5f5;
}

/* 선택된 장소 */
.kakaomap-selected-place {
    margin-top: 15px;
    padding: 15px;
    background-color: #e7f3ff;
    border-left: 4px solid #007bff;
    border-radius: 4px;
}

.kakaomap-selected-place strong {
    color: #004085;
    display: block;
    margin-bottom: 5px;
    font-size: 14px;
}

.kakaomap-selected-place p {
    margin: 0;
    color: #004085;
    font-size: 13px;
}

.kakaomap-help {
    margin-top: 10px;
    font-size: 12px;
    color: #666;
}

/* 모달 푸터 */
.kakaomap-modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    padding: 20px 24px;
    border-top: 1px solid #e0e0e0;
    background-color: #f8f9fa;
    border-radius: 0 0 8px 8px;
}

.kakaomap-btn-secondary,
.kakaomap-btn-primary {
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.kakaomap-btn-secondary {
    background-color: #6c757d;
    color: white;
}

.kakaomap-btn-secondary:hover {
    background-color: #5a6268;
}

.kakaomap-btn-primary {
    background-color: #007bff;
    color: white;
}

.kakaomap-btn-primary:hover {
    background-color: #0056b3;
}

/* 반응형 */
@media (max-width: 768px) {
    .kakaomap-modal-content {
        width: 95%;
        margin: 20px auto;
    }
    
    #kakaomap-container {
        height: 300px;
    }
    
    .kakaomap-search-box {
        flex-direction: column;
    }
    
    .kakaomap-search-btn {
        width: 100%;
    }
}
</style>