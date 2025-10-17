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
    .activity-container { background: white; border-radius: 8px; padding: 2rem; margin-bottom: 2rem; box-shadow: 0 2px 8px rgba(0,0,0,.1); }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 2px solid var(--primary-color,#6a4c93); }
    .page-header h1 { margin: 0; color: var(--text-color,#111); font-size: 1.8rem; }
    .page-header .btn { padding: .5rem 1rem; border: none; border-radius: 6px; cursor: pointer; font-size: .9rem; transition: all .3s; text-decoration: none; display: inline-block; }
    .btn-secondary { background:#6c757d; color:#fff; } .btn-secondary:hover { background:#5a6268; }
    
    /* 탭 스타일 */
    .tab-container { margin-bottom: 2rem; }
    .tab-list { display: flex; gap: 1rem; border-bottom: 2px solid #e0e0e0; margin-bottom: 2rem; }
    .tab-button { padding: 1rem 1.5rem; background: transparent; border: none; border-bottom: 3px solid transparent; cursor: pointer; font-size: 1rem; font-weight: 500; color: var(--text-secondary,#666); transition: all .3s; }
    .tab-button:hover { color: var(--primary-color,#6a4c93); }
    .tab-button.active { color: var(--primary-color,#6a4c93); border-bottom-color: var(--primary-color,#6a4c93); }
    .tab-content { display: none; }
    .tab-content.active { display: block; }
    
    /* 리스트 스타일 */
    .post-list, .comment-list { list-style:none; padding:0; margin:0; }
    .post-item, .comment-item { padding:1.5rem; border-bottom:1px solid #e0e0e0; transition: background .2s; display: flex; justify-content: space-between; align-items: start; }
    .post-item:hover, .comment-item:hover { background:#f8f9fa; }
    .post-item:last-child, .comment-item:last-child { border-bottom:none; }
    
    .item-content { flex: 1; }
    .post-title { font-weight:600; color: var(--text-color,#111); margin-bottom:.5rem; text-decoration:none; display:block; font-size: 1.1rem; }
    .post-title:hover { color: var(--primary-color,#6a4c93); }
    .post-meta, .comment-meta { font-size:.85rem; color: var(--text-secondary,#666); margin-top: .5rem; }
    .comment-text { color: var(--text-color,#333); line-height: 1.6; margin-bottom: .5rem; }
    .item-actions { display: flex; gap: .5rem; }
    .item-actions .btn-small { padding: .4rem .8rem; font-size: .85rem; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; }
    .btn-view { background: var(--primary-color,#6a4c93); color: #fff; }
    .btn-view:hover { opacity: 0.9; }
    
    .empty-message, .loading { text-align:center; padding:3rem; color: var(--text-secondary,#666); font-size: 1.1rem; }
    
    /* 페이지네이션 */
    .pagination { display: flex; justify-content: center; gap: .5rem; margin-top: 2rem; padding-top: 2rem; border-top: 1px solid #e0e0e0; }
    .pagination button { padding: .5rem 1rem; border: 1px solid #ddd; background: white; border-radius: 4px; cursor: pointer; transition: all .2s; }
    .pagination button:hover:not(:disabled) { background: var(--primary-color,#6a4c93); color: white; border-color: var(--primary-color,#6a4c93); }
    .pagination button:disabled { opacity: 0.5; cursor: not-allowed; }
    .pagination .current-page { padding: .5rem 1rem; font-weight: 600; color: var(--primary-color,#6a4c93); }
    
    /* 통계 요약 */
    .stats-summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 1rem; margin-bottom: 2rem; }
    .stat-box { text-align: center; padding: 1.5rem; background: #f8f9fa; border-radius: 8px; }
    .stat-box .number { font-size: 2rem; font-weight: bold; color: var(--primary-color,#6a4c93); }
    .stat-box .label { color: var(--text-secondary,#666); font-size: .9rem; margin-top: .5rem; }
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

