<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>

<%
request.setCharacterEncoding("UTF-8");

/* 1) 목데이터 (제목/날짜/링크) */
List<Map<String,String>> posts = new ArrayList<>();

String ctx = request.getContextPath();
String[][] seed = {
  {"노을 맛집 베스트 10",            "2025-01-02", ctx + "/sunset.jsp"},
  {"오늘의 노을 스팟 추천",          "2025-01-05", ctx + "/sunset-reco.jsp"},
  {"장비 추천: 미러리스 입문 가이드", "2025-01-03", ctx + "/equipment-reco.jsp"},
  {"촬영 TIP: 삼각대 제대로 쓰기",    "2025-01-07", ctx + "/equipment-tips.jsp"},
  {"중고 거래 가이드 (사기 예방법)",   "2025-01-04", ctx + "/equipment-market.jsp"},
  {"'해'쳐 모여: 이번주 번개",        "2025-01-06", ctx + "/meeting-gather.jsp"},
  {"장소 추천 모음",                  "2025-01-08", ctx + "/meeting-reco.jsp"},
  {"전체글 안내 및 규칙",             "2025-01-01", ctx + "/all.jsp"}
};
for (String[] row : seed) {
  Map<String,String> m = new HashMap<>();
  m.put("title", row[0]);
  m.put("date",  row[1]);
  m.put("url",   row[2]);
  posts.add(m);
}

/* 2) 쿼리 필터 (제목 contains, 대소문자 무시) */
String q = Optional.ofNullable(request.getParameter("q")).orElse("").trim();
List<Map<String,String>> results = new ArrayList<>();
if (q.isEmpty()) {
  results.addAll(posts); // 쿼리 없으면 전체(또는 인기글) 노출
} else {
  String ql = q.toLowerCase();
  for (Map<String,String> p : posts) {
    String title = String.valueOf(p.get("title"));
    if (title != null && title.toLowerCase().contains(ql)) {
      results.add(p);
    }
  }
}

/* 3) 뷰로 전달 후, board 안에 꽂을 파셜만 반환 */
request.setAttribute("q", q);
request.setAttribute("results", results);
%>
<jsp:include page="/WEB-INF/include/searchResult.jsp" />
