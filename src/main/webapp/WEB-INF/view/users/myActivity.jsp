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
  <title>내 활동 내역</title>

  <link rel="stylesheet" href="${ctx}/css/app.css?v=2" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

  <style>
  /* 폰트 */
  @import url('https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@400;600;700&family=Noto+Sans+KR:wght@300;400;500;600&display=swap');

  /* ✅ 고정 헤더 여백 제거 */
  html[data-fixed-header] body::before,
  body::before{ display:none !important; height:0 !important; content:none !important; }
  html[data-fixed-header]{ scroll-padding-top:0 !important; }

  /* 전역 배경/텍스트 */
  body{
    background: linear-gradient(to bottom, #0f0d0c, #1a1614);
    color:#fff;
    font-family:"Noto Sans KR", system-ui, -apple-system, Segoe UI, Roboto, Apple SD Gothic Neo, sans-serif;
    margin:0; padding:0;
  }

  /* 메인 컨테이너 */
  .main.grid-14x5{
    grid-template-columns: 1fr;
    max-width: 1200px;
    margin: 0 auto;
    padding: 24px;
  }
  .slot-nav:empty{ display:none; }

  /* ───────── 프로필 카드 (상단) ───────── */
  .user-profile-card{
    background: linear-gradient(145deg, rgba(30,24,22,0.85), rgba(20,16,14,0.85));
    border:1px solid rgba(255,139,122,0.20);
    border-radius:16px;
    padding:28px;
    margin-bottom:24px;
    box-shadow:0 8px 24px rgba(0,0,0,.35);
    backdrop-filter: blur(8px);
  }
  .profile-header{ display:flex; align-items:center; gap:18px; padding-bottom:16px; margin-bottom:16px; border-bottom:1px solid rgba(255,139,122,.22); }
  .profile-avatar{
    width:84px; height:84px; border-radius:50%;
    background:linear-gradient(145deg,#EEAF61,#FB9062 60%,#EE5D6C);
    display:flex; align-items:center; justify-content:center;
    font-size:2rem; font-weight:800; color:#fff;
    box-shadow:0 6px 20px rgba(255,139,122,.35);
    flex-shrink:0;
  }
  .profile-info h2{ margin:0 0 4px; font-size:1.4rem; font-weight:700; }
  .profile-info .user-email{ margin:0 0 8px; color:rgba(255,255,255,.7); }
  .user-role{
    display:inline-block; padding:6px 12px; border-radius:9999px;
    background:linear-gradient(90deg,#FB9062,#EE5D6C);
    font-size:.875rem; font-weight:700; color:#fff;
  }

  .profile-stats{
    display:grid; grid-template-columns: repeat(3,1fr);
    gap:12px; margin-bottom:14px;
  }
  .stat-item{
    background: rgba(255,255,255,.05);
    border:1px solid rgba(255,139,122,.18);
    border-radius:12px; padding:16px; text-align:center;
    transition:.2s;
  }
  .stat-item:hover{ border-color:rgba(255,139,122,.38); transform: translateY(-2px); }
  .stat-number{ font-family:'Noto Serif KR',serif; font-weight:800; font-size:1.4rem; color:#FB9062; }
  .stat-label{ color:rgba(255,255,255,.7); }

  .profile-actions{ display:flex; gap:10px; }
  .btn{
    flex:1; padding:12px 16px; border-radius:10px; font-weight:700; text-align:center; text-decoration:none; transition:.2s;
  }
  .btn-primary{ background:linear-gradient(135deg,#EE5D6C,#FB9062); color:#fff; }
  .btn-primary:hover{ filter:brightness(1.1); }
  .btn-secondary{ background:rgba(255,255,255,.08); color:#fff; border:1px solid rgba(255,139,122,.25); }
  .btn-secondary:hover{ background:rgba(255,139,122,.18); border-color:rgba(255,139,122,.45); }

  /* ───────── 콘텐츠 레이아웃 ───────── */
  .content-grid{ display:grid; grid-template-columns: 1fr; gap:24px; }
  .content-section{
    background: linear-gradient(145deg, rgba(30,24,22,.82), rgba(20,16,14,.82));
    border:1px solid rgba(255,139,122,.18);
    border-radius:14px; padding:22px; box-shadow:0 6px 18px rgba(0,0,0,.28);
  }

  /* 통계 요약(총합) */
  .stats-summary{
    display:grid; grid-template-columns: repeat(auto-fit, minmax(200px,1fr));
    gap:16px;
  }
  .stat-box{
    text-align:center; padding:22px 18px;
    background: rgba(255,255,255,.05);
    border:1px solid rgba(255,139,122,.20);
    border-radius:12px; transition:.2s; position:relative; overflow:hidden;
  }
  .stat-box::before{
    content:""; position:absolute; top:0; left:0; right:0; height:3px;
    background:linear-gradient(90deg,#EEAF61,#FB9062,#EE5D6C);
    transform:scaleX(0); transform-origin:left; transition:.25s;
  }
  .stat-box:hover{ transform: translateY(-2px); border-color: rgba(255,139,122,.4); }
  .stat-box:hover::before{ transform:scaleX(1); }
  .stat-box .number{ font-family:'Noto Serif KR',serif; font-size:1.8rem; font-weight:800; color:#FB9062; }
  .stat-box .label{ color:rgba(255,255,255,.72); }

  /* 탭 */
  .tab-list{ display:flex; gap:8px; border-bottom:1px solid rgba(255,139,122,.22); margin-bottom:18px; }
  .tab-button{
    padding:12px 16px; background:transparent; border:none; border-bottom:3px solid transparent;
    cursor:pointer; font-size:15px; font-weight:800; color:rgba(255,255,255,.58); transition:.2s;
  }
  .tab-button[data-tab="posts"]::before{ content:"📝"; margin-right:8px; }
  .tab-button[data-tab="comments"]::before{ content:"💬"; margin-right:8px; }
  .tab-button:hover{ color:#FB9062; }
  .tab-button.active{ color:#FB9062; border-bottom-color:#FB9062; }
  .tab-content{ display:none; }
  .tab-content.active{ display:block; }

  /* 리스트 공통 */
  .post-list, .comment-list{ list-style:none; padding:0; margin:0; }
  .post-item, .comment-item{
    padding:16px 12px; border-bottom:1px solid rgba(255,255,255,.08);
    display:flex; justify-content:space-between; gap:14px; border-radius:8px; transition:.2s;
    animation: fadeInUp .22s ease-out both;
  }
  .post-item:hover, .comment-item:hover{ background:rgba(255,139,122,.08); border-color:rgba(255,139,122,.2); transform: translateX(2px); }
  .item-content{ flex:1; min-width:0; }
  .post-title{ color:#fff; font-weight:700; font-size:1.02rem; display:block; line-height:1.5; }
  .post-title:hover{ color:#FB9062; }
  .comment-text{ color:rgba(255,255,255,.9); line-height:1.6; font-size:15px; }
  .post-meta, .comment-meta{ color:rgba(255,255,255,.6); font-size:.9rem; margin-top:6px; display:flex; gap:12px; }
  .post-meta::before{ content:"👁️"; }
  .comment-meta::before{ content:"📅"; }

  /* 액션 버튼 */
  .item-actions{ display:flex; gap:8px; flex-shrink:0; }
  .btn-small{
    padding:8px 12px; font-size:14px; border:none; border-radius:8px; cursor:pointer;
    text-decoration:none; font-weight:700; transition:.2s; white-space:nowrap;
    background: linear-gradient(135deg,#EE5D6C,#FB9062); color:#fff;
    box-shadow:0 2px 8px rgba(255,107,107,.3);
  }
  .btn-small::before{ content:"👁️ "; }
  .btn-small:hover{ filter:brightness(1.08); transform: translateY(-1px); }

  /* 페이지네이션 */
  .pagination{
    display:flex; justify-content:center; align-items:center; gap:8px;
    margin-top:22px; padding-top:16px; border-top:1px solid rgba(255,139,122,.15);
  }
  .pagination button{
    padding:10px 14px; border:1px solid rgba(255,139,122,.25);
    background: rgba(255,255,255,.08); color:#fff; border-radius:8px;
    cursor:pointer; font-size:14px; font-weight:700; transition:.2s;
  }
  .pagination button:hover:not(:disabled){ background:rgba(255,139,122,.2); border-color:rgba(255,139,122,.45); transform: translateY(-1px); }
  .pagination button:disabled{ opacity:.35; cursor:not-allowed; }
  .pagination .current-page{ padding:10px 18px; font-weight:800; color:#FB9062; }

  /* 로딩/빈 상태 */
  .empty-message, .loading{
    text-align:center; padding:48px 18px; color:rgba(255,255,255,.6);
    background: rgba(255,255,255,.05); border:2px dashed rgba(255,255,255,.12); border-radius:12px;
  }
  .loading{ color:#FB9062; animation:pulse 2s ease-in-out infinite; }
  .loading::before{ content:"⏳"; display:block; font-size:2.6rem; margin-bottom:8px; }
  @keyframes pulse{ 0%,100%{opacity:.6;} 50%{opacity:1;} }
  @keyframes fadeInUp{ from{opacity:0; transform:translateY(12px);} to{opacity:1; transform:translateY(0);} }

  /* 반응형 */
  @media (max-width:768px){
    .main.grid-14x5{ padding:16px; }
    .profile-stats{ grid-template-columns:1fr; }
    .profile-actions{ flex-direction:column; }
    .tab-list{ flex-direction:column; gap:0; border-bottom:none; }
    .tab-button{ padding:12px 14px; border-bottom:1px solid rgba(255,255,255,.08); border-left:3px solid transparent; }
    .tab-button.active{ background:rgba(255,139,122,.08); border-left-color:#FB9062; }
    .post-item, .comment-item{ flex-direction:column; }
    .item-actions{ width:100%; }
    .item-actions .btn-small{ flex:1; text-align:center; }
  }
  </style>
</head>
<body>

  <jsp:include page="/WEB-INF/include/header.jsp" />

  <main class="main grid-14x5">
    <div class="slot-nav"><jsp:include page="/WEB-INF/include/nav.jsp" /></div>

    <div class="slot-board">

      <!-- 상단 프로필 카드 -->
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
            <div class="stat-number" id="joinDate">
              <c:choose>
                <c:when test="${not empty user.createdAt}">
                  <span data-year="${user.createdAt.year}" 
                        data-month="${user.createdAt.monthValue}" 
                        data-day="${user.createdAt.dayOfMonth}"></span>
                </c:when>
                <c:otherwise>-</c:otherwise>
              </c:choose>
            </div>
            <div class="stat-label">가입일</div>
          </div>
        </div>

        <div class="profile-actions">
          <a href="${ctx}/users/myInfoEdit" class="btn btn-primary">내 정보 수정</a>
          <a href="${ctx}/users/myActivity" class="btn btn-secondary">내 활동 내역</a>
        </div>
      </div>

      <!-- 하단 콘텐츠 -->
      <div class="content-grid">

        <!-- 통계 요약 -->
        <div class="content-section">
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
        </div>

        <!-- 탭 영역 -->
        <div class="content-section">
          <div class="tab-list">
            <button class="tab-button active" data-tab="posts">내가 쓴 게시글</button>
            <button class="tab-button" data-tab="comments">내가 쓴 댓글</button>
          </div>

          <!-- 게시글 탭 -->
          <div class="tab-content active" id="posts-tab">
            <div id="postsContainer" class="loading">불러오는 중...</div>
            <div class="pagination" id="postsPagination" style="display:none;">
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
            <div class="pagination" id="commentsPagination" style="display:none;">
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
    const ITEMS_PER_PAGE = 10;
    let postsCurrentPage = 1, commentsCurrentPage = 1;
    let totalPostsData = [], totalCommentsData = [];

    $(function() {
      formatJoinDate();
      loadUserStats();
      loadAllPosts();
      loadAllComments();

      $('.tab-button').on('click', function(){
        const tab = $(this).data('tab');
        $('.tab-button').removeClass('active');
        $(this).addClass('active');
        $('.tab-content').removeClass('active');
        $('#' + tab + '-tab').addClass('active');
      });

      // 게시글 페이지네이션
      $('#postsFirstPage').on('click', () => goToPostsPage(1));
      $('#postsPrevPage').on('click', () => goToPostsPage(postsCurrentPage - 1));
      $('#postsNextPage').on('click', () => goToPostsPage(postsCurrentPage + 1));
      $('#postsLastPage').on('click', () => goToPostsPage(Math.ceil(totalPostsData.length / ITEMS_PER_PAGE)));

      // 댓글 페이지네이션
      $('#commentsFirstPage').on('click', () => goToCommentsPage(1));
      $('#commentsPrevPage').on('click', () => goToCommentsPage(commentsCurrentPage - 1));
      $('#commentsNextPage').on('click', () => goToCommentsPage(commentsCurrentPage + 1));
      $('#commentsLastPage').on('click', () => goToCommentsPage(Math.ceil(totalCommentsData.length / ITEMS_PER_PAGE)));
    });

    // 가입일 포맷팅
    function formatJoinDate() {
      const $joinDate = $('#joinDate span');
      if ($joinDate.length > 0) {
        const year = $joinDate.data('year');
        const month = String($joinDate.data('month')).padStart(2, '0');
        const day = String($joinDate.data('day')).padStart(2, '0');
        $joinDate.parent().text(year + '.' + month + '.' + day);
      }
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

    // 공통 함수
    function escapeHtml(text){ 
      if(!text) return ''; 
      const map={'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}; 
      return String(text).replace(/[&<>"']/g,m=>map[m]); 
    }
    
    function formatDate(d){
      if(!d) return '';
      if(Array.isArray(d)&&d.length>=3){ 
        const y=d[0], m=String(d[1]).padStart(2,'0'), day=String(d[2]).padStart(2,'0'); 
        return y + '.' + m + '.' + day; 
      }
      if(typeof d==='string'){ 
        const dt=new Date(d); 
        if(!isNaN(dt)) return dt.getFullYear() + '.' + String(dt.getMonth()+1).padStart(2,'0') + '.' + String(dt.getDate()).padStart(2,'0'); 
      }
      return '';
    }

    // 게시글 관련
    function loadAllPosts(){
      $.ajax({ url: CTX + '/users/ajax/allPosts', type:'GET', dataType:'json', cache:false })
        .done(data => { 
          totalPostsData = Array.isArray(data)? data : []; 
          $('#totalPosts').text(totalPostsData.length); 
          renderPosts(); 
        })
        .fail(jq => handleFail('#postsContainer', jq));
    }

    function renderPosts(){
      const $container = $('#postsContainer');
      if(totalPostsData.length===0){ 
        $container.html('<p class="empty-message">작성한 게시글이 없습니다.</p>'); 
        $('#postsPagination').hide(); 
        return; 
      }
      const start=(postsCurrentPage-1)*ITEMS_PER_PAGE, end=start+ITEMS_PER_PAGE, pageData=totalPostsData.slice(start,end);
      let html='<ul class="post-list">';
      pageData.forEach(post=>{
        const postUrl = CTX + '/post-detail.post?postId=' + post.postId + (post.listId ? '&listId=' + post.listId : '');
        html += '<li class="post-item">';
        html += '<div class="item-content">';
        html += '<a class="post-title" href="' + postUrl + '">' + escapeHtml(post.title||'제목 없음') + '</a>';
        html += '<div class="post-meta">조회 ' + (post.hit||0) + ' · ' + formatDate(post.createdAt) + '</div>';
        html += '</div>';
        html += '<div class="item-actions"><a class="btn-small" href="' + postUrl + '">보기</a></div>';
        html += '</li>';
      });
      html+='</ul>';
      $container.html(html);
      updatePostsPagination();
    }

    function updatePostsPagination(){
      const totalPages = Math.ceil(totalPostsData.length/ITEMS_PER_PAGE);
      if(totalPages<=1){ $('#postsPagination').hide(); return; }
      $('#postsPagination').show();
      $('#postsCurrentPage').text(postsCurrentPage + ' / ' + totalPages);
      $('#postsFirstPage, #postsPrevPage').prop('disabled', postsCurrentPage===1);
      $('#postsNextPage, #postsLastPage').prop('disabled', postsCurrentPage===totalPages);
    }

    function goToPostsPage(page){
      const totalPages = Math.ceil(totalPostsData.length/ITEMS_PER_PAGE);
      if(page<1 || page>totalPages) return;
      postsCurrentPage = page; 
      renderPosts();
      $('html, body').animate({ scrollTop: $('#posts-tab').offset().top - 64 }, 250);
    }

    // 댓글 관련
    function loadAllComments(){
      $.ajax({ url: CTX + '/users/ajax/allComments', type:'GET', dataType:'json', cache:false })
        .done(data => { 
          totalCommentsData = Array.isArray(data)? data : []; 
          $('#totalComments').text(totalCommentsData.length); 
          renderComments(); 
        })
        .fail(jq => handleFail('#commentsContainer', jq));
    }

    function extractTextFromTipTap(doc){
      if(!doc) return ''; 
      let text=''; 
      (function walk(n){ 
        if(!n) return; 
        if(n.type==='text'&&n.text) text+=n.text; 
        if(n.type==='image') text+='[이미지] '; 
        if(Array.isArray(n.content)){ 
          n.content.forEach(walk); 
          if(n.type==='paragraph') text+=' '; 
        } 
      })(doc); 
      return text.trim();
    }

    function extractTextFromComment(raw){
      if(!raw) return '';
      try{ 
        let outer=typeof raw==='string'? JSON.parse(raw):raw; 
        let inner=typeof outer.text==='string'? JSON.parse(outer.text) : (outer.text||outer.contentJson||outer); 
        return extractTextFromTipTap(inner); 
      }
      catch(e){ 
        try{ 
          const m=String(raw).match(/"text":"([^"]+)"/); 
          if(m&&m[1]) return m[1].replace(/\\n/g,' ').replace(/\\"/g,'"').replace(/\\\\/g,'\\'); 
        }catch(_){} 
        return '(내용을 불러올 수 없습니다)'; 
      }
    }

    function renderComments(){
      const $container = $('#commentsContainer');
      if(totalCommentsData.length===0){ 
        $container.html('<p class="empty-message">작성한 댓글이 없습니다.</p>'); 
        $('#commentsPagination').hide(); 
        return; 
      }
      const start=(commentsCurrentPage-1)*ITEMS_PER_PAGE, end=start+ITEMS_PER_PAGE, pageData=totalCommentsData.slice(start,end);
      let html='<ul class="comment-list">';
      pageData.forEach(c=>{
        const txt = extractTextFromComment(c.contentRaw||c.content||'');
        const display = txt.length>200? (txt.substring(0,200)+'...') : txt;
        const url = CTX + '/post-detail.post?postId=' + c.postId + (c.listId ? '&listId=' + c.listId : '') + '#comment-' + c.commentId;
        html += '<li class="comment-item">';
        html += '<div class="item-content">';
        html += '<div class="comment-text">' + escapeHtml(display||'(내용 없음)') + '</div>';
        html += '<div class="comment-meta">' + formatDate(c.createdAt) + '</div>';
        html += '</div>';
        html += '<div class="item-actions"><a class="btn-small" href="' + url + '">보기</a></div>';
        html += '</li>';
      });
      html+='</ul>';
      $container.html(html);
      updateCommentsPagination();
    }

    function updateCommentsPagination(){
      const totalPages = Math.ceil(totalCommentsData.length/ITEMS_PER_PAGE);
      if(totalPages<=1){ $('#commentsPagination').hide(); return; }
      $('#commentsPagination').show();
      $('#commentsCurrentPage').text(commentsCurrentPage + ' / ' + totalPages);
      $('#commentsFirstPage, #commentsPrevPage').prop('disabled', commentsCurrentPage===1);
      $('#commentsNextPage, #commentsLastPage').prop('disabled', commentsCurrentPage===totalPages);
    }

    function goToCommentsPage(page){
      const totalPages = Math.ceil(totalCommentsData.length/ITEMS_PER_PAGE);
      if(page<1 || page>totalPages) return;
      commentsCurrentPage = page; 
      renderComments();
      $('html, body').animate({ scrollTop: $('#comments-tab').offset().top - 64 }, 250);
    }

    function handleFail(target, jqXHR){
      if(jqXHR && jqXHR.status===401){ 
        window.location.href = CTX + '/users/login?error=session_expired'; 
      }
      else { 
        $(target).html('<p class="empty-message">데이터를 불러올 수 없습니다.</p>'); 
      }
    }
  </script>
</body>
</html>