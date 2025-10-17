<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>${not empty post ? '게시글 수정' : '게시글 작성'} - Sunset Community</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <style>
    /* ========== Sunset Theme Variables ========== */
    :root {
      --bg-primary: #1a1a2e;
      --bg-secondary: #16213e;
      --bg-tertiary: #0f1624;
      --text-primary: #e8e8f0;
      --text-secondary: #a8a8b8;
      --text-tertiary: #7a7a8a;
      --accent-coral: #ff6b6b;
      --accent-orange: #ffa45c;
      --accent-pink: #ff6b9d;
      --accent-purple: #c44569;
      --gradient-sunset: linear-gradient(135deg, #ff6b6b 0%, #ffa45c 50%, #ff6b9d 100%);
      --gradient-dark: linear-gradient(135deg, #16213e 0%, #0f1624 100%);
      --shadow-soft: 0 8px 32px rgba(255, 107, 107, 0.15);
      --shadow-hover: 0 12px 48px rgba(255, 107, 107, 0.25);
      --border-color: rgba(255, 107, 107, 0.2);
    }

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      background: var(--bg-tertiary);
      background-image: 
        radial-gradient(ellipse at top, rgba(255, 107, 107, 0.1) 0%, transparent 50%),
        radial-gradient(ellipse at bottom, rgba(255, 164, 92, 0.08) 0%, transparent 50%);
      min-height: 100vh;
      padding: 24px 16px;
      color: var(--text-primary);
    }

    /* ========== 컨테이너 ========== */
    .container { 
      max-width: 900px; 
      margin: 0 auto; 
      padding: 0;
    }

    /* ========== 폼 그룹 ========== */
    .form-group { 
      margin-bottom: 24px;
    }

    .form-group label {
      display: block;
      margin-bottom: 10px;
      font-weight: 700;
      font-size: 15px;
      color: var(--text-primary);
      text-shadow: 0 2px 8px rgba(255, 107, 107, 0.2);
    }

    .required { 
      color: var(--accent-coral);
      margin-left: 4px;
    }

    .form-control {
      width: 100%; 
      padding: 14px 16px; 
      border: 2px solid var(--border-color);
      border-radius: 12px;
      font-size: 15px; 
      background: rgba(26, 26, 46, 0.6);
      color: var(--text-primary);
      transition: all 0.3s ease;
      backdrop-filter: blur(10px);
    }

    .form-control:focus { 
      outline: none; 
      border-color: var(--accent-coral);
      box-shadow: 0 0 0 4px rgba(255, 107, 107, 0.15);
      background: rgba(26, 26, 46, 0.8);
    }

    .form-control::placeholder {
      color: var(--text-tertiary);
    }

    select.form-control {
      cursor: pointer;
      appearance: none;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%23ff6b6b' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
      background-repeat: no-repeat;
      background-position: right 16px center;
      padding-right: 40px;
    }

    select.form-control option {
      background: var(--bg-secondary);
      color: var(--text-primary);
      padding: 10px;
    }

    .form-help { 
      font-size: 13px; 
      color: var(--text-tertiary);
      margin-top: 8px;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .form-help::before {
      content: "💡";
      font-size: 14px;
    }

    /* ========== 툴바 ========== */
    .toolbar {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;
      padding: 14px 16px;
      background: rgba(26, 26, 46, 0.6);
      border: 2px solid var(--border-color);
      border-radius: 12px 12px 0 0;
      border-bottom: 1px solid var(--border-color);
      box-shadow: var(--shadow-soft);
      margin-bottom: 0;
      backdrop-filter: blur(20px);
    }

    .toolbar-group { 
      display: flex; 
      gap: 6px; 
      align-items: center;
    }

    .toolbar-divider { 
      width: 1px; 
      height: 28px; 
      background: var(--border-color);
      margin: 0 8px;
    }

    .toolbar-media { 
      display: flex; 
      gap: 6px; 
      flex-wrap: wrap;
    }

    .toolbar-feature { 
      display: inline-block;
    }

    .toolbar-feature[data-feature]:not([data-feature="emoji"]):not([data-feature="link"]) { 
      display: none;
    }

    .toolbar-feature[data-feature].active { 
      display: inline-block;
    }

    .toolbar button {
      padding: 8px 14px;
      background: rgba(255, 107, 107, 0.1);
      border: 1px solid var(--border-color);
      border-radius: 8px;
      cursor: pointer;
      font-size: 13px;
      font-weight: 700;
      color: var(--text-secondary);
      transition: all 0.2s ease;
      min-width: 38px;
      height: 38px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .toolbar button:hover {
      background: rgba(255, 107, 107, 0.2);
      border-color: var(--accent-coral);
      color: var(--accent-coral);
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
    }

    .toolbar button:active,
    .toolbar button.is-active {
      background: rgba(255, 107, 107, 0.3);
      border-color: var(--accent-coral);
      color: var(--accent-coral);
      transform: translateY(0);
    }

    .toolbar button strong { font-weight: 700; }
    .toolbar button i { font-style: italic; }
    .toolbar button s { text-decoration: line-through; }

    /* ========== 에디터 영역 ========== */
    .board {
      min-height: 500px;
      max-height: none;
      border: 2px solid var(--border-color);
      border-top: none;
      border-radius: 0 0 12px 12px;
      background: rgba(26, 26, 46, 0.4);
      padding: 24px;
      box-shadow: var(--shadow-soft);
      overflow: auto;
      backdrop-filter: blur(20px);
    }
    
    .board .schedule-block {
      user-select: none;
      cursor: default;
      pointer-events: auto;
    }

    .board .schedule-block * {
      user-select: none;
      cursor: default;
    }

    .board .ProseMirror { 
      min-height: 460px; 
      outline: none;
      color: var(--text-secondary);
      line-height: 1.8;
    }

    .board .ProseMirror p {
      margin: 0.8em 0;
    }

    .board .ProseMirror h1,
    .board .ProseMirror h2,
    .board .ProseMirror h3 {
      color: var(--text-primary);
      margin: 1.2em 0 0.6em;
      font-weight: 700;
    }

    .board .ProseMirror h1 {
      font-size: 2em;
      background: var(--gradient-sunset);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    .board .ProseMirror h2 {
      font-size: 1.6em;
      color: var(--accent-orange);
    }

    .board .ProseMirror h3 {
      font-size: 1.3em;
      color: var(--accent-pink);
    }

    .board .ProseMirror p.is-editor-empty:first-child::before {
      content: "여기에 내용을 작성하세요...";
      float: left;
      color: var(--text-tertiary);
      pointer-events: none;
      height: 0;
      font-style: italic;
    }

    .board .ProseMirror img {
      max-width: 100%;
      border-radius: 12px;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
      margin: 16px 0;
    }

    .board .ProseMirror ul,
    .board .ProseMirror ol {
      padding-left: 24px;
      margin: 1em 0;
    }

    .board .ProseMirror li {
      margin: 0.4em 0;
      color: var(--text-secondary);
    }

    .board .ProseMirror code {
      background: rgba(255, 107, 107, 0.1);
      color: var(--accent-coral);
      padding: 2px 6px;
      border-radius: 4px;
      font-size: 0.9em;
    }

    .board .ProseMirror a {
      color: var(--accent-coral);
      text-decoration: underline;
      transition: color 0.2s;
    }

    .board .ProseMirror a:hover {
      color: var(--accent-orange);
    }

    /* ========== 버튼 ========== */
    .actions { 
      display: flex; 
      gap: 12px; 
      margin-top: 24px;
      justify-content: flex-end;
    }

    .btn-primary, 
    .btn-secondary {
      border: none; 
      border-radius: 12px; 
      padding: 14px 32px; 
      font-size: 15px;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.3s ease;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .btn-primary { 
      background: var(--gradient-sunset);
      color: white;
      box-shadow: var(--shadow-soft);
    }

    .btn-primary:hover {
      transform: translateY(-3px);
      box-shadow: var(--shadow-hover);
    }

    .btn-primary:disabled { 
      opacity: 0.5;
      cursor: not-allowed;
      transform: none;
    }

    .btn-secondary { 
      background: rgba(168, 168, 184, 0.2);
      color: var(--text-primary);
      border: 2px solid rgba(168, 168, 184, 0.3);
    }

    .btn-secondary:hover {
      background: rgba(168, 168, 184, 0.3);
      border-color: rgba(168, 168, 184, 0.5);
      transform: translateY(-2px);
    }

    /* ========== 페이지 헤더 ========== */
    .page-header {
      margin-bottom: 32px;
      text-align: center;
    }

    .page-title {
      font-size: 2.5em;
      font-weight: 700;
      background: var(--gradient-sunset);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      margin-bottom: 8px;
      text-shadow: 0 4px 16px rgba(255, 107, 107, 0.3);
    }

    .page-subtitle {
      color: var(--text-tertiary);
      font-size: 1.1em;
    }

    /* ========== 수정 모드 배지 ========== */
    .edit-mode-badge {
      display: inline-block;
      padding: 6px 16px;
      background: rgba(255, 164, 92, 0.2);
      color: var(--accent-orange);
      border: 1px solid rgba(255, 164, 92, 0.3);
      border-radius: 20px;
      font-size: 0.85em;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
      margin-left: 12px;
      vertical-align: middle;
    }

    /* ========== 반응형 ========== */
    @media (max-width: 768px) {
      body {
        padding: 16px 12px;
      }

      .page-title {
        font-size: 1.8em;
      }

      .page-subtitle {
        font-size: 1em;
      }

      .edit-mode-badge {
        display: block;
        margin: 12px auto 0;
        width: fit-content;
      }

      .toolbar { 
        gap: 6px; 
        padding: 10px 12px;
      }

      .toolbar-group { 
        gap: 4px;
      }

      .toolbar button { 
        padding: 6px 10px; 
        font-size: 12px;
        min-width: 34px;
        height: 34px;
      }

      .toolbar-divider {
        height: 24px;
        margin: 0 4px;
      }

      .board {
        padding: 16px;
      }

      .form-control {
        padding: 12px 14px;
        font-size: 14px;
      }

      .btn-primary,
      .btn-secondary {
        padding: 12px 24px;
        font-size: 14px;
      }

      .actions {
        flex-direction: column-reverse;
      }

      .actions button {
        width: 100%;
      }
    }

    /* ========== 스크롤바 커스텀 ========== */
    ::-webkit-scrollbar {
      width: 10px;
      height: 10px;
    }

    ::-webkit-scrollbar-track {
      background: var(--bg-tertiary);
    }

    ::-webkit-scrollbar-thumb {
      background: var(--gradient-sunset);
      border-radius: 5px;
    }

    ::-webkit-scrollbar-thumb:hover {
      background: var(--accent-coral);
    }
  </style>
</head>
<body>

<!-- ★ 수정/작성 모드 감지 -->
<c:set var="isEditMode" value="${not empty post}" />

<!-- ★ Front Controller로 제출 -->
<form action="<c:url value='${isEditMode ? "/update.post" : "/create.post"}'/>" method="post" onsubmit="return prepareAndSubmit()">
  <div class="container">

    <!-- 페이지 헤더 -->
    <div class="page-header">
      <h1 class="page-title">
        <c:choose>
          <c:when test="${isEditMode}">
            게시글 수정
            <span class="edit-mode-badge">✏️ Edit Mode</span>
          </c:when>
          <c:otherwise>
            새 게시글 작성
          </c:otherwise>
        </c:choose>
      </h1>
      <p class="page-subtitle">
        <c:choose>
          <c:when test="${isEditMode}">
            내용을 수정하고 저장하세요 ✨
          </c:when>
          <c:otherwise>
            커뮤니티와 당신의 이야기를 공유하세요 ✨
          </c:otherwise>
        </c:choose>
      </p>
    </div>

    <!-- 수정 모드일 때 postId 전달 -->
    <c:if test="${isEditMode}">
      <input type="hidden" name="postId" value="${post.postId}" />
    </c:if>

    <!-- 카테고리 선택 -->
    <div class="form-group">
      <label for="listId">
        카테고리 선택 <span class="required">*</span>
      </label>
      <select id="listId" name="listId" class="form-control" required>
        <option value="">-- 카테고리를 선택하세요 --</option>
        <option value="1" ${(isEditMode && post.listId == 1) || (!isEditMode && param.listId == '1') ? 'selected' : ''}>🌅 노을</option>
        <option value="2" ${(isEditMode && post.listId == 2) || (!isEditMode && param.listId == '2') ? 'selected' : ''}>🍽️ 맛집 추천</option>
        <option value="3" ${(isEditMode && post.listId == 3) || (!isEditMode && param.listId == '3') ? 'selected' : ''}>⭐ 맛집 후기</option>
        <option value="4" ${(isEditMode && post.listId == 4) || (!isEditMode && param.listId == '4') ? 'selected' : ''}>📸 촬영 TIP</option>
        <option value="5" ${(isEditMode && post.listId == 5) || (!isEditMode && param.listId == '5') ? 'selected' : ''}>🎥 장비 추천</option>
        <option value="6" ${(isEditMode && post.listId == 6) || (!isEditMode && param.listId == '6') ? 'selected' : ''}>💰 중고 거래</option>
        <option value="7" ${(isEditMode && post.listId == 7) || (!isEditMode && param.listId == '7') ? 'selected' : ''}>👥 해'쳐 모여</option>
        <option value="8" ${(isEditMode && post.listId == 8) || (!isEditMode && param.listId == '8') ? 'selected' : ''}>📍 장소 추천</option>
      </select>
      <div class="form-help">게시글을 작성할 카테고리를 선택하세요</div>
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
        placeholder="멋진 제목을 입력하세요"
        value="${isEditMode ? post.title : ''}"
        required
        maxlength="100"
      />
      <div class="form-help">최대 100자까지 입력 가능합니다</div>
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
      <button type="button" class="btn-secondary" onclick="cancelPost()">취소</button>
      <button type="submit" class="btn-primary">
        ${isEditMode ? '수정 완료' : '저장'}
      </button>
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

  // ✅ 수정 모드 확인
  const isEditMode = ${not empty post};
  console.log('수정 모드:', isEditMode);

  // ✅ URL 파라미터 또는 post 객체에서 listId 가져오기
  const urlParams = new URLSearchParams(window.location.search);
  const initialListId = isEditMode ? '${post.listId}' : (urlParams.get('listId') || '${param.listId}' || '');
  
  console.log('초기 listId:', initialListId);

  // ✅ 수정 모드일 때 기존 content 파싱
  let existingContent = null;
  <c:if test="${not empty post.content}">
  try {
    const jsonData = `${post.content}`;
    existingContent = JSON.parse(jsonData);
    console.log('기존 content 로드 성공');
  } catch (err) {
    console.error('기존 content JSON 파싱 오류:', err);
    existingContent = null;
  }
  </c:if>

  // ========================================
  // 에디터 초기화
  // ========================================
  function initializeEditor() {
    editor = initEditor(
      document.getElementById("board"),
      document.getElementById("toolbar")
    );

    // ✅ 수정 모드일 때 기존 content 로드
    if (isEditMode && existingContent) {
      editor.commands.setContent(existingContent);
      console.log('에디터에 기존 content 설정 완료');
    }

    // 내용 변경 감지
    editor.on('update', () => { hasContentChanged = true; });
    return editor;
  }
  editor = initializeEditor();
  
  // ✅ 전역 변수로 에디터 등록 (이미지 모달 등에서 사용)
  window.currentEditor = editor;

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

  // ✅ 초기 카테고리가 있으면 툴바 기능 활성화
  if (initialListId) {
    currentCategory = initialListId;
    updateToolbarFeatures(initialListId);
    console.log('초기 툴바 기능 활성화:', initialListId);
  } else {
    // 초기엔 emoji/link만
    updateToolbarFeatures('');
  }

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
    if (!newCategory) { 
      currentCategory = '';
      updateToolbarFeatures(''); 
      return; 
    }

    const titleValue = document.getElementById('title').value.trim();
    const hasContent = hasContentChanged || !!titleValue;

    // ✅ 수정 모드에서는 카테고리 변경 시 항상 확인
    // ✅ 작성 모드에서는 초기 로드 시에는 확인 안 함
    const shouldConfirm = isEditMode 
      ? (currentCategory && currentCategory !== newCategory)
      : (currentCategory && currentCategory !== newCategory && hasContent);

    if (shouldConfirm) {
      if (!confirm('카테고리를 변경하면 현재까지의 작성 내용이 모두 삭제됩니다. 그래도 진행하시겠습니까?')) {
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
    const message = isEditMode 
      ? "수정을 취소하시겠습니까? 변경 사항은 저장되지 않습니다."
      : "작성을 취소하시겠습니까? 작성 중인 내용은 저장되지 않습니다.";
    
    if (confirm(message)) {
      hasContentChanged = false;
      
      // ✅ 수정 모드일 때는 게시글 상세 페이지로
      <c:if test="${not empty post.postId}">
      window.location.href = "<c:url value='/post-detail.post'/>?postId=${post.postId}";
      return;
      </c:if>
      
      // ✅ 작성 모드일 때는 listId가 있으면 해당 리스트로 돌아가기
      if (initialListId) {
        window.location.href = "<c:url value='/post-list'/>?listId=" + initialListId;
      } else {
        window.location.href = "<c:url value='/meeting-gather.jsp'/>";
      }
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