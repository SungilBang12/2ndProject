<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<link rel="stylesheet" href="<c:url value='/css/header-profile-dropdown.css'/>" />
<!-- 세션에서 로그인 상태 확인: User 객체를 UserType으로 캐스팅하여 확인한다고 가정 -->
<c:set var="isLoggedIn" value="${sessionScope.loggedInUser != null}" />
<c:set var="userName" value="${sessionScope.loggedInUser.userName}" />
<c:set var="userEmail" value="${sessionScope.loggedInUser.userEmail}" />

<!-- 프로필 드롭다운 트리거 (페이지 이동 X) -->
<button type="button" class="avatar-btn" id="avatar-btn"
	aria-haspopup="menu" aria-expanded="false"
	aria-controls="profile-popover" title="내 정보">
	<!-- 프로필 이미지가 없다고 가정하고 익명(사람) 아이콘 표시 -->
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
		<!-- 1. 프로필 카드 영역 -->
		<div class="profile-row">
			<div class="avatar-mini">
				<!-- 프로필 이미지가 없으면 익명 아이콘 표시 -->
				<svg width="36" height="36" viewBox="0 0 24 24" fill="#6b7280"
					aria-hidden="true">
              <path
						d="M12 12c2.761 0 5-2.686 5-6s-2.239-6-5-6-5 2.686-5 6 2.239 6 5 6zm0 2c-4.418 0-8 3.358-8 7.5V24h16v-2.5C20 17.358 16.418 14 12 14z" />
            </svg>
			</div>
			<div class="meta">
				<c:choose>
					<c:when test="${isLoggedIn}">
						<!-- 로그인 상태: 사용자 이름과 이메일 표시 -->
						<strong class="name">
							<c:out value="${userName != null ? userName : '사용자'}" />
						</strong>
						<div class="sub">
							<c:out value="${userEmail != null ? userEmail : ''}" />
						</div>
					</c:when>
					<c:otherwise>
						<!-- 비로그인 상태: 로그인 안내 메시지 표시 -->
						<strong class="name name-guest">
							서비스를 제대로 이용하려면
						</strong>
						<div class="sub sub-guest">
							로그인이 필요합니다
						</div>
					</c:otherwise>
				</c:choose>
			</div>
		</div>

		<div class="divider"></div>

		<!-- 2. 메뉴 항목 영역 (로그인 상태에 따라 달라짐) -->
		<c:choose>
			<c:when test="${isLoggedIn}">
				<!-- 로그인 상태 메뉴 -->
				<a href="<c:url value='/users/myInfo'/>" class="menu-item"
					role="menuitem">내 정보 수정</a> 
				<a href="<c:url value='/users/myPosts'/>" class="menu-item"
					role="menuitem">내가 단 게시글</a> 
				<a href="<c:url value='/users/myComments'/>" class="menu-item"
					role="menuitem">내가 단 댓글 보기</a>

				<div class="divider"></div>
				
				<!-- 로그아웃 버튼 (빨간색) -->
				<form action="<c:url value='/users/logout'/>" method="post"
					style="margin: 0;">
					<button type="submit" class="menu-item is-danger" role="menuitem">로그아웃</button>
				</form>
			</c:when>
			<c:otherwise>
				<!-- 비로그인 상태 메뉴 -->
				<a href="<c:url value='/users/login'/>" class="menu-item is-primary"
					role="menuitem">로그인</a>
			</c:otherwise>
		</c:choose>
	</div>
</div>
<script>
/* 프로필 드롭다운 토글 & 외부클릭/ESC 닫기 */
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
    // 드롭다운 내부나 버튼 클릭이면 닫지 않음
    if (pop.contains(e.target) || btn.contains(e.target)) return;
    close();
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') close();
  });
})();
</script>
