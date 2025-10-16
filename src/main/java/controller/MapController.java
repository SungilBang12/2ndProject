package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.post.CreateTradePostSyncService;

import java.io.IOException;

import action.Action;
import action.ActionForward;
import dao.PostDaoImpl;

/**
 * Servlet implementation class MapController
 */
@WebServlet("*.do")
public class MapController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private void doProcess(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// 데이터 받기
		// URL 방식
		String requestUri = request.getRequestURI();
		String contextPath = request.getContextPath();
		String urlCommand = requestUri.substring(contextPath.length());

		System.out.println(urlCommand);
		
		Action action = null;
		ActionForward forward = null;
		if ("/post/create.do".equals("*.do")) {
		   // action = new PostCreateController(new PostDaoImpl());
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

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}


	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
