package service.post;

import action.Action;
import action.ActionForward;
import dao.PostDao;
import dto.Post;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class UpdatePostService implements Action {

    @Override
    public ActionForward excute(HttpServletRequest request, HttpServletResponse response) {
        
        System.out.println("=== UpdatePostService 실행됨 ===");
        
        ActionForward forward = new ActionForward();
        PostDao postDao = new PostDao();
        
        try {
           
            
            // ============================================
            // 2. 폼 데이터 받기
            // ============================================
            String postIdParam = request.getParameter("postId");
            String listIdParam = request.getParameter("listId");
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            
            System.out.println("받은 파라미터:");
            System.out.println("- postId: " + postIdParam);
            System.out.println("- listId: " + listIdParam);
            System.out.println("- title: " + title);
            System.out.println("- content 길이: " + (content != null ? content.length() : 0));
            
            if (postIdParam == null || postIdParam.isEmpty()) {
                request.setAttribute("error_msg", "게시글 번호가 누락되었습니다.");
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-list.post");
                return forward;
            }
            
            int postId = Integer.parseInt(postIdParam);
            Integer listId = (listIdParam != null && !listIdParam.isEmpty()) 
                    ? Integer.parseInt(listIdParam) 
                    : null;
            
            if (title == null || title.trim().isEmpty()) {
                request.setAttribute("error_msg", "제목을 입력해주세요.");
                forward.setRedirect(false);
                forward.setPath("/post-edit-form.post?postId=" + postId);
                return forward;
            }
            
            if (content == null || content.trim().isEmpty()) {
                request.setAttribute("error_msg", "내용을 입력해주세요.");
                forward.setRedirect(false);
                forward.setPath("/post-edit-form.post?postId=" + postId);
                return forward;
            }
            
            // ============================================
            // 3. 게시글 조회 및 권한 체크
            // ============================================
            Post existingPost = postDao.getPostById(postId);
            
            if (existingPost == null) {
                request.setAttribute("error_msg", "게시글을 찾을 수 없습니다.");
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-list.post");
                return forward;
            }
                
            
            
            // ============================================
            // 4. 게시글 수정
            // ============================================
            Post post = new Post();
            post.setPostId(postId);
            post.setListId(listId);
            post.setTitle(title.trim());
            post.setContent(content);
            
            int result = postDao.updatePost(post);
            
            if (result > 0) {
                System.out.println("✅ 게시글 수정 성공");
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-detail.post?postId=" + postId);
            } else {
                System.out.println("❌ 게시글 수정 실패");
                request.setAttribute("error_msg", "게시글 수정에 실패했습니다.");
                forward.setRedirect(false);
                forward.setPath("/post-edit-form.post?postId=" + postId);
            }
            
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