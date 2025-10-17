<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
  /* ====== 에디터 컨테이너 Sunset 테마 ====== */
  .container {
    max-width: 100%;
    margin: 0;
  }

  /* ====== 헤더 액션 (목록으로 버튼) ====== */
  .header-actions {
    margin-bottom: 24px;
  }

  .header-actions .btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 20px;
    background: rgba(42, 31, 26, 0.6);
    color: #e5e5e5;
    text-decoration: none;
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 10px;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.3s ease;
  }

  .header-actions .btn:hover {
    background: rgba(42, 31, 26, 0.8);
    border-color: rgba(255, 139, 122, 0.4);
    color: #FF8B7A;
    transform: translateX(-4px);
  }

  /* ====== 제목 입력 필드 ====== */
  .input-title {
    width: 100%;
    padding: 16px 20px;
    margin-bottom: 20px;
    background: rgba(42, 31, 26, 0.5);
    border: 2px solid rgba(255, 139, 122, 0.2);
    border-radius: 12px;
    color: #fff;
    font-size: 1.5rem;
    font-weight: 600;
    font-family: 'Noto Serif KR', serif;
    outline: none;
    transition: all 0.3s ease;
    box-sizing: border-box;
  }

  .input-title::placeholder {
    color: rgba(229, 229, 229, 0.4);
  }

  .input-title:focus {
    background: rgba(42, 31, 26, 0.7);
    border-color: #FF8B7A;
    box-shadow: 0 0 0 3px rgba(255, 139, 122, 0.1);
  }

  /* ====== 툴바 ====== */
  .toolbar {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    padding: 16px;
    margin-bottom: 20px;
    background: linear-gradient(135deg, 
      rgba(42, 31, 26, 0.6) 0%, 
      rgba(26, 22, 20, 0.6) 100%
    );
    border: 1px solid rgba(255, 139, 122, 0.15);
    border-radius: 12px;
    box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.2);
  }

  /* ====== 툴바 버튼 기본 스타일 ====== */
  .toolbar button,
  .toolbar [data-cmd] {
    padding: 8px 14px;
    background: rgba(42, 31, 26, 0.5);
    color: #e5e5e5;
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    white-space: nowrap;
  }

  .toolbar button:hover,
  .toolbar [data-cmd]:hover {
    background: rgba(255, 139, 122, 0.15);
    border-color: rgba(255, 139, 122, 0.4);
    color: #FF8B7A;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(255, 107, 107, 0.2);
  }

  .toolbar button:active,
  .toolbar [data-cmd]:active {
    transform: translateY(0);
  }

  /* 텍스트 스타일 버튼 아이콘 */
  .toolbar [data-cmd="bold"] strong {
    font-weight: 900;
    color: #FF8B7A;
  }

  .toolbar [data-cmd="italic"] i {
    font-style: italic;
    color: #FF8B7A;
  }

  .toolbar [data-cmd="strike"] s {
    color: #FF8B7A;
  }

  .toolbar [data-cmd="underline"] {
    text-decoration: underline;
    color: #FF8B7A;
  }

  /* 헤딩 버튼 강조 */
  .toolbar [data-cmd^="heading"] {
    font-weight: 700;
    background: linear-gradient(135deg, 
      rgba(255, 107, 107, 0.15) 0%, 
      rgba(255, 139, 122, 0.1) 100%
    );
  }

  /* 리스트 버튼 */
  .toolbar [data-cmd$="List"] {
    font-family: monospace;
  }

  /* 활성화된 버튼 */
  .toolbar button.is-active,
  .toolbar [data-cmd].is-active {
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    color: #fff;
    border-color: rgba(255, 255, 255, 0.2);
    box-shadow: 0 2px 8px rgba(255, 107, 107, 0.4);
  }

  /* ====== 에디터 보드 ====== */
  .board {
    min-height: 500px;
    padding: 24px;
    background: rgba(42, 31, 26, 0.3);
    border: 2px solid rgba(255, 139, 122, 0.15);
    border-radius: 12px;
    color: #e5e5e5;
    font-size: 16px;
    line-height: 1.8;
    outline: none;
    margin-bottom: 24px;
    box-shadow: inset 0 2px 8px rgba(0, 0, 0, 0.2);
  }

  .board:focus-within {
    border-color: #FF8B7A;
    box-shadow: 
      inset 0 2px 8px rgba(0, 0, 0, 0.2),
      0 0 0 3px rgba(255, 139, 122, 0.1);
  }

  /* 에디터 내부 텍스트 스타일 */
  .board h1 {
    color: #FF8B7A;
    font-size: 2rem;
    font-weight: 700;
    margin: 0 0 16px 0;
  }

  .board h2 {
    color: #FF8B7A;
    font-size: 1.5rem;
    font-weight: 600;
    margin: 0 0 12px 0;
  }

  .board h3 {
    color: #FF8B7A;
    font-size: 1.25rem;
    font-weight: 600;
    margin: 0 0 10px 0;
  }

  .board p {
    margin: 0 0 12px 0;
  }

  .board ul,
  .board ol {
    padding-left: 24px;
    margin: 0 0 12px 0;
  }

  .board li {
    margin-bottom: 6px;
  }

  .board a {
    color: #FF8B7A;
    text-decoration: underline;
  }

  .board strong {
    color: #fff;
    font-weight: 700;
  }

  .board code {
    background: rgba(255, 139, 122, 0.1);
    color: #FFA07A;
    padding: 2px 6px;
    border-radius: 4px;
    font-family: 'Courier New', monospace;
  }

  /* ====== 하단 액션 버튼 ====== */
  .actions {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    padding-top: 24px;
    border-top: 1px solid rgba(255, 139, 122, 0.15);
  }

  .btn-primary {
    flex: 1;
    max-width: 200px;
    padding: 14px 32px;
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    color: #fff;
    border: none;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
    position: relative;
    overflow: hidden;
  }

  .btn-primary::before {
    content: "💾";
    margin-right: 8px;
  }

  .btn-primary::after {
    content: "";
    position: absolute;
    inset: 0;
    background: linear-gradient(135deg, 
      rgba(255, 255, 255, 0.2) 0%, 
      transparent 100%
    );
    opacity: 0;
    transition: opacity 0.3s ease;
  }

  .btn-primary:hover {
    background: linear-gradient(135deg, #FF8B7A 0%, #FFA07A 100%);
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(255, 107, 107, 0.5);
  }

  .btn-primary:hover::after {
    opacity: 1;
  }

  .btn-primary:active {
    transform: translateY(0);
  }

  .btn-secondary {
    padding: 14px 32px;
    background: rgba(42, 31, 26, 0.6);
    color: #e5e5e5;
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 10px;
    font-size: 16px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s ease;
  }

  .btn-secondary::before {
    content: "❌";
    margin-right: 8px;
  }

  .btn-secondary:hover {
    background: rgba(42, 31, 26, 0.8);
    border-color: rgba(255, 139, 122, 0.4);
    color: #FF8B7A;
    transform: translateY(-2px);
  }

  .btn-secondary:active {
    transform: translateY(0);
  }

  /* ====== 반응형 ====== */
  @media (max-width: 768px) {
    .input-title {
      font-size: 1.25rem;
      padding: 14px 16px;
    }

    .toolbar {
      gap: 4px;
      padding: 12px;
    }

    .toolbar button,
    .toolbar [data-cmd] {
      padding: 7px 12px;
      font-size: 13px;
    }

    .board {
      min-height: 400px;
      padding: 20px;
      font-size: 15px;
    }

    .actions {
      flex-direction: column-reverse;
    }

    .btn-primary {
      max-width: 100%;
    }

    .btn-secondary {
      width: 100%;
    }
  }

  /* ====== 로딩 상태 ====== */
  @keyframes saving {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.6; }
  }

  .btn-primary.is-saving {
    animation: saving 1.5s ease-in-out infinite;
    pointer-events: none;
  }

  .btn-primary.is-saving::before {
    content: "⏳";
  }
</style>

<!-- 에디터 컨테이너 -->
<div class="container">
  <!-- 헤더 액션 -->
  <div class="header-actions">
    <a href="${pageContext.request.contextPath}/meeting-gather.jsp" class="btn">
      ← 목록으로
    </a>
  </div>

  <!-- 제목 입력 -->
  <input 
    type="text" 
    id="post-title-input" 
    class="input-title"
    value="${post.title}" 
    placeholder="제목을 입력하세요. 예: 한강공원 노을 맛집 🌅" 
  />

  <!-- 툴바 -->
  <div id="toolbar" class="toolbar">
    <button data-cmd="bold" title="굵게 (Ctrl+B)">
      <strong>B</strong>
    </button>
    <button data-cmd="italic" title="기울임 (Ctrl+I)">
      <i>I</i>
    </button>
    <button data-cmd="strike" title="취소선">
      <s>S</s>
    </button>
    <button data-cmd="underline" title="밑줄 (Ctrl+U)">
      U
    </button>

    <jsp:include page="/WEB-INF/template/text-style-btn.jsp"></jsp:include>

    <button data-cmd="heading1" title="제목 1">H1</button>
    <button data-cmd="heading2" title="제목 2">H2</button>
    <button data-cmd="heading3" title="제목 3">H3</button>

    <button data-cmd="bulletList" title="글머리 기호">● List</button>
    <button data-cmd="orderedList" title="번호 매기기">1. List</button>

    <jsp:include page="/WEB-INF/include/image-modal.jsp" />
    <jsp:include page="/WEB-INF/include/map-modal.jsp" />
    <jsp:include page="/WEB-INF/include/schedule-modal.jsp" />
    <jsp:include page="/WEB-INF/include/emoji-picker.jsp" />
    <jsp:include page="/WEB-INF/template/link-btn.jsp"></jsp:include>
  </div>

  <!-- 에디터 보드 -->
  <div id="board" class="board" contenteditable="true"></div>

  <!-- 하단 액션 버튼 -->
  <div class="actions">
    <button class="btn-secondary" onclick="cancelPost()">취소</button>
    <button class="btn-primary" onclick="savePost()">저장</button>
  </div>
</div>

<script type="module">
  import { initEditor } from "./js/editor-init.js";

  // 에디터 초기화
  const editor = initEditor(
    document.getElementById("board"),
    document.getElementById("toolbar")
  );

  // 저장 함수
  window.savePost = function() {
    const saveBtn = document.querySelector('.btn-primary');
    const titleInput = document.querySelector("#post-title-input");
    
    // 제목 검증
    if (!titleInput.value.trim()) {
      alert("제목을 입력해주세요.");
      titleInput.focus();
      return;
    }

    // 로딩 상태 표시
    saveBtn.classList.add('is-saving');
    saveBtn.disabled = true;

    const content = editor.getJSON();
    const data = {
      title: titleInput.value,
      content: content
    };

    fetch("/editor-create.post", {
      method: "POST",
      headers: { 
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest" 
      },
      body: JSON.stringify(data)
    })
    .then(res => {
      if (!res.ok) {
        throw new Error('서버 오류: ' + res.status);
      }
      return res.json();
    })
    .then(result => {
      console.log("서버 응답:", result);

      if (result.success && result.redirectUrl) {
        alert("✨ 게시글이 저장되었습니다!");
        history.back();
      } else {
        alert("⚠️ 게시글 저장에 성공했으나 이동할 페이지 정보가 없습니다.");
      }
    })
    .catch(err => {
      console.error("전송 오류:", err);
      alert("❌ 게시글 저장 중 오류가 발생했습니다.");
    })
    .finally(() => {
      // 로딩 상태 해제
      saveBtn.classList.remove('is-saving');
      saveBtn.disabled = false;
    });
  };

  // 취소 함수
  window.cancelPost = function() {
    if (confirm("작성을 취소하시겠습니까?\n작성 중인 내용은 저장되지 않습니다.")) {
      history.back();
    }
  };

  // 이모지 기능
  import * as EmojiModule from "./js/emoji.js";
  window.openEmojiPicker = EmojiModule.openPicker;
  EmojiModule.setupEmojiSuggestion(editor);

  // 키보드 단축키
  document.addEventListener('keydown', (e) => {
    // Ctrl/Cmd + S: 저장
    if ((e.ctrlKey || e.metaKey) && e.key === 's') {
      e.preventDefault();
      savePost();
    }
    // Esc: 취소
    if (e.key === 'Escape') {
      cancelPost();
    }
  });

  // 자동 저장 (선택사항)
  let autoSaveTimer;
  const autoSave = () => {
    const content = editor.getJSON();
    const title = document.querySelector("#post-title-input").value;
    if (title.trim()) {
      localStorage.setItem('draft_title', title);
      localStorage.setItem('draft_content', JSON.stringify(content));
      console.log('📝 자동 저장됨');
    }
  };

  // 5분마다 자동 저장
  setInterval(autoSave, 5 * 60 * 1000);

  // 페이지 로드 시 임시 저장 복원
  window.addEventListener('load', () => {
    const draftTitle = localStorage.getItem('draft_title');
    const draftContent = localStorage.getItem('draft_content');
    
    if (draftTitle && draftContent) {
      if (confirm('저장되지 않은 임시 글이 있습니다. 복원하시겠습니까?')) {
        document.querySelector("#post-title-input").value = draftTitle;
        // editor.commands.setContent(JSON.parse(draftContent));
      } else {
        localStorage.removeItem('draft_title');
        localStorage.removeItem('draft_content');
      }
    }
  });
</script>