<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>노을 맛집 - 전체글 게시판</title>

  <!-- ✅ CSS 분리 -->
  <link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=6">
  <link rel="stylesheet" href="<c:url value='/css/post-list.css'/>?v=1">
  <link rel="icon" href="<c:url value='/images/favicon.ico'/>?v=1">
</head>

<body>
  <!-- ✅ header & nav include -->
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

  <jsp:include page="/WEB-INF/include/footer.jsp" />

  <!-- ✅ JS -->
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

    let currentPage = 1;
    let totalPages = 1;

    async function loadPosts() {
      const sort = sortSelect.value;
      const limit = limitSelect.value;

      grid.innerHTML = '<div class="loading">로딩 중...</div>';

      try {
        const res = await fetch(`${contextPath}postList.async?sort=${sort}&limit=${limit}&page=${currentPage}`);
        const data = await res.json();
        console.log("📦 불러온 데이터:", data);

        totalPages = data.totalPages;
        currentPage = data.currentPage;

        curPageEl.textContent = currentPage;
        totalPagesEl.textContent = totalPages;

        grid.innerHTML = data.posts.map(p => `
          <article class="post-card" data-id="${p.postId}">
            <div class="post-head">
              <button class="monogram-btn" type="button">${p.title ? p.title.charAt(0) : "?"}</button>
              <div class="post-title">${p.title || "제목 없음"}</div>
            </div>
            <div class="post-body">
              <div class="post-content">${p.content || "내용 없음"}</div>
              <div class="meta">${p.userId || "익명"} · 🕒 ${p.createdAt || "-"} · 👁️ ${p.hit ?? 0} views</div>
            </div>
          </article>
        `).join('');

        document.querySelectorAll(".post-card").forEach(card => {
          card.addEventListener("click", () => {
            const content = card.querySelector(".post-content");
            content.style.display = (content.style.display === "none" || !content.style.display)
              ? "block" : "none";
          });
        });

        prevBtn.disabled = (currentPage === 1);
        nextBtn.disabled = (currentPage === totalPages);

      } catch (err) {
        console.error(err);
        grid.innerHTML = '<div class="error">⚠️ 게시글을 불러오지 못했습니다.</div>';
      }
    }

    prevBtn.addEventListener("click", () => {
      if (currentPage > 1) { currentPage--; loadPosts(); }
    });

    nextBtn.addEventListener("click", () => {
      if (currentPage < totalPages) { currentPage++; loadPosts(); }
    });

    sortSelect.addEventListener("change", () => { currentPage = 1; loadPosts(); });
    limitSelect.addEventListener("change", () => { currentPage = 1; loadPosts(); });

    loadPosts();
  })(); 
 </script>
</body>
</html>
