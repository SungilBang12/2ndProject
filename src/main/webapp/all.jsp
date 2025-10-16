<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>노을 맛집 - 전체글 게시판</title>

  <link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=6">
  <link rel="stylesheet" href="<c:url value='/css/post-list.css'/>?v=2">
  <link rel="icon" href="<c:url value='/images/favicon.ico'/>?v=1">
</head>

<body>
  <jsp:include page="/WEB-INF/include/header.jsp" />

  <main class="main grid-14x5">
    <div class="slot-nav">
      <jsp:include page="/WEB-INF/include/nav.jsp" />
    </div>

    <div id="board" class="slot-board">
      <header class="board-header">
        <h1 class="board-title">전체 게시판</h1>
      </header>

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
  </main>

<script>
(function(){
  const contextPath = "<c:url value='/'/>";
  const grid = document.getElementById("boardGrid");
  const sortSelect = document.getElementById("sortSelect");
  const limitSelect = document.getElementById("limitSelect");
  const prevBtn = document.getElementById("prevBtn");
  const nextBtn = document.getElementById("nextBtn");
  const curPageEl = document.getElementById("curPage");
  const totalPagesEl = document.getElementById("totalPages");

  // ✅ 전역 상태
  window.currentPage = 1;
  window.currentQuery = "";
  let totalPages = 1;

  // ✅ 하이라이트 함수
  function highlightText(text, query) {
    if (!query || !text) return text;
    const regex = new RegExp(`(${query})`, "gi");
    return text.replace(regex, "<mark>$1</mark>");
  }

  // ✅ 게시글 로드 함수
  window.loadPosts = async function() {
    const sort = sortSelect.value;
    const limit = limitSelect.value;
    const query = window.currentQuery;

    grid.innerHTML = '<div class="loading">로딩 중...</div>';
    try {
      let url = `${contextPath}postList.async?sort=${sort}&limit=${limit}&page=${window.currentPage}`;
      if (query) url += `&q=${encodeURIComponent(query)}`;

      const res = await fetch(url);
      const data = await res.json();

      totalPages = data.totalPages;
      window.currentPage = data.currentPage;

      curPageEl.textContent = window.currentPage;
      totalPagesEl.textContent = totalPages;

      // ✅ 게시글 렌더링 + 검색어 하이라이트
      grid.innerHTML = data.posts.map(p => {
        const title = query ? highlightText(p.title || "제목 없음", query) : (p.title || "제목 없음");
        const shortContentRaw = p.content
          ? (p.content.length > 120 ? p.content.substring(0, 120) + "..." : p.content)
          : "내용 없음";
        const shortContent = query ? highlightText(shortContentRaw, query) : shortContentRaw;

        return `
          <article class="post-card" data-id="${p.postId}">
            <div class="post-head">
              <button class="monogram-btn ${p.postType ? p.postType.toLowerCase() : ''}" type="button">
                ${p.postType ? p.postType.charAt(0).toUpperCase() : "?"}
              </button>
              <div class="post-title">
                <a href="post-detail.post?postId=${p.postId}&categoryId=${p.categoryId}&postTypeId=${p.postTypeId}">
                  ${title}
                </a>
              </div>
            </div>
            <div class="post-body">
              <div class="post-content">${shortContent}</div>
              <div class="meta">
                <span>${p.category || "카테고리 없음"}</span> · 
                <span>${p.userId || "익명"}</span> · 
                <span>🕒 ${p.createdAt || "-"}</span> · 
                <span>👁️ ${p.hit ?? 0}</span>
              </div>
            </div>
          </article>
        `;
      }).join('');

      // ✅ 게시글 개수 문구 표시
      let infoLabel = document.querySelector(".post-count");
      if (infoLabel) infoLabel.remove();

      const sortBar = document.querySelector(".sort-bar");
      const countSpan = document.createElement("span");
      countSpan.className = "post-count";
      countSpan.innerHTML = data.countLabel; // 서버에서 내려온 문구 그대로 표시
      countSpan.style.marginLeft = "16px";
      countSpan.style.fontWeight = "500";
      sortBar.appendChild(countSpan);

      // ✅ 페이지 버튼 상태 갱신
      prevBtn.disabled = (window.currentPage === 1);
      nextBtn.disabled = (window.currentPage === totalPages);
    } catch (err) {
      console.error(err);
      grid.innerHTML = '<div class="error">⚠️ 게시글을 불러오지 못했습니다.</div>';
    }
  };

  prevBtn.addEventListener("click", () => {
    if (window.currentPage > 1) { window.currentPage--; loadPosts(); }
  });
  nextBtn.addEventListener("click", () => {
    if (window.currentPage < totalPages) { window.currentPage++; loadPosts(); }
  });
  sortSelect.addEventListener("change", () => { window.currentPage = 1; loadPosts(); });
  limitSelect.addEventListener("change", () => { window.currentPage = 1; loadPosts(); });

  document.getElementById("writeBtn").addEventListener("click", () => {
    window.location.href = `${contextPath}editor.post`;
  });

  // ✅ 최초 로드
  loadPosts();
})();
</script>

</body>
</html>



