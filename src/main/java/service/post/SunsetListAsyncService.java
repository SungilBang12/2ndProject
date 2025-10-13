package service.post;

import dao.PostDao;
import dto.Post;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class SunsetListAsyncService {

    private static final Integer SUNSET_LIST_ID_DEFAULT = 11;
    private static final int PAGE_SIZE = 6;  // ← 6개씩

    public void render(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        int pageNo = parseIntOr(req.getParameter("pageno"), 1);
        Integer listIdParam = parseIntOrNull(req.getParameter("listId"));
        final Integer effectiveListId = (listIdParam != null) ? listIdParam : SUNSET_LIST_ID_DEFAULT;

        List<Post> filtered = new ArrayList<>();
        try {
            PostDao dao = new PostDao();
            List<Post> all = dao.getAllPosts(); // 전용 메서드 없다고 가정

            // sunset 보드만 필터
            final Integer target = effectiveListId;
            filtered = all.stream()
                    .filter(p -> {
                        try {
                            Integer lid = p.getListId();
                            return lid != null && lid.equals(target);
                        } catch (Exception ignore) { return false; }
                    })
                    .collect(Collectors.toList());

        } catch (Exception e) {
            filtered = new ArrayList<>();
        }

        // 페이징
        int totalCount = filtered.size();
        int pageCount  = (int)Math.ceil(totalCount / (double)PAGE_SIZE);
        if (pageNo < 1) pageNo = 1;
        if (pageCount > 0 && pageNo > pageCount) pageNo = pageCount;

        int fromIndex = Math.max(0, (pageNo - 1) * PAGE_SIZE);
        int toIndex   = Math.min(totalCount, fromIndex + PAGE_SIZE);
        List<Post> pageItems = (fromIndex < toIndex) ? filtered.subList(fromIndex, toIndex) : new ArrayList<>();

        // 뷰로 전달
        req.setAttribute("posts", pageItems);
        req.setAttribute("pageno", pageNo);
        req.setAttribute("pageCount", pageCount);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("pageSize", PAGE_SIZE);

        RequestDispatcher rd = req.getRequestDispatcher("/WEB-INF/include/sunset-list.jsp");
        rd.forward(req, resp);
    }

    private int parseIntOr(String s, int def){
        try{ return Integer.parseInt(s); }catch(Exception e){ return def; }
    }
    private Integer parseIntOrNull(String s){
        try{ return (s==null || s.isBlank()) ? null : Integer.parseInt(s); }catch(Exception e){ return null; }
    }
}
