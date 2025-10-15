package service.post;

import action.Action;
import action.ActionForward;
import dao.PostDao;
import dto.Post;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Enumeration;

public class GetPostEditFormService implements Action {
    
    @Override
    public ActionForward excute(HttpServletRequest request, HttpServletResponse response) {
        
        System.out.println("=== GetPostEditFormService 실행됨 ===");
        
        // 모든 파라미터 출력
        System.out.println("=== 전체 파라미터 목록 ===");
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            System.out.println("파라미터: " + paramName + " = " + paramValue);
        }
        
        // 요청 정보 출력
        System.out.println("=== 요청 정보 ===");
        System.out.println("Request URI: " + request.getRequestURI());
        System.out.println("Query String: " + request.getQueryString());
        System.out.println("Method: " + request.getMethod());
        
        ActionForward forward = new ActionForward();
        PostDao postDao = new PostDao();
        
        try {
            String postIdParam = request.getParameter("postId");
            System.out.println("=== postId 파라미터: [" + postIdParam + "] ===");
            System.out.println("=== postId가 null인가? " + (postIdParam == null));
            System.out.println("=== postId가 비어있나? " + (postIdParam != null && postIdParam.isEmpty()));
            
            if (postIdParam == null || postIdParam.trim().isEmpty()) {
                System.out.println("❌ postId가 없습니다!");
                throw new NumberFormatException("게시글 번호가 누락되었습니다.");
            }
            
            int postId = Integer.parseInt(postIdParam.trim());
            System.out.println("✅ postId 파싱 성공: " + postId);
            
            Post post = postDao.getPostById(postId);
            
            System.out.println("조회된 게시글: " + (post != null ? post.getTitle() : "null"));
            
            HttpSession session = request.getSession();
            String loggedInUserId = "user001"; // 임시
            
            if (post == null) {
                System.out.println("❌ 게시글을 찾을 수 없습니다!");
                request.setAttribute("error_msg", "게시글을 찾을 수 없습니다.");
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-list.post");
            } else if (!post.getUserId().equals(loggedInUserId)) {
                System.out.println("❌ 권한 없음: " + post.getUserId() + " vs " + loggedInUserId);
                request.setAttribute("error_msg", "수정 권한이 없습니다.");
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-detail.post?postId=" + postId);
            } else {
                System.out.println("✅ 게시글 조회 성공, request에 저장");
                request.setAttribute("post", post);
                forward.setRedirect(false);
                forward.setPath("/WEB-INF/view/post/post-edit.jsp");
                System.out.println("✅ Forward 경로 설정: " + forward.getPath());
            }
            
        } catch (NumberFormatException e) {
            System.out.println("❌ NumberFormatException: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error_msg", "유효하지 않은 게시글 번호입니다.");
            forward.setRedirect(true);
            forward.setPath(request.getContextPath() + "/post-list.post");
        } catch (Exception e) {
            System.out.println("❌ Exception: " + e.getMessage());
            e.printStackTrace();
            forward.setRedirect(true);
            forward.setPath(request.getContextPath() + "/error.jsp");
        }
        
        return forward;
    }
}