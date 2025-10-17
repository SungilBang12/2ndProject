package service.post;

import action.Action;
import action.ActionForward;
import dao.PostDao;
import dto.Post;
import dto.Users;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class GetPostEditFormService implements Action {
    
    @Override
    public ActionForward excute(HttpServletRequest request, HttpServletResponse response) {
        
        System.out.println("=== GetPostEditFormService 실행됨 ===");
        
        ActionForward forward = new ActionForward();
        PostDao postDao = new PostDao();
        
        try {
            // ============================================
            // 1. 세션 체크 (로그인 확인)
            // ============================================
            HttpSession session = request.getSession(false);
            String userId = null;
            
            if (session != null) {
                // ✅ 세션에서 user 객체를 가져와서 userId 추출
                Users user = (Users) session.getAttribute("user");
                if (user != null) {
                    userId = user.getUserId();
                }
                System.out.println("=== 세션에서 가져온 userId: " + userId + " ===");
            } else {
                System.out.println("=== 세션이 존재하지 않음 ===");
            }
            

            
            // ============================================
            // 2. postId 파라미터 확인
            // ============================================
            String postIdParam = request.getParameter("postId");
            System.out.println("=== postId 파라미터: [" + postIdParam + "] ===");
            
            if (postIdParam == null || postIdParam.trim().isEmpty()) {
                System.out.println("❌ postId가 없습니다!");
                request.setAttribute("error_msg", "게시글 번호가 누락되었습니다.");
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-list.post");
                return forward;
            }
            
            int postId = Integer.parseInt(postIdParam.trim());
            System.out.println("✅ postId 파싱 성공: " + postId);
            
            // ============================================
            // 3. 게시글 조회
            // ============================================
            Post post = postDao.getPostById(postId);
            System.out.println("조회된 게시글: " + (post != null ? post.getTitle() : "null"));
            
            if (post == null) {
                System.out.println("❌ 게시글을 찾을 수 없습니다!");
                request.setAttribute("error_msg", "게시글을 찾을 수 없습니다.");
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-list.post");
                return forward;
            }
            
            // ============================================
            // 4. 작성자 권한 체크
            // ============================================
            System.out.println("=== 권한 체크: 게시글 작성자=" + post.getUserId() + ", 로그인 사용자=" + userId + " ===");
            
            if (!post.getUserId().equals(userId)) {
                System.out.println("❌ 권한 없음 - 본인이 작성한 게시글이 아님");
                System.out.println(post.getUserId());
                System.out.println(userId);
                request.setAttribute("error_msg", "수정 권한이 없습니다. 본인이 작성한 게시글만 수정할 수 있습니다.");
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-detail.post?postId=" + postId);
                return forward;
            }
            
            // ============================================
            // 5. 권한 확인 완료 - 수정 페이지로 이동
            // ============================================
            System.out.println("✅ 권한 확인 완료 - 수정 페이지로 이동");
            request.setAttribute("post", post);
            forward.setRedirect(false);
            forward.setPath("/WEB-INF/view/post/post-edit.jsp");
            
        } catch (NumberFormatException e) {
            System.out.println("❌ NumberFormatException: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error_msg", "유효하지 않은 게시글 번호입니다.");
            forward.setRedirect(true);
            forward.setPath(request.getContextPath() + "/post-list.post");
        } catch (Exception e) {
            System.out.println("❌ Exception: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error_msg", "서버 오류가 발생했습니다.");
            forward.setRedirect(true);
            forward.setPath(request.getContextPath() + "/error.jsp");
        }
        
        return forward;
    }
}