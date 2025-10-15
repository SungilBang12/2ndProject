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
import service.post.GetPostEditFormService;
import service.post.GetPostViewService;
import service.post.UpdatePostService;

/**
 * Servlet implementation class FrontController
 */
@WebServlet("*.post")
public class PostViewController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public PostViewController() {
	}
	
	private void doProcess(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// 데이터 받기
		// URL 방식
		String requestUri = request.getRequestURI();
		String contextPath = request.getContextPath();
		String urlCommand = requestUri.substring(contextPath.length());

		System.out.println(urlCommand);

		// 요청하기
		Action action = null;
		ActionForward forward = null;
		if (urlCommand.equals("/editor.post")) {
			// 홈페이지 이동 view 경로
			System.out.println("경로이동");
			forward = new ActionForward();
			forward.setRedirect(false);
			forward.setPath("/WEB-INF/view/post/post-trade-create.jsp");
		} else if (urlCommand.equals("/post-detail.post")) {
			//request에 postId parameter로 필요
			action = new GetPostViewService();
			forward = action.excute(request, response);
		}	else if (urlCommand.equals("/post-edit-form.post")) {
			    action = new GetPostEditFormService(); // ← 올바른 클래스명
			    forward = action.excute(request, response);
		    forward = action.excute(request, response);
		}  else if (urlCommand.equals("/ssp.post")) {
			forward = new ActionForward();
			forward.setRedirect(false);
			forward.setPath("/WEB-INF/view/post/sunset-pic.jsp");
		} 
		else if (urlCommand.equals("/update.post")) {
		    action = new UpdatePostService();
		    forward = action.excute(request, response);
		}
//		else if (urlCommand.equals("/toList.post") ) {
//			action = new getListIdByPostId();
//			forward = action.excute(request, response)
//		}
		
//		
//		} else if (urlCommand.equals("/create.post")) {
//			action = new CreateTradePostSyncService();
//			forward = action.excute(request, response);
//		} else if(urlCommand.equals("/edit.post")) {
//			action = new GetPostEditFormService();
//			forward = action.excute(request, response);
//		} else if(urlCommand.equals("/list.post")) {
//			action = new PostListService();
//			forward = action.excute(request, response);
//		} else if(urlCommand.equals("/view.post")) {
//			action = new GetPostViewService();
//			forward = action.excute(request, response);
//		}
		

		if (forward != null) {
	        // 💡 1. 요청 헤더를 확인하여 fetch 요청인지 판단
	        String requestedWith = request.getHeader("X-Requested-With");
	        boolean isAjax = "XMLHttpRequest".equals(requestedWith);
	        
	        if (forward.isRedirect()) {
	            System.out.println("페이지 리다이렉트");

	            if (isAjax) {
	                // 💡 2. fetch 요청인 경우, JSON으로 redirect URL을 반환
	                response.setContentType("application/json");
	                response.setCharacterEncoding("UTF-8");
	                String redirectUrl = forward.getPath();
	                
	                // JSON 응답을 클라이언트에게 직접 보냅니다.
	                String jsonResponse = "{\"success\": true, \"redirectUrl\": \"" + redirectUrl + "\"}";
	                response.getWriter().write(jsonResponse);
	                return; // 처리 종료
	            } else {
	                // 3. 일반적인 브라우저 요청인 경우, 기존 sendRedirect() 수행
	                response.sendRedirect(forward.getPath());
	            }
	        } else {
	            // 보낼 곳 있을 경우 => 데이터 처리 반환 (forward)
	            System.out.println("포워딩");
	            RequestDispatcher dis = request.getRequestDispatcher(forward.getPath());
	            
	            // 💡 fetch 요청이라도 forward는 JSP 내용을 HTML로 돌려주는 것이므로 그대로 둡니다.
	            // (클라이언트 JS에서 .text()로 받은 후 DOM에 삽입해야 함)
	            dis.forward(request, response);
	        }
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
