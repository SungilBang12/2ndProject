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
        
        ActionForward forward = new ActionForward();
        PostDao postDao = new PostDao();
        
        try {
            // 1. 폼 데이터 받기
            String postIdParam = request.getParameter("postId");
            String listIdParam = request.getParameter("listId");
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            
            // 2. 유효성 검사
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
                forward.setPath("/post-edit.post?postId=" + postId);
                return forward;
            }
            
            if (content == null || content.trim().isEmpty()) {
                request.setAttribute("error_msg", "내용을 입력해주세요.");
                forward.setRedirect(false);
                forward.setPath("/post-edit.post?postId=" + postId);
                return forward;
            }
            
            // 3. 권한 확인
            HttpSession session = request.getSession();
            // String loggedInUserId = (String) session.getAttribute("userId");
            String loggedInUserId = "user001"; // 임시 사용자 ID
            
            // 기존 게시글 조회
            Post existingPost = postDao.getPostById(postId);
            
            if (existingPost == null) {
                request.setAttribute("error_msg", "게시글을 찾을 수 없습니다.");
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-list.post");
                return forward;
            }
            
            if (!existingPost.getUserId().equals(loggedInUserId)) {
                request.setAttribute("error_msg", "수정 권한이 없습니다.");
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-detail.post?postId=" + postId);
                return forward;
            }
            
            // 4. Post 객체 생성 및 업데이트
            Post post = new Post();
            post.setPostId(postId);
            post.setListId(listId);
            post.setTitle(title.trim());
            post.setContent(content);
            
            System.out.println("게시글 수정 시도: postId=" + postId + ", listId=" + listId + ", title=" + title);
            
            // 5. 데이터베이스 업데이트
            int result = postDao.updatePost(post);
            
            // 6. 결과 처리
            if (result > 0) {
                // 성공 - 게시글 상세 페이지로 리다이렉트
                System.out.println("게시글 수정 성공: postId=" + postId);
                
                // 성공 메시지를 세션에 저장 (선택사항)
                session.setAttribute("success_msg", "게시글이 성공적으로 수정되었습니다.");
                
                forward.setRedirect(true);
                forward.setPath(request.getContextPath() + "/post-detail.post?postId=" + postId);
            } else {
                // 실패 - 수정 페이지로 다시 이동
                System.out.println("게시글 수정 실패: postId=" + postId);
                
                request.setAttribute("error_msg", "게시글 수정에 실패했습니다.");
                forward.setRedirect(false);
                forward.setPath("/post-edit.post?postId=" + postId);
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error_msg", "잘못된 요청입니다.");
            forward.setRedirect(true);
            forward.setPath(request.getContextPath() + "/post-list.post");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error_msg", "서버 오류가 발생했습니다: " + e.getMessage());
            forward.setRedirect(true);
            forward.setPath(request.getContextPath() + "/error.jsp");
        }
        
        return forward;
    }
}