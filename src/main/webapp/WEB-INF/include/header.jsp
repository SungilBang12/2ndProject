<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- jQuery (필요 시 한 번만 로드) -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<!-- 전역 CSS/파비콘 (프로젝트 경로에 맞게) -->
<link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=6" />
<link rel="icon" href="${pageContext.request.contextPath}/images/favicon.ico?v=1">

<style>

  /* ====== 헤더 Sunset 테마 (Grid 레이아웃) ====== */
  .site-header {
    background: linear-gradient(135deg, #1a1614 0%, #0f0d0c 100%);
    border-bottom: 1px solid rgba(255, 139, 122, 0.15);
    box-shadow: 0 2px 16px rgba(0, 0, 0, 0.3);
    padding: 12px 16px;
    display: grid;
    grid-template-columns: auto 1fr auto;  /* 좌(홈) | 중앙(검색) | 우(프로필) */
    align-items: center;
    column-gap: 16px;
    position: sticky;
    top: 0;
    z-index: 100;
    backdrop-filter: blur(8px);
  }

  /* ====== 좌측: 홈 버튼 ====== */
  .home-btn--top {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 44px;
    height: 44px;
    border-radius: 12px;
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
  }
  .home-btn--top::before { content: "🌅"; font-size: 24px; position: relative; z-index: 2; }
  .home-btn--top::after {
    content: "";
    position: absolute; inset: 0;
    background: linear-gradient(135deg, rgba(255,255,255,0.2) 0%, transparent 100%);
    opacity: 0; transition: opacity 0.3s ease;
  }
  .home-btn--top:hover {
    transform: translateY(-2px) scale(1.05);
    box-shadow: 0 6px 20px rgba(255,107,107,0.5);
  }
  .home-btn--top:hover::after { opacity: 1; }

  /* ====== 중앙: 검색바 ====== */
  .site-search-wrap {
    justify-self: center;               /* 중앙 고정 */
    width: min(680px, 100%);            /* 고정폭 + 반응형 */
  }
  .site-search {
    position: relative;
    display: flex;
    align-items: center;
    background: rgba(42, 31, 26, 0.6);
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 12px;
    overflow: hidden;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }
  .site-search:focus-within {
    background: rgba(42,31,26,0.8);
    border-color: rgba(255,139,122,0.4);
    box-shadow: 0 0 0 3px rgba(255,139,122,0.1);
  }
  .search-input {
    flex: 1;
    background: transparent; border: none;
    padding: 12px 16px;
    color: #e5e5e5; font-size: 15px; font-weight: 400;
    outline: none; font-family: 'Noto Sans KR', -apple-system, sans-serif;
  }
  .search-input::placeholder { color: rgba(229,229,229,0.5); }
  .search-btn {
    width: 44px; height: 44px;
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    border: none; border-radius: 8px; margin: 4px; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative; overflow: hidden;
  }
  .search-btn::before { content: "🔍"; font-size: 18px; position: relative; z-index: 2; }
  .search-btn::after {
    content: ""; position: absolute; inset: 0;
    background: linear-gradient(135deg, rgba(255,255,255,0.2) 0%, transparent 100%);
    opacity: 0; transition: opacity 0.3s ease;
  }
  .search-btn:hover { transform: scale(1.05); box-shadow: 0 4px 12px rgba(255,107,107,0.4); }
  .search-btn:hover::after { opacity: 1; }
  .search-btn:active { transform: scale(0.95); }

  /* ====== 우측: 프로필 ====== */
  .header-right {
    justify-self: end;                  /* 오른쪽 끝 고정 */
    display: flex; align-items: center; gap: 8px;
    min-width: 44px;                    /* 레이아웃 점프 방지 */
  }

  /* ====== 접근성 ====== */
  .sr-only {
    position: absolute; width:1px; height:1px; padding:0; margin:-1px;
    overflow:hidden; clip:rect(0,0,0,0); white-space:nowrap; border:0;
  }

  /* ====== 검색 로딩 ====== */
  @keyframes searchPulse { 0%,100%{opacity:1;} 50%{opacity:0.5;} }
  .site-search.is-searching .search-btn { animation: searchPulse 1.5s ease-in-out infinite; }

  /* ====== 반응형 ====== */
  @media (max-width: 768px) {
    .site-header { padding: 10px 12px; column-gap: 10px; }
    .home-btn--top { width: 40px; height: 40px; }
    .home-btn--top::before { font-size: 20px; }
    .site-search-wrap { width: 100%; }
    .search-input { padding: 10px 12px; font-size: 14px; }
    .search-btn { width: 40px; height: 40px; }
    .search-btn::before { font-size: 16px; }
  }
</style>

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
