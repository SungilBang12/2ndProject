<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- 게시글 수정 폼 -->
<div class="container">
    <!-- 게시글 ID (hidden) -->
    <input type="hidden" id="postId" value="${post.postId}">
    
    <!-- 카테고리 선택 -->
    <div class="form-group">
        <label for="category">
            카테고리 선택 <span class="required">*</span>
        </label>
        <select id="category" name="category" class="form-control" required>
            <option value="">-- 카테고리를 선택하세요 --</option>
            <option value="sunset">노을</option>
            <option value="restaurant_recommend">맛집 추천</option>
            <option value="restaurant_review">맛집 후기</option>
            <option value="photo_tip">촬영 TIP</option>
            <option value="equipment_recommend">장비 추천</option>
            <option value="trade">중고 거래</option>
            <option value="gathering">'해'쳐 모여</option>
            <option value="place_recommend">장소 추천</option>
        </select>
        <div class="form-help">게시글의 카테고리를 선택하세요.</div>
    </div>

    <!-- 제목 입력 -->
    <div class="form-group">
        <label for="title">
            제목 <span class="required">*</span>
        </label>
        <input 
            type="text" 
            id="title" 
            name="title" 
            class="form-control" 
            placeholder="제목을 입력하세요"
            value="${post.title}"
            required 
            maxlength="100">
        <div class="form-help">최대 100자까지 입력 가능합니다.</div>
    </div>

    <!-- 에디터 툴바 -->
    <div id="toolbar" class="toolbar">
        <!-- 기본 텍스트 스타일 그룹 -->
        <div class="toolbar-group">
            <button data-cmd="bold" title="굵게"><strong>B</strong></button>
            <button data-cmd="italic" title="기울임"><i>I</i></button>
            <button data-cmd="strike" title="취소선"><s>S</s></button>
            <button data-cmd="underline" title="밑줄">U</button>
            <jsp:include page="/WEB-INF/template/text-style-btn.jsp" />
        </div>

        <div class="toolbar-divider"></div>

        <!-- 제목 스타일 그룹 -->
        <div class="toolbar-group">
            <button data-cmd="heading1" title="제목 1">H1</button>
            <button data-cmd="heading2" title="제목 2">H2</button>
            <button data-cmd="heading3" title="제목 3">H3</button>
        </div>

        <div class="toolbar-divider"></div>

        <!-- 리스트 그룹 -->
        <div class="toolbar-group">
            <button data-cmd="bulletList" title="글머리 기호">● List</button>
            <button data-cmd="orderedList" title="번호 매기기">1. List</button>
        </div>

        <div class="toolbar-divider"></div>

        <!-- 미디어 및 기능 버튼 그룹 -->
        <div class="toolbar-group toolbar-media">
            <!-- 1. 이미지 (모든 카테고리) -->
            <div class="toolbar-feature" data-feature="image">
                <jsp:include page="/WEB-INF/include/image-modal.jsp" />
            </div>

            <!-- 2. 지도 - map-modal.jsp (기본) -->
            <div class="toolbar-feature" data-feature="map-modal">
                <jsp:include page="/WEB-INF/include/map-modal.jsp" />
            </div>

            <!-- 3. 지도 - map.jsp (Enhanced) -->
            <div class="toolbar-feature" data-feature="map">
                <jsp:include page="/WEB-INF/include/map.jsp" />
            </div>

            <!-- 4. 일정 -->
            <div class="toolbar-feature" data-feature="schedule">
                <jsp:include page="/WEB-INF/include/schedule-modal.jsp" />
            </div>

            <!-- 5. 이모지 (공통 - 항상 표시) -->
            <div class="toolbar-feature" data-feature="emoji">
                <jsp:include page="/WEB-INF/include/emoji-picker.jsp" />
            </div>

            <!-- 6. 링크 (공통 - 항상 표시) -->
            <div class="toolbar-feature" data-feature="link">
                <jsp:include page="/WEB-INF/template/link-btn.jsp" />
            </div>
        </div>
    </div>

    <!-- 에디터 본문 -->
    <div id="board" class="board"></div>

    <!-- 액션 버튼 -->
    <div class="actions">
        <button class="btn-primary" onclick="updatePost()">수정 완료</button>
        <button class="btn-secondary" onclick="cancelEdit()">취소</button>
    </div>
</div>

<!-- 추가 CSS -->
<style>
/* 툴바 레이아웃 개선 */
.toolbar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;
    padding: 12px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    margin-bottom: 12px;
}

.toolbar-group {
    display: flex;
    gap: 4px;
    align-items: center;
}

.toolbar-divider {
    width: 1px;
    height: 24px;
    background: #ddd;
    margin: 0 4px;
}

.toolbar-media {
    display: flex;
    gap: 4px;
    flex-wrap: wrap;
}

.toolbar-feature {
    display: inline-block;
}

.toolbar-feature[data-feature]:not([data-feature="emoji"]):not([data-feature="link"]) {
    display: none; /* 기본적으로 숨김 */
}

.toolbar-feature[data-feature].active {
    display: inline-block; /* 활성화된 기능만 표시 */
}

/* 에디터 영역 확장 */
.board {
    min-height: 500px;
    max-height: none;
    border: 1px solid #d1d7df;
    border-radius: 8px;
    background: white;
    padding: 20px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
    overflow: auto;
    cursor: text;
}

.board .ProseMirror {
    min-height: 460px;
    outline: none;
}

/* 카테고리 선택 스타일 */
.form-control {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 14px;
    transition: border-color 0.2s;
}

.form-control:focus {
    outline: none;
    border-color: #1a73e8;
    box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.1);
}

.required {
    color: #dc3545;
}

.form-help {
    font-size: 12px;
    color: #666;
    margin-top: 4px;
}

/* 반응형 디자인 */
@media (max-width: 768px) {
    .toolbar {
        gap: 4px;
        padding: 8px;
    }
    
    .toolbar-group {
        gap: 2px;
    }
    
    .toolbar button {
        padding: 6px 10px;
        font-size: 12px;
    }
}
</style>

<!-- 에디터 초기화 및 수정 스크립트 -->
<script type="module">
    import { initEditor } from "${pageContext.request.contextPath}/js/editor-init.js";
    import * as EmojiModule from "${pageContext.request.contextPath}/js/emoji.js"; 

    // ========================================
    // LIST_ID와 카테고리 매핑
    // ========================================
    const LIST_ID_TO_CATEGORY = {
        1: 'sunset',
        2: 'restaurant_recommend',
        3: 'restaurant_review',
        4: 'photo_tip',
        5: 'equipment_recommend',
        6: 'trade',
        7: 'gathering',
        8: 'place_recommend'
    };

    const CATEGORY_TO_LIST_ID = {
        'sunset': 1,
        'restaurant_recommend': 2,
        'restaurant_review': 3,
        'photo_tip': 4,
        'equipment_recommend': 5,
        'trade': 6,
        'gathering': 7,
        'place_recommend': 8
    };

    // ========================================
    // 카테고리별 사용 가능한 기능 매핑
    // ========================================
    const CATEGORY_FEATURES = {
        'sunset': ['image'],
        'restaurant_recommend': ['image', 'map'],
        'restaurant_review': ['image'],
        'photo_tip': ['image'],
        'equipment_recommend': ['image'],
        'trade': ['image', 'map', 'schedule'],
        'gathering': ['image', 'map', 'schedule'],
        'place_recommend': ['image', 'map']
    };

    // ========================================
    // 전역 변수
    // ========================================
    let editor = null;
    let currentCategory = '';
    let hasContentChanged = false;
    let originalContent = null;
    let originalTitle = '';
    let originalCategory = '';

    // ========================================
    // 서버에서 전달받은 데이터
    // ========================================
    const postId = document.getElementById('postId').value;
    const listId = ${post.listId != null ? post.listId : 0};
    const postContent = '${post.content}'; // JSON 문자열
    const postTitle = '${post.title}';

    // ========================================
    // 에디터 초기화
    // ========================================
    function initializeEditor() {
        editor = initEditor(
            document.getElementById("board"),
            document.getElementById("toolbar")
        );

        // 내용 변경 감지
        editor.on('update', () => {
            hasContentChanged = true;
        });

        return editor;
    }

    editor = initializeEditor();

    // ========================================
    // 초기 데이터 로드
    // ========================================
    function loadInitialData() {
        // 1. 카테고리 설정
        const categoryValue = LIST_ID_TO_CATEGORY[listId];
        if (categoryValue) {
            document.getElementById('category').value = categoryValue;
            currentCategory = categoryValue;
            originalCategory = categoryValue;
            updateToolbarFeatures(categoryValue);
        }

        // 2. 에디터 내용 로드
        try {
            if (postContent && postContent !== '') {
                const contentJson = JSON.parse(postContent);
                editor.commands.setContent(contentJson);
                originalContent = contentJson;
            }
        } catch (e) {
            console.error('콘텐츠 로드 실패:', e);
        }

        // 3. 원본 데이터 저장
        originalTitle = postTitle;
        hasContentChanged = false;
    }

    // 페이지 로드 시 초기 데이터 설정
    loadInitialData();

    // ========================================
    // 이모지 기능 설정
    // ========================================
    window.openEmojiPicker = EmojiModule.openPicker;
    EmojiModule.setupEmojiSuggestion(editor);

    // ========================================
    // 카카오맵 버튼 연결
    // ========================================
    function setupMapButtons() {
        const mapModalButton = document.querySelector('.toolbar-feature[data-feature="map-modal"] button[data-cmd="Map"]');
        if (mapModalButton && window.openKakaoMapModal) {
            mapModalButton.onclick = () => window.openKakaoMapModal(editor);
        }

        const mapButton = document.querySelector('.toolbar-feature[data-feature="map"] button[data-cmd="Map"]');
        if (mapButton && window.openKakaoMapModalEnhanced) {
            mapButton.onclick = () => window.openKakaoMapModalEnhanced(editor);
        }
    }

    setupMapButtons();

    // ========================================
    // 툴바 기능 표시/숨김 전환
    // ========================================
    function updateToolbarFeatures(category) {
        const features = CATEGORY_FEATURES[category] || [];
        const allFeatures = document.querySelectorAll('.toolbar-feature');

        allFeatures.forEach(feature => {
            const featureName = feature.getAttribute('data-feature');
            
            if (featureName === 'emoji' || featureName === 'link') {
                feature.style.display = 'inline-block';
                return;
            }

            if (features.includes(featureName)) {
                feature.style.display = 'inline-block';
                feature.classList.add('active');
            } else {
                feature.style.display = 'none';
                feature.classList.remove('active');
            }
        });
    }

    // ========================================
    // 카테고리 변경 이벤트
    // ========================================
    document.getElementById('category').addEventListener('change', function(e) {
        const newCategory = e.target.value;

        if (!newCategory) {
            updateToolbarFeatures('');
            return;
        }

        // 카테고리가 변경되는 경우 경고
        if (currentCategory && newCategory !== currentCategory) {
            if (!confirm('카테고리를 변경하면 일부 콘텐츠가 제대로 표시되지 않을 수 있습니다. 계속하시겠습니까?')) {
                e.target.value = currentCategory;
                return;
            }
        }

        currentCategory = newCategory;
        updateToolbarFeatures(newCategory);
    });

    // ========================================
    // 제목 입력 시 내용 변경 추적
    // ========================================
    document.getElementById('title').addEventListener('input', function() {
        if (this.value !== originalTitle) {
            hasContentChanged = true;
        }
    });

    // ========================================
    // 게시글 수정 함수 (AJAX)
    // ========================================
    window.updatePost = function(event) {
        if (!editor) {
            alert("에디터가 초기화되지 않았습니다.");
            return;
        }

        // 카테고리 확인
        const category = document.getElementById('category').value;
        if (!category) {
            alert("카테고리를 선택해주세요.");
            document.getElementById('category').focus();
            return;
        }
        
        // 제목 입력값 가져오기
        const titleInput = document.getElementById("title");
        const title = titleInput.value.trim();

        if (!title) {
            alert("제목을 입력해주세요.");
            titleInput.focus();
            return;
        }

        // 본문 내용 가져오기
        const content = editor.getJSON();
        
        if (!content || !content.content || content.content.length === 0) {
            if (!confirm("본문 내용이 비어있습니다. 계속 진행하시겠습니까?")) {
                return;
            }
        }

        // 전송할 데이터 준비
        const data = {
            postId: parseInt(postId),
            listId: CATEGORY_TO_LIST_ID[category],
            title: title,
            content: content
        };

        // 저장 중 버튼 비활성화
        const saveBtn = event ? event.target : document.querySelector('.btn-primary');
        saveBtn.disabled = true;
        saveBtn.textContent = "수정 중...";

        // AJAX 요청
        $.ajax({
            url: "${pageContext.request.contextPath}/update.postasync", 
            type: "POST",
            contentType: "application/json; charset=UTF-8",
            data: JSON.stringify(data),
            
            success: function(result) {
                console.log("서버 응답:", result);
                
                if (result.status === "success") {
                    alert("게시글이 성공적으로 수정되었습니다!");
                    hasContentChanged = false;
                    // 상세 페이지로 이동
                    window.location.href = "${pageContext.request.contextPath}/post-detail.post?postId=" + postId;
                } else if (result.status === "error") {
                    alert("게시글 수정 실패: " + (result.message || "알 수 없는 오류"));
                    saveBtn.disabled = false;
                    saveBtn.textContent = "수정 완료";
                } else {
                    alert("알 수 없는 서버 응답 형식입니다.");
                    saveBtn.disabled = false;
                    saveBtn.textContent = "수정 완료";
                }
            },
            
            error: function(jqXHR, textStatus, errorThrown) {
                console.error("AJAX 전송 오류:", textStatus, errorThrown);
                console.error("응답 내용:", jqXHR.responseText);
                alert("게시글 수정 중 서버 통신 오류가 발생했습니다.");
                saveBtn.disabled = false;
                saveBtn.textContent = "수정 완료";
            }
        });
    };

    // ========================================
    // 수정 취소 함수
    // ========================================
    window.cancelEdit = function() {
        if (hasContentChanged) {
            if (!confirm("수정을 취소하시겠습니까? 변경된 내용은 저장되지 않습니다.")) {
                return;
            }
        }
        // 상세 페이지로 돌아가기
        window.location.href = "${pageContext.request.contextPath}/post-detail.post?postId=" + postId;
    };

    // ========================================
    // 페이지 이탈 경고
    // ========================================
    window.addEventListener('beforeunload', function(e) {
        if (hasContentChanged) {
            e.preventDefault();
            e.returnValue = '';
            return '';
        }
    });

    // ========================================
    // 에디터 클릭 시 포커스
    // ========================================
    document.getElementById('board').addEventListener('click', function() {
        if (editor) {
            editor.commands.focus();
        }
    });
</script>