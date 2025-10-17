<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=6" />
<link rel="icon"
	href="${pageContext.request.contextPath}/images/favicon.ico?v=1">

<header class="site-header">
	<a href="<c:url value='/index.jsp'/>" class="home-btn home-btn--top"
		aria-label="홈"></a>

	<!-- ✅ 검색창 -->
	<div class="site-search-wrap">
		<form class="site-search">
			<label for="q" class="sr-only">검색</label> <input id="q"
				class="search-input" type="search" name="q" placeholder="게시물 검색" />
			<button type="submit" class="search-btn" aria-label="검색"></button>
		</form>
	</div>	
	<jsp:include page="/WEB-INF/include/header-profile-dropdown.jsp"></jsp:include>
</header>

<script>
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




