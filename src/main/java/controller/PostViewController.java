package controller;

import java.io.IOException;

import action.Action;
import action.ActionForward;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.post.CreatePostService;
import service.post.GetPostEditFormService;
import service.post.GetPostViewService;
import service.post.UpdatePostService;

@WebServlet("*.post")
public class PostViewController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public PostViewController() {
    }
    
    private void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String requestUri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String urlCommand = requestUri.substring(contextPath.length());

        System.out.println("=== 요청 URL Command: " + urlCommand);

        Action action = null;
        ActionForward forward = null;
        
        if (urlCommand.equals("/editor.post")) {
            System.out.println(">>> 게시글 작성 페이지");
            forward = new ActionForward();
            forward.setRedirect(false);
            forward.setPath("/WEB-INF/view/post/post-trade-create.jsp");
            
        } else if (urlCommand.equals("/post-detail.post")) {
            System.out.println(">>> 게시글 상세 조회");
            action = new GetPostViewService();
            forward = action.excute(request, response);
            
        } else if (urlCommand.equals("/post-edit-form.post")) {
            System.out.println(">>> 게시글 수정 폼 조회");
            action = new GetPostEditFormService();
            forward = action.excute(request, response);
            
        } else if (urlCommand.equals("/update.post")) {
            System.out.println(">>> 게시글 수정 처리");
            action = new UpdatePostService();
            forward = action.excute(request, response);
            
        } else if (urlCommand.equals("/ssp.post")) {
            System.out.println(">>> 노을 페이지");
            forward = new ActionForward();
            forward.setRedirect(false);
            forward.setPath("/WEB-INF/view/post/sunset-pic.jsp");
        }   else if (urlCommand.equals("/create.post")) {
            System.out.println(">>> 게시글 생성 처리 (Synchronous)");
            action = new CreatePostService(); // Use the new service
            forward = action.excute(request, response);
        } 
        else {
            System.out.println(">>> 매칭되는 URL이 없습니다: " + urlCommand);
        }

        if (forward != null) {
            String requestedWith = request.getHeader("X-Requested-With");
            boolean isAjax = "XMLHttpRequest".equals(requestedWith);
            
            if (forward.isRedirect()) {
                System.out.println(">>> 리다이렉트: " + forward.getPath());
                if (isAjax) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    String redirectUrl = forward.getPath();
                    String jsonResponse = "{\"success\": true, \"redirectUrl\": \"" + redirectUrl + "\"}";
                    response.getWriter().write(jsonResponse);
                    return;
                } else {
                    response.sendRedirect(forward.getPath());
                }
            } else {
                System.out.println(">>> 포워딩: " + forward.getPath());
                RequestDispatcher dis = request.getRequestDispatcher(forward.getPath());
                dis.forward(request, response);
            }
        } else {
            System.out.println(">>> forward가 null입니다!");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doProcess(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doProcess(request, response);
    }
}
