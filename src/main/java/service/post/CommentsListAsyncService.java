package service.post;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.CommentsDao;
import dto.Comments;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CommentsListAsyncService {
    
    // ✅ LocalDate 처리를 위한 Gson
    private static final Gson GSON = new GsonBuilder()
            .registerTypeAdapter(LocalDate.class, (com.google.gson.JsonSerializer<LocalDate>) (src, typeOfSrc, context) -> 
                new com.google.gson.JsonPrimitive(src.format(DateTimeFormatter.ISO_LOCAL_DATE)))
            .create();
    
    public void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        
        Map<String, Object> out = new HashMap<>();
        
        try {
            // ============================================
            // 1. 파라미터 받기
            // ============================================
            int postId = Integer.parseInt(req.getParameter("postId"));
            int pageNo = 1;
            try { 
                pageNo = Integer.parseInt(req.getParameter("pageno")); 
            } catch (Exception ignore) {}
            
            System.out.println("=== CommentsListAsyncService ===");
            System.out.println("postId: " + postId);
            System.out.println("pageNo: " + pageNo);
            
            // ============================================
            // 2. DAO 호출
            // ============================================
            CommentsDao dao = new CommentsDao();
            
            // 게시글 작성자 조회
            String postWriterId = dao.getPostWriterId(postId);
            
            // 전체 댓글 수
            int total = dao.countByPost(postId);
            
            // 댓글 목록 조회 (최신순, DESC 고정)
            List<Comments> list = dao.findByPost(postId, pageNo, 20, postWriterId);
            
            // ============================================
            // 3. 응답 구성 (기존 서비스와 동일한 형식)
            // ============================================
            out.put("ok", true);
            out.put("total", total);
            out.put("pageNo", pageNo);
            out.put("pageSize", 20);
            out.put("items", list);
            
            System.out.println("✅ 댓글 " + total + "개 조회 완료");
            
        } catch (NumberFormatException e) {
            System.err.println("❌ 숫자 변환 오류: " + e.getMessage());
            out.put("ok", false);
            out.put("error", "잘못된 파라미터 형식입니다.");
            
        } catch (Exception e) {
            System.err.println("❌ 서버 오류: " + e.getMessage());
            e.printStackTrace();
            out.put("ok", false);
            out.put("error", e.getMessage());
        }
        
        resp.getWriter().write(GSON.toJson(out));
    }
}