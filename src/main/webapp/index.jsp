<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>노을 맛집 - 홈</title>
  <link rel="icon" href="<%=request.getContextPath()%>/images/favicon.ico?v=1">

  <style>
    /* ====== Top10 Hero Slider (scoped to .slot-board) ====== */
    .slot-board .hero-slider{ position:relative; border-radius:16px; overflow:hidden; background:#111; box-shadow:0 8px 24px rgba(0,0,0,.08); }
    .slot-board .hs-viewport{ position:relative; width:100%; aspect-ratio: 16/9; overflow:hidden; }
    .slot-board .hs-track{ display:flex; width:100%; height:100%; transform:translate3d(0,0,0); transition:transform .45s ease; will-change:transform; margin:0; padding:0; list-style:none; }
    .slot-board .hs-slide{ flex:0 0 100%; height:100%; position:relative; }
    .slot-board .hs-link{ display:block; width:100%; height:100%; color:inherit; text-decoration:none; }
    .slot-board .hs-figure{ position:relative; width:100%; height:100%; margin:0; }
    .slot-board .hs-img{ width:100%; height:100%; object-fit:cover; display:block; }
    .slot-board .hs-overlay{ position:absolute; inset:0; background:
      linear-gradient(180deg, rgba(0,0,0,0) 40%, rgba(0,0,0,.55) 100%),
      linear-gradient(90deg, rgba(0,0,0,.35) 0%, rgba(0,0,0,0) 40%); }
    .slot-board .hs-caption{ position:absolute; left:20px; right:20px; bottom:18px; color:#fff; }
    .slot-board .hs-chip{ display:inline-block; padding:6px 10px; font-weight:700; border-radius:9999px; background:rgba(0,0,0,.5); border:1px solid rgba(255,255,255,.25); margin-bottom:8px; }
    .slot-board .hs-chip.is-map{ margin-left:6px; background:rgba(31,122,31,.6); border-color:rgba(255,255,255,.25); }
    .slot-board .hs-title{ margin:0 0 6px 0; font-size:1.35rem; line-height:1.35; letter-spacing:-0.01em; text-shadow:0 2px 8px rgba(0,0,0,.35); }
    .slot-board .hs-meta{ margin:0; opacity:.85; font-size:.95rem; }
    .slot-board .hs-nav{ position:absolute; top:50%; transform:translateY(-50%); z-index:3; width:42px; height:42px; border-radius:50%; border:1px solid rgba(255,255,255,.35);
      background:rgba(0,0,0,.25); color:#fff; display:flex; align-items:center; justify-content:center; cursor:pointer; }
    .slot-board .hs-prev{ left:10px; } .slot-board .hs-next{ right:10px; }
    .slot-board .hs-nav:hover{ background:rgba(0,0,0,.4); }
    .slot-board .hs-dots{ position:absolute; left:0; right:0; bottom:8px; display:flex; gap:6px; justify-content:center; list-style:none; margin:0; padding:0; z-index:3; }
    .slot-board .hs-dots button{ width:8px; height:8px; border-radius:50%; border:none; background:rgba(255,255,255,.45); cursor:pointer; }
    .slot-board .hs-dots .is-active button{ background:#fff; }
    .slot-board .hs-empty{ padding:20px; text-align:center; color:#555; background:#fafafa; border:1px dashed #e5e5e5; border-radius:12px; }

    /* ====== 이미지가 없을 때: 본문을 흐릿 배경으로 ====== */
    .slot-board .hs-textposter{ position:relative; width:100%; height:100%; background:
      radial-gradient(120% 120% at 80% 10%, rgba(255,255,255,.10) 0%, rgba(255,255,255,0) 60%),
      linear-gradient(180deg, #2f2b27 0%, #1f1b18 100%); }
    .slot-board .hs-textbg{ position:absolute; inset:0; padding:28px; color:#fff; font-weight:700;
      font-size:clamp(16px, 2.8vw, 22px); line-height:1.6; white-space:pre-line; overflow:hidden;
      opacity:.28; filter:blur(6px); }
    .slot-board .hs-textposter .hs-overlay{ position:absolute; inset:0;
      background:linear-gradient(180deg, rgba(0,0,0,0) 30%, rgba(0,0,0,.55) 100%); }

    @media (max-width: 720px){
      .slot-board .hs-title{ font-size:1.05rem; }
      .slot-board .hs-meta{ font-size:.85rem; }
    }
  </style>
</head>

<body>
  <!-- 전역 레이아웃 유지 -->
  <jsp:include page="/WEB-INF/include/header.jsp" />

  <main class="main grid-14x5">
    <div class="slot-nav">
      <jsp:include page="/WEB-INF/include/nav.jsp" />
    </div>

    <div class="slot-board">
      <h1 style="margin:0 0 16px 0;">인기 Top10</h1>

      <section class="hero-slider" id="top10-root">
        <div class="hs-viewport">
          <ul class="hs-track" id="hsTrack"><!-- JS 렌더 --></ul>
        </div>
        <button class="hs-nav hs-prev" id="hsPrev" aria-label="이전">‹</button>
        <button class="hs-nav hs-next" id="hsNext" aria-label="다음">›</button>
        <ol class="hs-dots" id="hsDots"></ol>
      </section>

      <div id="top10-fallback" class="hs-empty" style="display:none;">인기 글을 불러오는 중입니다…</div>
    </div>

    <div class="slot-extra"></div>
  </main>

  <script>
  (function(){
    const contextPath = "<%= request.getContextPath() %>/";
    const API_URL     = contextPath + "postList2.async";
    const POST_DETAIL = contextPath + "post-detail.post";
    const LIMIT       = 10;
    const AUTOPLAY_MS = 4500;

    const track = document.getElementById('hsTrack');
    const dots  = document.getElementById('hsDots');
    const prev  = document.getElementById('hsPrev');
    const next  = document.getElementById('hsNext');
    const fb    = document.getElementById('top10-fallback');

    let slides = [];
    let index  = 0;
    let timer  = null;

    // ===== 이미지 추출(노을 앨범과 동일 로직) — 없으면 null을 반환 =====
    function pickThumb(p){
      if (p && (p.thumbnail || p.thumb || p.imageSrc || p.imageUrl)) return p.thumbnail || p.thumb || p.imageSrc || p.imageUrl;
      const list = (p && (p.images || p.imageList || p.image_list)) || [];
      if (Array.isArray(list) && list.length){
        const i0 = list[0] || {};
        return i0.imageSrc || i0.src || i0.url || null;
      }
      const c = p && p.content;
      if (!c) return null;
      if (typeof c === 'string' && /<img/i.test(c)){
        const m = c.match(/<img[^>]+src=["']([^"']+)["']/i);
        return (m && m[1]) ? m[1] : null;
      }
      try{
        const json = (typeof c === 'object') ? c : JSON.parse(c);
        let found=null;
        (function walk(node){
          if (found) return;
          if (Array.isArray(node)) { node.forEach(walk); return; }
          if (node && typeof node === 'object'){
            if (node.type === 'image' && node.attrs && node.attrs.src) { found=node.attrs.src; return; }
            if (node.content) walk(node.content);
          }
        })(json);
        return found;
      }catch(_){ return null; }
    }

    // ===== 본문 텍스트 추출(HTML/TipTap 모두 대응) =====
    function getTextSnippet(p, maxLen){
      const c = p && p.content;
      if (!c) return '';
      let text = '';
      if (typeof c === 'string'){
        // HTML 태그 제거
        text = c.replace(/<style[\s\S]*?<\/style>/gi,'')
                .replace(/<script[\s\S]*?<\/script>/gi,'')
                .replace(/<[^>]+>/g,' ')
                .replace(/\s+/g,' ')
                .trim();
      }else{
        try{
          const json = c;
          let buf = [];
          (function walk(node){
            if (Array.isArray(node)){ node.forEach(walk); return; }
            if (!node || typeof node !== 'object') return;
            if (node.type === 'text' && node.text) buf.push(node.text);
            if (node.content) walk(node.content);
          })(json);
          text = buf.join(' ').replace(/\s+/g,' ').trim();
        }catch(_){ text = ''; }
      }
      if (!text) return '';
      if (text.length > (maxLen||180)) return text.substring(0, maxLen||180) + '…';
      return text;
    }

    // ===== 지도 포함 판단(있으면 배지 표시) =====
    function hasMap(p){
      if (!p) return false;
      if ((p.maps && p.maps.length) || (p.mapList && p.mapList.length)) return true;
      const c = p.content;
      if (!c) return false;
      if (typeof c === 'string') return /kakao|map|lat|lng|latitude|longitude/i.test(c);
      try{
        let found=false;
        (function walk(node){
          if (found) return;
          if (Array.isArray(node)){ node.forEach(walk); return; }
          if (!node || typeof node !== 'object') return;
          if (node.type && /map|place|location/i.test(node.type)) { found=true; return; }
          if (node.attrs && (node.attrs.lat || node.attrs.lng || node.attrs.latitude || node.attrs.longitude)) { found=true; return; }
          if (node.content) walk(node.content);
        })(c);
        return found;
      }catch(_){ return false; }
    }

    function esc(s){ return (s==null?'':String(s))
      .replace(/&/g,'&amp;').replace(/</g,'&lt;')
      .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;') }

    function detailUrl(p){
      const id  = p.postId || p.id;
      const cid = p.categoryId || '';
      const tid = p.postTypeId || '';
      let url = POST_DETAIL + "?postId=" + encodeURIComponent(id);
      if (cid) url += "&categoryId=" + encodeURIComponent(cid);
      if (tid) url += "&postTypeId=" + encodeURIComponent(tid);
      return url;
    }

    function render(){
      const FALLBACK_TITLE = '제목 없음';
      if (!slides.length){
        fb.style.display = "";
        fb.textContent = "표시할 인기 글이 없습니다.";
        return;
      }
      fb.style.display = "none";

      track.innerHTML = slides.map(p => {
        const img   = pickThumb(p);                 // 존재하면 이미지
        const text  = getTextSnippet(p, 220);       // 이미지가 없을 때 흐릿하게
        const cat   = esc(p.category || "카테고리");
        const ttl   = esc(p.title || FALLBACK_TITLE);
        const hit   = (p.hit != null ? p.hit : 0);
        const href  = detailUrl(p);
        const mapYN = hasMap(p);

        if (img){
          return `
            <li class="hs-slide">
              <a class="hs-link" href="${href}">
                <figure class="hs-figure">
                  <img class="hs-img" src="${img}" alt="${ttl}">
                  <div class="hs-overlay"></div>
                  <figcaption class="hs-caption">
                    <span class="hs-chip">${cat}</span>${mapYN?'<span class="hs-chip is-map">지도</span>':''}
                    <h3 class="hs-title">${ttl}</h3>
                    <p class="hs-meta">👁️ ${hit} views</p>
                  </figcaption>
                </figure>
              </a>
            </li>`;
        } else if (text){
          /* 이미지가 없으면: 본문을 흐릿 배경으로 */
          return `
            <li class="hs-slide">
              <a class="hs-link" href="${href}">
                <figure class="hs-figure hs-textposter">
                  <div class="hs-textbg" aria-hidden="true">${esc(text)}</div>
                  <div class="hs-overlay"></div>
                  <figcaption class="hs-caption">
                    <span class="hs-chip">${cat}</span>${mapYN?'<span class="hs-chip is-map">지도</span>':''}
                    <h3 class="hs-title">${ttl}</h3>
                    <p class="hs-meta">👁️ ${hit} views</p>
                  </figcaption>
                </figure>
              </a>
            </li>`;
        } else {
          /* 텍스트도 없으면: 아주 간단한 컬러 배경만 */
          return `
            <li class="hs-slide">
              <a class="hs-link" href="${href}">
                <figure class="hs-figure hs-textposter">
                  <div class="hs-overlay"></div>
                  <figcaption class="hs-caption">
                    <span class="hs-chip">${cat}</span>${mapYN?'<span class="hs-chip is-map">지도</span>':''}
                    <h3 class="hs-title">${ttl}</h3>
                    <p class="hs-meta">👁️ ${hit} views</p>
                  </figcaption>
                </figure>
              </a>
            </li>`;
        }
      }).join('');

      dots.innerHTML = slides.map((_,i)=>`<li ${i===index?'class="is-active"':''}><button type="button" data-idx="${i}" aria-label="${i+1}번 슬라이드"></button></li>`).join('');
      moveTo(index, false);
      dots.querySelectorAll('button[data-idx]').forEach(btn=>{
        btn.addEventListener('click', ()=>{ moveTo(Number(btn.dataset.idx)||0, true); });
      });
    }

    function moveTo(i, withStop){
      if (!slides.length) return;
      index = (i+slides.length)%slides.length;
      track.style.transform = `translate3d(${-index*100}%,0,0)`;
      dots.querySelectorAll('li').forEach((li,idx)=>{
        if (idx===index) li.classList.add('is-active'); else li.classList.remove('is-active');
      });
      if (withStop) restartAutoplay();
    }

    function nextSlide(){ moveTo(index+1, false); }
    function prevSlide(){ moveTo(index-1, false); }
    function startAutoplay(){ stopAutoplay(); timer = setInterval(nextSlide, AUTOPLAY_MS); }
    function stopAutoplay(){ if (timer){ clearInterval(timer); timer=null; } }
    function restartAutoplay(){ startAutoplay(); }

    document.getElementById('top10-root').addEventListener('mouseenter', stopAutoplay);
    document.getElementById('top10-root').addEventListener('mouseleave', startAutoplay);
    document.getElementById('hsPrev').addEventListener('click', ()=>{ prevSlide(); restartAutoplay(); });
    document.getElementById('hsNext').addEventListener('click', ()=>{ nextSlide(); restartAutoplay(); });
    document.addEventListener('visibilitychange', ()=>{ document.hidden ? stopAutoplay() : startAutoplay(); });

    async function loadTop10(){
      fb.style.display = "";
      fb.textContent = "인기 글을 불러오는 중입니다…";
      const url = new URL(API_URL, location.origin);
      url.searchParams.set('sort','views'); // 조회수순
      url.searchParams.set('limit', String(LIMIT));
      url.searchParams.set('page','1');
      try{
        const res = await fetch(url.toString(), { headers: { 'X-Requested-With': 'fetch' }});
        if(!res.ok) throw new Error('HTTP '+res.status);
        const json = await res.json();
        const list = json.posts || json.items || json.list || json.data || [];
        slides = Array.isArray(list) ? list.slice(0, LIMIT) : [];
        render();
        startAutoplay();
      }catch(err){
        console.error(err);
        fb.style.display = "";
        fb.textContent = "인기 글을 불러오지 못했습니다.";
      }
    }

    loadTop10();
  })();
  </script>
</body>
</html>
