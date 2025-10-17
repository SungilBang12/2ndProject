<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>게시글 작성</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

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
    .toolbar-group { display: flex; gap: 4px; align-items: center; }
    .toolbar-divider { width: 1px; height: 24px; background: #ddd; margin: 0 4px; }
    .toolbar-media { display: flex; gap: 4px; flex-wrap: wrap; }
    .toolbar-feature { display: inline-block; }
    .toolbar-feature[data-feature]:not([data-feature="emoji"]):not([data-feature="link"]) { display: none; }
    .toolbar-feature[data-feature].active { display: inline-block; }

    /* 에디터 영역 */
    .board {
      min-height: 500px;
      max-height: none;
      border: 1px solid #d1d7df;
      border-radius: 8px;
      background: white;
      padding: 20px;
      box-shadow: 0 1px 2px rgba(0,0,0,0.04);
      overflow: auto;
    }
    
    .board .schedule-block {
    user-select: none;
    cursor: default;
    pointer-events: auto;
  }
  .board .schedule-block * {
    user-select: none;
    cursor: default; // 커서 이동 방지
  }
    .board .ProseMirror { min-height: 460px; outline: none; }

    /* 폼 공통 */
    .container { max-width: 880px; margin: 24px auto; padding: 0 16px; }
    .form-group { margin-bottom: 16px; }
    .form-control {
      width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 6px;
      font-size: 14px; transition: border-color 0.2s;
    }
    .form-control:focus { outline: none; border-color: #1a73e8; box-shadow: 0 0 0 3px rgba(26,115,232,0.1); }
    .required { color: #dc3545; }
    .form-help { font-size: 12px; color: #666; margin-top: 4px; }

    /* 버튼 */
    .actions { display: flex; gap: 8px; margin-top: 16px; }
    .btn-primary, .btn-secondary {
      border: none; border-radius: 8px; padding: 10px 16px; font-size: 14px; cursor: pointer;
    }
    .btn-primary { background: #1a73e8; color: #fff; }
    .btn-primary:disabled { opacity: 0.6; cursor: not-allowed; }
    .btn-secondary { background: #f1f3f4; color: #333; }

    @media (max-width: 768px) {
      .toolbar { gap: 4px; padding: 8px; }
      .toolbar-group { gap: 2px; }
      .toolbar button { padding: 6px 10px; font-size: 12px; }
    }
  </style>
</head>
<body>

<!-- ★ Front Controller로 제출 -->
<form action="<c:url value='/create.post'/>" method="post" onsubmit="return prepareAndSubmit()">
  <div class="container">

    <!-- 카테고리 선택 -->
    <div class="form-group">
      <label for="listId">
        카테고리 선택 <span class="required">*</span>
      </label>
      <!-- ★ 서버와 일치: name="listId" -->
      <select id="listId" name="listId" class="form-control" required>
        <option value="">-- 카테고리를 선택하세요 --</option>
        <option value="1">노을</option>
        <option value="2">맛집 추천</option>
        <option value="3">맛집 후기</option>
        <option value="4">촬영 TIP</option>
        <option value="5">장비 추천</option>
        <option value="6">중고 거래</option>
        <option value="7">'해'쳐 모여</option>
        <option value="8">장소 추천</option>
      </select>
      <div class="form-help">게시글을 작성할 카테고리를 선택하세요.</div>
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
        required
        maxlength="100"
      />
      <div class="form-help">최대 100자까지 입력 가능합니다.</div>
    </div>

    <!-- 에디터 툴바 -->
    <div id="toolbar" class="toolbar">
      <!-- 기본 텍스트 스타일 그룹 -->
      <div class="toolbar-group">
        <button type="button" data-cmd="bold" title="굵게"><strong>B</strong></button>
        <button type="button" data-cmd="italic" title="기울임"><i>I</i></button>
        <button type="button" data-cmd="strike" title="취소선"><s>S</s></button>
        <button type="button" data-cmd="underline" title="밑줄">U</button>
        <jsp:include page="/WEB-INF/template/text-style-btn.jsp" />
      </div>

      <div class="toolbar-divider"></div>

      <!-- 제목 스타일 그룹 -->
      <div class="toolbar-group">
        <button type="button" data-cmd="heading1" title="제목 1">H1</button>
        <button type="button" data-cmd="heading2" title="제목 2">H2</button>
        <button type="button" data-cmd="heading3" title="제목 3">H3</button>
      </div>

      <div class="toolbar-divider"></div>

      <!-- 리스트 그룹 -->
      <div class="toolbar-group">
        <button type="button" data-cmd="bulletList" title="글머리 기호">● List</button>
        <button type="button" data-cmd="orderedList" title="번호 매기기">1. List</button>
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

    <!-- TipTap JSON을 문자열로 담을 hidden 필드 -->
    <input type="hidden" id="content" name="content" />

    <!-- 액션 버튼 -->
    <div class="actions">
      <button type="submit" class="btn-primary">저장</button>
      <button type="button" class="btn-secondary" onclick="cancelPost()">취소</button>
    </div>

  </div>
</form>

<script type="module">
  import { initEditor } from "${pageContext.request.contextPath}/js/editor-init.js";
  import * as EmojiModule from "${pageContext.request.contextPath}/js/emoji.js";

  // ========================================
  // 카테고리별 사용 가능한 기능 매핑
  // ========================================
  const CATEGORY_FEATURES = {
    '1': ['image'],                  // 노을
    '2': ['image', 'map'],           // 맛집 추천
    '3': ['image'],                  // 맛집 후기
    '4': ['image'],                  // 촬영 TIP
    '5': ['image'],                  // 장비 추천
    '6': ['image', 'map', 'schedule'], // 중고 거래
    '7': ['image', 'map', 'schedule'], // '해'쳐 모여
    '8': ['image', 'map']            // 장소 추천
  };

  // ========================================
  // 전역 상태
  // ========================================
  let editor = null;
  let currentCategory = '';
  let hasContentChanged = false;

  // ========================================
  // 에디터 초기화
  // ========================================
  function initializeEditor() {
    editor = initEditor(
      document.getElementById("board"),
      document.getElementById("toolbar")
    );

    // 내용 변경 감지
    editor.on('update', () => { hasContentChanged = true; });
    return editor;
  }
  editor = initializeEditor();

  // ========================================
  // 이모지 기능
  // ========================================
  window.openEmojiPicker = EmojiModule.openPicker;
  EmojiModule.setupEmojiSuggestion(editor);

  // ========================================
  // 카카오맵 버튼 연결(존재 시)
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
  // 툴바 기능 표시/숨김
  // ========================================
  function updateToolbarFeatures(category) {
    const features = CATEGORY_FEATURES[category] || [];
    const all = document.querySelectorAll('.toolbar-feature');

    all.forEach(feature => {
      const featureName = feature.getAttribute('data-feature');
      // emoji/link는 항상
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
  // 초기엔 emoji/link만
  updateToolbarFeatures('');

  // ========================================
  // 에디터 리셋
  // ========================================
  function resetEditor() {
    if (editor) {
      editor.commands.setContent('');
      document.getElementById('title').value = '';
      hasContentChanged = false;
    }
  }

  // ========================================
  // 카테고리 변경 이벤트
  // ========================================
  document.getElementById('listId').addEventListener('change', (e) => {
    const newCategory = e.target.value;
    if (!newCategory) { updateToolbarFeatures(''); return; }

    const titleValue = document.getElementById('title').value.trim();
    const hasContent = hasContentChanged || !!titleValue;

    if (currentCategory && hasContent) {
      if (!confirm('현재까지의 작성 내용이 모두 삭제됩니다. 그래도 진행하시겠습니까?')) {
        e.target.value = currentCategory; // 되돌리기
        return;
      }
      resetEditor();
    }
    currentCategory = newCategory;
    updateToolbarFeatures(newCategory);
  });

  // 제목 입력 시 변경 플래그
  document.getElementById('title').addEventListener('input', function () {
    if (this.value.trim()) hasContentChanged = true;
  });

  // ========================================
  // 폼 제출 전에 TipTap JSON 주입 + 유효성 검사
  // ========================================
  window.prepareAndSubmit = function () {
    if (!editor) { alert("에디터가 초기화되지 않았습니다."); return false; }

    const title  = document.getElementById('title').value.trim();
    const listId = document.getElementById('listId').value;

    if (!listId) { alert("카테고리를 선택해주세요."); return false; }
    if (!title)  { alert("제목을 입력해주세요."); return false; }

    const contentData = editor.getJSON();
    if (!contentData || !contentData.content || contentData.content.length === 0) {
      if (!confirm("본문 내용이 비어있습니다. 계속 진행하시겠습니까?")) return false;
    }

    // ★ 서버는 문자열 JSON을 기대
    document.getElementById('content').value = JSON.stringify(contentData);
    return true; // 제출 진행
  };

  // ========================================
  // 취소
  // ========================================
  window.cancelPost = function () {
    if (confirm("작성을 취소하시겠습니까? 작성 중인 내용은 저장되지 않습니다.")) {
      hasContentChanged = false;
      window.location.href = "<c:url value='/meeting-gather.jsp'/>";
    }
  };

  // ========================================
  // 페이지 이탈 경고
  // ========================================
  window.addEventListener('beforeunload', function (e) {
    if (hasContentChanged) { e.preventDefault(); e.returnValue = ''; return ''; }
  });

  // ========================================
  // 에디터 클릭 시 포커스
  // ========================================
  document.getElementById('board').addEventListener('click', function () {
    if (editor) editor.commands.focus();
  });
</script>

</body>
</html>
