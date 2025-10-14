package service.post;

import com.google.gson.Gson;
import dao.CommentsDao;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class UpdateCommentAsyncService {

    public void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String,Object> out = new HashMap<>();
        try{
            String userId = (String)req.getSession().getAttribute("userId");
            if (userId == null || userId.isBlank()){
                out.put("ok", false);
                out.put("error", "로그인이 필요합니다.");
                resp.getWriter().write(new Gson().toJson(out));
                return;
            }

            String body = readBody(req);
            Map<?,?> data = new Gson().fromJson(body, Map.class);
            int commentId = ((Number)data.get("commentId")).intValue();
            String text = ((String) (data.get("text") != null ? data.get("text") : "")).trim();
            String imageUrl = (String) data.get("imageUrl");

            if ( (text.isEmpty() && (imageUrl==null || imageUrl.isBlank())) ||
                 (!text.isEmpty() && (text.length()<1 || text.length()>300)) ) {
                out.put("ok", false);
                out.put("error", "댓글은 1~300자 또는 이미지 1개만 등록 가능합니다.");
                resp.getWriter().write(new Gson().toJson(out));
                return;
            }

            int affected = new CommentsDao().update(commentId, userId, text, imageUrl);
            out.put("ok", affected > 0);
            if (affected == 0) out.put("error", "수정 권한이 없거나 이미 삭제된 댓글입니다.");
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
