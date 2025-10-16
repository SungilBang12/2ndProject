<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
        <a href="<c:url value='/all.jsp'/>">All</a>
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
        <a href="<c:url value='/sunset.jsp'/>">노을</a>
        <a href="<c:url value='/post-list-view.post'>
                   <c:param name='listId' value='2'/>
                   <c:param name='openAcc' value='acc-sunset'/>
                 </c:url>">맛집 추천</a>
        <a href="<c:url value='/post-list-view.post'>
                   <c:param name='listId' value='3'/>
                   <c:param name='openAcc' value='acc-sunset'/>
                 </c:url>">맛집 후기</a>
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
        <a href="<c:url value='/post-list-view.post'>
                   <c:param name='listId' value='4'/>
                   <c:param name='openAcc' value='acc-equipment'/>
                 </c:url>">촬영 TIP</a>
        <a href="<c:url value='/post-list-view.post'>
                   <c:param name='listId' value='5'/>
                   <c:param name='openAcc' value='acc-equipment'/>
                 </c:url>">장비 추천</a>
        <a href="<c:url value='/post-list-view.post'>
                   <c:param name='listId' value='6'/>
                   <c:param name='openAcc' value='acc-equipment'/>
                 </c:url>">중고 거래</a>
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
        <a href="<c:url value='/post-list-view.post'>
                   <c:param name='listId' value='7'/>
                   <c:param name='openAcc' value='acc-meeting'/>
                 </c:url>">'해'쳐 모여</a>
        <a href="<c:url value='/post-list-view.post'>
                   <c:param name='listId' value='8'/>
                   <c:param name='openAcc' value='acc-meeting'/>
                 </c:url>">장소 추천</a>
      </div>
    </section>
  </div>

  <!-- 하단(footer 대체 영역) : 기존 footer.jsp 재사용 -->
  <div class="sidebar-footer">
    <jsp:include page="/WEB-INF/include/footer.jsp" />
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

const _defaultOpen = '${param.openAcc}';
if (_defaultOpen) {
  document.getElementById(_defaultOpen)?.classList.add('open');
  document.getElementById(_defaultOpen + '-btn')?.setAttribute('aria-expanded', 'true');
}
</script>