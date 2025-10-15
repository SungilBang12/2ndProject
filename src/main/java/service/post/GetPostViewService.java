package service.post;

import java.io.IOException;

import action.Action;
import action.ActionForward;
import dao.PostDao;
import dto.Post;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class GetPostViewService implements Action {

    @Override
    public ActionForward excute(HttpServletRequest request, HttpServletResponse response) throws IOException {
        ActionForward forward = null;

        try {
            // 1️⃣ 요청 파라미터 받기
<<<<<<< HEAD
            String postIdParam = request.getParameter("postId");
=======
        	// TODO 프론트 request로 id값 전달해주는 것 필요
            String postIdParam = request.getParameter("postId");
            if (postIdParam == null || postIdParam.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "postId가 필요합니다.");
                return null;
            }
            int postId = Integer.parseInt(postIdParam);

            // 2️⃣ DAO 호출
            PostDao dao = new PostDao();
            Post post = dao.getPostById(postId);

            if (post == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "해당 게시글을 찾을 수 없습니다.");
                return null;
            }

            // 3️⃣ JSP로 전달할 데이터 설정
            request.setAttribute("post", post);

            // 4️⃣ 페이지 이동 설정
            forward = new ActionForward();
            forward.setRedirect(false); // forward 방식
            forward.setPath("/public/post-detail.jsp"); // ✅ 상세 보기 페이지 JSP 경로

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "서버 처리 중 오류 발생");
        }

        return forward;
    }
}