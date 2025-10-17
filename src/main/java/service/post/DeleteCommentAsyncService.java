package service.post;

import com.google.gson.Gson;
import dao.CommentsDao;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import dto.Users;

public class DeleteCommentAsyncService {

    public void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String,Object> out = new HashMap<>();
        HttpSession session = req.getSession(false);


        try{
            Users user = (Users) session.getAttribute("user");
            String userId = user.getUserId();
            if (userId == null || userId.isBlank()){
                out.put("ok", false);
                out.put("error", "로그인이 필요합니다.");
                resp.getWriter().write(new Gson().toJson(out));
                return;
            }

            String body = readBody(req);
            Map<?,?> data = new Gson().fromJson(body, Map.class);
            int commentId = ((Number)data.get("commentId")).intValue();

            int affected = new CommentsDao().softDelete(commentId, userId);
            out.put("ok", affected > 0);
            if (affected == 0) out.put("error", "삭제 권한이 없거나 이미 삭제되었습니다.");
        }catch(Exception e){
            out.put("ok", false);
            out.put("error", e.getMessage());
        }
        resp.getWriter().write(new Gson().toJson(out));
    }

    private String readBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try(BufferedReader br = req.getReader()){
            String line; while((line=br.readLine())!=null) sb.append(line);
        }
        return sb.toString();
    }
}
