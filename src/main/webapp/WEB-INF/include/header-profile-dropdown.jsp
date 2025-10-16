<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%-- 
    🚨 Controller에서 session.setAttribute("loggedInUser", user); 로 저장했으므로,
    세션 변수 이름을 "loggedInUser"로 변경하여 접근합니다.
--%>
<c:set var="user" value="${sessionScope.user}" />
<c:set var="isLoggedIn" value="${user != null}" />
<c:set var="userName" value="${user.userName}" />
<c:set var="userId" value="${user.userId}" />
<c:set var="userEmail" value="${user.email}" />
<!-- 게시글 정보 -->
<input type="hidden" id="isLoggedIn" value="${userName}">


<link rel="stylesheet"
	href="<c:url value='/css/header-profile-dropdown.css'/>" />
<!-- 세션에서 로그인 상태 확인: User 객체를 UserType으로 캐스팅하여 확인한다고 가정 -->

<!-- 우측: 액션들(모바일 햄버거 + 프로필 버튼) -->
<div class="header-actions">
	<!-- 햄버거(모바일에서만 보임: CSS로 제어) -->
	<div class="hamburger14" aria-label="사이드바 토글">
		<input type="checkbox" id="hamburger14-input" /> <label
			for="hamburger14-input" aria-controls="sidebar" aria-expanded="false">
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

		<c:choose>
			<c:when test="${isLoggedIn}">
				<!-- ✅ 로그인 상태: 사용자 이름 이니셜 표시 -->
				<span class="user-initial">${fn:substring(userName, 0, 1)}</span>
			</c:when>
			<c:otherwise>
				<!-- ✅ 비로그인 상태: 일반 사람 모양 아이콘 표시 -->
				<svg width="18" height="18" viewBox="0 0 24 24" fill="#4b5563"
					aria-hidden="true">
					<path
						d="M12 12c2.761 0 5-2.686 5-6s-2.239-6-5-6-5 2.686-5 6 2.239 6 5 6zm0 2c-4.418 0-8 3.358-8 7.5V24h16v-2.5C20 17.358 16.418 14 12 14z" />
				</svg>
			</c:otherwise>
		</c:choose>
	</button>

	<!-- 프로필 드롭다운 -->
	<div class="profile-popover" id="profile-popover" role="menu"
		aria-labelledby="avatar-btn" hidden>

		<c:choose>
			<c:when test="${isLoggedIn}">
				<!-- ============================================== -->
				<!-- ✅ case 1: 로그인 상태 메뉴 (정보 표시 + 로그아웃) -->
				<!-- ============================================== -->
				<div class="profile-card">
					<div class="profile-row">
						<div class="avatar-mini">
							<!-- 이니셜/아이콘 -->
							<span class="user-initial-mini">${fn:substring(userName, 0, 1)}</span>
						</div>
						<div class="meta">
							<strong class="name"><c:out value="${userName}" /></strong>
							<input type="hidden" id="userName" value="${user.userName}" />
							<input type="hidden" id="userId" value="${user.userId}" />
							<div class="sub">
								<c:out value="${userEmail}" />
							</div>
						</div>
					</div>

					<div class="divider"></div>

					<!-- 🚨 수정된 메뉴 항목 시작 -->
					<a href="<c:url value='/users/myInfo'/>" class="menu-item"
						role="menuitem">내 정보 수정</a> <a
						href="<c:url value='/users/myPosts'/>" class="menu-item"
						role="menuitem">내가 쓴 게시글</a> <a
						href="<c:url value='/users/myComments'/>" class="menu-item"
						role="menuitem">내가 쓴 댓글</a>
					<!-- 🚨 수정된 메뉴 항목 끝 -->

					<div class="divider"></div>

					<form action="<c:url value='/users/logout'/>" method="get"
						style="margin: 0;">
						<button type="submit" class="menu-item is-danger" role="menuitem">로그아웃</button>
					</form>
				</div>
			</c:when>
			<c:otherwise>
				<!-- ============================================== -->
				<!-- ✅ case 2: 비로그인 상태 메뉴 (로그인 + 회원가입) -->
				<!-- ============================================== -->
				<div class="profile-card is-compact">
					<a href="<c:url value='/users/login'/>"
						class="menu-item is-primary" role="menuitem">로그인</a> <a
						href="<c:url value='/users/join'/>" class="menu-item"
						role="menuitem">회원가입</a>
				</div>
			</c:otherwise>
		</c:choose>

	</div>
</div>
<!-- 우측 : 액션들 끝 지우지 말기! -->

<script>
/* ===================== 프로필 드롭다운 ===================== */
(function(){
  const btn = document.getElementById('avatar-btn');
  const pop = document.getElementById('profile-popover');
  if(!btn || !pop) return;

  const open = () => { pop.hidden = false; btn.setAttribute('aria-expanded','true'); };
  const close = () => { pop.hidden = true; btn.setAttribute('aria-expanded','false'); };

  // 토글 이벤트
  btn.addEventListener('click', () => {
    if(pop.hidden) {
      open();
    } else {
      close();
    }
  });

  // 외부 클릭 시 닫기
  document.addEventListener('click', (e) => {
    // Check if the click target is outside both the button and the popover
    const isTarget = btn.contains(e.target) || pop.contains(e.target);
    if (!isTarget && !pop.hidden) {
      close();
    }
  });

  // ESC 키 누를 시 닫기
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !pop.hidden) {
      close();
    }
  });

})();
</script>