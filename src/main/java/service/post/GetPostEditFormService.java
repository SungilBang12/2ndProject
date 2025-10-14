package service.post;

import action.Action;
import action.ActionForward;
import dao.PostDao;
import dto.Post;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class GetPostEditFormService implements Action {

 @Override
 public ActionForward excute(HttpServletRequest request, HttpServletResponse response) {
     
     ActionForward forward = new ActionForward();
     PostDao postDao = new PostDao();
     
     try {
         // 1. postId 파라미터 획득
         String postIdParam = request.getParameter("postId");
         if (postIdParam == null || postIdParam.isEmpty()) {
             throw new NumberFormatException("게시글 번호가 누락되었습니다.");
         }
         int postId = Integer.parseInt(postIdParam);
         
         // 2. 게시글 데이터 조회
         // PostDAO는 post를 조회하는 selectPost(postId) 메서드가 있다고 가정합니다.
         Post post = postDao.getPostById(postId); 

         // 3. 권한 확인 (중요!)
         HttpSession session = request.getSession();
         // String loggedInUserId = (String) session.getAttribute("userId");
         String loggedInUserId = "user001"; // 임시 사용자 ID

         if (post == null) {
             // 게시글이 없는 경우
             request.setAttribute("error_msg", "게시글을 찾을 수 없습니다.");
             forward.setRedirect(true);
             forward.setPath(request.getContextPath() + "/post-list.post");
         } else if (!post.getUserId().equals(loggedInUserId)) { 
             // 작성자와 로그인된 사용자가 다른 경우 (수정 권한 없음)
             request.setAttribute("error_msg", "수정 권한이 없습니다.");
             forward.setRedirect(true);
             forward.setPath("/post-detail.post?postId=" + postId); // 상세 페이지로 돌려보냄
         } else {
             // 4. request에 Post 객체 저장 (JSP로 전달)
             request.setAttribute("post", post); 
             
             // 5. ActionForward 설정: 수정 폼 JSP로 forward
             forward.setRedirect(false); // forward 방식 지정
             forward.setPath("/WEB-INF/view/post/post-edit.jsp"); // 수정 폼 JSP 경로
         }

     } catch (NumberFormatException e) {
         // postId 파라미터 오류 처리
         request.setAttribute("error_msg", "유효하지 않은 게시글 번호입니다.");
         forward.setRedirect(true);
         forward.setPath(request.getContextPath() + "/post-list.post");
     } catch (Exception e) {
         e.printStackTrace();
         // DB 또는 기타 예외 처리
         forward.setRedirect(true);
         forward.setPath(request.getContextPath() + "/error.jsp");
     }
     
     return forward;
 }
}