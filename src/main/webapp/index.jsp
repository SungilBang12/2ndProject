<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>노을 맛집 - 홈</title>
  <link rel="icon" href="<%=request.getContextPath()%>/images/favicon.ico?v=1">

  <style>
  /* ====== 전역 폰트 임포트 ====== */
  @import url('https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@400;600;700&family=Noto+Sans+KR:wght@300;400;500;600&display=swap');

  /* ====== Top10 Hero Slider (Sunset 테마) ====== */
  .slot-board .hero-slider {
    position: relative;
    border-radius: 20px;
    overflow: hidden;
    background: linear-gradient(135deg, #2a1f1a 0%, #1a1311 100%);
    box-shadow: 
      0 20px 60px rgba(0, 0, 0, 0.5),
      0 0 40px rgba(255, 139, 122, 0.1);
  }

  .slot-board .hs-viewport {
    position: relative;
    width: 100%;
    aspect-ratio: 16/9;
    overflow: hidden;
  }

  .slot-board .hs-track {
    display: flex;
    width: 100%;
    height: 100%;
    transform: translate3d(0, 0, 0);
    transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
    will-change: transform;
    margin: 0;
    padding: 0;
    list-style: none;
  }

  .slot-board .hs-slide {
    flex: 0 0 100%;
    height: 100%;
    position: relative;
  }

  .slot-board .hs-link {
    display: block;
    width: 100%;
    height: 100%;
    color: inherit;
    text-decoration: none;
  }

  .slot-board .hs-figure {
    position: relative;
    width: 100%;
    height: 100%;
    margin: 0;
  }

  .slot-board .hs-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }

  /* 석양 그라데이션 오버레이 */
  .slot-board .hs-overlay {
    position: absolute;
    inset: 0;
    background: 
      linear-gradient(180deg, 
        rgba(0, 0, 0, 0) 0%,
        rgba(26, 19, 17, 0.3) 50%,
        rgba(26, 19, 17, 0.85) 100%
      ),
      linear-gradient(90deg,
        rgba(255, 107, 107, 0.15) 0%,
        rgba(255, 139, 122, 0.08) 50%,
        rgba(0, 0, 0, 0) 100%
      );
  }

  .slot-board .hs-caption {
    position: absolute;
    left: 32px;
    right: 32px;
    bottom: 32px;
    color: #fff;
    z-index: 2;
  }

  /* 산호색 칩 디자인 */
  .slot-board .hs-chip {
    display: inline-block;
    padding: 8px 16px;
    font-weight: 600;
    font-size: 0.875rem;
    border-radius: 9999px;
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    border: 1px solid rgba(255, 255, 255, 0.2);
    margin-bottom: 12px;
    box-shadow: 0 2px 8px rgba(255, 107, 107, 0.3);
    letter-spacing: -0.01em;
  }

  .slot-board .hs-chip.is-map {
    margin-left: 8px;
    background: linear-gradient(135deg, #48BB78 0%, #38A169 100%);
    box-shadow: 0 2px 8px rgba(72, 187, 120, 0.3);
  }

  .slot-board .hs-title {
    margin: 0 0 10px 0;
    font-family: 'Noto Serif KR', serif;
    font-size: clamp(1.25rem, 2.5vw, 1.75rem);
    line-height: 1.4;
    letter-spacing: -0.02em;
    font-weight: 700;
    text-shadow: 
      0 2px 12px rgba(0, 0, 0, 0.5),
      0 4px 24px rgba(0, 0, 0, 0.3);
  }

  .slot-board .hs-meta {
    margin: 0;
    opacity: 0.9;
    font-size: 1rem;
    font-weight: 500;
    letter-spacing: -0.01em;
  }

  /* 산호색 네비게이션 버튼 */
  .slot-board .hs-nav {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    z-index: 3;
    width: 48px;
    height: 48px;
    border-radius: 50%;
    border: 2px solid rgba(255, 139, 122, 0.4);
    background: rgba(26, 19, 17, 0.6);
    backdrop-filter: blur(8px);
    color: #FF8B7A;
    font-size: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .slot-board .hs-prev { left: 16px; }
  .slot-board .hs-next { right: 16px; }

  .slot-board .hs-nav:hover {
    background: rgba(255, 139, 122, 0.25);
    border-color: rgba(255, 139, 122, 0.6);
    transform: translateY(-50%) scale(1.1);
    box-shadow: 0 4px 16px rgba(255, 107, 107, 0.4);
  }

  /* 점 네비게이션 */
  .slot-board .hs-dots {
    position: absolute;
    left: 0;
    right: 0;
    bottom: 12px;
    display: flex;
    gap: 8px;
    justify-content: center;
    list-style: none;
    margin: 0;
    padding: 0;
    z-index: 3;
  }

  .slot-board .hs-dots button {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    border: none;
    background: rgba(255, 255, 255, 0.4);
    cursor: pointer;
    transition: all 0.3s ease;
  }

  .slot-board .hs-dots .is-active button {
    background: #FF8B7A;
    box-shadow: 0 0 8px rgba(255, 139, 122, 0.6);
    width: 12px;
    height: 12px;
  }

  .slot-board .hs-dots button:hover {
    background: rgba(255, 139, 122, 0.8);
  }

  /* 이미지 없을 때 텍스트 포스터 */
  .slot-board .hs-textposter {
    position: relative;
    width: 100%;
    height: 100%;
    background: 
      radial-gradient(circle at 80% 20%, rgba(255, 107, 107, 0.15) 0%, transparent 60%),
      radial-gradient(circle at 20% 80%, rgba(255, 139, 122, 0.1) 0%, transparent 50%),
      linear-gradient(135deg, #2f2520 0%, #1a1311 100%);
  }

  .slot-board .hs-textbg {
    position: absolute;
    inset: 0;
    padding: 40px;
    color: rgba(255, 255, 255, 0.6);
    font-weight: 400;
    font-size: clamp(16px, 2.5vw, 20px);
    line-height: 1.8;
    white-space: pre-line;
    overflow: hidden;
    opacity: 0.3;
    filter: blur(8px);
  }

  /* 빈 상태 */
  .slot-board .hs-empty {
    padding: 60px 20px;
    text-align: center;
    color: #888;
    background: linear-gradient(135deg, rgba(42, 31, 26, 0.5) 0%, rgba(26, 19, 17, 0.5) 100%);
    border: 2px dashed rgba(255, 139, 122, 0.2);
    border-radius: 20px;
    font-size: 1.125rem;
  }

  /* 반응형 */
  @media (max-width: 768px) {
    .slot-board .hs-caption {
      left: 20px;
      right: 20px;
      bottom: 20px;
    }

    .slot-board .hs-title {
      font-size: 1.125rem;
    }

    .slot-board .hs-meta {
      font-size: 0.875rem;
    }

    .slot-board .hs-chip {
      padding: 6px 12px;
      font-size: 0.75rem;
    }

    .slot-board .hs-nav {
      width: 40px;
      height: 40px;
      font-size: 20px;
    }
  }
  
  /* 1) 슬라이더 좌상단 배지 */
.slot-board .hero-slider::before{
  content: '인기 Top10';
  position: absolute;
  top: 12px; left: 12px;
  z-index: 4;
  display: inline-block;
  padding: 6px 10px;
  border-radius: 8px;
  font-weight: 700;
  font-size: .875rem;
  letter-spacing: -0.01em;
  color: #fff;
  background: rgba(0,0,0,.78);
  border: 1px solid rgba(255,255,255,.15);
  box-shadow: 0 2px 8px rgba(0,0,0,.35);
}
@media (max-width: 768px){
  .slot-board .hero-slider::before{
    top: 10px; left: 10px;
    padding: 5px 9px;
    font-size: .8rem;
  }
}

/* 2) 기존 H1은 화면에서만 숨기기(접근성/SEO 유지) */
.slot-board > h1{
  position: absolute !important;
  width:1px; height:1px; margin:-1px; padding:0; border:0;
  overflow:hidden; clip:rect(0 0 0 0); clip-path: inset(50%);
  white-space: nowrap;
}

/* ===== 슬라이더 아래 2열: 좌 공지 / 우 통계 ===== */
.slot-board .home-row{
  display:grid;
  grid-template-columns: 1.6fr 1fr; /* 좌측 약간 더 넓게 */
  gap:16px;
  margin-top:16px;
}

/* 공통 카드 */
.card-panel{
  background: rgba(26,19,17,.72);
  border:1px solid rgba(255,255,255,.08);
  border-radius:16px;
  box-shadow: 0 10px 30px rgba(0,0,0,.25);
  color:#fff;
  padding:14px 16px;
}
.card-panel h3{ margin:0 0 10px 0; font-size:1rem; font-weight:700; letter-spacing:-0.01em; }

/* 공지 리스트 */
.notice-list{ list-style:none; margin:0; padding:0; display:flex; flex-direction:column; gap:8px; }
.notice-list li a{
  display:flex; align-items:center; gap:8px;
  color:#fff; text-decoration:none;
  padding:8px 10px;
  border-radius:10px;
  background: rgba(255,255,255,.04);
  border: 1px solid rgba(255,255,255,.06);
}
.notice-list li a:hover{ background: rgba(255,255,255,.08); }
.notice-badge{
  flex:0 0 auto; font-size:.75rem; font-weight:700;
  padding:2px 6px; border-radius:6px;
  background:#111; color:#fff; border:1px solid rgba(255,255,255,.15);
}
.notice-title{
  flex:1 1 auto; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;
  font-weight:600; letter-spacing:-0.01em;
}
.notice-meta{ opacity:.8; font-size:.8rem; }

/* 통계 */
.stats-grid{ display:grid; grid-template-columns: 1fr 1fr; gap:12px; }
.stat{ background: rgba(255,255,255,.04); border:1px solid rgba(255,255,255,.06); border-radius:12px; padding:12px; }
.stat .label{ font-size:.8rem; opacity:.85; margin-bottom:6px; }
.stat .value{ font-size:1.6rem; font-weight:800; line-height:1; }

/* 반응형: 태블릿 이하는 한 줄씩 */
@media (max-width: 768px){
  .slot-board .home-row{ grid-template-columns: 1fr; }
}

  
</style>
</head>

<body>
  <jsp:include page="/WEB-INF/include/header.jsp" />

  <main class="main grid-14x5">
    <div class="slot-nav">
      <jsp:include page="/WEB-INF/include/nav.jsp" />
    </div>

    <div class="slot-board">
      <h1 style="margin:0 0 16px 0;">인기 Top10</h1>

      <section class="hero-slider" id="top10-root">
        <div class="hs-viewport">
          <ul class="hs-track" id="hsTrack"></ul>
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

    // 안전 JSON 파서 (문자열일 때만 시도)
    function safeParseJSON(maybe) {
      if (typeof maybe !== 'string') return maybe;
      let s = maybe.trim();
      if (!/^[{\[]/.test(s)) return null; // JSON 모양 아니면 포기
      s = s.replace(/&quot;/g, '"')
           .replace(/&#34;/g, '"')
           .replace(/&apos;|&#39;/g, "'")
           .replace(/&amp;/g, '&');
      s = s.replace(/,\s*([}\]])/g, '$1'); // trailing comma 제거
      try { return JSON.parse(s); } catch { return null; }
    }

    // ===== 썸네일 추출 (JSON 문자열 처리 우선순위 조정) =====
    function pickThumb(p){
      // 1. Post 객체 자체의 썸네일 속성 우선 체크
      if (p && (p.thumbnail || p.thumb || p.imageSrc || p.imageUrl))
        return p.thumbnail || p.thumb || p.imageSrc || p.imageUrl;

      // 2. image 리스트 속성 체크
      const list = (p && (p.images || p.imageList || p.image_list)) || [];
      if (Array.isArray(list) && list.length){
        const i0 = list[0] || {};
        return i0.imageSrc || i0.src || i0.url || null;
      }

      const content = p && p.content;
      if (!content) return null;

      let json = null;
      let htmlContent = null;

      if (typeof content === 'string') {
        // 3. 🚨 JSON 문자열인지 확인하고 파싱 시도 (가장 높은 확률의 오류 원인 해결)
        if (/^[{\[]/.test(content.trim())) {
           json = safeParseJSON(content);
        } else {
           // JSON이 아니면 일반 HTML/텍스트로 간주
           htmlContent = content;
        }
      } else if (typeof content === 'object') {
        // 4. content가 이미 파싱된 객체인 경우
        json = content;
      }

      // 5. JSON/객체에서 이미지 찾기 (ProseMirror 구조 처리)
      if (json) {
        let found = null;
        (function walk(node){
          if (found) return;
          if (Array.isArray(node)) { node.forEach(walk); return; }
          if (node && typeof node === 'object'){
            // "type":"image", "attrs":{"src":"..."} 패턴 찾기
            if (node.type === 'image' && node.attrs && node.attrs.src) { found = node.attrs.src; return; }
            if (node.content) walk(node.content);
          }
        })(json);
        if (found) return found;
        
        // JSON에서 이미지를 못 찾았으면, HTML 추출 단계로 넘어가지 않음
        htmlContent = null; 
      }
      
      // 6. HTML 문자열에서 이미지 찾기 (content가 JSON이 아니었을 경우에만 시도)
      if (typeof htmlContent === 'string' && /<img/i.test(htmlContent)){
        // <img ... src="URL" ...> 패턴에서 URL 추출 (이전 개선된 정규식 유지)
        const m = htmlContent.match(/<img[^>]*\s+src\s*=\s*['"]([^'"]+)['"][^>]*>/i);
        return (m && m[1]) ? m[1] : null;
      }

      return null;
    }

    // ===== 본문 텍스트 (기존 로직 유지) =====
    function getTextSnippet(p, maxLen){
      const content = p && p.content;
      if (!content) return '';
      if (typeof content === 'string'){
        // JSON처럼 보이면 파싱해서 텍스트만 추출
        if (/^[{\[]/.test(content)) {
          const json = safeParseJSON(content);
          if (json) {
            let buf = [];
            (function walk(node){
              if (Array.isArray(node)){ node.forEach(walk); return; }
              if (!node || typeof node !== 'object') return;
              if (node.type === 'text' && node.text) buf.push(node.text);
              if (node.content) walk(node.content);
            })(json);
            const text = buf.join(' ').replace(/\s+/g,' ').trim();
            return text.length > (maxLen||180) ? text.slice(0,maxLen||180)+'…' : text;
          }
        }
        // 일반 문자열/HTML
        const text = content.replace(/<style[\s\S]*?<\/style>/gi,'')
                            .replace(/<script[\s\S]*?<\/script>/gi,'')
                            .replace(/<[^>]+>/g,' ')
                            .replace(/\s+/g,' ')
                            .trim();
        return text.length > (maxLen||180) ? text.slice(0,maxLen||180)+'…' : text;
      } else {
        try{
          let buf = [];
          (function walk(node){
            if (Array.isArray(node)){ node.forEach(walk); return; }
            if (!node || typeof node !== 'object') return;
            if (node.type === 'text' && node.text) buf.push(node.text);
            if (node.content) walk(node.content);
          })(content);
          const text = buf.join(' ').replace(/\s+/g,' ').trim();
          return text.length > (maxLen||180) ? text.slice(0,maxLen||180)+'…' : text;
        }catch{ return ''; }
      }
    }

 // ===== 지도 포함 여부 (hasMap 함수 수정) =====
    function hasMap(p){
        if (!p) return false;
        // 1. Post 객체 자체의 mapList/maps 속성 체크 (JSON 파싱 전에 체크)
        if ((p.maps && p.maps.length) || (p.mapList && p.mapList.length)) return true;

        const content = p.content;
        if (!content) return false;

        // 2. content가 문자열일 경우, 키워드 체크를 제거하고 JSON 파싱만 시도
        if (typeof content === 'string') {
            // 🚨 이 라인을 제거하거나 주석 처리하세요. (오탐의 주범)
            // if (/kakao|map|lat|lng|latitude|longitude/i.test(content)) return true;

            const json = safeParseJSON(content);
            if (!json) return false; // JSON이 아니면 지도가 없는 것으로 확정

            let found=false;
            (function walk(node){
                if (found) return;
                if (Array.isArray(node)){ node.forEach(walk); return; }
                if (!node || typeof node !== 'object') return;
                // 지도의 고유 타입 체크
                if (node.type && /kakao-map|map|place|location/i.test(node.type)) { found=true; return; }
                if (node.attrs && (node.attrs.lat || node.attrs.lng || node.attrs.latitude || node.attrs.longitude)) { found=true; return; }
                if (node.content) walk(node.content);
            })(json);
            return found;
        }

        // 3. content가 이미 객체인 경우 (기존 JSON 탐색 로직 유지)
        // (여기서는 수정할 필요 없음)
        try{
            let found=false;
            (function walk(node){
                if (found) return;
                if (Array.isArray(node)){ node.forEach(walk); return; }
                if (!node || typeof node !== 'object') return;
                if (node.type && /kakao-map|map|place|location/i.test(node.type)) { found=true; return; }
                if (node.attrs && (node.attrs.lat || node.attrs.lng || node.attrs.latitude || node.attrs.longitude)) { found=true; return; }
                if (node.content) walk(node.content);
            })(content);
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
        const img   = pickThumb(p);
        const text  = getTextSnippet(p, 220);
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
      url.searchParams.set('sort','views');
      url.searchParams.set('limit', String(LIMIT));
      url.searchParams.set('page','1');
      try{
        const res = await fetch(url.toString(), { headers: { 'X-Requested-With': 'fetch' }});
        if(!res.ok) throw new Error('HTTP '+res.status);
        const json = await res.json();
        const list = json.posts || json.items || json.list || json.data || [];
        slides = Array.isArray(list) ? list.slice(0, LIMIT) : [];
        
        // 디버깅 로직 (개선된 pickThumb 테스트)
        slides.forEach((p, idx) => {
            const thumbUrl = pickThumb(p);
            if (thumbUrl) {
                console.info(`[Top10] Slide ${idx + 1} (${p.postId || 'N/A'}): 썸네일 URL 추출 성공: ${thumbUrl}`);
            } else {
                const contentSnippet = (p.content && typeof p.content === 'string') ? p.content.slice(0, 150) + '...' : String(p.content);
                console.warn(`[Top10] Slide ${idx + 1} (${p.postId || 'N/A'}): 썸네일 URL 추출 실패. content 타입: ${typeof p.content}. CONTENT SNIPPET: ${contentSnippet}`);
            }
        });
        
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
  
  
  (function(){
	  const ctx = "<%= request.getContextPath() %>/";
	  const API_LIST = ctx + "postList2.async";
	  const POST_DETAIL = ctx + "post-detail.post";
	  const LIMIT = 12;

	  const $board = document.querySelector('.slot-board');
	  const $slider = document.getElementById('top10-root');
	  const hide = el => el && (el.style.display = 'none');
	  const show = el => el && (el.style.display = '');

	  let $result; // 동적 결과 영역

	  function ensureResultRoot(){
	    if ($result) return $result;
	    $result = document.createElement('section');
	    $result.id = 'search-list-root';
	    $result.style.display = 'none';
	    $board.appendChild($result);
	    return $result;
	  }

	  function esc(s){ return (s==null?'':String(s))
	    .replace(/&/g,'&amp;').replace(/</g,'&lt;')
	    .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;'); }

	  function detailUrl(p){
	    const id  = p.postId || p.id;
	    const cid = p.categoryId || '';
	    const tid = p.postTypeId || '';
	    let url = POST_DETAIL + "?postId=" + encodeURIComponent(id);
	    if (cid) url += "&categoryId=" + encodeURIComponent(cid);
	    if (tid) url += "&postTypeId=" + encodeURIComponent(tid);
	    return url;
	  }

	  // 간단 썸네일 추출 (가벼운 버전)
	  function pickThumb(p){
	    if (!p) return null;
	    if (p.thumbnail || p.thumb || p.imageSrc || p.imageUrl)
	      return p.thumbnail || p.thumb || p.imageSrc || p.imageUrl;

	    const list = p.images || p.imageList || p.image_list || [];
	    if (Array.isArray(list) && list.length){
	      const i0 = list[0] || {};
	      return i0.imageSrc || i0.src || i0.url || null;
	    }

	    const c = p.content;
	    if (!c) return null;

	    if (typeof c === 'string'){
	      if (/^[{\[]/.test(c.trim())){ // JSON 같으면 파싱해서 image 탐색
	        try{
	          const json = JSON.parse(
	            c.replace(/&quot;/g,'"').replace(/&#34;/g,'"')
	             .replace(/&apos;|&#39;/g,"'").replace(/&amp;/g,'&')
	             .replace(/,\s*([}\]])/g,'$1')
	          );
	          let found = null;
	          (function walk(n){
	            if (found) return;
	            if (Array.isArray(n)) return n.forEach(walk);
	            if (n && typeof n === 'object'){
	              if (n.type === 'image' && n.attrs && n.attrs.src){ found = n.attrs.src; return; }
	              if (n.content) walk(n.content);
	            }
	          })(json);
	          if (found) return found;
	        }catch(_){}
	      } else {
	        const m = c.match(/<img[^>]*\s+src\s*=\s*['"]([^'"]+)['"][^>]*>/i);
	        return m && m[1] ? m[1] : null;
	      }
	    }
	    return null;
	  }

	  // 홈 전용: 검색 → 보드 섹션만 AJAX로 교체 / 검색어 비우면 슬라이더 복귀
	  window.loadPosts = async function(){
	    const q = (window.currentQuery || '').trim();
	    const page = window.currentPage || 1;
	    const $root = ensureResultRoot();

	    if (!q){
	      // 검색어 비우면 원래 슬라이더 UI 복귀
	      hide($root);
	      show(document.getElementById('hsPrev'));
	      show(document.getElementById('hsNext'));
	      show(document.getElementById('hsDots'));
	      show($slider);
	      return;
	    }

	    // 슬라이더 UI 숨기고 결과 영역 표시
	    hide($slider);
	    hide(document.getElementById('hsPrev'));
	    hide(document.getElementById('hsNext'));
	    hide(document.getElementById('hsDots'));
	    show($root);
	    $root.innerHTML = `<div class="hs-empty">"${esc(q)}" 검색 중…</div>`;

	    // 목록 가져오기
	    const url = new URL(API_LIST, location.origin);
	    url.searchParams.set('q', q);
	    url.searchParams.set('limit', String(LIMIT));
	    url.searchParams.set('page', String(page));

	    try{
	      const res = await fetch(url.toString(), { headers: { 'X-Requested-With': 'fetch' }});
	      if (!res.ok) throw new Error('HTTP '+res.status);
	      const json = await res.json();
	      const items = json.posts || json.items || json.list || json.data || [];

	      if (!Array.isArray(items) || !items.length){
	        $root.innerHTML = `<div class="hs-empty">"${esc(q)}"에 대한 결과가 없습니다.</div>`;
	        return;
	      }

	      // 심플 카드 그리드로 보드 영역만 교체
	       $root.innerHTML = `
			<h2 style="margin:0 0 12px 0;color:#fff">"${esc(q)}" 검색 결과</h2>
			<ul class="search-cards"
			style="display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px;margin:0;padding:0;list-style:none;color:#fff;"></ul>
		   `;
	      const $ul = $root.querySelector('.search-cards');
	      $ul.innerHTML = items.map(p=>{
	        const href = detailUrl(p);
	        const img = pickThumb(p);
	        const ttl = esc(p.title || '제목 없음');
	        const cat = esc(p.category || '');
	        const views = (p.hit != null ? p.hit : 0);
	        return `
	           <li class="card" style="background:#1a1311;border-radius:16px;overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,.25);">
	             <a href="${href}" style="display:block;color:inherit;text-decoration:none">
	              ${img ? `<img src="${img}" alt="${ttl}" style="width:100%;height:140px;object-fit:cover;display:block">` : ''}
	              <div style="padding:12px 14px">
	              <div style="font-size:.8rem;color:rgba(255,255,255,.85);margin-bottom:4px">${cat}</div>
	              <div style="font-weight:700;line-height:1.4;color:#fff">${ttl}</div>
	              <div style="font-size:.85rem;color:rgba(255,255,255,.8);margin-top:6px">👁️ ${views} views</div>
	              </div>
	            </a>
	          </li>`;
	      }).join('');
	    }catch(err){
	      console.error(err);
	      $root.innerHTML = `<div class="hs-empty">검색을 불러오지 못했습니다.</div>`;
	    }
	  };
	})();
  
  /* ===== 슬라이더 아래: 공지(listId=9) + 통계(게시물/유저 수) ===== */
  (function(){
    const ctx = "<%= request.getContextPath() %>/";
    const NOTICE_API = ctx + "postList2.async";      // ★ 기존 API 재활용
    const STATS_API = ctx + "stats.async"; // 두 개 숫자를 한번에 받기
    const NOTICE_LIMIT = 6;

    // 슬라이더 바로 아래에 마크업 주입
    const slider = document.getElementById('top10-root');
    if (slider){
      slider.insertAdjacentHTML('afterend', `
        <div class="home-row" id="homeRow">
          <section class="card-panel home-notice">
            <h3>📌 공지</h3>
            <ul class="notice-list" id="noticeList">
              <li><a><span class="notice-title">불러오는 중…</span></a></li>
            </ul>
          </section>
          <section class="card-panel home-stats">
            <h3>🌇 노을 맛집 정보</h3>
            <div class="stats-grid">
              <div class="stat">
                <div class="label">게시물 수</div>
                <div class="value" id="statPosts">—</div>
              </div>
              <div class="stat">
                <div class="label">유저 수</div>
                <div class="value" id="statUsers">—</div>
              </div>
            </div>
          </section>
        </div>
      `);
    }

    // 공지 로드: listId=9
    async function loadNotices(){
      const url = new URL(NOTICE_API, location.origin);
      url.searchParams.set('listId', '9');
      url.searchParams.set('limit',  String(NOTICE_LIMIT));
      url.searchParams.set('sort',   'latest');
      try{
        const res = await fetch(url.toString(), { headers: { 'X-Requested-With':'fetch' }});
        if(!res.ok) throw new Error('HTTP '+res.status);
        const json = await res.json();
        const list = json.posts || json.items || json.list || json.data || [];
        const notices = Array.isArray(list) ? list.slice(0, NOTICE_LIMIT) : [];

        const $ul = document.getElementById('noticeList');
        if (!$ul) return;
        if (!notices.length){
          $ul.innerHTML = `<li><a><span class="notice-title">공지 글이 없습니다.</span></a></li>`;
          return;
        }
        $ul.innerHTML = notices.map(p=>{
          const href = buildDetailUrl(p);
          const ttl  = esc(p.title || '제목 없음');
          const date = formatDate(p.createdAt || p.regDate || p.created || p.date);
          return `
            <li>
              <a href="${href}">
                <span class="notice-badge">공지</span>
                <span class="notice-title">${ttl}</span>
                <span class="notice-meta">${date}</span>
              </a>
            </li>`;
        }).join('');
      }catch(err){
        console.error(err);
        const $ul = document.getElementById('noticeList');
        if ($ul) $ul.innerHTML = `<li><a><span class="notice-title">공지 로드 실패</span></a></li>`;
      }
    }

    async function loadStats(){
    	try{
    	const res = await fetch(STATS_API, { headers:{ 'X-Requested-With':'fetch' } });
    	if (!res.ok) throw 0;
    	const j = await res.json();
    	setText('#statPosts', (j.postCount != null ? String(j.postCount) : '—'));
    	setText('#statUsers', (j.userCount != null ? String(j.userCount) : '—'));
    	}catch(_){
    	setText('#statPosts', '—');
    	setText('#statUsers', '—');
    	}
    }
    // ===== helpers =====
    function esc(s){ return (s==null?'':String(s))
      .replace(/&/g,'&amp;').replace(/</g,'&lt;')
      .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;'); }

    function buildDetailUrl(p){
      const POST_DETAIL = ctx + "post-detail.post";
      const id  = p.postId || p.id;
      const cid = p.categoryId || '';
      const tid = p.postTypeId || '';
      let url = POST_DETAIL + "?postId=" + encodeURIComponent(id);
      if (cid) url += "&categoryId=" + encodeURIComponent(cid);
      if (tid) url += "&postTypeId=" + encodeURIComponent(tid);
      return url;
    }

    function formatDate(d){
      try{
        const dt = (d ? new Date(d) : null);
        if (!dt || isNaN(+dt)) return '';
        const y=dt.getFullYear(), m=String(dt.getMonth()+1).padStart(2,'0'), day=String(dt.getDate()).padStart(2,'0');
        return `${y}.${m}.${day}`;
      }catch{ return ''; }
    }

    function setText(sel, v){ const el = document.querySelector(sel); if (el) el.textContent = v; }

    // 초기 로드
    loadNotices();
    loadStats();

    // 검색 중일 땐 하단(공지/통계) 숨기고, 검색 해제 시 다시 표시
    const originalLoadPosts = window.loadPosts;
    window.loadPosts = async function(){
      const q = (window.currentQuery || '').trim();
      const row = document.getElementById('homeRow');
      if (q){ if (row) row.style.display = 'none'; }
      else { if (row) row.style.display = ''; }
      if (typeof originalLoadPosts === 'function'){
        return originalLoadPosts.apply(this, arguments);
      }
    };
  })();
  </script>
</body>
</html>