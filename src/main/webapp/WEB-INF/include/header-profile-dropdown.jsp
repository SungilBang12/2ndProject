<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>


<%-- 
    🚨 Controller에서 session.setAttribute("user", user); 로 저장했으므로,
    세션 변수 이름을 "user"로 변경하여 접근합니다.
--%>
<c:set var="user" value="${sessionScope.user}" />
<c:set var="isLoggedIn" value="${user != null}" />
<c:set var="userName" value="${user.userName}" />
<c:set var="userId" value="${user.userId}" />
<c:set var="userEmail" value="${user.email}" />
<input type="hidden" id="isLoggedIn" value="${userName}">

<link rel="stylesheet" href="<c:url value='/css/header-profile-dropdown.css'/>" />

<div class="header-actions">
  <!-- 햄버거 -->
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

  <!-- 프로필 버튼 -->
  <button type="button" class="avatar-btn" id="avatar-btn"
          aria-haspopup="menu" aria-expanded="false"
          aria-controls="profile-popover" title="내 정보">
    <c:choose>
      <c:when test="${isLoggedIn}">
        <span class="user-initial">${fn:substring(userName, 0, 1)}</span>
      </c:when>
      <c:otherwise>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="#4b5563" aria-hidden="true">
          <path d="M12 12c2.761 0 5-2.686 5-6s-2.239-6-5-6-5 2.686-5 6 2.239 6 5 6zm0 2c-4.418 0-8 3.358-8 7.5V24h16v-2.5C20 17.358 16.418 14 12 14z"/>
        </svg>
      </c:otherwise>
    </c:choose>
  </button>

  <!-- 드롭다운 -->
   <div class="profile-popover" id="profile-popover" role="menu"
       aria-labelledby="avatar-btn" hidden>
    <c:choose>
      <c:when test="${isLoggedIn}">
        <div class="profile-card">
          <div class="profile-row">
            <div class="avatar-mini">
              <span class="user-initial-mini">${fn:substring(userName, 0, 1)}</span>
            </div>
            <div class="meta">
              <strong class="name"><c:out value="${userName}" /></strong>
              <!-- ⬇️ 중복 id 정리 -->
              <input type="hidden" id="userName" value="${user.userName}" />
              <input type="hidden" id="userId" value="${user.userId}" />
              <div class="sub"><c:out value="${userEmail}" /></div>
            </div>
          </div>

          <div class="divider"></div>

          <!-- ✅ 컨트롤러 라우팅에 맞춘 경로 -->
          <a href="<c:url value='/users/myInfo'/>" class="menu-item" role="menuitem">내 정보</a>
          <a href="<c:url value='/users/myActivity'/>" class="menu-item" role="menuitem">내 활동 내역</a>

          <div class="divider"></div>

          <form action="<c:url value='/users/logout'/>" method="get" style="margin:0;">
            <button type="submit" class="menu-item is-danger" role="menuitem">로그아웃</button>
          </form>
        </div>
      </c:when>
      <c:otherwise>
        <div class="profile-card is-compact">
          <a href="<c:url value='/users/login'/>" class="menu-item is-primary" role="menuitem">로그인</a>
          <a href="<c:url value='/users/join'/>" class="menu-item" role="menuitem">회원가입</a>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<script>
(function(){
  const btn = document.getElementById('avatar-btn');
  const pop = document.getElementById('profile-popover');
  if(!btn || !pop) return;

  const open = () => { pop.hidden = false; btn.setAttribute('aria-expanded','true'); };
  const close = () => { pop.hidden = true; btn.setAttribute('aria-expanded','false'); };

  btn.addEventListener('click', () => { pop.hidden ? open() : close(); });

  document.addEventListener('click', (e) => {
    const isInside = btn.contains(e.target) || pop.contains(e.target);
    if (!isInside && !pop.hidden) close();
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !pop.hidden) close();
  });
})();
</script>
