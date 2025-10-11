<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=5" />
<link rel="icon"
	href="${pageContext.request.contextPath}/images/favicon.ico?v=1">

<header class="site-header">
	<!-- 좌측: 홈 버튼 -->
	<a href="<c:url value='/'/>" class="home-btn home-btn--top"
		aria-label="홈"></a>

	<!-- 중앙: 검색 -->
	<div class="site-search-wrap">
		<!-- ✅ 404 방지: /search.jsp 로 고정 -->
		<form class="site-search" action="<c:url value='/search.jsp'/>"
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
						<strong class="name"><c:out
								value="${sessionScope.userName != null ? sessionScope.userName : 'Guest'}" /></strong>
						<div class="sub">
							<c:out
								value="${sessionScope.userEmail != null ? sessionScope.userEmail : ''}" />
						</div>
					</div>
				</div>

				<div class="divider"></div>

				<a href="<c:url value='/account.jsp'/>" class="menu-item"
					role="menuitem">내 정보</a> <a href="<c:url value='/settings.jsp'/>"
					class="menu-item" role="menuitem">설정</a>
				<form action="<c:url value='/logout'/>" method="post"
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
      $.get('<c:url value="/search.jsp"/>', { q:q }, function(html){
        var $board = $('#board');
        if(!$board.length){ $board = $('.slot-board'); }
        $board.html(html);
      });
    });
  });
})(jQuery);
</script>
