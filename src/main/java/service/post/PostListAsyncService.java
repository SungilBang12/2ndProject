package service.post;

import com.google.gson.Gson;
import dao.PostDao;
import dto.PostSummary;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PostListAsyncService {

    private final PostDao postDao = new PostDao();
    private final Gson gson = new Gson();

    public void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");

        String sort = safe(req.getParameter("sort"), "newest");
        int limit = parseInt(req.getParameter("limit"), 10, 5, 50);
        int page  = parseInt(req.getParameter("page"), 1, 1, 1_000_000);
        String q  = safe(req.getParameter("q"), null);

        Integer listId = null;
        try {
            String raw = req.getParameter("listId");
            if (raw != null && !raw.isBlank()) {
                int tmp = Integer.parseInt(raw);
                if (tmp > 0) listId = tmp; // 0 또는 없음은 전체
            }
        } catch (NumberFormatException ignore) {}

        int totalCount = postDao.countPosts(q, listId);
        int totalPages = (int) Math.ceil(totalCount / (double) limit);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * limit;

        List<PostSummary> posts = postDao.listPostSummaries(sort, limit, offset, q, listId);

        Map<String,Object> out = new HashMap<>();
        out.put("ok", true);
        out.put("totalPages", totalPages);
        out.put("currentPage", page);
        out.put("posts", posts);

        resp.getWriter().write(gson.toJson(out));
    }

    private static String safe(String s, String def) {
        return (s == null || s.isBlank()) ? def : s;
    }
    private static int parseInt(String s, int def, int min, int max){
        try{
            int v = Integer.parseInt(s);
            if (v < min) return min;
            if (v > max) return max;
            return v;
        }catch(Exception e){
            return def;
        }
    }
}
