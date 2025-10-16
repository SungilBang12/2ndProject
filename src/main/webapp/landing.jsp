<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Sunset</title>
  <link rel="icon" href="<%=request.getContextPath()%>/images/favicon.ico?v=1">
  <style>
    /* ============ DESIGN TOKENS ============ */
    :root{
      --bg: #0d0d0d;
      --ink: #f5f3ef;
      --muted: #b7b2ab;
      --accent: #f3b664;
      --soft: #22201c;
      --maxw: 1200px;
      --pad: clamp(16px, 4vw, 32px);
      --radius: 16px;
      --shadow: 0 10px 30px rgba(0,0,0,.25);
      --ease: cubic-bezier(.2,.7,.2,1);
    }
    *{box-sizing:border-box}
    html,body{height:100%}
    body{
      margin:0; background:var(--bg); color:var(--ink);
      font-family: ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Inter,Pretendard,Apple SD Gothic Neo,sans-serif;
      line-height:1.6;
    }
    a{color:inherit; text-decoration:none}
    img,video{display:block; max-width:100%}
    .container{max-width:var(--maxw); margin:0 auto; padding:0 var(--pad)}
    .grid{display:grid; gap:clamp(16px,2.5vw,28px)}

    /* ============ HEADER ============ */
    .site-header{
      position:fixed; top:0; z-index:50;
      width: 100%;
      backdrop-filter: blur(6px);
      background: linear-gradient(180deg, rgba(13,13,13,.9), rgba(13,13,13,.65));
      border-bottom:1px solid rgba(255,255,255,.06);
    }
    .nav{
      display:flex; align-items:center; justify-content:space-between;
      padding:12px var(--pad);
      max-width:var(--maxw); margin:0 auto;
    }
    .logo{font-weight:800; letter-spacing:.02em}
    .nav a{opacity:.85}
    .nav a:hover{opacity:1}

    /* ============ HERO ============ */
    .hero{
      position:relative; min-height:100svh; display:grid; place-items:center; overflow:hidden;
      border-bottom:1px solid rgba(255,255,255,.06);
      isolation:isolate;
    }
    .hero-media{
      position:absolute; inset:0; z-index:-1; overflow:hidden;
    }
    .hero-media img, .hero-media video{
      width:100%; height:100%; object-fit:cover;
      transform: scale(1.05);
      animation: kenburns 18s ease-in-out both;
      filter: saturate(1.08) contrast(1.02) brightness(.98);
    }
    @keyframes kenburns{
      0%{transform: scale(1.05)}
      50%{transform: scale(1.12)}
      100%{transform: scale(1.08)}
    }
    .hero::after{
      content:""; position:absolute; inset:0;
      background:
        linear-gradient(180deg, rgba(0,0,0,.25), rgba(0,0,0,.45)),
        radial-gradient(110% 70% at 50% 90%, rgba(0,0,0,.6) 0%, rgba(0,0,0,0) 60%);
      z-index:0;
    }
   
    /* 기존 hero-inner 스타일 유지 */
    .hero-inner{ text-align:center; max-width:900px; padding:calc(var(--pad) * 2) var(--pad); position: relative; z-index: 1;}

    /* ------------------------------------- */
    /* H1/P.lead 기본 스타일 */
    /* ------------------------------------- */
    .hero-inner h1 {
        margin:.9rem 0 0;
        font-size:clamp(36px, 5.8vw, 72px); 
        line-height:1.12;
        letter-spacing:-.01em;
        text-wrap:balance;
        margin-bottom: 0.5rem;
    }
    .hero-inner p.lead {
        margin:0.5rem auto 0;
        max-width:60ch;
        font-size:clamp(15px, 1.8vw, 18px);
        color:var(--muted);
    }

    /* ------------------------------------- */
    /* P.lead 반사 스타일 */
    /* ------------------------------------- */
    .reflection-wrapper {
        position: relative;
        color: var(--ink);
    }
    
    /* P.lead 반사 (::after 사용) */
    .reflection-wrapper::after {
        content: attr(data-p-text); /* p.lead 텍스트 가져오기 */
        position: absolute;
        left: 0;
        right: 0;
        text-align: center;
        /* P.lead의 바로 아래를 기준점으로 잡습니다. */
        top: 100%; 
       
        /* P.lead의 스타일을 그대로 적용 */
        font-size: clamp(15px, 1.8vw, 18px); 
        line-height: 1.6;
       
        color: var(--muted); 
        opacity: 0.3;
        white-space: normal;
    
        /* 위치 조정 및 반전: P.lead 텍스트 1줄 높이만큼 끌어올립니다. */
        transform: scaleY(-1) translateY(-2.7rem); 
        transform-origin: center top;
        pointer-events: none;
        z-index: -1;
       
        /* 마스킹 및 블러 (원본 텍스트에서 멀어질수록 투명) */
        -webkit-mask-image: linear-gradient(to top, transparent 0%, rgba(0,0,0,0.5) 20%, transparent 70%);
        mask-image: linear-gradient(to top, transparent 0%, rgba(0,0,0,0.5) 20%, transparent 70%);
        filter: blur(0.2px);
    }

    /* ============ SECTION BASICS ============ */
    section{padding:clamp(40px, 10vw, 120px) 0}
    .sec-title{font-size:clamp(28px, 3.5vw, 42px); line-height:1.15; margin:0 0 10px}
    .sec-desc{color:var(--muted); margin:0 0 26px; max-width:65ch}

    /* ============ “WHAT LIVES HERE” ============ */
    .stack{ grid-template-columns: 1.2fr 1fr; align-items:start; }
    @media (max-width: 960px){ .stack{grid-template-columns:1fr} }
    .pill{display:inline-block; padding:.4rem .8rem; border-radius:999px; background:#1d1a16; color:#e6e1da; font-weight:700; font-size:.85rem}
    .stack-gallery{ display:grid; gap:22px; grid-template-columns:1fr; }
    .card-media{
      border-radius:var(--radius); overflow:hidden; background:var(--soft); box-shadow:var(--shadow);
      position:relative;
    }
    .card-media img{width:100%; height:auto; display:block}
    .caption{position:absolute; left:12px; bottom:12px; padding:.35rem .6rem; border-radius:999px; font-size:.8rem;
      background:rgba(0,0,0,.55); border:1px solid rgba(255,255,255,.14); backdrop-filter: blur(3px)}

    /* ============ LSV alternating ============ */
    .split{ grid-template-columns:1.05fr 1fr; align-items:center }
    .split.reverse{ grid-auto-flow: dense }
    .split .media{border-radius:var(--radius); overflow:hidden; box-shadow:var(--shadow)}
    .split .media img{width:100%; height:auto}
    .kicker{color:var(--accent); font-weight:800; letter-spacing:.08em; text-transform:uppercase; font-size:.8rem}
    @media (max-width: 960px){ .split{ grid-template-columns:1fr; } }

    /* ============ CTA ============ */
    .cta{
      text-align:center; background:linear-gradient(180deg, #16130f, #12100c);
      border-top:1px solid rgba(255,255,255,.06);
      border-bottom:1px solid rgba(255,255,255,.06);
    }
    .cta .btn{
      display:inline-block; padding:12px 20px; border-radius:999px; font-weight:800;
      background:var(--accent); color:#111; border:1px solid rgba(0,0,0,.15);
      box-shadow: 0 8px 20px rgba(243,182,100,.25); transition: transform .12s var(--ease), filter .12s var(--ease);
    }
    .cta .btn:hover{ filter:brightness(1.05); transform:translateY(-1px) }

    /* ============ IN-VIEW ANIMATION ============ */
    .reveal{
      opacity:0; transform: translateY(24px); filter: blur(2px);
      transition: opacity .7s var(--ease), transform .7s var(--ease), filter .7s var(--ease);
    }
    .reveal.is-inview{ opacity:1; transform:none; filter: blur(0); }
    .reveal[data-stagger] .reveal-item{
      opacity:0; transform: translateY(20px); filter: blur(2px);
      transition: opacity .6s var(--ease), transform .6s var(--ease), filter .6s var(--ease);
    }
    .reveal[data-stagger].is-inview .reveal-item{ opacity:1; transform:none; filter: blur(0); }

    /* ============ PARALLAX (light) ============ */
    [data-parallax]{ will-change: transform; }
   
    .yt-embed__ratio{
      position:relative; width:100%;
      padding-top:56.25%; /* 16:9 */
      background:#000; border-radius:16px; overflow:hidden;
      box-shadow: var(--shadow, 0 10px 30px rgba(0,0,0,.25));
    }
    .yt-embed__ratio iframe{
      position:absolute; inset:0; width:100%; height:100%; border:0;
    }
  </style>
</head>
<body>

  <header class="site-header">
    <nav class="nav">
      <a class="logo" href="#">TOP</a>
      <div class="nav-links">
        <a href="#what">What</a>&nbsp;&nbsp;
        <a href="#share">Share</a>&nbsp;&nbsp;
        <a href="#visit">Visit</a>
      </div>
    </nav>
  </header>

  <section class="hero">
    <div class="hero-media">
      <img src="/images/top.jpg?q=80&w=1920&auto=format&fit=crop" alt="배경 이미지">
    </div>

   <div class="hero-inner container">
	  <br>
      <h1 class="reveal" data-delay="0.2s">
        지평선에 걸린 <br> 노을 한 폭
      </h1>
      <div class="reflection-wrapper reveal" data-delay="0.3s"
           data-p-text="해질녘 노을의 모든 것을 공유하는 곳"> 
        <p class="lead">
            해질녘 노을의 모든 것을 공유하는 곳
        </p>
      </div>
    </div>
  </section>

  <section id="what">
    <div class="container grid stack">
      <div>
        <span class="pill reveal" data-delay=".05s">What is this place</span>
        <h2 class="sec-title reveal" data-delay=".15s">순간을 공유하세요</h2>
        <p class="sec-desc reveal" data-delay=".25s">
          노을을 보았을 때의 감정을 공유하는 곳
        </p>
      </div>

      <div class="stack-gallery reveal" data-stagger>
        <figure class="card-media reveal-item" data-delay=".05s" data-parallax="0.1">
          <img src="/images/sea_1280.jpg?q=80&w=1600&auto=format&fit=crop" alt="gallery 1">
          <figcaption class="caption">Sea</figcaption>
        </figure>
        <figure class="card-media reveal-item" data-delay=".15s" data-parallax="0.08">
          <img src="/images/mountain.jpg?q=80&w=1600&auto=format&fit=crop" alt="gallery 2">
          <figcaption class="caption">Mountain</figcaption>
        </figure>
        <figure class="card-media reveal-item" data-delay=".25s" data-parallax="0.06">
          <img src="/images/person_1280.jpg?q=80&w=1600&auto=format&fit=crop" alt="gallery 3">
          <figcaption class="caption">Person</figcaption>
        </figure>
      </div>
    </div>
  </section>

  <section id="share">
    <div class="container grid split">
      <div class="media reveal" data-parallax="0.07">
        <img src="/images/focus.jpg?q=80&w=1600&auto=format&fit=crop" alt="Land">
      </div>
      <div class="copy">
        <div class="kicker reveal" data-delay=".05s">The Sunset</div>
        <h3 class="sec-title reveal" data-delay=".15s">노을이 들려주는 이야기</h3>
        <p class="sec-desc reveal" data-delay=".25s">
          노을이 들려주고 싶은 이야기는 뭘까요?<br>
          매일 노을을 보며 많은 사람들이 소망을 빕니다.<br>
          그 모든 소망을 가진 노을의 이야기가 궁금하지 않으신가요?
        </p>
      </div>
    </div>

    <div class="container grid split reverse" style="margin-top: min(8vw, 80px);">
      <div class="copy">
        <div class="kicker reveal" data-delay=".05s">The Daily Happiness</div>
        <h3 class="sec-title reveal" data-delay=".15s">매일의 행복</h3>
        <p class="sec-desc reveal" data-delay=".25s">
          고된 하루의 끝에서 노을을 마주했을 때 무슨 생각이 들었나요?<br>
          일상 속에서 발견한 사소한 행복을 들려주세요.
        </p>
      </div>
      <div class="media reveal" data-parallax="0.09">
        <img src="/images/city_1280.jpg?q=80&w=1600&auto=format&fit=crop" alt="Spirit">
      </div>
    </div>

    <div class="container grid split" style="margin-top: min(8vw, 80px);">
      <div class="media reveal" data-parallax="0.05">
        <img src="/images/air_1280.jpg?q=80&w=1600&auto=format&fit=crop" alt="Vision">
      </div>
      <div class="copy">
        <div class="kicker reveal" data-delay=".05s">The Travel</div>
        <h3 class="sec-title reveal" data-delay=".15s">특별한 여행</h3>
        <p class="sec-desc reveal" data-delay=".25s">
          어떤 행복은 특별한 장소에서 더 큰 행복이 되기도 합니다.<br>
          색다른 장소에서 느꼈던 감정을 공유해 주세요!
        </p>
      </div>
    </div>
  </section>

  <section>
    <div class="container grid" style="grid-template-columns:1fr; gap:16px;">
      <h3 class="sec-title reveal">Sunset</h3>
      <div class="yt-embed reveal" data-parallax="0.04">
      <div class="yt-embed__ratio">
        <iframe
          src="https://www.youtube-nocookie.com/embed/WKctu8b5BmM?t=85&autoplay=1&mute=1&controls=1&playsinline=1&modestbranding=1&rel=0"
          title="YouTube video"
          frameborder="0"
          allow="autoplay; encrypted-media; picture-in-picture"
          allowfullscreen
        ></iframe>
      </div>
    </div>
  </div>
</section>

  <section id="visit" class="cta">
    <div class="container">
      <h3 class="sec-title reveal">홈으로</h3>
      <p class="sec-desc reveal">
      </p>
      <a class="btn reveal" href="/index.jsp" data-delay=".1s">Visit</a>
    </div>
  </section>

  <footer class="container" style="padding:40px 0; color:var(--muted); font-size:.9rem">
    © <span id="year"></span> 노을 맛집
  </footer>

  <script>
    // ===== Util: set CSS transition-delay from data-delay =====
    function applyDelay(el){
      var d = el.getAttribute('data-delay');
      if(d) el.style.transitionDelay = d;
    }

    // ===== In-view reveal (IntersectionObserver) =====
    var io = new IntersectionObserver(function(entries){
      entries.forEach(function(entry){
        if(entry.isIntersecting){
          var el = entry.target;
          el.classList.add('is-inview');
          io.unobserve(el);
          // 스태거 컨테이너
          if(el.hasAttribute('data-stagger')){
            var items = el.querySelectorAll('.reveal-item');
            items.forEach(function(it, i){
              it.style.transitionDelay = ((parseFloat(it.getAttribute('data-delay')) || 0) + i * 0.08) + 's';
              requestAnimationFrame(function(){ it.classList.add('is-inview'); });
            });
          }
        }
      });
    }, { rootMargin: '0px 0px -10% 0px', threshold: 0.08 });

    Array.prototype.forEach.call(document.querySelectorAll('.reveal'), function(el){
      applyDelay(el);
      io.observe(el);
    });

    // ===== Light parallax (translateY based on scroll) =====
    var parallaxEls = Array.prototype.slice.call(document.querySelectorAll('[data-parallax]'));
    function onScroll(){
      var wh = window.innerHeight;
      parallaxEls.forEach(function(el){
        var speed = parseFloat(el.getAttribute('data-parallax')) || 0.1;
        var rect = el.getBoundingClientRect();
        var pct = (rect.top - wh) / (wh + rect.height); // -1 ~ 0 ~ 1
        var move = pct * speed * 80; // px
        // ▼ JSP EL 충돌 방지를 위해 템플릿 리터럴 대신 문자열 결합 사용
        el.style.transform = 'translateY(' + move + 'px)';
      });
    }
    onScroll();
    window.addEventListener('scroll', onScroll, {passive:true});
    window.addEventListener('resize', onScroll);

    // year
    document.getElementById('year').textContent = new Date().getFullYear();

 	// -------------------------------------
    // 수면 반사 텍스트를 위한 JavaScript (제거 및 정리)
    // -------------------------------------
    window.addEventListener('DOMContentLoaded', function() {
        // Hero content initial reveal
        Array.prototype.forEach.call(document.querySelectorAll('.hero .reveal'), function(el){
            el.classList.add('is-inview');
        });
    });
  </script>
</body>
</html>