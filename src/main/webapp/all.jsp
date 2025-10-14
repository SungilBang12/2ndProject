<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>노을 맛집 - 전체글 게시판</title>

<!-- ✅ JSP 표현식으로 contextPath 직접 삽입 -->
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=6">
<link rel="icon" href="<%= request.getContextPath() %>/images/favicon.ico?v=1">

<style>
/* 🎨 네가 작성한 스타일 그대로 유지 (생략하지 않음) */
.slot-board {
  --primary:#6750a4; --surface:#fef7ff; --card-bg:#fdfbff;
  --border:rgba(0,0,0,.12); --gap:12px;
  --sunset-1:#EEAF61; --sunset-2:#FB9062; --sunset-3:#EE5D6C; --sunset-4:#CE4993; --sunset-5:#6A0D83;
  background:linear-gradient(to bottom,#fff5ef,#fdf4fa);
  font-family:"Noto Sans KR",sans-serif; padding:var(--gap);
}
.slot-board .board-main { width:100%; display:grid; grid-template-rows:auto 60px; gap:var(--gap); }
.slot-board .board-grid { display:grid; grid-template-columns:1fr; grid-auto-rows:max-content; gap:var(--gap); width:100%; }
.slot-board .post-card { background:var(--card-bg); border:1px solid var(--border); border-radius:12px; padding:16px; display:flex; flex-direction:column; justify-content:center; transition:transform .12s, box-shadow .15s; }
.slot-board .post-card:hover { transform:translateY(-2px); box-shadow:0 6px 12px rgba(0,0,0,.06); }
.slot-board .post-head { display:flex; align-items:center; gap:10px; }
.slot-board .post-title { flex:1; font-weight:800; font-size:15px; color:#1a1523; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.slot-board .post-body { margin-top:6px; }
.slot-board .post-content { font-size:13px; line-height:1.6; color:#4b4b4b; opacity:.95; background:#fff; border-radius:8px; padding:8px 10px; display:none; } /* 기본 숨김 */
.slot-board .meta { font-size:12px; color:#999; margin-top:6px; text-align:right; }
.bottom-bar { background:linear-gradient(to right,#fff7f7,#fff2f0,#fff7f7); border:1px solid rgba(0,0,0,.08); border-radius:12px; display:flex; align-items:center; justify-content:space-between; padding:0 20px; font-weight:600; color:#1d1b20; box-shadow:0 2px 6px rgba(255,165,130,.2); }
.page-controls{ display:flex; align-items:center; gap:8px; }
.page-btn{ border-radius:12px; padding:8px 16px; font-weight:600; cursor:pointer; transition:all .25s; position:relative; overflow:hidden; }
.page-btn[disabled]{ opacity:.45; cursor:not-allowed; filter:grayscale(.2); }
.page-btn.sunset-linefill{ border:2px solid rgba(0,0,0,.15); color:#2b2530; background:transparent; }
.page-btn.sunset-linefill>span{ position:relative; z-index:1; }
.page-btn.sunset-ghost{ border:2px solid transparent; background:linear-gradient(#0000,#0000),linear-gradient(135deg,var(--sunset-1),var(--sunset-3),var(--sunset-5)); background-origin:border-box; background-clip:padding-box,border-box; color:transparent; -webkit-background-clip:text; -webkit-text-fill-color:transparent; box-shadow:0 2px 4px rgba(206,73,147,.25); }
.page-btn.sunset-ghost:hover{ transform:translateY(-1px); box-shadow:0 4px 8px rgba(206,73,147,.35); }
.monogram-btn{ --size:40px; width:var(--size); height:var(--size); border-radius:50%; position:relative; border:0; background:transparent; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; font-weight:800; font-size:14px; color:#5b3a5e; box-shadow:inset 0 0 0 999px #f9f0ff; }
.monogram-btn::before{ content:""; position:absolute; inset:-2px; border-radius:inherit; opacity:.9; background:conic-gradient(from 0deg,var(--sunset-1),var(--sunset-2),var(--sunset-3),var(--sunset-4),var(--sunset-5),var(--sunset-1)); -webkit-mask:radial-gradient(farthest-side,#0000 calc(100% - 3px),#000 calc(100% - 2px)) content-box,linear-gradient(#000,#000); -webkit-mask-composite:xor; mask-composite:exclude; animation: monoring-rotate 3.2s linear infinite; animation-play-state:paused; }
.monogram-btn:hover::before{ animation-play-state:running; }
@keyframes monoring-rotate{ to{ transform:rotate(360deg); } }
</style>
</head>

<body>
<jsp:include page="/WEB-INF/include/header.jsp" />
<main class="main grid-14x5">
  <div class="slot-nav">
    <jsp:include page="/WEB-INF/include/nav.jsp">
      <jsp:param name="openAcc" value="acc-all"/>
    </jsp:include>
  </div>

  <div id="board" class="slot-board">
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
  const contextPath = "<%= request.getContextPath() %>";
  const grid = document.getElementById("boardGrid");

  async function loadPosts() {
    grid.innerHTML = '<div class="loading">로딩 중...</div>';

    try {
      const res = await fetch(`${contextPath}/postList.async`);
      const data = await res.json();
      console.log("📦 불러온 데이터:", data);

      if (!Array.isArray(data)) throw new Error("데이터 형식 오류");

      // 제목만 우선 렌더링
      grid.innerHTML = data.map(p => `
        <article class="post-card" data-id="${p.postId}">
          <div class="post-head">
            <button class="monogram-btn" type="button">${p.title ? p.title.charAt(0) : "?"}</button>
            <div class="post-title">${p.title || "제목 없음"}</div>
          </div>
          <div class="post-body">
            <div class="post-content">${p.content || "내용 없음"}</div>
            <div class="meta">✍ ${p.userId || "익명"} · 🕒 ${p.createdAt || "-"}</div>
          </div>
        </article>
      `).join('');

      // 클릭 시 내용 펼침
      document.querySelectorAll(".post-card").forEach(card => {
        card.addEventListener("click", () => {
          const content = card.querySelector(".post-content");
          content.style.display = (content.style.display === "none" || !content.style.display)
            ? "block" : "none";
        });
      });

    } catch (err) {
      console.error(err);
      grid.innerHTML = '<div class="error">⚠️ 게시글을 불러오지 못했습니다.</div>';
    }
  }

  loadPosts();
})();
</script>
</body>
</html>
