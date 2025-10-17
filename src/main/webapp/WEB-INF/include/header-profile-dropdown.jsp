<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="user" value="${sessionScope.user}" />
<c:set var="isLoggedIn" value="${user != null}" />
<c:set var="userName" value="${user.userName}" />
<c:set var="userId" value="${user.userId}" />
<c:set var="userEmail" value="${user.email}" />
<input type="hidden" id="isLoggedIn" value="${userName}">

<style>
  /* ====== 헤더 액션 영역 ====== */
  .header-actions {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  /* ====== 햄버거 메뉴 Sunset 테마 ====== */
  .hamburger14 {
    position: relative;
    z-index: 300;
  }

  #hamburger14-input {
    display: none;
  }

  .hamburger14-container {
    position: relative;
    width: 40px;
    height: 40px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    border-radius: 10px;
    background: rgba(42, 31, 26, 0.6);
    border: 1px solid rgba(255, 139, 122, 0.2);
    transition: all 0.3s ease;
  }

  .hamburger14-container:hover {
    background: rgba(255, 139, 122, 0.15);
    border-color: rgba(255, 139, 122, 0.4);
    transform: scale(1.05);
  }

  .hamburger14-container .line {
    width: 20px;
    height: 2px;
    background: #FF8B7A;
    border-radius: 2px;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: absolute;
  }

  .hamburger14-container .line1 {
    top: 12px;
  }

  .hamburger14-container .line2 {
    top: 19px;
  }

  .hamburger14-container .line3 {
    top: 26px;
  }

  /* 햄버거 열림 상태 */
  #hamburger14-input:checked + label .line1 {
    transform: rotate(45deg);
    top: 19px;
  }

  #hamburger14-input:checked + label .line2 {
    opacity: 0;
  }

  #hamburger14-input:checked + label .line3 {
    transform: rotate(-45deg);
    top: 19px;
  }

  /* ====== 아바타 버튼 Sunset 테마 ====== */
  .avatar-btn {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    border: 2px solid rgba(255, 139, 122, 0.3);
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    color: white;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
    position: relative;
    overflow: hidden;
  }

  .avatar-btn::before {
    content: '';
    position: absolute;
    inset: 0;
    background: radial-gradient(circle at 30% 30%, rgba(255, 255, 255, 0.3) 0%, transparent 60%);
    opacity: 0;
    transition: opacity 0.3s ease;
  }

  .avatar-btn:hover {
    transform: scale(1.1);
    box-shadow: 0 6px 20px rgba(255, 107, 107, 0.5);
    border-color: rgba(255, 139, 122, 0.5);
  }

  .avatar-btn:hover::before {
    opacity: 1;
  }

  .avatar-btn:active {
    transform: scale(0.95);
  }

  .avatar-btn .user-initial {
    font-size: 18px;
    font-weight: 700;
    font-family: 'Noto Serif KR', serif;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  }

  /* 로그인 전 아바타 */
  .avatar-btn svg {
    filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
  }

  /* ====== 드롭다운 메뉴 Sunset 테마 ====== */
  .profile-popover {
    position: absolute;
    top: calc(100% + 8px);
    right: 0;
    min-width: 280px;
    background: linear-gradient(135deg, 
      rgba(42, 31, 26, 0.98) 0%, 
      rgba(26, 22, 20, 0.98) 100%
    );
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 12px;
    box-shadow: 
      0 12px 40px rgba(0, 0, 0, 0.5),
      0 0 20px rgba(255, 139, 122, 0.1);
    z-index: 1000;
    animation: slideDown 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }

  @keyframes slideDown {
    from {
      opacity: 0;
      transform: translateY(-10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .profile-popover[hidden] {
    display: none;
  }

  /* ====== 프로필 카드 ====== */
  .profile-card {
    padding: 16px;
  }

  .profile-card.is-compact {
    padding: 12px;
  }

  /* ====== 프로필 행 ====== */
  .profile-row {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px;
    background: rgba(255, 139, 122, 0.08);
    border-radius: 10px;
    margin-bottom: 12px;
  }

  .avatar-mini {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
    border: 2px solid rgba(255, 255, 255, 0.2);
  }

  .user-initial-mini {
    color: white;
    font-size: 20px;
    font-weight: 700;
    font-family: 'Noto Serif KR', serif;
  }

  .meta {
    flex: 1;
    min-width: 0;
  }

  .meta .name {
    display: block;
    color: #fff;
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 4px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .meta .sub {
    color: rgba(229, 229, 229, 0.7);
    font-size: 13px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  /* ====== 구분선 ====== */
  .divider {
    height: 1px;
    background: rgba(255, 139, 122, 0.15);
    margin: 8px 0;
  }

  /* ====== 메뉴 아이템 ====== */
  .menu-item {
    display: block;
    width: 100%;
    padding: 12px 16px;
    color: #e5e5e5;
    text-decoration: none;
    background: transparent;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    text-align: left;
    cursor: pointer;
    transition: all 0.3s ease;
    margin: 4px 0;
    position: relative;
  }

  .menu-item::before {
    font-size: 1.1em;
    margin-right: 10px;
  }

  .menu-item:hover {
    background: rgba(255, 139, 122, 0.15);
    color: #FF8B7A;
    transform: translateX(4px);
  }

  /* 내 정보 */
  .menu-item[href*="myInfo"]::before {
    content: "👤";
  }

  /* 내 활동 내역 */
  .menu-item[href*="myActivity"]::before {
    content: "📊";
  }

  /* 로그인 */
  .menu-item.is-primary {
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    color: white;
    font-weight: 600;
    box-shadow: 0 2px 8px rgba(255, 107, 107, 0.3);
  }

  .menu-item.is-primary::before {
    content: "🔓";
  }

  .menu-item.is-primary:hover {
    background: linear-gradient(135deg, #FF8B7A 0%, #FFA07A 100%);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.5);
  }

  /* 회원가입 */
  .menu-item[href*="join"]::before {
    content: "✍️";
  }

  /* 로그아웃 */
  .menu-item.is-danger {
    color: #FC8181;
  }

  .menu-item.is-danger::before {
    content: "🚪";
  }

  .menu-item.is-danger:hover {
    background: rgba(229, 62, 62, 0.15);
    color: #F56565;
  }

  /* ====== 반응형 ====== */
  @media (max-width: 768px) {
    .profile-popover {
      right: -8px;
      min-width: 260px;
    }

    .avatar-btn {
      width: 40px;
      height: 40px;
    }

    .avatar-btn .user-initial {
      font-size: 16px;
    }

    .avatar-mini {
      width: 44px;
      height: 44px;
    }

    .user-initial-mini {
      font-size: 18px;
    }

    .meta .name {
      font-size: 15px;
    }

    .meta .sub {
      font-size: 12px;
    }

    .menu-item {
      padding: 10px 14px;
      font-size: 13px;
    }
  }

  /* ====== 포커스 스타일 (접근성) ====== */
  .avatar-btn:focus-visible {
    outline: 2px solid #FF8B7A;
    outline-offset: 2px;
  }

  .menu-item:focus-visible {
    outline: 2px solid #FF8B7A;
    outline-offset: -2px;
  }

  /* ====== 로딩 상태 (선택사항) ====== */
  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .avatar-btn.is-loading::after {
    content: '';
    position: absolute;
    inset: -2px;
    border: 2px solid transparent;
    border-top-color: white;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }
</style>

<div class="header-actions">
  <!-- 햄버거 -->
  <div class="hamburger14" aria-label="사이드바 토글">
    <input type="checkbox" id="hamburger14-input" />
    <label for="hamburger14-input" aria-controls="sidebar" aria-expanded="false">
      <div class="hamburger14-container">
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
        <svg width="18" height="18" viewBox="0 0 24 24" fill="white" aria-hidden="true">
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
              <input type="hidden" id="userName" value="${user.userName}" />
              <input type="hidden" id="userId" value="${user.userId}" />
              <div class="sub"><c:out value="${userEmail}" /></div>
            </div>
          </div>

          <div class="divider"></div>

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

  const open = () => { 
    pop.hidden = false; 
    btn.setAttribute('aria-expanded','true');
  };
  
  const close = () => { 
    pop.hidden = true; 
    btn.setAttribute('aria-expanded','false'); 
  };

  btn.addEventListener('click', () => { 
    pop.hidden ? open() : close(); 
  });

  document.addEventListener('click', (e) => {
    const isInside = btn.contains(e.target) || pop.contains(e.target);
    if (!isInside && !pop.hidden) close();
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !pop.hidden) close();
  });

  // 메뉴 아이템 포커스 네비게이션
  const menuItems = pop.querySelectorAll('.menu-item');
  menuItems.forEach((item, index) => {
    item.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        const next = menuItems[index + 1];
        if (next) next.focus();
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        const prev = menuItems[index - 1];
        if (prev) prev.focus();
      }
    });
  });
})();
</script>