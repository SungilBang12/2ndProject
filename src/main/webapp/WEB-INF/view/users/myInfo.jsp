<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>

<c:if test="${empty sessionScope.user}">
  <c:redirect url="/users/login">
    <c:param name="error" value="login_required"/>
  </c:redirect>
</c:if>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="user" value="${sessionScope.user}" />

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>내 정보</title>
  <link rel="stylesheet" href="${ctx}/css/style.css?v=2" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

  <style>
  /* Sunset 다크톤 유지 */
  body {
    background: linear-gradient(to bottom, #0f0d0c, #1a1614);
    color: #fff;
    font-family: "Noto Sans KR", sans-serif;
    margin: 0;
    padding: 0;
  }

  /* ✅ 헤더 공간 제거: 기존 style.css의 body::before 규칙 무시 */
  html[data-fixed-header] body::before,
  body::before {
    display: none !important;
    height: 0 !important;
    content: none !important;
  }

  html[data-fixed-header] {
    scroll-padding-top: 0 !important;
  }

  .user-profile-card {
    background: linear-gradient(145deg, rgba(30,24,22,0.85), rgba(20,16,14,0.85));
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 16px;
    padding: 40px;
    margin-bottom: 30px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(8px);
  }

  .profile-header {
    display: flex;
    align-items: center;
    gap: 24px;
    border-bottom: 1px solid rgba(255,139,122,0.25);
    padding-bottom: 20px;
    margin-bottom: 24px;
  }

  .profile-avatar {
    width: 110px; height: 110px;
    border-radius: 50%;
    background: linear-gradient(145deg, #EEAF61, #EE5D6C);
    display: flex; align-items: center; justify-content: center;
    font-size: 2.5rem; font-weight: 700; color: #fff;
    box-shadow: 0 6px 24px rgba(255,139,122,0.35);
  }

  .profile-info h2 {
    margin: 0 0 6px;
    font-size: 1.8rem;
    color: #fff;
  }

  .profile-info .user-email {
    color: rgba(255,255,255,0.6);
    margin-bottom: 10px;
  }

  .user-role {
    display: inline-block;
    padding: 6px 14px;
    border-radius: 20px;
    background: linear-gradient(90deg, #FB9062, #EE5D6C);
    color: #fff;
    font-weight: 600;
    font-size: 0.9rem;
  }

  .profile-stats {
    display: flex; gap: 16px; justify-content: space-between;
    margin-bottom: 24px;
  }

  .stat-item {
    flex: 1;
    background: rgba(255,255,255,0.05);
    border: 1px solid rgba(255,139,122,0.15);
    border-radius: 10px;
    text-align: center;
    padding: 20px;
    transition: all .25s;
  }
  .stat-item:hover { border-color: rgba(255,139,122,0.4); transform: translateY(-3px); }

  .stat-number { color: #FB9062; font-size: 1.8rem; font-weight: 700; }
  .stat-label { color: rgba(255,255,255,0.7); }

  .profile-actions {
    display: flex; gap: 10px; flex-wrap: wrap;
  }
  .btn {
    flex: 1;
    padding: 12px 20px;
    border-radius: 8px;
    text-align: center;
    font-weight: 600;
    transition: all .3s;
  }
  .btn-primary {
    background: linear-gradient(135deg, #EE5D6C, #FB9062);
    color: #fff;
  }
  .btn-primary:hover { filter: brightness(1.15); }
  .btn-secondary {
    background: rgba(255,255,255,0.1);
    border: 1px solid rgba(255,139,122,0.2);
    color: #fff;
  }
  .btn-secondary:hover {
    background: rgba(255,139,122,0.2);
  }

  .content-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(340px, 1fr));
    gap: 24px;
  }

  .content-section {
    background: linear-gradient(145deg, rgba(30,24,22,0.8), rgba(20,16,14,0.8));
    border: 1px solid rgba(255,139,122,0.2);
    border-radius: 14px;
    padding: 24px;
    box-shadow: 0 6px 18px rgba(0,0,0,0.3);
    min-height: 400px;
  }

  .content-section h3 {
    color: #FB9062;
    border-bottom: 1px solid rgba(255,139,122,0.3);
    padding-bottom: 10px;
    margin-bottom: 18px;
    font-size: 1.3rem;
    font-weight: 700;
  }

  .post-item, .comment-item {
    border-bottom: 1px solid rgba(255,255,255,0.08);
    padding: 14px 0;
  }
  .post-item:last-child, .comment-item:last-child { border-bottom: none; }

  .post-title {
    color: #fff;
    font-weight: 500;
  }
  .post-title:hover { color: #FB9062; }

  .post-meta, .comment-meta {
    color: rgba(255,255,255,0.6);
    font-size: 0.9rem;
  }

  .empty-message {
    text-align: center;
    padding: 60px 20px;
    color: rgba(255,255,255,0.4);
    border: 2px dashed rgba(255,255,255,0.1);
    border-radius: 12px;
  }
  </style>
</head>

<body>
  <jsp:include page="/WEB-INF/include/header.jsp" />
  <main class="main grid-14x5">
    <div class="slot-nav"><jsp:include page="/WEB-INF/include/nav.jsp" /></div>
    <div class="slot-board">
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

        <div class="profile-stats">
          <div class="stat-item"><div class="stat-number" id="postCount">0</div><div class="stat-label">작성한 글</div></div>
          <div class="stat-item"><div class="stat-number" id="commentCount">0</div><div class="stat-label">작성한 댓글</div></div>
          <div class="stat-item">
            <div class="stat-number">
              <c:if test="${not empty user.createdAt}">
                ${user.createdAt.year}.${String.format('%02d', user.createdAt.monthValue)}.${String.format('%02d', user.createdAt.dayOfMonth)}
              </c:if>
              <c:if test="${empty user.createdAt}">-</c:if>
            </div>
            <div class="stat-label">가입일</div>
          </div>
        </div>

        <div class="profile-actions">
          <a href="${ctx}/users/myInfoEdit" class="btn btn-primary">내 정보 수정</a>
          <a href="${ctx}/users/myActivity" class="btn btn-secondary">내 활동 내역</a>
        </div>
      </div>

      <div class="content-grid">
        <div class="content-section">
          <h3>최근 작성한 글</h3>
          <div id="recentPostsContainer" class="loading">불러오는 중...</div>
        </div>
        <div class="content-section">
          <h3>최근 작성한 댓글</h3>
          <div id="recentCommentsContainer" class="loading">불러오는 중...</div>
        </div>
      </div>
    </div>
  </main>

  <script src="${ctx}/js/user-profile.js"></script>
</body>


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
            const postUrl = CTX + '/post-detail.post?postId=' + post.postId + 
                            (post.listId ? '&listId=' + post.listId : '');
            
            html += '<li class="post-item">';
            html +=   '<a class="post-title" href="' + postUrl + '">';
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

    // 이중 JSON 구조에서 순수 텍스트 추출
    function extractTextFromComment(contentRaw) {
      if (!contentRaw) return '';
      
      try {
        let outerJson = contentRaw;
        if (typeof contentRaw === 'string') {
          outerJson = JSON.parse(contentRaw);
        }
        
        let textField = outerJson.text || outerJson.contentJson || contentRaw;
        
        let tiptapJson = textField;
        if (typeof textField === 'string') {
          tiptapJson = JSON.parse(textField);
        }
        
        return extractTextFromTipTap(tiptapJson);
        
      } catch (e) {
        console.error('댓글 파싱 오류:', e, contentRaw);
        
        try {
          const match = contentRaw.match(/"text":"([^"]+)"/);
          if (match && match[1]) {
            return match[1]
              .replace(/\\n/g, ' ')
              .replace(/\\"/g, '"')
              .replace(/\\\\/g, '\\');
          }
        } catch (e2) {
          console.error('대체 파싱 실패:', e2);
        }
        
        return '(내용을 불러올 수 없습니다)';
      }
    }

    // TipTap JSON에서 순수 텍스트 추출
    function extractTextFromTipTap(tiptapDoc) {
      if (!tiptapDoc) return '';
      
      let text = '';
      
      function extractText(node) {
        if (!node) return;
        
        if (node.type === 'text' && node.text) {
          text += node.text;
        }
        
        if (node.type === 'image') {
          text += '[이미지] ';
        }
        
        if (node.marks && Array.isArray(node.marks)) {
          const linkMark = node.marks.find(m => m.type === 'link');
          if (linkMark && node.text) {
            text += node.text;
            return;
          }
        }
        
        if (node.content && Array.isArray(node.content)) {
          node.content.forEach(child => {
            extractText(child);
          });
          
          if (node.type === 'paragraph') {
            text += ' ';
          }
        }
      }
      
      extractText(tiptapDoc);
      return text.trim();
    }

    // 최근 작성한 댓글
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
            const raw = comment.contentRaw || comment.content || '';
            const plainText = extractTextFromComment(raw);
            const displayText = plainText.length > 100 
              ? plainText.substring(0, 100) + '...' 
              : plainText;
            
            const commentUrl = CTX + '/post-detail.post?postId=' + comment.postId + 
                              (comment.listId ? '&listId=' + comment.listId : '') +
                              '#comment-' + comment.commentId;
            
            html += '<li class="comment-item">';
            html +=   '<a class="post-title" href="' + commentUrl + '">';
            html +=     escapeHtml(displayText || '(내용 없음)') + '</a>';
            html +=   '<div class="comment-meta">' + formatDate(comment.createdAt) + '</div>';
            html += '</li>';
          });
          
          html += '</ul>';
          $container.html(html);
        } else {
          $container.html('<p class="empty-message">작성한 댓글이 없습니다.</p>');
        }
      }).fail(function(jqXHR) { 
        handleAjaxError(jqXHR, '#recentCommentsContainer'); 
      });
    }
  </script>
</body>
</html>