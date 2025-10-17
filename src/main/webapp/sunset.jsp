<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>노을 맛집 - 노을 앨범</title>

  <!-- 공통/그리드 CSS -->
  <link rel="stylesheet" href="<c:url value='/css/style.css'/>?v=6" />
  <link rel="stylesheet" href="<c:url value='/css/post-grid.css'/>?v=1" />
  <link rel="icon" href="<c:url value='/images/favicon.ico'/>?v=1">

  <style>
    /* post-grid.css가 전역 스타일에 덮이지 않도록 최소 보정 */
    .pg-grid{ list-style:none; margin:0; padding:0; }
  </style>
</head>
<body>

<jsp:include page="/WEB-INF/include/header.jsp" />

<main class="main grid-14x5">
  <!-- 좌측: 네비 -->
  <div class="slot-nav">
    <jsp:include page="/WEB-INF/include/nav.jsp">
      <jsp:param name="openAcc" value="acc-sunset"/>
    </jsp:include>
  </div>

  <!-- 가운데: 보드 -->
  <div id="board" class="slot-board pg-scope">
    <!-- 상단 툴바 -->
    <div class="pg-toolbar">
      <h1 class="pg-h1">노을 앨범</h1>
      <div style="margin-left:auto; display:flex; gap:10px;">
        <!-- 정렬 -->
        <form id="sunset-sort" style="display:flex; gap:8px; align-items:center;" onsubmit="return false;">
          <label for="sort" style="font-weight:600;">정렬</label>
          <select id="sort" name="sort" style="padding:8px 10px; border:1px solid #e5e7eb; border-radius:8px;">
            <option value="new" ${param.sort == 'new' || empty param.sort ? 'selected' : ''}>최신순</option>
            <option value="old" ${param.sort == 'old' ? 'selected' : ''}>오래된순</option>
            <option value="hit" ${param.sort == 'hit' ? 'selected' : ''}>조회수순</option>
          </select>
        </form>
        <!-- 글쓰기 -->
        <a href="<c:url value='/editor.post'/>" class="pg-write-btn">글쓰기</a>
      </div>
    </div>

    <!-- 앨범(그리드) 리스트 -->
    <div id="album-root">
      <div class="pg-empty"><p>목록을 불러오는 중입니다…</p></div>
    </div>
  </div>

  <div class="slot-extra"></div>
</main>

<script>
(function(){
  // ===== 설정값 =====
  var API_URL         = '<c:url value="/postList.async"/>';
  var POST_DETAIL_URL = '<c:url value="/post-detail.post"/>';
  var CATEGORY_ID     = 1;     // 노을(고정)
  var CLIENT_LIMIT    = 12;    // 화면당 카드 수(그리드)
  var SERVER_LIMIT    = 100;   // 서버에서 한 번에 크게 가져오기(호출 최소화)
  var FALLBACK_IMG    = '<c:url value="/images/missing.jpg"/>';

  // ===== DOM =====
  var root    = document.getElementById('album-root');
  var sortSel = document.getElementById('sort');

  // ===== 상태 =====
  var STATE = {
    sort: 'new',
    clientPage: 1,
    filtered: [],      // 노을만 모아둔 전체 목록(정렬 반영된 상태)
    totalPages: 1
  };

  // ===== 유틸 =====
  function getParam(name, def){
    try{
      var u = new URL(location.href);
      return u.searchParams.get(name) || def;
    }catch(_){ return def; }
  }

  function escapeHtml(s){
    if(s == null) return '';
    return String(s)
      .replace(/&/g,'&amp;').replace(/</g,'&lt;')
      .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
  }

  // 서버 정렬 파라미터로 변환(ALL.jsp와 동일 계열)
  function mapSortForServer(s){
    switch(s){
      case 'new': return 'newest';
      case 'old': return 'oldest';
      case 'hit': return 'views';
      case 'cmt': return 'comments'; // 백엔드 미지원이면 newest로 동작할 수 있음
      default:    return 'newest';
    }
  }

  // 서버 호출 URL(카테고리 필터링은 백엔드가 무시해도 되고, 우리는 프론트에서 다시 걸러냄)
  function buildServerUrl(page, sort){
    var u = new URL(API_URL, location.origin);
    // 백엔드가 혹시 지원한다면…(무시해도 무해)
    u.searchParams.set('categoryId', String(CATEGORY_ID));
    u.searchParams.set('categoryName', '노을');

    u.searchParams.set('page',  String(page));
    u.searchParams.set('limit', String(SERVER_LIMIT));
    u.searchParams.set('sort',  mapSortForServer(sort));
    u.searchParams.set('_ts', Date.now()); // 캐시 회피
    return u.toString();
  }

  // 노을 카테고리 판정(서버 응답키 다양성 대비)
  function isSunset(post){
    if (!post) return false;
    if (post.categoryId == CATEGORY_ID || post.category_id == CATEGORY_ID) return true;
    if ((post.category||'').trim() === '노을') return true;
    // listId/타 조합이 있을 수도 있지만, 일단 위 기준이면 충분
    return false;
  }

  // 대표 이미지(첫 이미지) 추출
  function pickThumb(p){
    if (p && (p.thumbnail || p.thumb || p.imageSrc || p.imageUrl)) {
      return p.thumbnail || p.thumb || p.imageSrc || p.imageUrl;
    }
    var list = (p && (p.images || p.imageList || p.image_list)) || [];
    if (Array.isArray(list) && list.length){
      var i0 = list[0] || {};
      return i0.imageSrc || i0.src || i0.url || FALLBACK_IMG;
    }
    var c = p && p.content;
    if (!c) return FALLBACK_IMG;
    if (typeof c === 'string' && /<img/i.test(c)) {
      var m = c.match(/<img[^>]+src=["']([^"']+)["']/i);
      if (m && m[1]) return m[1];
      return FALLBACK_IMG;
    }
    try{
      var json = (typeof c === 'object') ? c : JSON.parse(c);
      var found = null;
      (function walk(node){
        if (found) return;
        if (Array.isArray(node)) { node.forEach(walk); return; }
        if (node && typeof node === 'object') {
          if (node.type === 'image' && node.attrs && node.attrs.src) {
            found = node.attrs.src; return;
          }
          if (node.content) walk(node.content);
        }
      })(json);
      return found || FALLBACK_IMG;
    }catch(_){
      return FALLBACK_IMG;
    }
  }

  // ===== 데이터 적재(모든 페이지 수집 → 노을만 필터 → 클라이언트 페이징) =====
  async function fetchAllFiltered(sort){
    // 상태/캐시 초기화
    STATE.filtered = [];
    STATE.totalPages = 1;

    // 1페이지 먼저 요청해서 총 페이지 파악
    var firstUrl = buildServerUrl(1, sort);
    var firstRes = await fetch(firstUrl, { headers: { 'X-Requested-With': 'fetch' }});
    if(!firstRes.ok) throw new Error('HTTP ' + firstRes.status);
    var firstJson = await firstRes.json();

    var itemsKey = (firstJson.items && 'items')
                || (firstJson.list && 'list')
                || (firstJson.posts && 'posts')
                || (firstJson.data && 'data');
    var firstItems = itemsKey ? firstJson[itemsKey] : [];
    var serverTotalPages = Number(firstJson.totalPages || firstJson.pageCount || firstJson.totalPage || firstJson.endPage || 1);
    if (!serverTotalPages || isNaN(serverTotalPages)) serverTotalPages = 1;

    // 필터링 적재
    if (Array.isArray(firstItems)) {
      STATE.filtered = STATE.filtered.concat(firstItems.filter(isSunset));
    }

    // 나머지 페이지 순회 적재
    for (var sp = 2; sp <= serverTotalPages; sp++){
      var url = buildServerUrl(sp, sort);
      var res = await fetch(url, { headers: { 'X-Requested-With': 'fetch' }});
      if(!res.ok) throw new Error('HTTP ' + res.status);
      var json = await res.json();
      var key = (json.items && 'items')
             || (json.list && 'list')
             || (json.posts && 'posts')
             || (json.data && 'data');
      var arr = key ? json[key] : [];
      if (Array.isArray(arr)) {
        STATE.filtered = STATE.filtered.concat(arr.filter(isSunset));
      }
    }

    // 클라이언트 페이지 수 계산
    STATE.totalPages = Math.max(1, Math.ceil(STATE.filtered.length / CLIENT_LIMIT));
  }

  // ===== 렌더링 =====
  function renderPage(page){
    page = Math.max(1, Math.min(page, STATE.totalPages));
    STATE.clientPage = page;

    var start = (page - 1) * CLIENT_LIMIT;
    var end   = start + CLIENT_LIMIT;
    var slice = STATE.filtered.slice(start, end);

    if (!slice.length){
      root.innerHTML = '<div class="pg-empty"><p>노을 앨범에 게시물이 없습니다.</p></div>';
      return;
    }

    var cards = '';
    slice.forEach(function(p){
      var id    = p.postId || p.id;
      var link  = id ? (POST_DETAIL_URL + '?postId=' + encodeURIComponent(id)) : '#';
      var thumb = pickThumb(p);
      var title = escapeHtml(p.title || '제목 없음');

      cards += ''
        + '<li class="pg-card">'
        + '  <a class="pg-card__link" href="' + link + '">'
        + '    <div class="pg-thumb">'
        + '      <img class="pg-img" src="' + thumb + '" alt="썸네일" loading="lazy" onerror="this.onerror=null; this.src=FALLBACK_IMG">'
        + '    </div>'
        + '    <div class="pg-title">' + title + '</div>'
        + '  </a>'
        + '</li>';
    });

    var pager = buildPager(STATE.clientPage, STATE.totalPages);
    root.innerHTML = '<ul class="pg-grid">' + cards + '</ul>' + pager;

    wirePagerLinks(); // 새로 그린 링크에 이벤트 연결
  }

  function buildPager(cur, total){
    if(total <= 1) return '';
    function pageItem(i, active){
      if (active) return '<li class="is-active"><span>' + i + '</span></li>';
      return '<li><a href="#" data-page="' + i + '">' + i + '</a></li>';
    }
    var html = '<nav class="pg-pagination"><ul class="pg-pages">';
    // 이전
    if (cur > 1) html += '<li class="pg-prev-block"><a href="#" data-page="' + (cur-1) + '">이전</a></li>';
    else         html += '<li class="is-disabled"><span>이전</span></li>';
    // 숫자
    for (var i=1; i<=total; i++){
      html += pageItem(i, i===cur);
    }
    // 다음
    if (cur < total) html += '<li class="pg-next-block"><a href="#" data-page="' + (cur+1) + '">다음</a></li>';
    else             html += '<li class="is-disabled"><span>다음</span></li>';

    html += '</ul></nav>';
    return html;
  }

  function wirePagerLinks(){
    var links = root.querySelectorAll('.pg-pages a[data-page]');
    links.forEach(function(a){
      a.addEventListener('click', function(e){
        e.preventDefault();
        var p = Number(a.getAttribute('data-page') || '1');
        // 주소표시줄 동기화
        var cur = new URL(location.href);
        cur.searchParams.set('page', String(p));
        cur.searchParams.set('sort', STATE.sort);
        history.replaceState({}, '', cur);
        renderPage(p);
      });
    });
  }

  // ===== 이벤트 =====
  sortSel.addEventListener('change', async function(){
    STATE.sort = sortSel.value || 'new';
    // 주소표시줄 동기화
    var cur = new URL(location.href);
    cur.searchParams.set('sort', STATE.sort);
    cur.searchParams.set('page', '1');
    history.replaceState({}, '', cur);

    // 정렬 바뀌면 서버부터 다시 싹 가져와 필터 → 렌더
    root.innerHTML = '<div class="pg-empty"><p>목록을 불러오는 중입니다…</p></div>';
    try{
      await fetchAllFiltered(STATE.sort);
      renderPage(1);
    }catch(err){
      console.error(err);
      root.innerHTML = '<div class="pg-empty"><p>목록을 불러오는 중 오류가 발생했습니다.</p></div>';
    }
  });

  // ===== 최초 로드 =====
  (async function init(){
    STATE.sort = getParam('sort', 'new');
    sortSel.value = STATE.sort;
    var initPage = Number(getParam('page', '1'));

    try{
      await fetchAllFiltered(STATE.sort);
      renderPage(initPage);
      // 주소표시줄 보정
      var cur = new URL(location.href);
      cur.searchParams.set('sort', STATE.sort);
      cur.searchParams.set('page', String(STATE.clientPage));
      history.replaceState({}, '', cur);
    }catch(err){
      console.error(err);
      root.innerHTML = '<div class="pg-empty"><p>목록을 불러오는 중 오류가 발생했습니다.</p></div>';
    }
  })();
})();
</script>

</body>
</html>