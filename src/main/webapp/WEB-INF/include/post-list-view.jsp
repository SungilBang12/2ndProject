<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="listId" value="${empty param.listId ? 0 : param.listId}" />

<c:set var="boardTitle">
  <c:choose>
    <c:when test="${listId == 0}">전체 게시판</c:when>
    <c:when test="${listId == 1}">노을</c:when>
    <c:when test="${listId == 2}">맛집 추천</c:when>
    <c:when test="${listId == 3}">맛집 후기</c:when>
    <c:when test="${listId == 4}">촬영 TIP</c:when>
    <c:when test="${listId == 5}">장비 추천</c:when>
    <c:when test="${listId == 6}">중고 거래</c:when>
    <c:when test="${listId == 7}">'해'쳐 모여</c:when>
    <c:when test="${listId == 8}">장소 추천</c:when>
    <c:otherwise>게시판</c:otherwise>
  </c:choose>
</c:set>

<div id="board" class="slot-board" data-list-id="${listId}">
  
  <!-- 헤더 -->
  <header class="board-header">
    <h1 class="board-title">${boardTitle}</h1>
  </header>

  <!-- 공지사항 -->
  <div id="noticeArea" class="notice-area" style="display: none;">
    <div class="notice-badge">📢</div>
    <div class="notice-content" id="noticeContent"></div>
    <div class="notice-dots" id="noticeIndicator"></div>
  </div>

  <!-- 정렬 옵션 -->
  <div class="controls">
    <div class="sort-group">
      <select id="sortSelect">
        <option value="newest">최신순</option>
        <option value="views">조회수</option>
        <option value="oldest">오래된순</option>
      </select>
      <select id="limitSelect">
        <option value="5">5개</option>
        <option value="10" selected>10개</option>
        <option value="15">15개</option>
      </select>
    </div>
    <button class="btn-write" id="writeBtn">글쓰기</button>
  </div>

  <!-- 게시글 목록 -->
  <div class="post-list" id="boardGrid"></div>

  <!-- 페이지네이션 -->
  <div class="pagination">
    <button class="page-btn" id="prevBtn">이전</button>
    <span class="page-info">
      <span id="curPage">1</span> / <span id="totalPages">1</span>
    </span>
    <button class="page-btn" id="nextBtn">다음</button>
  </div>

</div>

<style>
/* ========== 변수 ========== */
:root {
  --coral: #ff6b6b;
  --gray-50: #f9fafb;
  --gray-100: #f3f4f6;
  --gray-200: #e5e7eb;
  --gray-300: #d1d5db;
  --gray-600: #4b5563;
  --gray-700: #374151;
  --gray-800: #1f2937;
  --gray-900: #111827;
}

/* ========== 헤더 ========== */
.board-header {
  margin-bottom: 32px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--gray-200);
}

.board-title {
  margin: 0;
  font-size: 28px;
  font-weight: 700;
  color: var(--gray-900);
}

/* ========== 공지사항 ========== */
.notice-area {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  margin-bottom: 24px;
  background: #fff5f5;
  border-left: 4px solid var(--coral);
  border-radius: 8px;
}

.notice-badge {
  font-size: 20px;
  flex-shrink: 0;
}

.notice-content {
  flex: 1;
  font-size: 15px;
  font-weight: 500;
  color: var(--gray-800);
}

.notice-content a {
  color: var(--gray-800);
  text-decoration: none;
}

.notice-content a:hover {
  color: var(--coral);
}

.notice-dots {
  display: flex;
  gap: 6px;
}

.notice-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--gray-300);
  cursor: pointer;
}

.notice-dot.active {
  background: var(--coral);
}

/* ========== 컨트롤 ========== */
.controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.sort-group {
  display: flex;
  gap: 8px;
}

.controls select {
  padding: 8px 32px 8px 12px;
  border: 1px solid var(--gray-300);
  border-radius: 6px;
  background: white;
  font-size: 14px;
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%234b5563' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 10px center;
}

.controls select:focus {
  outline: none;
  border-color: var(--coral);
}

.btn-write {
  padding: 8px 20px;
  background: var(--coral);
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
}

.btn-write:hover {
  background: #ff5252;
}

/* ========== 게시글 목록 ========== */
.post-list {
  display: flex;
  flex-direction: column;
  gap: 1px;
  background: #e5e7eb00;
  border-radius: 8px;
  overflow: hidden;
  margin-bottom: 24px;
}

.post-card {
  padding: 20px;
  background: white;
  cursor: pointer;
  transition: background 0.2s;
}

.post-card:hover {
  background: var(--gray-50);
}

.post-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.post-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: #171425;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: 700;
  flex-shrink: 0;
}

.post-icon.equipment { background: #171425; }
.post-icon.meeting { background: #171425 }

.post-title {
  flex: 1;
  font-size: 16px;
  font-weight: 600;
  color: var(--gray-900);
  line-height: 1.4;
}

.post-title a {
  color: inherit;
  text-decoration: none;
}

.post-title a:hover {
  color: var(--coral);
}

.post-content {
  color: var(--gray-600);
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 12px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.post-meta {
  display: flex;
  gap: 12px;
  font-size: 13px;
  color: var(--gray-600);
}

.post-meta span {
  display: flex;
  align-items: center;
  gap: 4px;
}

/* 하이라이트 */
mark {
  background: #fff5f5;
  color: var(--coral);
  padding: 2px 4px;
  border-radius: 3px;
  font-weight: 600;
}

/* ========== 페이지네이션 ========== */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
}

.page-btn {
  padding: 8px 16px;
  border: 1px solid var(--gray-300);
  background: white;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  color: var(--gray-700);
}

.page-btn:hover:not(:disabled) {
  border-color: var(--coral);
  color: var(--coral);
}

.page-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.page-info {
  font-size: 14px;
  color: var(--gray-600);
  min-width: 80px;
  text-align: center;
}

/* ========== 상태 ========== */
.empty, .loading, .error {
  padding: 60px 20px;
  text-align: center;
  color: var(--gray-600);
  font-size: 15px;
  background: var(--gray-50);
  border-radius: 8px;
}

.loading {
  color: var(--coral);
}

.error {
  color: #dc2626;
}

/* ========== 반응형 ========== */
@media (max-width: 768px) {
  .board-title {
    font-size: 24px;
  }

  .controls {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .sort-group {
    justify-content: space-between;
  }

  .btn-write {
    width: 100%;
  }

  .post-card {
    padding: 16px;
  }

  .post-icon {
    width: 36px;
    height: 36px;
    font-size: 16px;
  }

  .post-title {
    font-size: 15px;
  }

  .pagination {
    gap: 12px;
  }
}
</style>

<script>
(function(){
  function escapeHtml(s) {
    if (s == null) return "";
    return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }
  
  function escapeRegExp(s){ 
    var specials = ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\', '^'];
    var escapedStr = s;
    for (var i = 0; i < specials.length; i++) {
      escapedStr = escapedStr.split(specials[i]).join('\\' + specials[i]);
    }
    escapedStr = escapedStr.split('$').join('\\$');
    return escapedStr;
  }
  
  function highlightText(text, query) {
    if (!query || !text) return text;
    try {
      var re = new RegExp("(" + escapeRegExp(query) + ")", "gi");
      return text.replace(re, "<mark>$1</mark>");
    } catch(e) { return text; }
  }

  var contextPath = "<c:url value='/'/>";
  var grid = document.getElementById("boardGrid");
  var sortSelect = document.getElementById("sortSelect");
  var limitSelect = document.getElementById("limitSelect");
  var prevBtn = document.getElementById("prevBtn");
  var nextBtn = document.getElementById("nextBtn");
  var curPageEl = document.getElementById("curPage");
  var totalPagesEl = document.getElementById("totalPages");
  var listId = document.getElementById("board").getAttribute("data-list-id") || "0";

  window.currentPage = 1;
  window.currentQuery = "";
  var totalPages = 1;
  
  var notices = [];
  var currentNoticeIndex = 0;
  var noticeInterval = null;

  // 공지사항
  function loadNotices() {
    fetch(contextPath + "postList2.async?listId=9&limit=100")
      .then(function(res) {
        if (!res.ok) throw new Error("Network " + res.status);
        return res.json();
      })
      .then(function(data) {
        notices = data.posts || [];
        if (notices.length > 0) {
          document.getElementById("noticeArea").style.display = "flex";
          showNotice(0);
          if (notices.length > 1) startNoticeRotation();
        }
      })
      .catch(function(err) {
        console.error("공지사항 로드 실패:", err);
      });
  }
  
  function showNotice(index) {
    if (!notices || notices.length === 0) return;
    
    currentNoticeIndex = index;
    var notice = notices[index];
    var noticeContent = document.getElementById("noticeContent");
    
    var link = "post-detail.post?postId=" + encodeURIComponent(notice.postId)
             + "&listId=" + encodeURIComponent(notice.listId || 9);
    
    noticeContent.innerHTML = '<a href="' + link + '">' 
      + escapeHtml(notice.title || "공지사항") 
      + '</a>';
    
    updateNoticeIndicator(index);
  }
  
  function updateNoticeIndicator(activeIndex) {
    var indicator = document.getElementById("noticeIndicator");
    if (notices.length <= 1) {
      indicator.style.display = "none";
      return;
    }
    
    indicator.style.display = "flex";
    var html = "";
    for (var i = 0; i < notices.length; i++) {
      html += '<span class="notice-dot' + (i === activeIndex ? ' active' : '') + '"></span>';
    }
    indicator.innerHTML = html;
    
    var dots = indicator.querySelectorAll(".notice-dot");
    for (var i = 0; i < dots.length; i++) {
      (function(idx) {
        dots[idx].onclick = function() {
          showNotice(idx);
        };
      })(i);
    }
  }
  
  function startNoticeRotation() {
    if (noticeInterval) clearInterval(noticeInterval);
    noticeInterval = setInterval(function() {
      var nextIndex = (currentNoticeIndex + 1) % notices.length;
      showNotice(nextIndex);
    }, 3000);
  }
  
  // 게시글 렌더링
  function renderPosts(posts){
    if (!Array.isArray(posts) || posts.length === 0){
      grid.innerHTML = '<div class="empty">게시글이 없습니다</div>';
      return;
    }
    
    var html = "";
    for (var i=0; i<posts.length; i++){
      var p = posts[i] || {};
      var postId = (p.postId != null ? p.postId : "");
      var titleRaw = p.title ? String(p.title) : "제목 없음";
      var contentRaw = p.content ? String(p.content) : "내용 없음";
      var shortContent = contentRaw.length > 100 ? contentRaw.substring(0,100) + "..." : contentRaw;

      if (window.currentQuery) {
        titleRaw = highlightText(titleRaw, window.currentQuery);
        shortContent = highlightText(shortContent, window.currentQuery);
      }

      var postType = p.postType || "";
      var postTypeClass = postType ? postType.toLowerCase() : "";
      
      var postTypeInitial = postType ? postType.charAt(0).toUpperCase() : "📄";
      
      if (postTypeInitial == 'S') {
    	  postTypeInitial = "🌅";
        } else if (postTypeInitial == 'E') {
        	postTypeInitial = "📷";
        } else {
        	postTypeInitial = "👥";
        }
      

      var link = "post-detail.post?postId=" + encodeURIComponent(postId)
               + "&listId=" + encodeURIComponent(p.listId || listId);

      html += ''
        + '<div class="post-card">'
        +   '<div class="post-header">'
        +     '<div class="post-icon ' + postTypeClass + '">' + postTypeInitial + '</div>'
        +     '<div class="post-title">'
        +       '<a href="' + link + '">' + titleRaw + '</a>'
        +     '</div>'
        +   '</div>'
        +   '<div class="post-content">' + shortContent + '</div>'
        +   '<div class="post-meta">'
        +     '<span>' + escapeHtml(p.category || "-") + '</span>'
        +     '<span>' + escapeHtml(p.userId || "익명") + '</span>'
        +     '<span>' + escapeHtml(p.createdAt || "-") + '</span>'
        +     '<span>👁️ ' + escapeHtml(String((typeof p.hit === "number" ? p.hit : 0))) + '</span>'
        +   '</div>'
        + '</div>';
    }
    grid.innerHTML = html;
  }

  // 게시글 로드
  window.loadPosts = function() {
    var sort = sortSelect.value;
    var limit = limitSelect.value;
    var query = window.currentQuery;

    grid.innerHTML = '<div class="loading">로딩 중...</div>';

    try {
      var params = new URLSearchParams({
        sort: String(sort),
        limit: String(limit),
        page: String(window.currentPage),
        listId: String(listId)
      });
      if (query) params.set("q", query);

      var url = contextPath + "postList2.async?" + params.toString();
      fetch(url)
        .then(function(res){
          if (!res.ok) throw new Error("Network " + res.status);
          return res.json();
        })
        .then(function(data){
          totalPages = data.totalPages || 1;
          window.currentPage = data.currentPage || 1;

          curPageEl.textContent = window.currentPage;
          totalPagesEl.textContent = totalPages;

          renderPosts(data.posts || []);
          prevBtn.disabled = (window.currentPage === 1);
          nextBtn.disabled = (window.currentPage === totalPages);
        })
        .catch(function(err){
          console.error(err);
          grid.innerHTML = '<div class="error">게시글을 불러올 수 없습니다</div>';
        });
    } catch (err) {
      console.error(err);
      grid.innerHTML = '<div class="error">게시글을 불러올 수 없습니다</div>';
    }
  };

  // 이벤트
  prevBtn.addEventListener("click", function(){
    if (window.currentPage > 1) { window.currentPage--; loadPosts(); }
  });
  nextBtn.addEventListener("click", function(){
    if (window.currentPage < totalPages) { window.currentPage++; loadPosts(); }
  });
  sortSelect.addEventListener("change", function(){ window.currentPage = 1; loadPosts(); });
  limitSelect.addEventListener("change", function(){ window.currentPage = 1; loadPosts(); });

  document.getElementById("writeBtn").addEventListener("click", function(){
    window.location.href = contextPath + "editor.post?listId=" + encodeURIComponent(listId);
  });

  loadNotices();
  loadPosts();
})();
</script>