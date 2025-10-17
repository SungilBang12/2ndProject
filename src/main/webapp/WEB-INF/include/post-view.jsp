<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- Kakao Map API -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=c72248c25fcfe17e7a6934e08908d1f4&libraries=services"></script>

<script>
// [기존 전역 설정 스크립트는 그대로 유지]
window.contextPath = "<c:out value='${pageContext.request.contextPath}'/>";
console.log("=== 전역 contextPath 설정:", window.contextPath);

window.getPostIdFromUrl = function() {
  const params = new URLSearchParams(window.location.search);
  const postId = params.get("postId");
  console.log("=== URL에서 추출한 postId:", postId);
  return postId ? parseInt(postId, 10) : null;
};

window.currentPostId = window.getPostIdFromUrl();
console.log("=== 전역 postId 설정:", window.currentPostId);

window.editPost = function() {
  console.log("=== editPost 함수 호출 ===");
  
  const postId = window.currentPostId || document.getElementById('hiddenPostId')?.value;
  const contextPath = window.contextPath;
  
  console.log("postId:", postId);
  console.log("contextPath:", contextPath);
  
  if (!postId || isNaN(postId) || postId <= 0) {
      alert("게시글 번호 정보가 누락되었습니다.");
      console.error("유효하지 않은 postId:", postId);
      return;
  }
  
  const editUrl = contextPath + "/post-edit-form.post?postId=" + postId;
  console.log("=== 이동할 URL:", editUrl);
  
  window.location.href = editUrl;
};

window.deletePost = function() {
  console.log("=== deletePost 함수 호출 ===");
  
  const postId = window.currentPostId || document.getElementById('hiddenPostId')?.value;
  const contextPath = window.contextPath;
  
  console.log("postId:", postId);
  
  if (!postId || isNaN(postId) || postId <= 0) {
      alert("게시글 번호 정보가 누락되었습니다.");
      return;
  }

  if (!confirm("정말로 이 게시글을 삭제하시겠습니까?")) return;

  $.ajax({
      url: "<c:url value='/delete.postasync'/>",
      type: "POST",
      contentType: "application/json",
      data: JSON.stringify({ postId: parseInt(postId) }),
      dataType: "json",
      success: function(result) {
          if (result.status === "success") {
              alert("✨ 게시글이 성공적으로 삭제되었습니다.");
              
              const previousUrl = document.referrer;
              const redirectUrl = (previousUrl && previousUrl !== window.location.href) 
                  ? previousUrl 
                  : contextPath + "/index.jsp";
              
              window.location.href = redirectUrl;
          } else {
              alert("❌ 삭제 실패: " + (result.message || "알 수 없는 오류"));
          }
      },
      error: function(jqXHR, textStatus, errorThrown) {
          console.error("AJAX 오류:", textStatus, errorThrown);
          alert("❌ 서버 통신 오류로 삭제에 실패했습니다.");
      }
  });
};

console.log("=== 전역 함수 등록 완료 ===");
</script>

<!-- Sunset 테마 CSS -->
<style>
  /* ====== 목록으로 버튼 ====== */
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
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 10px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s ease;
  }

  .header-actions .btn:hover {
    background: rgba(42, 31, 26, 0.8);
    border-color: rgba(255, 139, 122, 0.4);
    color: #FF8B7A;
    transform: translateX(-4px);
  }

  /* ====== 게시글 헤더 ====== */
  .post-header {
    margin-bottom: 32px;
    padding-bottom: 24px;
    border-bottom: 2px solid rgba(255, 139, 122, 0.2);
  }

  .post-title {
    margin: 0 0 16px 0;
    font-family: 'Noto Serif KR', serif;
    font-size: clamp(1.75rem, 3vw, 2.5rem);
    font-weight: 700;
    color: #fff;
    letter-spacing: -0.02em;
    line-height: 1.4;
    word-break: keep-all;
  }

  .post-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    color: rgba(229, 229, 229, 0.7);
    font-size: 14px;
  }

  .post-meta-item {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .post-meta-item strong {
    color: #FF8B7A;
    font-weight: 600;
  }

  /* ====== 게시글 본문 (ProseMirror) ====== */
  .ProseMirror {
    background: linear-gradient(135deg, 
      rgba(42, 31, 26, 0.4) 0%, 
      rgba(26, 22, 20, 0.4) 100%
    );
    border: 1px solid rgba(255, 139, 122, 0.15);
    border-radius: 12px;
    padding: 32px;
    min-height: 400px;
    line-height: 1.8;
    word-break: break-word;
    color: #e5e5e5;
    font-size: 16px;
    box-shadow: inset 0 2px 8px rgba(0, 0, 0, 0.2);
  }

  /* 본문 제목 스타일 */
  .ProseMirror h1 {
    color: #FF8B7A;
    font-size: 2rem;
    font-weight: 700;
    margin: 32px 0 16px 0;
    padding-bottom: 12px;
    border-bottom: 2px solid rgba(255, 139, 122, 0.3);
  }

  .ProseMirror h1:first-child {
    margin-top: 0;
  }

  .ProseMirror h2 {
    color: #FF8B7A;
    font-size: 1.5rem;
    font-weight: 600;
    margin: 28px 0 14px 0;
  }

  .ProseMirror h3 {
    color: #FF8B7A;
    font-size: 1.25rem;
    font-weight: 600;
    margin: 24px 0 12px 0;
  }

  /* 본문 문단 */
  .ProseMirror p {
    margin: 0 0 16px 0;
    line-height: 1.8;
  }

  /* 리스트 */
  .ProseMirror ul,
  .ProseMirror ol {
    margin: 16px 0;
    padding-left: 28px;
    color: #e5e5e5;
  }

  .ProseMirror li {
    margin-bottom: 8px;
    line-height: 1.6;
  }

  /* 링크 */
  .ProseMirror a {
    color: #FF8B7A;
    text-decoration: underline;
    transition: all 0.3s ease;
  }

  .ProseMirror a:hover {
    color: #FFA07A;
    text-decoration: none;
  }

  /* 강조 */
  .ProseMirror strong {
    color: #fff;
    font-weight: 700;
  }

  .ProseMirror em {
    color: #FFA07A;
    font-style: italic;
  }

  /* 인라인 코드 */
  .ProseMirror code {
    background: rgba(255, 139, 122, 0.15);
    color: #FFA07A;
    padding: 3px 8px;
    border-radius: 4px;
    font-family: 'Courier New', monospace;
    font-size: 0.9em;
  }

  /* 코드 블록 */
  .ProseMirror pre {
    background: rgba(26, 22, 20, 0.8);
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 8px;
    padding: 16px;
    overflow-x: auto;
    margin: 16px 0;
  }

  .ProseMirror pre code {
    background: none;
    color: #68D391;
    padding: 0;
  }

  /* 인용구 */
  .ProseMirror blockquote {
    border-left: 4px solid #FF8B7A;
    padding-left: 20px;
    margin: 20px 0;
    color: rgba(229, 229, 229, 0.8);
    font-style: italic;
  }

  /* 이미지 */
  .ProseMirror img {
    max-width: 100%;
    height: auto;
    border-radius: 12px;
    margin: 24px 0;
    display: block;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
    transition: transform 0.3s ease;
  }

  .ProseMirror img:hover {
    transform: scale(1.02);
  }

  /* 구분선 */
  .ProseMirror hr {
    border: none;
    border-top: 2px solid rgba(255, 139, 122, 0.2);
    margin: 32px 0;
  }

  /* 테이블 */
  .ProseMirror table {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
    background: rgba(42, 31, 26, 0.5);
    border-radius: 8px;
    overflow: hidden;
  }

  .ProseMirror th,
  .ProseMirror td {
    padding: 12px;
    border: 1px solid rgba(255, 139, 122, 0.2);
    text-align: left;
  }

  .ProseMirror th {
    background: rgba(255, 139, 122, 0.15);
    color: #FF8B7A;
    font-weight: 600;
  }

  /* ====== 액션 버튼 ====== */
  .action-buttons {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 12px;
    margin-top: 32px;
    padding-top: 24px;
    border-top: 1px solid rgba(255, 139, 122, 0.15);
  }

  .action-buttons .btn {
    padding: 12px 24px;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    font-size: 15px;
    font-weight: 600;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
  }

  .action-buttons .btn::before {
    margin-right: 6px;
  }

  /* 수정 버튼 */
  .action-buttons .btn-primary {
    background: linear-gradient(135deg, #4299E1 0%, #63B3ED 100%);
    color: white;
    box-shadow: 0 4px 12px rgba(66, 153, 225, 0.3);
  }

  .action-buttons .btn-primary::before {
    content: "✏️";
  }

  .action-buttons .btn-primary:hover {
    background: linear-gradient(135deg, #63B3ED 0%, #7DC4F5 100%);
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(66, 153, 225, 0.5);
  }

  /* 삭제 버튼 */
  .action-buttons .btn-danger {
    background: linear-gradient(135deg, #E53E3E 0%, #F56565 100%);
    color: white;
    box-shadow: 0 4px 12px rgba(229, 62, 62, 0.3);
  }

  .action-buttons .btn-danger::before {
    content: "🗑️";
  }

  .action-buttons .btn-danger:hover {
    background: linear-gradient(135deg, #F56565 0%, #FC8181 100%);
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(229, 62, 62, 0.5);
  }

  .action-buttons .btn:active {
    transform: translateY(0);
  }

  /* 권한 없음 메시지 */
  .action-buttons p {
    margin: 0;
    color: rgba(229, 229, 229, 0.6);
    font-size: 14px;
    font-style: italic;
  }

  /* ====== 카카오 맵 스타일 ====== */
  .map-container {
    margin: 24px 0;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 139, 122, 0.2);
  }

  /* ====== Hidden Input ====== */
  #hiddenPostId {
    display: none;
  }

  /* ====== 반응형 ====== */
  @media (max-width: 768px) {
    .post-title {
      font-size: 1.5rem;
    }

    .ProseMirror {
      padding: 20px;
      font-size: 15px;
    }

    .ProseMirror h1 {
      font-size: 1.5rem;
    }

    .ProseMirror h2 {
      font-size: 1.25rem;
    }

    .ProseMirror h3 {
      font-size: 1.125rem;
    }

    .action-buttons {
      flex-direction: column-reverse;
      gap: 8px;
    }

    .action-buttons .btn {
      width: 100%;
    }

    .post-meta {
      flex-direction: column;
      gap: 8px;
    }
  }

  /* ====== 로딩 애니메이션 ====== */
  @keyframes shimmer {
    0% {
      background-position: -1000px 0;
    }
    100% {
      background-position: 1000px 0;
    }
  }

  .loading-skeleton {
    background: linear-gradient(
      90deg,
      rgba(42, 31, 26, 0.4) 0%,
      rgba(255, 139, 122, 0.1) 50%,
      rgba(42, 31, 26, 0.4) 100%
    );
    background-size: 1000px 100%;
    animation: shimmer 2s infinite;
    border-radius: 8px;
  }

  /* ====== 이모지 스타일 ====== */
  .ProseMirror .emoji {
    font-size: 1.2em;
    vertical-align: middle;
  }

  /* ====== 체크리스트 ====== */
  .ProseMirror ul[data-type="taskList"] {
    list-style: none;
    padding-left: 0;
  }

  .ProseMirror ul[data-type="taskList"] li {
    display: flex;
    align-items: flex-start;
    gap: 8px;
  }

  .ProseMirror ul[data-type="taskList"] li input[type="checkbox"] {
    margin-top: 4px;
    accent-color: #FF8B7A;
  }
</style>

<!-- 목록으로 버튼 -->
<div class="header-actions">
    <button onclick="history.back()" class="btn">← 목록으로</button>
</div>

<!-- 게시글 정보 -->
<div class="post-header">
    <h1 class="post-title">${post.title}</h1>
    <div class="post-meta">
        <span class="post-meta-item">
            <strong>👤 작성자:</strong> 
            ${post.userId}
        </span>
        <span class="post-meta-item">
            <strong>📅 작성일:</strong> 
            ${post.createdAt}
        </span>
        <c:if test="${not empty post.hit}">
            <span class="post-meta-item">
                <strong>👁️ 조회수:</strong> 
                ${post.hit}
            </span>
        </c:if>
    </div>
</div>

<!-- Hidden input으로 postId 저장 -->
<input type="hidden" id="hiddenPostId" value="${post.postId}">

<!-- 게시글 본문 -->
<div id="board" class="ProseMirror"></div>

<!-- 액션 버튼 (작성자만 표시) -->
<c:if test="${not empty sessionScope.user.userId && sessionScope.user.userId == post.userId}">
    <div class="action-buttons">
        <button onclick="editPost()" class="btn btn-primary">수정</button>
        <button onclick="deletePost()" class="btn btn-danger">삭제</button>
    </div>
</c:if>

<!-- 권한 없는 사용자에게 메시지 표시 -->
<c:if test="${not empty sessionScope.userId && sessionScope.userId != post.userId}">
    <div class="action-buttons">
        <p>🔒 본인이 작성한 게시글만 수정/삭제할 수 있습니다.</p>
    </div>
</c:if>

<!-- 스크립트 -->
<script type="module">
import { initViewer, deactivateEditMode} from "<c:url value='/js/editor-view.js'/>";
console.log("=== post-view.jsp 모듈 스크립트 실행 ===");

// ===== 게시글 내용 로드 =====
const jsonData = `${post.content}`;
let content;

try {
    content = JSON.parse(jsonData);
} catch (err) {
    console.error("JSON 파싱 오류:", err);
    content = {
        type: "doc",
        content: [{
            type: "paragraph",
            content: [{ type: "text", text: "❌ 내용을 불러올 수 없습니다." }]
        }]
    };
}

// TipTap 뷰어 초기화
const editor = initViewer(document.getElementById("board"), content);
// 에디터 비활성화
deactivateEditMode(editor);

  
console.log("=== 에디터 초기화 완료 ===");
</script>