package service.post;

import java.io.IOException;
import java.util.List;

import action.ActionForward; // 사용은 안 하지만 의존성 상주
import dao.BoardDao;
import dao.PostDao;
import dto.Post;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.ThePager;

public class SunsetListAsyncService {

    public void render(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            request.setCharacterEncoding("UTF-8");
            String q = safe(request.getParameter("q"));
            int pageNo   = parseInt(request.getParameter("pageno"), 1);
            int pageSize = parseInt(request.getParameter("pagesize"), 12); // 그리드 12개씩

            BoardDao bdao = new BoardDao();
            int listId = bdao.getSunsetListId();

            PostDao pdao = new PostDao();
            int total = pdao.countByList(listId, q);
            List<Post> posts = pdao.findByList(listId, pageNo, pageSize, q);

            // 페이저 (링크는 쿼리스트링 형태로; 프론트에서 a클릭 가로채서 AJAX로 쓰면 됨)
            ThePager pager = new ThePager(total, pageNo, pageSize, 5, request.getContextPath() + "/SunsetList.async");

            request.setAttribute("q", q);
            request.setAttribute("total", total);
            request.setAttribute("posts", posts);
            request.setAttribute("pager", pager.toString());

            response.setContentType("text/html; charset=UTF-8");

            // 기존 보드 파셜 사용 (마크업은 프로젝트의 /WEB-INF/include/board-result.jsp)
            RequestDispatcher rd = request.getRequestDispatcher("/WEB-INF/include/board-result.jsp");
            rd.forward(request, response);

        } catch (Exception e){
            // 에러 시에도 HTML로 간단 안내
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<div style='padding:24px'>목록 로딩 중 오류가 발생했습니다.</div>");
        }
    }

    private String safe(String s){ return s == null ? "" : s.trim(); }
    private int parseInt(String s, int def){
        try { return Integer.parseInt(s); } catch(Exception e){ return def; }
    }
}
