<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>

<%-- 로그인 체크: 한글 쿼리를 헤더에 직접 넣지 않도록 ASCII 토큰 사용 --%>
<c:if test="${empty sessionScope.user}">
  <c:redirect url="/users/login">
    <c:param name="error" value="login_required"/>
  </c:redirect>
</c:if>

<%-- 편의용 컨텍스트 경로 변수 --%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="user" value="${sessionScope.user}" />

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>내 정보</title>

  <link rel="stylesheet" href="${ctx}/css/app.css?v=2" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

  <style>
  /* ====== 전역 폰트 ====== */
  @import url('https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@400;600;700&family=Noto+Sans+KR:wght@300;400;500;600&display=swap');

  /* ====== 메인 컨테이너 ====== */
  .main.grid-14x5 {
    max-width: 1400px;
    margin: 0 auto;
    padding: 24px;
  }

  .slot-board {
    display: grid;
    grid-template-columns: 1fr;
    gap: 24px;
  }

  /* ====== 프로필 카드 ====== */
  .user-profile-card {
    background: linear-gradient(135deg, 
      rgba(42, 31, 26, 0.6) 0%, 
      rgba(26, 22, 20, 0.6) 100%
    );
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 16px;
    padding: 32px;
    box-shadow: 
      0 8px 32px rgba(0, 0, 0, 0.3),
      inset 0 1px 0 rgba(255, 255, 255, 0.05);
  }

  /* ====== 프로필 헤더 ====== */
  .profile-header {
    display: flex;
    align-items: center;
    gap: 24px;
    margin-bottom: 32px;
    padding-bottom: 24px;
    border-bottom: 2px solid rgba(255, 139, 122, 0.2);
  }

  .profile-avatar {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 3rem;
    font-weight: 700;
    font-family: 'Noto Serif KR', serif;
    box-shadow: 
      0 8px 24px rgba(255, 107, 107, 0.4),
      inset 0 -2px 8px rgba(0, 0, 0, 0.2),
      inset 0 2px 8px rgba(255, 255, 255, 0.2);
    border: 3px solid rgba(255, 255, 255, 0.2);
    position: relative;
    overflow: hidden;
    flex-shrink: 0;
  }

  .profile-avatar::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.3) 0%, transparent 70%);
    animation: shimmer 3s infinite;
  }

  @keyframes shimmer {
    0%, 100% { transform: translate(-30%, -30%); }
    50% { transform: translate(30%, 30%); }
  }

  .profile-info {
    flex: 1;
  }

  .profile-info h2 {
    margin: 0 0 8px 0;
    font-family: 'Noto Serif KR', serif;
    font-size: 2rem;
    font-weight: 700;
    color: #fff;
    letter-spacing: -0.02em;
  }

  .profile-info .user-email {
    color: rgba(229, 229, 229, 0.7);
    font-size: 1rem;
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .profile-info .user-email::before {
    content: "✉️";
  }

  .profile-info .user-role {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 16px;
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    color: #fff;
    border-radius: 20px;
    font-size: 0.875rem;
    font-weight: 600;
    box-shadow: 0 2px 8px rgba(255, 107, 107, 0.3);
  }

  .profile-info .user-role::before {
    content: "👑";
  }

  /* ====== 통계 그리드 ====== */
  .profile-stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    margin-bottom: 28px;
  }

  .stat-item {
    text-align: center;
    padding: 24px 20px;
    background: linear-gradient(135deg, 
      rgba(42, 31, 26, 0.5) 0%, 
      rgba(26, 22, 20, 0.5) 100%
    );
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 12px;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
  }

  .stat-item::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 3px;
    background: linear-gradient(90deg, #FF6B6B 0%, #FF8B7A 100%);
    transform: scaleX(0);
    transition: transform 0.3s ease;
  }

  .stat-item:hover {
    transform: translateY(-4px);
    border-color: rgba(255, 139, 122, 0.4);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
  }

  .stat-item:hover::before {
    transform: scaleX(1);
  }

  .stat-number {
    font-size: 2.5rem;
    font-weight: 700;
    color: #FF8B7A;
    margin-bottom: 8px;
    font-family: 'Noto Serif KR', serif;
    text-shadow: 0 2px 8px rgba(255, 139, 122, 0.3);
  }

  .stat-label {
    color: rgba(229, 229, 229, 0.7);
    font-size: 0.95rem;
    font-weight: 500;
  }

  /* ====== 액션 버튼 ====== */
  .profile-actions {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
  }

  .profile-actions .btn {
    flex: 1;
    min-width: 150px;
    padding: 14px 24px;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    font-size: 15px;
    font-weight: 600;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }

  .btn-primary {
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    color: #fff;
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
  }

  .btn-primary::before {
    content: "✏️";
  }

  .btn-primary:hover {
    background: linear-gradient(135deg, #FF8B7A 0%, #FFA07A 100%);
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(255, 107, 107, 0.5);
  }

  .btn-secondary {
    background: rgba(42, 31, 26, 0.6);
    color: #e5e5e5;
    border: 1px solid rgba(255, 139, 122, 0.3);
  }

  .btn-secondary::before {
    content: "📊";
  }

  .btn-secondary:hover {
    background: rgba(255, 139, 122, 0.15);
    border-color: rgba(255, 139, 122, 0.5);
    color: #FF8B7A;
    transform: translateY(-2px);
  }

  .btn-danger {
    background: linear-gradient(135deg, #E53E3E 0%, #F56565 100%);
    color: #fff;
    box-shadow: 0 4px 12px rgba(229, 62, 62, 0.3);
  }

  .btn-danger:hover {
    background: linear-gradient(135deg, #F56565 0%, #FC8181 100%);
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(229, 62, 62, 0.5);
  }

  /* ====== 콘텐츠 그리드 (PC에서 2열) ====== */
  .content-grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 24px;
  }

  /* ====== 콘텐츠 섹션 ====== */
  .content-section {
    background: linear-gradient(135deg, 
      rgba(42, 31, 26, 0.5) 0%, 
      rgba(26, 22, 20, 0.5) 100%
    );
    border: 1px solid rgba(255, 139, 122, 0.15);
    border-radius: 16px;
    padding: 28px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
    display: flex;
    flex-direction: column;
    min-height: 400px;
  }

  .content-section h3 {
    margin: 0 0 20px 0;
    font-family: 'Noto Serif KR', serif;
    font-size: 1.5rem;
    font-weight: 700;
    color: #FF8B7A;
    border-bottom: 2px solid rgba(255, 139, 122, 0.3);
    padding-bottom: 12px;
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .content-section h3::before {
    font-size: 1.3em;
  }

  .content-section:nth-of-type(1) h3::before {
    content: "📝";
  }

  .content-section:nth-of-type(2) h3::before {
    content: "💬";
  }

  /* ====== 글/댓글 리스트 ====== */
  .post-list,
  .comment-list {
    list-style: none;
    padding: 0;
    margin: 0;
    flex: 1;
  }

  .post-item,
  .comment-item {
    padding: 16px 20px;
    border-bottom: 1px solid rgba(255, 139, 122, 0.1);
    transition: all 0.3s ease;
    border-radius: 8px;
    margin-bottom: 8px;
  }

  .post-item:hover,
  .comment-item:hover {
    background: rgba(255, 139, 122, 0.08);
    border-color: rgba(255, 139, 122, 0.2);
    transform: translateX(4px);
  }

  .post-item:last-child,
  .comment-item:last-child {
    border-bottom: none;
    margin-bottom: 0;
  }

  .post-title {
    font-weight: 600;
    font-size: 1.05rem;
    color: #fff;
    margin-bottom: 8px;
    text-decoration: none;
    display: block;
    line-height: 1.5;
    transition: color 0.3s ease;
  }

  .post-title:hover {
    color: #FF8B7A;
  }

  .post-meta,
  .comment-meta {
    font-size: 0.875rem;
    color: rgba(229, 229, 229, 0.6);
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .post-meta::before {
    content: "👁️";
  }

  .comment-meta::before {
    content: "📅";
  }

  /* ====== 빈 상태 / 로딩 ====== */
  .empty-message,
  .loading {
    text-align: center;
    padding: 48px 20px;
    color: rgba(229, 229, 229, 0.5);
    font-size: 1rem;
    background: rgba(42, 31, 26, 0.3);
    border: 2px dashed rgba(255, 139, 122, 0.2);
    border-radius: 12px;
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-direction: column;
  }

  .loading {
    color: #FF8B7A;
    animation: pulse 2s ease-in-out infinite;
  }

  .loading::before {
    content: "⏳ ";
    font-size: 1.2em;
  }

  @keyframes pulse {
    0%, 100% { opacity: 0.6; }
    50% { opacity: 1; }
  }

  .empty-message::before {
    content: "📭";
    display: block;
    font-size: 3rem;
    margin-bottom: 12px;
  }

  /* ====== 슬롯 네비 숨김 ====== */
  .slot-nav:empty {
    display: none;
  }

  /* ====== 태블릿 (768px ~ 1023px) ====== */
  @media (min-width: 768px) {
    .main.grid-14x5 {
      padding: 32px;
    }

    .user-profile-card {
      padding: 40px;
    }

    .profile-header {
      gap: 32px;
    }

    .profile-avatar {
      width: 140px;
      height: 140px;
      font-size: 3.5rem;
    }

    .profile-info h2 {
      font-size: 2.25rem;
    }

    .stat-number {
      font-size: 2.75rem;
    }
  }

  /* ====== PC (1024px 이상) ====== */
  @media (min-width: 1024px) {
    .main.grid-14x5 {
      padding: 40px;
    }

    /* 콘텐츠를 2열로 배치 */
    .content-grid {
      grid-template-columns: repeat(2, 1fr);
    }

    .user-profile-card {
      padding: 48px;
    }

    .profile-header {
      gap: 40px;
    }

    .profile-avatar {
      width: 160px;
      height: 160px;
      font-size: 4rem;
    }

    .profile-info h2 {
      font-size: 2.5rem;
    }

    .profile-info .user-email {
      font-size: 1.125rem;
    }

    .stat-number {
      font-size: 3rem;
    }

    .stat-label {
      font-size: 1rem;
    }

    .profile-actions .btn {
      padding: 16px 32px;
      font-size: 16px;
    }

    .content-section {
      min-height: 500px;
    }
  }

  /* ====== 대형 PC (1440px 이상) ====== */
  @media (min-width: 1440px) {
    .main.grid-14x5 {
      padding: 48px;
      max-width: 1600px;
    }

    .content-section {
      min-height: 550px;
    }
  }

  /* ====== 모바일 (767px 이하) ====== */
  @media (max-width: 767px) {
    .main.grid-14x5 {
      padding: 16px;
    }

    .user-profile-card {
      padding: 24px;
    }

    .profile-header {
      flex-direction: column;
      text-align: center;
      gap: 16px;
    }

    .profile-avatar {
      width: 100px;
      height: 100px;
      font-size: 2.5rem;
    }

    .profile-info h2 {
      font-size: 1.5rem;
    }

    .profile-info .user-email {
      justify-content: center;
    }

    .profile-stats {
      grid-template-columns: 1fr;
      gap: 12px;
    }

    .stat-number {
      font-size: 2rem;
    }

    .profile-actions {
      flex-direction: column;
    }

    .profile-actions .btn {
      width: 100%;
      min-width: 0;
    }

    .content-section {
      padding: 20px;
      min-height: 300px;
    }

    .content-section h3 {
      font-size: 1.25rem;
    }

    .post-item,
    .comment-item {
      padding: 14px 16px;
    }
  }
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

        <div class="profile-stats">
          <div class="stat-item">
            <div class="stat-number" id="postCount">0</div>
            <div class="stat-label">작성한 글</div>
          </div>
          <div class="stat-item">
            <div class="stat-number" id="commentCount">0</div>
            <div class="stat-label">작성한 댓글</div>
          </div>
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

      <!-- 콘텐츠 그리드 (PC에서 2열) -->
      <div class="content-grid">
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
            // ✅ URL 형식 변경: /post-detail.post?postId=X&listId=Y
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

 // ✅ 이중 JSON 구조에서 순수 텍스트 추출
    function extractTextFromComment(contentRaw) {
      if (!contentRaw) return '';
      
      try {
        // 1단계: 외부 JSON 파싱 {"text": "...", "edited": false, "deleted": false}
        let outerJson = contentRaw;
        if (typeof contentRaw === 'string') {
          outerJson = JSON.parse(contentRaw);
        }
        
        // text 필드 추출
        let textField = outerJson.text || outerJson.contentJson || contentRaw;
        
        // 2단계: TipTap JSON 파싱
        let tiptapJson = textField;
        if (typeof textField === 'string') {
          tiptapJson = JSON.parse(textField);
        }
        
        // 3단계: TipTap 문서에서 텍스트 추출
        return extractTextFromTipTap(tiptapJson);
        
      } catch (e) {
        console.error('댓글 파싱 오류:', e, contentRaw);
        
        // 파싱 실패 시 문자열에서 직접 추출 시도
        try {
          const match = contentRaw.match(/"text":"([^"]+)"/);
          if (match && match[1]) {
            // 이스케이프된 문자 복원
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
        
        // 텍스트 노드
        if (node.type === 'text' && node.text) {
          text += node.text;
        }
        
        // 이미지 노드
        if (node.type === 'image') {
          text += '[이미지] ';
        }
        
        // 링크는 텍스트만 추출
        if (node.marks && Array.isArray(node.marks)) {
          const linkMark = node.marks.find(m => m.type === 'link');
          if (linkMark && node.text) {
            text += node.text;
            return; // 링크 텍스트 처리 완료
          }
        }
        
        // 하위 content 재귀 처리
        if (node.content && Array.isArray(node.content)) {
          node.content.forEach(child => {
            extractText(child);
          });
          
          // paragraph 끝에 공백 추가
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
        
        console.log('받은 댓글 데이터:', data); // 디버깅용
        
        if (Array.isArray(data) && data.length > 0) {
          let html = '<ul class="comment-list">';
          
          data.forEach(function(comment) {
            // ✅ 이중 JSON 구조에서 텍스트 추출
            const raw = comment.contentRaw || comment.content || '';
            console.log('댓글 원본:', raw); // 디버깅용
            
            const plainText = extractTextFromComment(raw);
            console.log('추출된 텍스트:', plainText); // 디버깅용
            
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