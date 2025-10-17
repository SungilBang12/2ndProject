<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- ===== Prebuild URLs (가독성 & 안전한 href 렌더링) ===== -->
<c:url var="allUrl" value="/all.jsp"/>

<c:url var="sunsetUrl" value="/sunset.jsp"/>

<c:url var="sunsetList2" value="/post-list-view.post">
  <c:param name="listId" value="2"/>
  <c:param name="openAcc" value="acc-sunset"/>
</c:url>
<c:url var="sunsetList3" value="/post-list-view.post">
  <c:param name="listId" value="3"/>
  <c:param name="openAcc" value="acc-sunset"/>
</c:url>

<c:url var="equipList4" value="/post-list-view.post">
  <c:param name="listId" value="4"/>
  <c:param name="openAcc" value="acc-equipment"/>
</c:url>
<c:url var="equipList5" value="/post-list-view.post">
  <c:param name="listId" value="5"/>
  <c:param name="openAcc" value="acc-equipment"/>
</c:url>
<c:url var="equipList6" value="/post-list-view.post">
  <c:param name="listId" value="6"/>
  <c:param name="openAcc" value="acc-equipment"/>
</c:url>

<c:url var="meetList7" value="/post-list-view.post">
  <c:param name="listId" value="7"/>
  <c:param name="openAcc" value="acc-meeting"/>
</c:url>
<c:url var="meetList8" value="/post-list-view.post">
  <c:param name="listId" value="8"/>
  <c:param name="openAcc" value="acc-meeting"/>
</c:url>

<!-- Sunset 테마 사이드바 스타일 -->
<style>
  /* ====== 사이드바 Sunset 테마 ====== */
  .sidebar {
    position: fixed;
    left: 0;
    top: 0;
    bottom: 0;
    width: 280px;
    background: linear-gradient(180deg, #1a1614 0%, #0f0d0c 100%);
    border-right: 1px solid rgba(255, 139, 122, 0.15);
    box-shadow: 4px 0 24px rgba(0, 0, 0, 0.3);
    overflow-y: auto;
    overflow-x: hidden;
    z-index: 200;
    padding: 24px 0;
    transform: translateX(-100%);
    transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  }

  /* 사이드바 열림 상태 */
  body:has(#hamburger14-input:checked) .sidebar,
  body.sidebar-open .sidebar {
    transform: translateX(0);
  }

  /* 오버레이 */
  .overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.7);
    backdrop-filter: blur(4px);
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.3s ease;
    z-index: 190;
  }

  body:has(#hamburger14-input:checked) .overlay,
  body.sidebar-open .overlay {
    opacity: 1;
    pointer-events: auto;
  }

  /* 스크롤바 스타일링 */
  .sidebar::-webkit-scrollbar { width: 6px; }
  .sidebar::-webkit-scrollbar-track { background: rgba(26, 22, 20, 0.5); }
  .sidebar::-webkit-scrollbar-thumb {
    background: rgba(255, 139, 122, 0.3);
    border-radius: 3px;
  }
  .sidebar::-webkit-scrollbar-thumb:hover { background: rgba(255, 139, 122, 0.5); }

  /* ====== 메뉴 섹션 ====== */
  .menu { margin-bottom: 8px; padding: 0 16px; }

  /* ====== 아코디언 ====== */
  .accordion {
    border-radius: 12px;
    overflow: hidden;
    background: #fafafa00;
    transition: all 0.3s ease;
  }
  .accordion:hover { background: rgba(42, 31, 26, 0.5); }
  .accordion.open {
    background: #fafafa00;
    box-shadow: 0 0 0 1px rgba(255, 139, 122, 0.2);
  }

  /* ====== 아코디언 버튼 ====== */
  .accordion > button {
    width: 100%;
    background: transparent;
    border: none;
    padding: 14px 16px;
    text-align: left;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-family: 'Noto Sans KR', -apple-system, sans-serif;
    font-size: 15px;
    font-weight: 600;
    color: #e5e5e5;
    transition: all 0.3s ease;
    position: relative;
  }
  .accordion > button:hover { color: #FF8B7A; }
  .accordion > button a {
    color: inherit; text-decoration: none; flex: 1; display: flex; align-items: center; gap: 8px;
  }

  /* All 메뉴 특별 스타일 */
  #acc-all-btn a::before { content: "📋"; font-size: 18px; }

  /* Sunset / Equipment / Meeting 버튼 아이콘 */
  #acc-sunset-btn::before, #acc-equipment-btn::before, #acc-meeting-btn::before {
    margin-right: 8px; font-size: 18px;
  }
  #acc-sunset-btn::before { content: "🌅"; }
  #acc-equipment-btn::before { content: "📷"; }
  #acc-meeting-btn::before { content: "👥"; }

  /* 캐럿 아이콘 */
  .caret { font-size: 12px; transition: transform 0.3s ease; color: #FF8B7A; }
  .accordion.open > button .caret { transform: rotate(180deg); }

  /* ====== 패널 (하위 메뉴) ====== */
  .panel {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    background: linear-gradient(180deg, rgba(42,31,26,0.6) 0%, rgba(26,22,20,0.6) 100%);
    margin: 8px 12px;
    border-radius: 8px;
    border: 1px solid rgba(255, 139, 122, 0.15);
    box-shadow: inset 0 2px 8px rgba(0,0,0,0.2);
  }
  .accordion.open .panel { max-height: 500px; }

  .panel a {
    display: flex; align-items: center; gap: 12px;
    padding: 12px 16px; margin: 4px 8px; border-radius: 6px;
    color: #ffffff; text-decoration: none; font-size: 14px; font-weight: 500;
    transition: all 0.3s ease; position: relative; background: transparent;
    /* 배지 공간 확보 (겹침 방지) */
    padding-right: 20px;
  }

  /* 왼쪽 아이콘 점 */
  .panel a::before {
    content: "●";
    color: #FF8B7A; font-size: 10px; flex-shrink: 0;
    text-shadow: 0 0 8px rgba(255, 139, 122, 0.6);
  }

  /* 호버 상태 */
  .panel a:hover {
    color: #fff;
    background: linear-gradient(90deg, rgba(255,107,107,0.25) 0%, rgba(255,139,122,0.15) 100%);
    transform: translateX(4px);
    box-shadow: 0 2px 8px rgba(255,107,107,0.3), inset 0 0 20px rgba(255,139,122,0.1);
  }
  .panel a:hover::before {
    color: #fff; transform: scale(1.3);
    text-shadow: 0 0 12px rgba(255, 255, 255, 0.8);
  }

  /* 활성 링크 */
  .panel a.active {
    color: #fff; font-weight: 600;
    background: linear-gradient(90deg, rgba(255,107,107,0.35) 0%, rgba(255,139,122,0.25) 100%);
    box-shadow: 0 2px 12px rgba(255,107,107,0.4), inset 0 1px 0 rgba(255,255,255,0.1);
  }
  .panel a.active::before {
    content: "◆"; color: #fff; transform: scale(1.2);
    text-shadow: 0 0 8px rgba(255,139,122,1), 0 0 16px rgba(255,255,255,0.6);
  }

  /* ====== listId 배지: nav 기본색(#1a1614) + 남색 믹스 ====== */
  .panel a[data-list-id] {
    /* 배지가 텍스트 끝에 붙어도 줄바꿈 방지 */
    white-space: nowrap;
  }
  .panel a[data-list-id]::after {
    content: attr(data-list-id);
    display: inline-flex; align-items: center; justify-content: center;
    height: 22px; min-width: 22px; padding: 0 8px; margin-left: auto;
    border-radius: 9999px; font-size: 12px; font-weight: 700; line-height: 1; letter-spacing: .2px;
    background: linear-gradient(135deg, #16202e 0%, #1a2433 100%); /* 남보라-네이비 톤 */
    color: #e6f0ff;
    border: 1px solid rgba(255,255,255,0.08);
    box-shadow: inset 0 1px 0 rgba(255,255,255,0.05), 0 2px 8px rgba(0,0,0,0.25);
    /* 배지가 우측에 떠서 아이콘과 절대 겹치지 않음 */
    position: relative;
  }
  .panel a:hover[data-list-id]::after {
    filter: brightness(1.05);
    box-shadow: inset 0 1px 0 rgba(255,255,255,0.08), 0 3px 10px rgba(0,0,0,0.3);
  }
  .panel a.active[data-list-id]::after {
    filter: brightness(1.1);
    box-shadow: inset 0 1px 0 rgba(255,255,255,0.12), 0 4px 12px rgba(0,0,0,0.35);
  }

  /* ====== 사이드바 푸터 ====== */
  .sidebar-footer {
    margin-top: auto;
    padding: 24px 16px 16px;
    border-top: 1px solid rgba(255, 139, 122, 0.1);
  }

  /* ====== 반응형 ====== */
  @media (min-width: 1024px) {
    .sidebar { transform: translateX(0); position: static; width: 100%; border-right: none; box-shadow: none; }
    .overlay { display: none; }
  }
  @media (max-width: 768px) {
    .sidebar { width: 260px; }
    .menu { padding: 0 12px; }
    .accordion > button { padding: 12px 14px; font-size: 14px; }
    .panel a { padding: 10px 14px; font-size: 13px; padding-right: 18px; }
  }

  /* ====== 포커스 스타일 (접근성) ====== */
  .accordion > button:focus-visible,
  .panel a:focus-visible {
    outline: 2px solid #FF8B7A;
    outline-offset: -2px;
  }
</style>

<!-- Sidebar -->
<nav class="sidebar" id="sidebar" aria-label="사이드바 내비게이션">
  <!-- All -->
  <div class="menu">
    <section class="accordion" id="acc-all">
      <button
        id="acc-all-btn"
        type="button"
        aria-controls="acc-all-panel"
        aria-expanded="false"
        onclick="toggleAcc('acc-all','acc-all-btn')">
        <a href="${allUrl}" onclick="event.stopPropagation();">All</a>
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
        <a href="${sunsetUrl}">노을</a>
        <a href="${sunsetList2}" data-list-id="2">맛집 추천</a>
        <a href="${sunsetList3}" data-list-id="3">맛집 후기</a>
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
        <a href="${equipList4}" data-list-id="4">촬영 TIP</a>
        <a href="${equipList5}" data-list-id="5">장비 추천</a>
        <a href="${equipList6}" data-list-id="6">중고 거래</a>
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
        <a href="${meetList7}" data-list-id="7">'해'쳐 모여</a>
        <a href="${meetList8}" data-list-id="8">장소 추천</a>
      </div>
    </section>
  </div>

  <!-- 하단(footer 대체 영역) -->
  <div class="sidebar-footer">
    <jsp:include page="/WEB-INF/include/footer.jsp" />
  </div>
</nav>

<!-- Overlay -->
<div class="overlay" id="overlay" aria-hidden="true"></div>

<script>
/* ===================== 아코디언 토글 ===================== */
window.toggleAcc = function(sectionId, buttonId){
  const section = document.getElementById(sectionId);
  const btn = document.getElementById(buttonId);
  if (!section || !btn) return;
  const nowOpen = section.classList.toggle('open');
  btn.setAttribute('aria-expanded', nowOpen ? 'true' : 'false');
};

/* ===================== 사이드바 제어 ===================== */
const _cb = document.getElementById('hamburger14-input');
const _overlay = document.getElementById('overlay');
const _label = document.querySelector('label[for="hamburger14-input"]');

window.closeSidebar = function(){
  if (_cb) _cb.checked = false;
  document.body.classList.remove('sidebar-open');
  if (_label) _label.setAttribute('aria-expanded', 'false');
};

if (_cb) {
  _cb.addEventListener('change', () => {
    const open = _cb.checked;
    if (_label) _label.setAttribute('aria-expanded', open ? 'true' : 'false');
    document.body.classList.toggle('sidebar-open', open);
  });
}

if (_overlay) {
  _overlay.addEventListener('click', window.closeSidebar);
}

window.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') window.closeSidebar();
});

/* ===================== 초기 아코디언 상태 ===================== */
const _defaultOpen = '${param.openAcc}';
if (_defaultOpen) {
  const section = document.getElementById(_defaultOpen);
  const btn = document.getElementById(_defaultOpen + '-btn');
  if (section) section.classList.add('open');
  if (btn) btn.setAttribute('aria-expanded', 'true');
}

/* ===================== 현재 페이지 활성화 표시 ===================== */
(function markActiveLink(){
  const currentPath = window.location.pathname + window.location.search;
  document.querySelectorAll('.panel a').forEach(link => {
    if (link.getAttribute('href') === currentPath) {
      link.classList.add('active');
      const accordion = link.closest('.accordion');
      if (accordion) {
        accordion.classList.add('open');
        const btn = accordion.querySelector('button');
        if (btn) btn.setAttribute('aria-expanded', 'true');
      }
    }
  });
})();

/* ===================== 사이드바 링크 클릭 시 자동 닫기 (모바일) ===================== */
if (window.innerWidth < 1024) {
  document.querySelectorAll('.sidebar a').forEach(link => {
    link.addEventListener('click', () => {
      setTimeout(window.closeSidebar, 300);
    });
  });
}
</script>
