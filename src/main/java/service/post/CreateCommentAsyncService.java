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

public class CreateCommentAsyncService {

    public void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        req.setCharacterEncoding("UTF-8"); // 한글/이모지 안전

        Map<String,Object> out = new HashMap<>();
        Gson gson = new Gson();

        try{
            Users user = (Users) req.getAttribute("user"); // ✅ Users 객체로 캐스팅
            String userId = user.getUserId(); // ✅ userId 추출
            if (userId == null || userId.isBlank()){
                out.put("ok", false);
                out.put("error", "로그인이 필요합니다.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }

            String body = readBody(req);
            Map<?,?> data = gson.fromJson(body, Map.class);

            int postId = ((Number)data.get("postId")).intValue();
            String text = ((String) (data.get("text") != null ? data.get("text") : "")).trim();
            String imageUrl = (String) data.get("imageUrl");

            // ✅ 길이 제한 제거: 텍스트나 이미지 중 하나만 있으면 허용
            boolean hasText = (text != null && !text.isBlank());
            boolean hasImage = (imageUrl != null && !imageUrl.isBlank());
            if (!hasText && !hasImage) {
                out.put("ok", false);
                out.put("error", "내용이 비어 있습니다. 텍스트 또는 이미지를 입력하세요.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }

            // DB에 그대로 저장 (contentRaw/CLOB)
            int newId = new CommentsDao().create(postId, userId, text, imageUrl);

            out.put("ok", true);
            out.put("commentId", newId);
        } catch(Exception e){
            out.put("ok", false);
            out.put("error", e.getMessage());
        }

        resp.getWriter().write(gson.toJson(out));
    }

    private String readBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try(BufferedReader br = req.getReader()){
            String line; 
            while((line=br.readLine())!=null) sb.append(line);
        }
        return sb.toString();
    }
}
