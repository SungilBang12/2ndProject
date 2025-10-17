<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>

<%-- 로그인 체크: 한글 쿼리를 헤더에 직접 넣지 않도록 ASCII 토큰 사용 --%>
<c:if test="${empty sessionScope.loggedInUser}">
  <c:redirect url="/users/login">
    <c:param name="error" value="login_required"/>
  </c:redirect>
</c:if>

<%-- 편의용 컨텍스트 경로 변수 --%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="user" value="${sessionScope.loggedInUser}" />

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>내 정보</title>

  <link rel="stylesheet" href="${ctx}/css/app.css?v=2" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

  <style>
    .user-profile-card { background: white; border-radius: 8px; padding: 2rem; margin-bottom: 2rem; box-shadow: 0 2px 8px rgba(0,0,0,.1); }
    .profile-header { display: flex; align-items: center; gap: 2rem; margin-bottom: 2rem; padding-bottom: 2rem; border-bottom: 1px solid #e0e0e0; }
    .profile-avatar { width: 100px; height: 100px; border-radius: 50%; background: linear-gradient(135deg, var(--primary-color,#6a4c93), var(--accent,#f3b664)); display: flex; align-items: center; justify-content: center; color: white; font-size: 2.5rem; font-weight: bold; }
    .profile-info h2 { margin: 0 0 .5rem 0; color: var(--text-color,#111); }
    .profile-info .user-email { color: var(--text-secondary,#666); font-size: .95rem; }
    .profile-info .user-role { display: inline-block; padding: .25rem .75rem; background: var(--primary-color,#6a4c93); color: #fff; border-radius: 12px; font-size: .85rem; margin-top: .5rem; }
    .profile-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px,1fr)); gap: 1rem; margin-bottom: 2rem; }
    .stat-item { text-align: center; padding: 1rem; background: #f8f9fa; border-radius: 8px; }
    .stat-number { font-size: 2rem; font-weight: bold; color: var(--primary-color,#6a4c93); }
    .stat-label { color: var(--text-secondary,#666); font-size: .9rem; margin-top: .25rem; }
    .profile-actions { display: flex; gap: 1rem; flex-wrap: wrap; }
    .profile-actions .btn { padding: .75rem 1.5rem; border: none; border-radius: 6px; cursor: pointer; font-size: 1rem; transition: all .3s; text-decoration: none; display: inline-block; }
    .btn-primary { background: var(--primary-color,#6a4c93); color:#fff; } .btn-primary:hover{ background:#5a3c73; }
    .btn-secondary{ background:#6c757d; color:#fff; } .btn-secondary:hover{ background:#5a6268; }
    .btn-danger{ background:#e53e3e; color:#fff; } .btn-danger:hover{ background:#c82333; }
    .content-section { background:#fff; border-radius:8px; padding:2rem; margin-bottom:2rem; box-shadow:0 2px 8px rgba(0,0,0,.1); }
    .content-section h3 { margin:0 0 1.5rem 0; color: var(--text-color,#111); border-bottom:2px solid var(--primary-color,#6a4c93); padding-bottom:.5rem; }
    .post-list, .comment-list { list-style:none; padding:0; margin:0; }
    .post-item, .comment-item { padding:1rem; border-bottom:1px solid #e0e0e0; transition: background .2s; }
    .post-item:hover, .comment-item:hover { background:#f8f9fa; }
    .post-item:last-child, .comment-item:last-child { border-bottom:none; }
    .post-title { font-weight:600; color: var(--text-color,#111); margin-bottom:.5rem; text-decoration:none; display:block; }
    .post-title:hover { color: var(--primary-color,#6a4c93); }
    .post-meta, .comment-meta { font-size:.85rem; color: var(--text-secondary,#666); }
    .empty-message, .loading { text-align:center; padding:2rem; color: var(--text-secondary,#666); }
  </style>
</head>
<body>

  <jsp:include page="/WEB-INF/include/header.jsp" />

  <main class="main grid-14x5">
    <div class="slot-nav">
      <%-- 필요 시 세로 내비를 활성화하세요 --%>
      <%-- <jsp:include page="/WEB-INF/include/nav.jsp" /> --%>
    </div>

    <div class="slot-board">
      <!-- 사용자 프로필 카드 -->
      <div class="user-profile-card">
        <div class="profile-header">
          <div class="profile-avatar">
            <c:out value="${fn:substring(user.userName, 0, 1)}" />
          </div>
          <div class="profile-info">
            <h2><c:out value="${user.userName}" /></h2>
            <p class="user-email"><c:out value="${user.email}" /></p>
            <span class="user-role">
              <c:choose>
                <c:when test="${user.ROLE == 'ADMIN'}">관리자</c:when>
                <c:otherwise>일반 회원</c:otherwise>
              </c:choose>
            </span>
          </div>
        </div>

        <!-- 통계 -->
        <div class="profile-stats">
          <div class="stat-item">
            <div class="stat-number" id="postCount">-</div>
            <div class="stat-label">작성한 글</div>
          </div>
          <div class="stat-item">
            <div class="stat-number" id="commentCount">-</div>
            <div class="stat-label">작성한 댓글</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">
              <%-- 주의: fmt:formatDate는 java.util.Date만 지원. Controller에서 변환하지 않았다면 빈 값일 수 있음 --%>
              <fmt:formatDate value="${user.createdAt}" pattern="yyyy.MM.dd" />
            </div>
            <div class="stat-label">가입일</div>
          </div>
        </div>

        <!-- 액션 버튼 -->
        <div class="profile-actions">
          <a href="${ctx}/users/myInfoEdit"   class="btn btn-primary">정보 수정</a>
          <a href="${ctx}/users/myPosts"      class="btn btn-secondary">내 게시글</a>
          <a href="${ctx}/users/myComments"   class="btn btn-secondary">내 댓글</a>
          <button type="button" class="btn btn-danger" onclick="confirmDelete()">회원 탈퇴</button>
        </div>
      </div>

      <!-- 최근 작성한 글 -->
      <div class="content-section">
        <h3>최근 작성한 글</h3>
        <div id="recentPostsContainer" class="loading">불러오는 중...</div>
      </div>

      <!-- 최근 작성한 댓글 -->
      <div class="content-section">
        <h3>최근 작성한 댓글</h3>
        <div id="recentCommentsContainer" class="loading">불러오는 중...</div>
      </div>
    </div>
  </main>

  <script>
    // 컨텍스트 루트 전역 보장
    const CTX = (window.CTX || '${ctx}');

    $(function() {
      loadUserStats();
      loadRecentPosts();
      loadRecentComments();
    });

    // 공통 에러 처리 (401 → 로그인)
    function handleAjaxError(jqXHR, defaultTarget) {
      if (jqXHR && jqXHR.status === 401) {
        window.location.href = CTX + '/users/login?error=session_expired';
        return;
      }
      $(defaultTarget).html('<p class="empty-message">데이터를 불러올 수 없습니다.</p>');
    }

    // XSS 방지
    function escapeHtml(text) {
      if (!text) return '';
      const map = { '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#039;' };
      return String(text).replace(/[&<>"']/g, m => map[m]);
    }

    // 날짜 포맷팅: [y,m,d] 배열/ISO 문자열 모두 지원
    function formatDate(d) {
      if (!d) return '';
      if (Array.isArray(d) && d.length >= 3) {
        const y = d[0], m = String(d[1]).padStart(2,'0'), day = String(d[2]).padStart(2,'0');
        return y + '.' + m + '.' + day;
      }
      if (typeof d === 'string') {
        const dt = new Date(d);
        if (!isNaN(dt)) {
          const y = dt.getFullYear();
          const m = String(dt.getMonth()+1).padStart(2,'0');
          const day = String(dt.getDate()).padStart(2,'0');
          return y + '.' + m + '.' + day;
        }
      }
      return '';
    }

    // 사용자 통계
    function loadUserStats() {
      $.ajax({
        url: CTX + '/users/ajax/stats',
        type: 'GET',
        dataType: 'json',
        cache: false
      }).done(function(data) {
        $('#postCount').text((data && data.postCount) || 0);
        $('#commentCount').text((data && data.commentCount) || 0);
      }).fail(function(jqXHR) {
        $('#postCount').text('0');
        $('#commentCount').text('0');
        if (jqXHR && jqXHR.status === 401) {
          window.location.href = CTX + '/users/login?error=session_expired';
        }
      });
    }

    // 최근 작성한 글
    function loadRecentPosts() {
      $.ajax({
        url: CTX + '/users/ajax/recentPosts',
        type: 'GET',
        dataType: 'json',
        cache: false
      }).done(function(data) {
        const $container = $('#recentPostsContainer');
        if (Array.isArray(data) && data.length > 0) {
          let html = '<ul class="post-list">';
          data.forEach(function(post) {
            html += '<li class="post-item">';
            html +=   '<a class="post-title" href="' + CTX + '/board/view/' + post.postId + '">';
            html +=     escapeHtml(post.title || '제목 없음') + '</a>';
            html +=   '<div class="post-meta">조회 ' + (post.hit || 0) + ' · ' + formatDate(post.createdAt) + '</div>';
            html += '</li>';
          });
          html += '</ul>';
          $container.html(html);
        } else {
          $container.html('<p class="empty-message">작성한 글이 없습니다.</p>');
        }
      }).fail(function(jqXHR) { handleAjaxError(jqXHR, '#recentPostsContainer'); });
    }

    // 최근 작성한 댓글 (현재 서버는 빈 배열 가능)
    function loadRecentComments() {
      $.ajax({
        url: CTX + '/users/ajax/recentComments',
        type: 'GET',
        dataType: 'json',
        cache: false
      }).done(function(data) {
        const $container = $('#recentCommentsContainer');
        if (Array.isArray(data) && data.length > 0) {
          let html = '<ul class="comment-list">';
          data.forEach(function(comment) {
            const raw = comment.content || '';
            const text = raw.length > 100 ? raw.substring(0,100) + '...' : raw;
            html += '<li class="comment-item">';
            html +=   '<a class="post-title" href="' + CTX + '/board/view/' + comment.postId + '#comment-' + comment.commentId + '">';
            html +=     escapeHtml(text) + '</a>';
            html +=   '<div class="comment-meta">' + formatDate(comment.createdAt) + '</div>';
            html += '</li>';
          });
          html += '</ul>';
          $container.html(html);
        } else {
          $container.html('<p class="empty-message">작성한 댓글이 없습니다.</p>');
        }
      }).fail(function(jqXHR) { handleAjaxError(jqXHR, '#recentCommentsContainer'); });
    }

    // 회원 탈퇴
    function confirmDelete() {
      if (confirm('정말로 회원 탈퇴하시겠습니까?\n\n탈퇴 시 모든 정보가 삭제되며 복구할 수 없습니다.')) {
        const password = prompt('본인 확인을 위해 비밀번호를 입력해주세요:');
        if (password) {
          $.ajax({
            url: CTX + '/users/ajax/delete',
            type: 'POST',
            data: { password: password },
            dataType: 'json',
            cache: false
          }).done(function(res) {
            if (res && res.success) {
              alert('회원 탈퇴가 완료되었습니다.');
              window.location.href = CTX + '/index.jsp';
            } else {
              alert((res && res.message) || '회원 탈퇴 처리 중 오류가 발생했습니다.');
            }
          }).fail(function() {
            alert('회원 탈퇴 처리 중 오류가 발생했습니다.');
          });
        }
      }
    }
  </script>
</body>
</html>
