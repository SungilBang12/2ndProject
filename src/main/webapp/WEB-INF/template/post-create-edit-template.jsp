<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>노을 맛집 - 글쓰기</title>
  
  <style>
    /* ====== 전역 베이스 Sunset 테마 ====== */
    html, body {
      margin: 0;
      padding: 0;
      background: linear-gradient(180deg, #1a1614 0%, #0f0d0c 100%);
      color: #e5e5e5;
      font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
      min-height: 100vh;
    }

    /* ====== 메인 그리드 레이아웃 ====== */
    .main.grid-14x5 {
      display: grid;
      grid-template-columns: 280px 1fr 320px;
      gap: 24px;
      max-width: 1600px;
      margin: 0 auto;
      padding: 24px;
      min-height: calc(100vh - 80px);
    }

    /* ====== 슬롯 영역 ====== */
    .slot-nav {
      position: sticky;
      top: 80px;
      height: fit-content;
      max-height: calc(100vh - 100px);
      overflow-y: auto;
    }

    .slot-board {
      background: linear-gradient(135deg, 
        rgba(42, 31, 26, 0.4) 0%, 
        rgba(26, 22, 20, 0.4) 100%
      );
      border: 1px solid rgba(255, 139, 122, 0.15);
      border-radius: 16px;
      padding: 32px;
      box-shadow: 
        0 8px 32px rgba(0, 0, 0, 0.3),
        inset 0 1px 0 rgba(255, 255, 255, 0.05);
      backdrop-filter: blur(10px);
    }

    .slot-extra {
      background: linear-gradient(135deg, 
        rgba(42, 31, 26, 0.3) 0%, 
        rgba(26, 22, 20, 0.3) 100%
      );
      border: 1px solid rgba(255, 139, 122, 0.1);
      border-radius: 16px;
      padding: 24px;
      position: sticky;
      top: 80px;
      height: fit-content;
      max-height: calc(100vh - 100px);
      overflow-y: auto;
    }

    /* ====== 에디터 제목 영역 ====== */
    .slot-board h1 {
      margin: 0 0 24px 0;
      font-family: 'Noto Serif KR', serif;
      font-size: clamp(1.75rem, 3vw, 2.25rem);
      font-weight: 700;
      color: #FF8B7A;
      letter-spacing: -0.02em;
      text-shadow: 0 2px 12px rgba(255, 139, 122, 0.3);
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .slot-board h1::before {
      content: "✍️";
      font-size: 1.5em;
    }

    /* ====== 스크롤바 커스터마이징 ====== */
    .slot-nav::-webkit-scrollbar,
    .slot-extra::-webkit-scrollbar {
      width: 6px;
    }

    .slot-nav::-webkit-scrollbar-track,
    .slot-extra::-webkit-scrollbar-track {
      background: rgba(26, 22, 20, 0.5);
      border-radius: 3px;
    }

    .slot-nav::-webkit-scrollbar-thumb,
    .slot-extra::-webkit-scrollbar-thumb {
      background: rgba(255, 139, 122, 0.3);
      border-radius: 3px;
    }

    .slot-nav::-webkit-scrollbar-thumb:hover,
    .slot-extra::-webkit-scrollbar-thumb:hover {
      background: rgba(255, 139, 122, 0.5);
    }

    /* ====== 반응형 레이아웃 ====== */
    @media (max-width: 1400px) {
      .main.grid-14x5 {
        grid-template-columns: 280px 1fr;
        gap: 20px;
      }
      
      .slot-extra {
        display: none;
      }
    }

    @media (max-width: 1024px) {
      .main.grid-14x5 {
        grid-template-columns: 1fr;
        gap: 0;
        padding: 16px;
      }

      .slot-nav {
        display: none; /* 모바일에서는 햄버거 메뉴로 */
      }

      .slot-board {
        padding: 24px 20px;
        border-radius: 12px;
      }
    }

    @media (max-width: 768px) {
      .slot-board {
        padding: 20px 16px;
      }

      .slot-board h1 {
        font-size: 1.5rem;
      }

      .main.grid-14x5 {
        padding: 12px;
      }
    }

    /* ====== 빈 slot-extra 숨기기 ====== */
    .slot-extra:empty {
      display: none;
    }
  </style>
</head>
<body>
  <jsp:include page="/WEB-INF/include/header.jsp" />
  
  <main class="main grid-14x5">
    <!-- 사이드바 네비게이션 -->
    <div class="slot-nav">
      <jsp:include page="/WEB-INF/include/nav.jsp" />
    </div>

    <!-- 에디터 메인 영역 -->
    <div class="slot-board">
      <jsp:include page="/WEB-INF/template/editor-template.jsp" />
    </div>

    <!-- 우측 부가 정보 (선택사항) -->
    <div class="slot-extra">
      <!-- 필요 시 우측 칼럼 추가 -->
      <!-- 예: 작성 가이드, 최근 글 등 -->
    </div>
  </main>
</body>
</html>