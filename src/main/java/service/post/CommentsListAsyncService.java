package service.post;

import com.google.gson.Gson;
import dao.CommentsDao;
import dto.Comments;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CommentsListAsyncService {
    private static final int PAGE_SIZE = 20;

    public void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String,Object> out = new HashMap<>();
        try{
            int postId = Integer.parseInt(req.getParameter("postId"));
            int pageNo = 1;
            try{ pageNo = Integer.parseInt(req.getParameter("pageno")); }catch(Exception ignore){}

            CommentsDao dao = new CommentsDao();
            String postWriterId = dao.getPostWriterId(postId);

            int total = dao.countByPost(postId);
            List<Comments> list = dao.findByPost(postId, pageNo, PAGE_SIZE, postWriterId);

            out.put("ok", true);
            out.put("total", total);
            out.put("pageNo", pageNo);
            out.put("pageSize", PAGE_SIZE);
            out.put("items", list);
        }catch(Exception e){
            out.put("ok", false);
            out.put("error", e.getMessage());
        }
        resp.getWriter().write(new Gson().toJson(out));
    }
}
