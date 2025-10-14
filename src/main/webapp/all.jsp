<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>노을 맛집 - 전체글 게시판</title>

<!-- ✅ JSP 표현식으로 contextPath 직접 삽입 -->
<link rel="stylesheet" href="/2ndProject/css/style.css?v=6">
<link rel="icon" href="/2ndProject/images/favicon.ico?v=1">

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

/* 🌇 새 노을 헤더 스타일 */
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@700&display=swap');

.board-header {
  width: 100%;
  text-align: center;
  margin: 12px 0 28px;
  padding: 22px 0;
  border-radius: 14px;
  background: linear-gradient(90deg, var(--sunset-1), var(--sunset-3), var(--sunset-5), var(--sunset-4));
  background-size: 300% 300%;
  animation: headerFloat 5s ease-in-out infinite alternate;
  box-shadow: 0 4px 12px rgba(238, 93, 108, 0.2);
  overflow: hidden;
  position: relative;
  transition: transform 0.4s ease, box-shadow 0.4s ease;
}

/* ✨ 타이틀 텍스트 */
.board-title {
  font-family: "Poppins", "Noto Sans KR", sans-serif;
  font-size: 28px;
  font-weight: 800;
  background: linear-gradient(90deg, #ffffff, #ffe9d0, #ffd1d1, #ffffff);
  background-size: 300%;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  animation: textGlow 6s ease-in-out infinite;
  letter-spacing: 0.8px;
  margin: 0;
  position: relative;
}

/* 🌤 헤더 호버 시 */
.board-header:hover {
  animation-play-state: paused; /* hover하면 흐름 잠시 정지 */
  transform: scale(1.02);
  box-shadow: 0 8px 24px rgba(238, 93, 108, 0.35);
}

/* ☀️ 글자에 반짝이는 효과 */
.board-header:hover .board-title {
  animation: shineText 2s linear infinite;
}

/* 🌈 애니메이션 정의 */
@keyframes headerFloat {
  0% { background-position: 0% 50%; transform: translateY(0); }
  50% { background-position: 100% 50%; transform: translateY(-3px); }
  100% { background-position: 0% 50%; transform: translateY(0); }
}

@keyframes textGlow {
  0%, 100% { filter: drop-shadow(0 0 6px rgba(255, 180, 150, 0.5)); }
  50% { filter: drop-shadow(0 0 12px rgba(255, 120, 90, 0.7)); }
}

@keyframes shineText {
  0% { background-position: 0% 50%; }
  100% { background-position: 200% 50%; }
}

/* 🌇 정렬 바 스타일 */
.sort-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  margin-bottom: 12px;
  padding: 8px 16px;
  border-radius: 12px;
  background: linear-gradient(to right, #fff6f1, #fff1f7);
  box-shadow: 0 2px 6px rgba(0,0,0,0.05);
  font-family: "Poppins", "Noto Sans KR", sans-serif;
}

.sort-bar label {
  font-weight: 600;
  color: #4a3b4e;
  margin-right: 10px;
}

.sort-select {
  padding: 6px 12px;
  border-radius: 10px;
  border: 1px solid rgba(0,0,0,0.1);
  background: white;
  font-size: 14px;
  font-weight: 600;
  color: #3e2b4c;
  cursor: pointer;
  transition: all 0.25s ease;
}

.sort-select:hover {
  box-shadow: 0 0 10px rgba(255, 150, 120, 0.3);
  transform: translateY(-2px);
}




</style>
</head>

<body>


<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="/2ndProject/css/style.css?v=5" />
<link rel="icon"
	href="/2ndProject/images/favicon.ico?v=1">

<header class="site-header">
	<!-- 좌측: 홈 버튼 -->
	<a href="/2ndProject/" class="home-btn home-btn--top"
		aria-label="홈"></a>

	<!-- 중앙: 검색 -->
	<div class="site-search-wrap">
		<!-- ✅ 404 방지: /search.jsp 로 고정 -->
		<form class="site-search" action="/2ndProject/search.jsp"
			method="get">
			<label for="q" class="sr-only">검색</label> <input id="q"
				class="search-input" type="search" name="q" placeholder="게시물 검색" />
			<button type="submit" class="search-btn" aria-label="검색"></button>
		</form>
	</div>

	<!-- 우측: 액션들(모바일 햄버거 + 프로필 버튼) -->
	<div class="header-actions">
		<!-- 햄버거(모바일에서만 보임: CSS로 제어) -->
		<div class="hamburger14" aria-label="사이드바 토글">
			<input type="checkbox" id="hamburger14-input" /> <label
				for="hamburger14-input" aria-controls="sidebar"
				aria-expanded="false">
				<div class="hamburger14-container">
					<span class="circle"></span> <span class="line line1"></span> <span
						class="line line2"></span> <span class="line line3"></span>
				</div>
			</label>
		</div>

		<!-- 프로필 드롭다운 트리거 (페이지 이동 X) -->
		<button type="button" class="avatar-btn" id="avatar-btn"
			aria-haspopup="menu" aria-expanded="false"
			aria-controls="profile-popover" title="내 정보">
			<!-- 아이콘 (사람 모양) -->
			<svg width="18" height="18" viewBox="0 0 24 24" fill="#4b5563"
				aria-hidden="true">
        <path
					d="M12 12c2.761 0 5-2.686 5-6s-2.239-6-5-6-5 2.686-5 6 2.239 6 5 6zm0 2c-4.418 0-8 3.358-8 7.5V24h16v-2.5C20 17.358 16.418 14 12 14z" />
      </svg>
		</button>

		<!-- 프로필 드롭다운 -->
		<div class="profile-popover" id="profile-popover" role="menu"
			aria-labelledby="avatar-btn" hidden>
			<div class="profile-card">
				<div class="profile-row">
					<div class="avatar-mini">
						<!-- 이니셜/아이콘 -->
						<svg width="18" height="18" viewBox="0 0 24 24" fill="#6b7280"
							aria-hidden="true">
              <path
								d="M12 12c2.761 0 5-2.686 5-6s-2.239-6-5-6-5 2.686-5 6 2.239 6 5 6zm0 2c-4.418 0-8 3.358-8 7.5V24h16v-2.5C20 17.358 16.418 14 12 14z" />
            </svg>
					</div>
					<div class="meta">
						<strong class="name">Guest</strong>
						<div class="sub">
							
						</div>
					</div>
				</div>

				<div class="divider"></div>

				<a href="/2ndProject/account.jsp" class="menu-item"
					role="menuitem">내 정보</a> <a href="/2ndProject/settings.jsp"
					class="menu-item" role="menuitem">설정</a>
				<form action="/2ndProject/logout" method="post"
					style="margin: 0;">
					<button type="submit" class="menu-item is-danger" role="menuitem">로그아웃</button>
				</form>
			</div>
		</div>
	</div>
</header>

<script>
/* 프로필 드롭다운 토글 & 외부클릭/ESC 닫기 (유지) */
(function(){
  const btn = document.getElementById('avatar-btn');
  const pop = document.getElementById('profile-popover');
  if(!btn || !pop) return;

  const open = () => { pop.hidden = false; btn.setAttribute('aria-expanded','true'); };
  const close = () => { pop.hidden = true; btn.setAttribute('aria-expanded','false'); };

  btn.addEventListener('click', (e) => {
    e.stopPropagation();
    pop.hidden ? open() : close();
  });

  document.addEventListener('click', (e) => {
    if (pop.hidden) return;
    if (pop.contains(e.target) || btn.contains(e.target)) return;
    close();
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') close();
  });
})();

/* jQuery Ajax 검색: #board만 교체 */
(function($){
  $(function(){
    $(document).on('submit', '.site-search', function(e){
      e.preventDefault();
      var $form = $(this);
      var q = $.trim($form.find('[name="q"]').val() || '');

      $.ajax({
        url: $form.attr('action'),   // /search.jsp
        method: 'GET',
        data: { q: q },
        success: function(html){
          var $board = $('#board');
          if(!$board.length){ $board = $('.slot-board'); } // 폴백
          $board.html(html);

          // 주소 갱신 (새로고침해도 동일 상태)
          if (history.pushState) {
            var url = $form.attr('action') + (q ? ('?q=' + encodeURIComponent(q)) : '');
            history.pushState({ q: q }, '', url);
          }
        },
        error: function(){
          $('#board').html('<p>검색 중 오류가 발생했습니다.</p>');
        }
      });
    });

    // 뒤로/앞으로 이동 시 현재 URL의 q를 읽어 재요청 (선택)
    window.addEventListener('popstate', function(){
      var params = new URLSearchParams(location.search);
      var q = params.get('q') || '';
      $.get('/2ndProject/search.jsp', { q:q }, function(html){
        var $board = $('#board');
        if(!$board.length){ $board = $('.slot-board'); }
        $board.html(html);
      });
    });
  });
})(jQuery);
</script>

<main class="main grid-14x5">
  <div class="slot-nav">
    


<!-- Sidebar -->
<nav class="sidebar" id="sidebar" aria-label="사이드바 내비게이션">
  <div class="menu">
    <section class="accordion" id="acc-all">
      <button
        id="acc-all-btn"
        type="button"
        aria-controls="acc-all-panel"
        aria-expanded="false"
        onclick="toggleAcc('acc-all','acc-all-btn')">
        <a href="/2ndProject/all.jsp">All</a>
      </button>
    </section>
  </div> 

  <!-- Sunset -->
  <div class="menu">
    <section class="accordion" id="acc-sunset">
      <button
        id="acc-sunset-btn"
        type="button"
        aria-controls="acc-sunset-panel"
        aria-expanded="false"
        onclick="toggleAcc('acc-sunset','acc-sunset-btn')">
        Sunset <span class="caret">▾</span>
      </button>
      <div id="acc-sunset-panel" class="panel" role="region" aria-label="Sunset 카테고리">
        <a href="/2ndProject/sunset.jsp">노을</a>
        <a href="/2ndProject/sunset-reco.jsp">맛집 추천</a>
        <a href="/2ndProject/sunset-review.jsp">맛집 후기</a>
      </div>
    </section>
  </div>

  <!-- Equipment -->
  <div class="menu">
    <section class="accordion" id="acc-equipment">
      <button
        id="acc-equipment-btn"
        type="button"
        aria-controls="acc-equipment-panel"
        aria-expanded="false"
        onclick="toggleAcc('acc-equipment','acc-equipment-btn')">
        Equipment <span class="caret">▾</span>
      </button>
      <div id="acc-equipment-panel" class="panel" role="region" aria-label="Equipment 카테고리">
        <a href="/2ndProject/equipment-tips.jsp">촬영 TIP</a>
        <a href="/2ndProject/equipment-reco.jsp">장비 추천</a>
        <a href="/2ndProject/equipment-market.jsp">중고 거래</a>
      </div>
    </section>
  </div>

  <!-- Meeting -->
  <div class="menu">
    <section class="accordion" id="acc-meeting">
      <button
        id="acc-meeting-btn"
        type="button"
        aria-controls="acc-meeting-panel"
        aria-expanded="false"
        onclick="toggleAcc('acc-meeting','acc-meeting-btn')">
        Meeting <span class="caret">▾</span>
      </button>
      <div id="acc-meeting-panel" class="panel" role="region" aria-label="Meeting 카테고리">
        <a href="/2ndProject/meeting-gather.jsp">'해'쳐 모여</a>
        <a href="/2ndProject/meeting-reco.jsp">장소 추천</a>
      </div>
    </section>
  </div>
  <!-- 하단(footer 대체 영역) : 기존 footer.jsp 재사용 -->
  <div class="sidebar-footer">
    
<footer class="site-footer">
  <small>© 노을 맛집</small>
</footer>

  </div>
  
</nav>

<!-- Overlay -->
<div class="overlay" id="overlay" aria-hidden="true"></div>

<script>
/* 아코디언 */
window.toggleAcc = function(sectionId, buttonId){
  const section = document.getElementById(sectionId);
  const btn = document.getElementById(buttonId);
  const nowOpen = section.classList.toggle('open');
  if (btn) btn.setAttribute('aria-expanded', nowOpen ? 'true' : 'false');
};

/* 햄버거 체크박스는 헤더에 있음 */
const _cb = document.getElementById('hamburger14-input');
const _overlay = document.getElementById('overlay');
const _label = document.querySelector('label[for="hamburger14-input"]');

window.closeSidebar = function(){
  if (_cb) _cb.checked = false;
  document.body.classList.remove('sidebar-open'); // :has() 미지원 폴백
  if (_label) _label.setAttribute('aria-expanded','false');
};
if (_cb){
  _cb.addEventListener('change', () => {
    const open = _cb.checked;
    if (_label) _label.setAttribute('aria-expanded', open ? 'true' : 'false');
    document.body.classList.toggle('sidebar-open', open); // 폴백
  });
}
if (_overlay){ _overlay.addEventListener('click', window.closeSidebar); }
window.addEventListener('keydown', (e) => { if (e.key === 'Escape') window.closeSidebar(); });

const _defaultOpen = 'acc-all';
if (_defaultOpen) {
  document.getElementById(_defaultOpen)?.classList.add('open');
  document.getElementById(_defaultOpen + '-btn')?.setAttribute('aria-expanded', 'true');
}
</script>

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
	  const contextPath = "/2ndProject";
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
	      const res = await fetch(`${contextPath}/postList.async?sort=${sort}&limit=${limit}&page=${currentPage}`);
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

	      // 클릭 시 내용 펼침
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
	    if (currentPage > 1) {
	      currentPage--;
	      loadPosts();
	    }
	  });

	  nextBtn.addEventListener("click", () => {
	    if (currentPage < totalPages) {
	      currentPage++;
	      loadPosts();
	    }
	  });

	  sortSelect.addEventListener("change", () => { currentPage = 1; loadPosts(); });
	  limitSelect.addEventListener("change", () => { currentPage = 1; loadPosts(); });

	  loadPosts();
	})();
</script>
</body>
</html>