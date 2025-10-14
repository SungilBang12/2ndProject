package service.post;

import com.google.gson.Gson;
import dao.CommentsDao;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class CreateCommentAsyncService {

    public void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String,Object> out = new HashMap<>();
        try{
            String userId = (String) req.getSession().getAttribute("userId");
            if (userId == null || userId.isBlank()){
                out.put("ok", false);
                out.put("error", "로그인이 필요합니다.");
                resp.getWriter().write(new Gson().toJson(out));
                return;
            }

            String body = readBody(req);
            Map<?,?> data = new Gson().fromJson(body, Map.class);

            int postId = ((Number)data.get("postId")).intValue();
            String text = ((String) (data.get("text") != null ? data.get("text") : "")).trim();
            String imageUrl = (String) data.get("imageUrl");

            // 검증: 텍스트 1~300 / 이미지만 있으면 텍스트 0자도 허용
            if ( (text.isEmpty() && (imageUrl==null || imageUrl.isBlank())) ||
                 (!text.isEmpty() && (text.length()<1 || text.length()>300)) ) {
                out.put("ok", false);
                out.put("error", "댓글은 1~300자 또는 이미지 1개만 등록 가능합니다.");
                resp.getWriter().write(new Gson().toJson(out));
                return;
            }

            int newId = new CommentsDao().create(postId, userId, text, imageUrl);

            out.put("ok", true);
            out.put("commentId", newId);
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
