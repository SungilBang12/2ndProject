<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- jQuery (필요 시 한 번만 로드) -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<!-- 전역 CSS/파비콘 (프로젝트 경로에 맞게) -->
<link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=6" />
<link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">
<link rel="stylesheet" href="<c:url value='/css/header.css'/>?v=1" />
<header class="site-header">
  <!-- 좌측: 홈 -->
  <a href="<c:url value='/index.jsp'/>" class="home-btn home-btn--top" aria-label="홈으로 이동"></a>

  <!-- 중앙: 검색 -->
  <div class="site-search-wrap">
    <form class="site-search" id="global-search-form">
      <label for="q" class="sr-only">게시물 검색</label>
      <input 
        id="q"
        class="search-input" 
        type="search" 
        name="q" 
        placeholder="노을 맛집을 검색해보세요..." 
        autocomplete="off"
      />
      <button type="submit" class="search-btn" aria-label="검색하기"></button>
    </form>
  </div>

  <!-- 우측: 프로필 (우측 끝 정렬 보장) -->
  <div class="header-right">
    <jsp:include page="/WEB-INF/include/header-profile-dropdown.jsp"></jsp:include>
  </div>
</header>

<script>
/* ===================== 검색 Ajax ===================== */
(function($){
  $(function(){
    // 검색 폼 제출
    $(document).on('submit', '#global-search-form', function(e){
      e.preventDefault();
      const $form = $(this);
      const q = $.trim($form.find('[name="q"]').val());

      // 검색 상태 전역 값 (프로젝트의 목록 로더가 참조)
      window.currentQuery = q || "";
      window.currentPage = 1;

      // 로딩 표시
      $form.addClass('is-searching');

      // 전역 목록 로더가 있으면 호출
      if (typeof window.loadPosts === "function") {
        Promise.resolve(window.loadPosts())
          .finally(function(){ $form.removeClass('is-searching'); });
      } else {
        // 없으면 로딩만 종료
        $form.removeClass('is-searching');
      }
    });

    // 검색창 포커스 시 전체 선택
    $(document).on('focus', '.search-input', function(){
      // setTimeout으로 포커스 직후 select가 취소되는 이슈 방지
      const input = this;
      setTimeout(function(){ input.select(); }, 0);
    });

    // ESC 키로 검색창 초기화
    $(document).on('keydown', '.search-input', function(e){
      if (e.key === 'Escape') {
        $(this).val('').blur();
        window.currentQuery = "";
        window.currentPage = 1;
        if (typeof window.loadPosts === "function") {
          window.loadPosts();
        }
      }
    });
  });
})(jQuery);
</script>
