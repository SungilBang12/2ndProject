package controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Map;

import com.google.gson.Gson;

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
@WebServlet("*.test")
public class TestController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public TestController() {
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
		if (urlCommand.equals("/editor-create.test")) {
			try {
		        BufferedReader reader = request.getReader();
		        StringBuilder sb = new StringBuilder();
		        String line;
		        while ((line = reader.readLine()) != null) {
		            sb.append(line);
		        }

		        String jsonData = sb.toString();
		        System.out.println("수신된 JSON 데이터: " + jsonData);

		        // Gson 파싱
		        Gson gson = new Gson();
		        Map<String, Object> map = gson.fromJson(jsonData, Map.class);

		        // 처리 로직
		        String title = (String) map.get("title");
		        Object content = map.get("content");

		        System.out.println("제목: " + title);
		        System.out.println("내용: " + content);

		        // ✅ JSON 응답
		        response.setContentType("application/json; charset=UTF-8");
		        response.getWriter().write("{\"status\":\"ok\"}");

		    } catch (Exception e) {
		        e.printStackTrace();
		    }
			
			
			
//					action = new BoardListService();
//			forward = action.excute(request, response);
		} else if (urlCommand.equals("/editor.test")) {
			// 홈페이지 이동 view 경로
			System.out.println("경로이동");
			forward = new ActionForward();
			forward.setRedirect(false);
			forward.setPath("/WEB-INF/view/post/post-trade-create.jsp");
		} else if (urlCommand.equals("/ .test")) {
			// 동기식 페이지 처리 데이터 담아서 페이지 로딩해야 하는 처리
//					action = new BoardContentService();
			forward = action.excute(request, response);
		} else if (urlCommand.equals("/ .test")) {
			// 홈페이지 이동 view 경로
			forward = new ActionForward();
			forward.setRedirect(false);
			forward.setPath("/WEB-INF/views/board/board_write.jsp");
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
