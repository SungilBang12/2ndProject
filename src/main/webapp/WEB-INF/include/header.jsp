<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=6" />
<link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">

<header class="site-header">
  <a href="<c:url value='/'/>" class="home-btn home-btn--top" aria-label="홈"></a>

  <!-- ✅ 검색창 -->
  <div class="site-search-wrap">
    <form class="site-search">
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
  btn.addEventListener('click', e => { e.stopPropagation(); pop.hidden ? open() : close(); });
  document.addEventListener('click', e => { if (!pop.hidden && !pop.contains(e.target) && !btn.contains(e.target)) close(); });
  document.addEventListener('keydown', e => { if (e.key === 'Escape') close(); });
})();

/* ===================== 검색 Ajax ===================== */
(function($){
  $(function(){
    $(document).on('submit', '.site-search', function(e){
      e.preventDefault();
      const q = $.trim($(this).find('[name="q"]').val());
      window.currentQuery = q || "";  // ✅ 검색어를 전역 상태로 저장
      window.currentPage = 1;          // 검색 시 항상 첫 페이지부터
      if (typeof window.loadPosts === "function") {
        window.loadPosts();            // ✅ all.jsp의 함수 호출
      }
    });
  });
})(jQuery);
</script>




