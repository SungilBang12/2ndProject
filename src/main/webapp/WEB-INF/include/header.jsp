<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=5" />
<link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">

<header class="site-header">
  <a href="<c:url value='/'/>" class="home-btn home-btn--top" aria-label="홈"></a>

  <div class="site-search-wrap">
    <form class="site-search" action="<c:url value='/postSearch.async'/>" method="get">
      <label for="q" class="sr-only">검색</label>
      <input id="q" class="search-input" type="search" name="q" placeholder="게시물 검색" />
      <button type="submit" class="search-btn" aria-label="검색"></button>
    </form>
  </div>

  <div class="header-actions">
    <div class="hamburger14" aria-label="사이드바 토글">
      <input type="checkbox" id="hamburger14-input" />
      <label for="hamburger14-input" aria-controls="sidebar" aria-expanded="false">
        <div class="hamburger14-container">
          <span class="circle"></span>
          <span class="line line1"></span>
          <span class="line line2"></span>
          <span class="line line3"></span>
        </div>
      </label>
    </div>

    <button type="button" class="avatar-btn" id="avatar-btn" aria-haspopup="menu"
      aria-expanded="false" aria-controls="profile-popover" title="내 정보">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="#4b5563" aria-hidden="true">
        <path
          d="M12 12c2.761 0 5-2.686 5-6s-2.239-6-5-6-5 2.686-5 6 2.239 6 5 6zm0 2c-4.418 0-8 3.358-8 7.5V24h16v-2.5C20 17.358 16.418 14 12 14z" />
      </svg>
    </button>

    <div class="profile-popover" id="profile-popover" role="menu"
      aria-labelledby="avatar-btn" hidden>
      <div class="profile-card">
        <div class="profile-row">
          <div class="avatar-mini">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="#6b7280" aria-hidden="true">
              <path
                d="M12 12c2.761 0 5-2.686 5-6s-2.239-6-5-6-5 2.686-5 6 2.239 6 5 6zm0 2c-4.418 0-8 3.358-8 7.5V24h16v-2.5C20 17.358 16.418 14 12 14z" />
            </svg>
          </div>
          <div class="meta">
            <strong class="name">
              <c:out value="${sessionScope.userName != null ? sessionScope.userName : 'Guest'}" />
            </strong>
            <div class="sub">
              <c:out value="${sessionScope.userEmail != null ? sessionScope.userEmail : ''}" />
            </div>
          </div>
        </div>
        <div class="divider"></div>
        <a href="<c:url value='/account.jsp'/>" class="menu-item">내 정보</a>
        <a href="<c:url value='/settings.jsp'/>" class="menu-item">설정</a>
        <form action="<c:url value='/logout'/>" method="post" style="margin:0;">
          <button type="submit" class="menu-item is-danger">로그아웃</button>
        </form>
      </div>
    </div>
  </div>
</header>

<script>
/* ===================== 프로필 드롭다운 ===================== */
(function(){
  const btn = document.getElementById('avatar-btn');
  const pop = document.getElementById('profile-popover');
  if(!btn || !pop) return;

  const open = () => { pop.hidden = false; btn.setAttribute('aria-expanded','true'); };
  const close = () => { pop.hidden = true; btn.setAttribute('aria-expanded','false'); };

  btn.addEventListener('click', e => {
    e.stopPropagation();
    pop.hidden ? open() : close();
  });

  document.addEventListener('click', e => {
    if (!pop.hidden && !pop.contains(e.target) && !btn.contains(e.target)) close();
  });
  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') close();
  });
})();

/* ===================== 검색 Ajax (안정 버전) ===================== */
(function($){
  $(function(){
    $(document).on('submit', '.site-search', function(e){
      e.preventDefault();
      const q = $.trim($(this).find('[name="q"]').val());
      if (!q) return;

      // ✅ JSP는 EL 파싱 금지, JS만 실행되게 함
      $.getJSON('<c:url value="/postSearch.async"/>' + '?q=' + encodeURIComponent(q), function(data){
        const grid = $('#boardGrid');
        if (!data.posts || data.posts.length === 0) {
          grid.html('<div class="error">검색 결과가 없습니다.</div>');
          return;
        }

        grid.html(data.posts.map(p => `
          <article class="post-card" data-id="\${p.postId}">
            <div class="post-head">
              <button class="monogram-btn \${p.postType ? p.postType.toLowerCase() : ''}">
                \${p.postType ? p.postType.charAt(0).toUpperCase() : "?"}
              </button>
              <div class="post-title">
                <a href="post-detail.post?postId=\${p.postId}&categoryId=\${p.categoryId}&postTypeId=\${p.postTypeId}">
                  \${p.title || "제목 없음"}
                </a>
              </div>
            </div>
            <div class="meta">
              <span>\${p.category || "카테고리 없음"}</span> · 
              <span>\${p.userId || "익명"}</span> · 
              <span>🕒 \${p.createdAt || "-"}</span> · 
              <span>👁️ \${p.hit ?? 0}</span>
            </div>
          </article>
        `).join(''));
      }).fail(() => {
        $('#boardGrid').html('<div class="error">검색 중 오류가 발생했습니다.</div>');
      });
    });
  });
})(jQuery);
</script>



