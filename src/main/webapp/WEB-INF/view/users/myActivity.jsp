<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>

<%-- 로그인 체크 --%>
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
  <title>내 활동 내역</title>

  <link rel="stylesheet" href="${ctx}/css/app.css?v=2" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

  <style>
  /* ====== 전역 폰트 ====== */
  @import url('https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@400;600;700&family=Noto+Sans+KR:wght@300;400;500;600&display=swap');

  /* ====== 메인 그리드 조정 ====== */
  .main.grid-14x5 {
    grid-template-columns: 1fr;
    max-width: 1200px;
    margin: 0 auto;
    padding: 24px;
  }

  .slot-nav:empty {
    display: none;
  }

  /* ====== 활동 컨테이너 ====== */
  .activity-container {
    background: linear-gradient(135deg, 
      rgba(42, 31, 26, 0.6) 0%, 
      rgba(26, 22, 20, 0.6) 100%
    );
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 16px;
    padding: 40px;
    margin-bottom: 32px;
    box-shadow: 
      0 8px 32px rgba(0, 0, 0, 0.3),
      inset 0 1px 0 rgba(255, 255, 255, 0.05);
  }

  /* ====== 페이지 헤더 ====== */
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 32px;
    padding-bottom: 20px;
    border-bottom: 2px solid rgba(255, 139, 122, 0.3);
  }

  .page-header h1 {
    margin: 0;
    font-family: 'Noto Serif KR', serif;
    font-size: clamp(1.75rem, 3vw, 2.25rem);
    font-weight: 700;
    color: #FF8B7A;
    letter-spacing: -0.02em;
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .page-header h1::before {
    content: "📊";
    font-size: 1.2em;
  }

  .page-header .btn {
    padding: 10px 20px;
    background: rgba(42, 31, 26, 0.6);
    color: #e5e5e5;
    border: 1px solid rgba(255, 139, 122, 0.2);
    border-radius: 10px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s ease;
    text-decoration: none;
    display: inline-block;
  }

  .page-header .btn:hover {
    background: rgba(42, 31, 26, 0.8);
    border-color: rgba(255, 139, 122, 0.4);
    color: #FF8B7A;
    transform: translateX(-4px);
  }

  /* ====== 통계 요약 ====== */
  .stats-summary {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 16px;
    margin-bottom: 32px;
  }

  .stat-box {
    text-align: center;
    padding: 28px 20px;
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

  .stat-box::before {
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

  .stat-box:hover {
    transform: translateY(-4px);
    border-color: rgba(255, 139, 122, 0.4);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
  }

  .stat-box:hover::before {
    transform: scaleX(1);
  }

  .stat-box .number {
    font-size: 2.5rem;
    font-weight: 700;
    font-family: 'Noto Serif KR', serif;
    color: #FF8B7A;
    margin-bottom: 8px;
    text-shadow: 0 2px 8px rgba(255, 139, 122, 0.3);
  }

  .stat-box .label {
    color: rgba(229, 229, 229, 0.7);
    font-size: 0.95rem;
    font-weight: 500;
  }

  /* ====== 탭 컨테이너 ====== */
  .tab-container {
    margin-bottom: 0;
  }

  .tab-list {
    display: flex;
    gap: 8px;
    border-bottom: 2px solid rgba(255, 139, 122, 0.2);
    margin-bottom: 28px;
  }

  .tab-button {
    padding: 14px 24px;
    background: transparent;
    border: none;
    border-bottom: 3px solid transparent;
    cursor: pointer;
    font-size: 15px;
    font-weight: 600;
    color: rgba(229, 229, 229, 0.6);
    transition: all 0.3s ease;
    position: relative;
  }

  .tab-button::before {
    font-size: 1.2em;
    margin-right: 8px;
  }

  .tab-button[data-tab="posts"]::before {
    content: "📝";
  }

  .tab-button[data-tab="comments"]::before {
    content: "💬";
  }

  .tab-button:hover {
    color: #FF8B7A;
  }

  .tab-button.active {
    color: #FF8B7A;
    border-bottom-color: #FF8B7A;
  }

  .tab-content {
    display: none;
  }

  .tab-content.active {
    display: block;
  }

  /* ====== 리스트 스타일 ====== */
  .post-list,
  .comment-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .post-item,
  .comment-item {
    padding: 20px 24px;
    border-bottom: 1px solid rgba(255, 139, 122, 0.1);
    transition: all 0.3s ease;
    display: flex;
    justify-content: space-between;
    align-items: start;
    gap: 16px;
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

  .item-content {
    flex: 1;
    min-width: 0;
  }

  .post-title {
    font-weight: 600;
    font-size: 1.125rem;
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

  .comment-text {
    color: rgba(229, 229, 229, 0.9);
    line-height: 1.6;
    margin-bottom: 8px;
    font-size: 15px;
  }

  .post-meta,
  .comment-meta {
    font-size: 0.875rem;
    color: rgba(229, 229, 229, 0.6);
    margin-top: 8px;
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

  /* ====== 아이템 액션 버튼 ====== */
  .item-actions {
    display: flex;
    gap: 8px;
    flex-shrink: 0;
  }

  .item-actions .btn-small {
    padding: 8px 16px;
    font-size: 14px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
    white-space: nowrap;
  }

  .btn-view {
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    color: #fff;
    box-shadow: 0 2px 8px rgba(255, 107, 107, 0.3);
  }

  .btn-view::before {
    content: "👁️ ";
  }

  .btn-view:hover {
    background: linear-gradient(135deg, #FF8B7A 0%, #FFA07A 100%);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.5);
  }

  /* ====== 페이지네이션 ====== */
  .pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;
    margin-top: 32px;
    padding-top: 24px;
    border-top: 1px solid rgba(255, 139, 122, 0.15);
  }

  .pagination button {
    padding: 10px 18px;
    border: 1px solid rgba(255, 139, 122, 0.2);
    background: rgba(42, 31, 26, 0.6);
    color: #e5e5e5;
    border-radius: 8px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.3s ease;
  }

  .pagination button:hover:not(:disabled) {
    background: rgba(255, 139, 122, 0.15);
    border-color: rgba(255, 139, 122, 0.4);
    color: #FF8B7A;
    transform: translateY(-2px);
  }

  .pagination button:disabled {
    opacity: 0.3;
    cursor: not-allowed;
    transform: none !important;
  }

  .pagination .current-page {
    padding: 10px 20px;
    font-weight: 600;
    color: #FF8B7A;
    font-size: 14px;
  }

  /* ====== 빈 상태 / 로딩 ====== */
  .empty-message,
  .loading {
    text-align: center;
    padding: 60px 20px;
    color: rgba(229, 229, 229, 0.5);
    font-size: 1rem;
    background: rgba(42, 31, 26, 0.3);
    border: 2px dashed rgba(255, 139, 122, 0.2);
    border-radius: 12px;
  }

  .loading {
    color: #FF8B7A;
    animation: pulse 2s ease-in-out infinite;
  }

  .loading::before {
    content: "⏳";
    display: block;
    font-size: 3rem;
    margin-bottom: 12px;
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

  /* ====== 반응형 ====== */
  @media (max-width: 768px) {
    .activity-container {
      padding: 28px 20px;
    }

    .page-header {
      flex-direction: column;
      gap: 16px;
      text-align: center;
      align-items: stretch;
    }

    .page-header h1 {
      font-size: 1.5rem;
      justify-content: center;
    }

    .page-header .btn {
      width: 100%;
    }

    .stats-summary {
      grid-template-columns: 1fr;
      gap: 12px;
    }

    .stat-box {
      padding: 24px 16px;
    }

    .stat-box .number {
      font-size: 2rem;
    }

    .tab-list {
      flex-direction: column;
      gap: 0;
      border-bottom: none;
    }

    .tab-button {
      padding: 12px 20px;
      border-bottom: 1px solid rgba(255, 139, 122, 0.1);
      border-left: 3px solid transparent;
    }

    .tab-button.active {
      border-bottom-color: rgba(255, 139, 122, 0.1);
      border-left-color: #FF8B7A;
      background: rgba(255, 139, 122, 0.05);
    }

    .post-item,
    .comment-item {
      flex-direction: column;
      padding: 16px 18px;
      gap: 12px;
    }

    .item-actions {
      width: 100%;
    }

    .item-actions .btn-small {
      flex: 1;
      text-align: center;
    }

    .pagination {
      flex-wrap: wrap;
    }

    .pagination button {
      padding: 8px 14px;
      font-size: 13px;
    }

    .main.grid-14x5 {
      padding: 16px;
    }
  }

  /* ====== 스크롤 애니메이션 ====== */
  .post-item,
  .comment-item {
    animation: fadeInUp 0.3s ease-out backwards;
  }

  .post-item:nth-child(1),
  .comment-item:nth-child(1) { animation-delay: 0.05s; }
  .post-item:nth-child(2),
  .comment-item:nth-child(2) { animation-delay: 0.1s; }
  .post-item:nth-child(3),
  .comment-item:nth-child(3) { animation-delay: 0.15s; }
  .post-item:nth-child(4),
  .comment-item:nth-child(4) { animation-delay: 0.2s; }
  .post-item:nth-child(5),
  .comment-item:nth-child(5) { animation-delay: 0.25s; }

  @keyframes fadeInUp {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
</style>
</head>
<body>

  <jsp:include page="/WEB-INF/include/header.jsp" />

  <main class="main grid-14x5">
    <div class="slot-nav">
      <%-- 필요 시 세로 내비를 활성화하세요 --%>
    </div>

    <div class="slot-board">
      <div class="activity-container">
        <div class="page-header">
          <h1>내 활동 내역</h1>
          <a href="${ctx}/users/myInfo" class="btn btn-secondary">← 내 정보로</a>
        </div>

        <!-- 통계 요약 -->
        <div class="stats-summary">
          <div class="stat-box">
            <div class="number" id="totalPosts">0</div>
            <div class="label">전체 게시글</div>
          </div>
          <div class="stat-box">
            <div class="number" id="totalComments">0</div>
            <div class="label">전체 댓글</div>
          </div>
        </div>

        <!-- 탭 메뉴 -->
        <div class="tab-container">
          <div class="tab-list">
            <button class="tab-button active" data-tab="posts">내가 쓴 게시글</button>
            <button class="tab-button" data-tab="comments">내가 쓴 댓글</button>
          </div>

          <!-- 게시글 탭 -->
          <div class="tab-content active" id="posts-tab">
            <div id="postsContainer" class="loading">불러오는 중...</div>
            <div class="pagination" id="postsPagination" style="display: none;">
              <button id="postsFirstPage">처음</button>
              <button id="postsPrevPage">이전</button>
              <span class="current-page" id="postsCurrentPage">1</span>
              <button id="postsNextPage">다음</button>
              <button id="postsLastPage">마지막</button>
            </div>
          </div>

          <!-- 댓글 탭 -->
          <div class="tab-content" id="comments-tab">
            <div id="commentsContainer" class="loading">불러오는 중...</div>
            <div class="pagination" id="commentsPagination" style="display: none;">
              <button id="commentsFirstPage">처음</button>
              <button id="commentsPrevPage">이전</button>
              <span class="current-page" id="commentsCurrentPage">1</span>
              <button id="commentsNextPage">다음</button>
              <button id="commentsLastPage">마지막</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>

  <script>
    const CTX = (window.CTX || '${ctx}');
    
    // 페이지네이션 설정
    const ITEMS_PER_PAGE = 10;
    let postsCurrentPage = 1;
    let commentsCurrentPage = 1;
    let totalPostsData = [];
    let totalCommentsData = [];

    $(function() {
      loadAllPosts();
      loadAllComments();
      
      // 탭 전환 이벤트
      $('.tab-button').on('click', function() {
        const tab = $(this).data('tab');
        $('.tab-button').removeClass('active');
        $(this).addClass('active');
        $('.tab-content').removeClass('active');
        $('#' + tab + '-tab').addClass('active');
      });
      
      // 게시글 페이지네이션 버튼
      $('#postsFirstPage').on('click', () => goToPostsPage(1));
      $('#postsPrevPage').on('click', () => goToPostsPage(postsCurrentPage - 1));
      $('#postsNextPage').on('click', () => goToPostsPage(postsCurrentPage + 1));
      $('#postsLastPage').on('click', () => goToPostsPage(Math.ceil(totalPostsData.length / ITEMS_PER_PAGE)));
      
      // 댓글 페이지네이션 버튼
      $('#commentsFirstPage').on('click', () => goToCommentsPage(1));
      $('#commentsPrevPage').on('click', () => goToCommentsPage(commentsCurrentPage - 1));
      $('#commentsNextPage').on('click', () => goToCommentsPage(commentsCurrentPage + 1));
      $('#commentsLastPage').on('click', () => goToCommentsPage(Math.ceil(totalCommentsData.length / ITEMS_PER_PAGE)));
    });

    // XSS 방지
    function escapeHtml(text) {
      if (!text) return '';
      const map = { '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#039;' };
      return String(text).replace(/[&<>"']/g, m => map[m]);
    }

    // 날짜 포맷팅
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

    // 전체 게시글 로드
    function loadAllPosts() {
      $.ajax({
        url: CTX + '/users/ajax/allPosts',
        type: 'GET',
        dataType: 'json',
        cache: false
      }).done(function(data) {
        totalPostsData = Array.isArray(data) ? data : [];
        $('#totalPosts').text(totalPostsData.length);
        renderPosts();
      }).fail(function(jqXHR) {
        if (jqXHR && jqXHR.status === 401) {
          window.location.href = CTX + '/users/login?error=session_expired';
        } else {
          $('#postsContainer').html('<p class="empty-message">게시글을 불러올 수 없습니다.</p>');
        }
      });
    }

    // 게시글 렌더링
    function renderPosts() {
      const $container = $('#postsContainer');
      
      if (totalPostsData.length === 0) {
        $container.html('<p class="empty-message">작성한 게시글이 없습니다.</p>');
        $('#postsPagination').hide();
        return;
      }
      
      const start = (postsCurrentPage - 1) * ITEMS_PER_PAGE;
      const end = start + ITEMS_PER_PAGE;
      const pageData = totalPostsData.slice(start, end);
      
      let html = '<ul class="post-list">';
      pageData.forEach(function(post) {
        const postUrl = CTX + '/post-detail.post?postId=' + post.postId + 
                        (post.listId ? '&listId=' + post.listId : '');
        
        html += '<li class="post-item">';
        html +=   '<div class="item-content">';
        html +=     '<a class="post-title" href="' + postUrl + '">' + escapeHtml(post.title || '제목 없음') + '</a>';
        html +=     '<div class="post-meta">조회 ' + (post.hit || 0) + ' · ' + formatDate(post.createdAt) + '</div>';
        html +=   '</div>';
        html +=   '<div class="item-actions">';
        html +=     '<a href="' + postUrl + '" class="btn-small btn-view">보기</a>';
        html +=   '</div>';
        html += '</li>';
      });
      html += '</ul>';
      
      $container.html(html);
      updatePostsPagination();
    }

    // 게시글 페이지네이션 업데이트
    function updatePostsPagination() {
      const totalPages = Math.ceil(totalPostsData.length / ITEMS_PER_PAGE);
      
      if (totalPages <= 1) {
        $('#postsPagination').hide();
        return;
      }
      
      $('#postsPagination').show();
      $('#postsCurrentPage').text(postsCurrentPage + ' / ' + totalPages);
      $('#postsFirstPage').prop('disabled', postsCurrentPage === 1);
      $('#postsPrevPage').prop('disabled', postsCurrentPage === 1);
      $('#postsNextPage').prop('disabled', postsCurrentPage === totalPages);
      $('#postsLastPage').prop('disabled', postsCurrentPage === totalPages);
    }

    // 게시글 페이지 이동
    function goToPostsPage(page) {
      const totalPages = Math.ceil(totalPostsData.length / ITEMS_PER_PAGE);
      if (page < 1 || page > totalPages) return;
      postsCurrentPage = page;
      renderPosts();
      $('html, body').animate({ scrollTop: $('#posts-tab').offset().top - 100 }, 300);
    }

    // 전체 댓글 로드
    function loadAllComments() {
      $.ajax({
        url: CTX + '/users/ajax/allComments',
        type: 'GET',
        dataType: 'json',
        cache: false
      }).done(function(data) {
        totalCommentsData = Array.isArray(data) ? data : [];
        $('#totalComments').text(totalCommentsData.length);
        renderComments();
      }).fail(function(jqXHR) {
        if (jqXHR && jqXHR.status === 401) {
          window.location.href = CTX + '/users/login?error=session_expired';
        } else {
          $('#commentsContainer').html('<p class="empty-message">댓글을 불러올 수 없습니다.</p>');
        }
      });
    }

    // 댓글 텍스트 추출
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

    // TipTap JSON에서 텍스트 추출
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

    // 댓글 렌더링
    function renderComments() {
      const $container = $('#commentsContainer');
      
      if (totalCommentsData.length === 0) {
        $container.html('<p class="empty-message">작성한 댓글이 없습니다.</p>');
        $('#commentsPagination').hide();
        return;
      }
      
      const start = (commentsCurrentPage - 1) * ITEMS_PER_PAGE;
      const end = start + ITEMS_PER_PAGE;
      const pageData = totalCommentsData.slice(start, end);
      
      let html = '<ul class="comment-list">';
      pageData.forEach(function(comment) {
        const raw = comment.contentRaw || comment.content || '';
        const plainText = extractTextFromComment(raw);
        const displayText = plainText.length > 200 
          ? plainText.substring(0, 200) + '...' 
          : plainText;
        
        const commentUrl = CTX + '/post-detail.post?postId=' + comment.postId + 
                          (comment.listId ? '&listId=' + comment.listId : '') +
                          '#comment-' + comment.commentId;
        
        html += '<li class="comment-item">';
        html +=   '<div class="item-content">';
        html +=     '<div class="comment-text">' + escapeHtml(displayText || '(내용 없음)') + '</div>';
        html +=     '<div class="comment-meta">' + formatDate(comment.createdAt) + '</div>';
        html +=   '</div>';
        html +=   '<div class="item-actions">';
        html +=     '<a href="' + commentUrl + '" class="btn-small btn-view">보기</a>';
        html +=   '</div>';
        html += '</li>';
      });
      html += '</ul>';
      
      $container.html(html);
      updateCommentsPagination();
    }

    // 댓글 페이지네이션 업데이트
    function updateCommentsPagination() {
      const totalPages = Math.ceil(totalCommentsData.length / ITEMS_PER_PAGE);
      
      if (totalPages <= 1) {
        $('#commentsPagination').hide();
        return;
      }
      
      $('#commentsPagination').show();
      $('#commentsCurrentPage').text(commentsCurrentPage + ' / ' + totalPages);
      $('#commentsFirstPage').prop('disabled', commentsCurrentPage === 1);
      $('#commentsPrevPage').prop('disabled', commentsCurrentPage === 1);
      $('#commentsNextPage').prop('disabled', commentsCurrentPage === totalPages);
      $('#commentsLastPage').prop('disabled', commentsCurrentPage === totalPages);
    }

    // 댓글 페이지 이동
    function goToCommentsPage(page) {
      const totalPages = Math.ceil(totalCommentsData.length / ITEMS_PER_PAGE);
      if (page < 1 || page > totalPages) return;
      commentsCurrentPage = page;
      renderComments();
      $('html, body').animate({ scrollTop: $('#comments-tab').offset().top - 100 }, 300);
    }
  </script>
</body>
</html>

