<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%-- 서버 EL만 사용 --%>
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
  <header class="board-header">
    <h1 class="board-title">${boardTitle}</h1>
  </header>

  <!-- 📢 공지사항 영역 -->
  <div id="noticeArea" class="notice-area" style="display: none;">
    <div class="notice-container">
      <div class="notice-badge">📢 공지</div>
      <div class="notice-content" id="noticeContent"></div>
      <div class="notice-indicator" id="noticeIndicator"></div>
    </div>
  </div>

  <div class="sort-bar">
    <label for="sortSelect">정렬 기준:</label>
    <select id="sortSelect" class="sort-select">
      <option value="newest" selected>최신순</option>
      <option value="views">조회수순</option>
      <option value="oldest">오래된순</option>
    </select>

    <label for="limitSelect" style="margin-left: 12px;">표시 개수:</label>
    <select id="limitSelect" class="sort-select">
      <option value="5">5개</option>
      <option value="10" selected>10개</option>
      <option value="15">15개</option>
    </select>
  </div>

  <main class="board-main">
    <div class="board-grid" id="boardGrid"></div>

    <div class="bottom-bar">
      <div class="page-controls">
        <button class="page-btn sunset-linefill" id="prevBtn"><span>◀ Prev</span></button>
        <span id="pageInfo"><strong><span id="curPage">1</span> / <span id="totalPages">1</span> 페이지</strong></span>
        <button class="page-btn sunset-linefill" id="nextBtn"><span>Next ▶</span></button>
      </div>
      <button class="page-btn sunset-ghost" id="writeBtn"><span>글쓰기</span></button>
    </div>
  </main>
</div>

<style>
/* 공지사항 영역 */
.notice-area {
  margin: 16px 0;
  opacity: 0;
  animation: fadeIn 0.5s ease-in forwards;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.notice-container {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.notice-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}

.notice-container:hover::before {
  left: 100%;
}

.notice-container:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.notice-badge {
  flex-shrink: 0;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.95);
  color: #667eea;
  border-radius: 20px;
  font-weight: 700;
  font-size: 14px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.notice-content {
  flex: 1;
  color: white;
  font-size: 15px;
  font-weight: 500;
  line-height: 1.5;
  position: relative;
}

/* 공지 전환 애니메이션 */
.notice-content.fade-out {
  animation: noticeFadeOut 0.5s ease-out forwards;
}

.notice-content.fade-in {
  animation: noticeFadeIn 0.5s ease-in forwards;
}

@keyframes noticeFadeOut {
  from { opacity: 1; transform: translateX(0); }
  to { opacity: 0; transform: translateX(-20px); }
}

@keyframes noticeFadeIn {
  from { opacity: 0; transform: translateX(20px); }
  to { opacity: 1; transform: translateX(0); }
}

.notice-content a {
  color: white;
  text-decoration: none;
  display: block;
}

.notice-content a:hover {
  text-decoration: underline;
}

/* 공지 인디케이터 */
.notice-indicator {
  position: absolute;
  right: 20px;
  bottom: 12px;
  display: flex;
  gap: 6px;
}

.notice-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.4);
  transition: all 0.3s ease;
  cursor: pointer;
}

.notice-dot:hover {
  background: rgba(255, 255, 255, 0.6);
  transform: scale(1.2);
}

.notice-dot.active {
  width: 24px;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.9);
}
</style>

<script>
(function(){
  // --- utils ---
  function escapeHtml(s) {
    if (s == null) return "";
    return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }
  
  // ✅ 안전한 정규식 이스케이프 ($ 문자를 직접 포함하지 않음)
  function escapeRegExp(s){ 
    var specials = ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\', '^'];
    var escapedStr = s;
    for (var i = 0; i < specials.length; i++) {
      escapedStr = escapedStr.split(specials[i]).join('\\' + specials[i]);
    }
    // $ 문자는 별도로 처리
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

  // --- DOM refs ---
  var contextPath = "<c:url value='/'/>";
  var grid = document.getElementById("boardGrid");
  var sortSelect = document.getElementById("sortSelect");
  var limitSelect = document.getElementById("limitSelect");
  var prevBtn = document.getElementById("prevBtn");
  var nextBtn = document.getElementById("nextBtn");
  var curPageEl = document.getElementById("curPage");
  var totalPagesEl = document.getElementById("totalPages");
  var listId = document.getElementById("board").getAttribute("data-list-id") || "0";

  // --- state ---
  window.currentPage = 1;
  window.currentQuery = "";
  var totalPages = 1;
  
  // --- 공지사항 state ---
  var notices = [];
  var currentNoticeIndex = 0;
  var noticeInterval = null;

  // --- 공지사항 함수 ---
  function loadNotices() {
    fetch(contextPath + "postList2.async?listId=9&limit=100")
      .then(function(res) {
        if (!res.ok) throw new Error("Network " + res.status);
        return res.json();
      })
      .then(function(data) {
        notices = data.posts || [];
        if (notices.length > 0) {
          document.getElementById("noticeArea").style.display = "block";
          showNotice(0);
          
          // 여러 개의 공지가 있으면 자동 회전 시작
          if (notices.length > 1) {
            startNoticeRotation();
          }
        } else {
          document.getElementById("noticeArea").style.display = "none";
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
    
    // Fade out
    noticeContent.classList.add("fade-out");
    
    setTimeout(function() {
      // 내용 변경
      noticeContent.innerHTML = '<a href="' + link + '">' 
        + escapeHtml(notice.title || "공지사항") 
        + '</a>';
      
      // Fade in
      noticeContent.classList.remove("fade-out");
      noticeContent.classList.add("fade-in");
      
      setTimeout(function() {
        noticeContent.classList.remove("fade-in");
      }, 500);
      
      // 인디케이터 업데이트
      updateNoticeIndicator(index);
    }, 500);
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
    
    // 인디케이터 클릭 이벤트
    var dots = indicator.querySelectorAll(".notice-dot");
    for (var i = 0; i < dots.length; i++) {
      (function(idx) {
        dots[idx].onclick = function() {
          stopNoticeRotation();
          showNotice(idx);
          if (notices.length > 1) {
            setTimeout(function() {
              startNoticeRotation();
            }, 3000); // 3초 후 자동 회전 재개
          }
        };
      })(i);
    }
  }
  
  function startNoticeRotation() {
    // 기존 타이머 정리
    if (noticeInterval) {
      clearInterval(noticeInterval);
    }
    
    // 2초마다 다음 공지로 전환
    noticeInterval = setInterval(function() {
      var nextIndex = (currentNoticeIndex + 1) % notices.length;
      showNotice(nextIndex);
    }, 2000);
  }
  
  function stopNoticeRotation() {
    if (noticeInterval) {
      clearInterval(noticeInterval);
      noticeInterval = null;
    }
  }
  
  // --- render ---
  function renderPosts(posts){
    if (!Array.isArray(posts) || posts.length === 0){
      grid.innerHTML = '<div class="empty">게시글이 없습니다.</div>';
      return;
    }
    
    var html = "";
    for (var i=0; i<posts.length; i++){
      var p = posts[i] || {};
      var postId = (p.postId != null ? p.postId : "");
      var titleRaw = p.title ? String(p.title) : "제목 없음";
      var contentRaw = p.content ? String(p.content) : "내용 없음";
      var shortContent = contentRaw.length > 120 ? contentRaw.substring(0,120) + "..." : contentRaw;

      // ✅ 검색어 하이라이트
      if (window.currentQuery) {
        titleRaw = highlightText(titleRaw, window.currentQuery);
        shortContent = highlightText(shortContent, window.currentQuery);
      }

      // ✅ 게시글 타입 버튼 (첫 글자)
      var postType = p.postType || "";
      var postTypeClass = postType ? postType.toLowerCase() : "";
      var postTypeInitial = postType ? postType.charAt(0).toUpperCase() : "?";

      // ✅ 링크 생성
      var link = "post-detail.post?postId=" + encodeURIComponent(postId)
               + "&listId=" + encodeURIComponent(p.listId || listId);

      html += ''
        + '<article class="post-card" data-id="' + escapeHtml(postId) + '">'
        +   '<div class="post-head">'
        +     '<button class="monogram-btn ' + postTypeClass + '" type="button">'
        +       postTypeInitial
        +     '</button>'
        +     '<div class="post-title">'
        +       '<a href="' + link + '">' + titleRaw + '</a>'
        +     '</div>'
        +   '</div>'
        +   '<div class="post-body">'
        +     '<div class="post-content">' + shortContent + '</div>'
        +     '<div class="meta">'
        +       '<span>' + escapeHtml(p.category || "카테고리 없음") + '</span> · '
        +       '<span>' + escapeHtml(p.userId || "익명") + '</span> · '
        +       '<span>🕒 ' + escapeHtml(p.createdAt || "-") + '</span> · '
        +       '<span>👁️ ' + escapeHtml(String((typeof p.hit === "number" ? p.hit : 0))) + '</span>'
        +     '</div>'
        +   '</div>'
        + '</article>';
    }
    grid.innerHTML = html;
  }

  // --- load ---
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
          grid.innerHTML = '<div class="error">⚠️ 게시글을 불러오지 못했습니다.</div>';
        });
    } catch (err) {
      console.error(err);
      grid.innerHTML = '<div class="error">⚠️ 게시글을 불러오지 못했습니다.</div>';
    }
  };

  // --- events ---
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
  
  // 공지사항 클릭 시 회전 일시 정지/재개
  document.getElementById("noticeArea").addEventListener("mouseenter", function() {
    stopNoticeRotation();
  });
  
  document.getElementById("noticeArea").addEventListener("mouseleave", function() {
    if (notices.length > 1) {
      startNoticeRotation();
    }
  });

  // --- first load ---
  loadNotices();  // 공지사항 로드
  loadPosts();    // 일반 게시글 로드
})();
</script>