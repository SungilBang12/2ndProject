package service.post;

import com.google.gson.Gson;
import dao.CommentsDao;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import dto.Users;

public class UpdateCommentAsyncService {
    
    public void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        req.setCharacterEncoding("UTF-8");
        
        Map<String,Object> out = new HashMap<>();
        Gson gson = new Gson();
        
        try {
            Users user = (Users) req.getAttribute("user");
            
            if (user == null) {
                out.put("ok", false);
                out.put("error", "로그인이 필요합니다.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            
            String userId = user.getUserId();
            
            if (userId == null || userId.isBlank()) {
                out.put("ok", false);
                out.put("error", "로그인이 필요합니다.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            
            String body = readBody(req);
            Map<?,?> data = gson.fromJson(body, Map.class);
            
            int commentId = ((Number)data.get("commentId")).intValue();
            String text = ((String) (data.get("text") != null ? data.get("text") : "")).trim();
            String imageUrl = (String) data.get("imageUrl");
            
            boolean hasText = (text != null && !text.isBlank());
            boolean hasImage = (imageUrl != null && !imageUrl.isBlank());
            
            if (!hasText && !hasImage) {
                out.put("ok", false);
                out.put("error", "내용이 비어 있습니다.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            
            // ✅ text는 TipTap JSON 문자열 → DAO가 {"text":"...", "edited":true, ...} 형태로 저장
            int affected = new CommentsDao().update(commentId, userId, text, imageUrl);
            
            out.put("ok", affected > 0);
            if (affected == 0) {
                out.put("error", "수정 권한이 없거나 이미 삭제된 댓글입니다.");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            out.put("ok", false);
            out.put("error", e.getMessage());
        }
        
        resp.getWriter().write(gson.toJson(out));
    }
    
    private String readBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = req.getReader()) {
            String line; 
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }
}