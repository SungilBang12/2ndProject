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

/**
 * Servlet implementation class FrontController
 */
@WebServlet("/*.view")
public class FrontController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public FrontController() {
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
				if (urlCommand.equals("/ .view")) {
					// 동기식 페이지 처리 데이터 담아서 페이지 로딩해야 하는 처리
//					action = new BoardListService();
					forward = action.excute(request, response);
				} else if (urlCommand.equals("/ .view")) {
					// 홈페이지 이동 view 경로
					forward = new ActionForward();
					forward.setRedirect(false);
					forward.setPath("board.ok");
				} else if (urlCommand.equals("/ .view")) {
					// 동기식 페이지 처리 데이터 담아서 페이지 로딩해야 하는 처리
//					action = new BoardContentService();
					forward = action.excute(request, response);
				} else if (urlCommand.equals("/ .view")) {
					// 홈페이지 이동 view 경로
					forward = new ActionForward();
					forward.setRedirect(false);
					forward.setPath( "/WEB-INF/views/board/board_write.jsp");
				} 
		
				if (forward != null) {
					if (forward.isRedirect()) { // true location.href = "페이지 이동"
						// 뷰지정
						response.sendRedirect(forward.getPath()); // 주소값이 바뀌어서 잘 안씀
					} else {
						// 보낼 곳 있을 경우 => 데이터 처리 반환
						RequestDispatcher dis = request.getRequestDispatcher(forward.getPath());
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
