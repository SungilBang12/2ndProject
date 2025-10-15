<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="<c:url value='/css/style.css'/>" />
<link rel="stylesheet" href="<c:url value='/css/header.css'/>" />
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
		<jsp:include page="/WEB-INF/include/header-profile-dropdown.jsp"></jsp:include>
		
	</div>
</header>

<script>

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
