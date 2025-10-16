package controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Properties;

import com.google.gson.Gson;

import action.Action;
import action.ActionForward;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.post.GetPostViewService;
import utils.AblyChatConfig;
import utils.ConfigLoader;

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
		if (urlCommand.equals("/chat.test")) {
			// 홈페이지 이동 view 경로
			setAblyConfigToRequest(request);
			forward = new ActionForward();
			forward.setRedirect(false);
			forward.setPath("/public/schedule-chat-example.jsp");
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
	
	private void setAblyConfigToRequest(HttpServletRequest request) {
	    // 🚨 디버깅: ServletContext 확인
	    System.out.println("[DEBUG] ServletContext: " + getServletContext());
	    
	    Optional<Properties> configOpt = AblyChatConfig.getAblyConfig(getServletContext());
	    
	    // 🚨 디버깅: Properties 로드 여부 확인
	    System.out.println("[DEBUG] ably Config 로드 여부: " + configOpt.isPresent());

	    if (configOpt.isPresent()) {
	        Properties props = configOpt.get();
	        
	        System.out.println(props);
	        
	        // 🚨 디버깅: Properties 내용 확인 (apiKey는 일부만)
	        System.out.println("[DEBUG] pubKey 존재: " + (props.getProperty("ably.pubkey") != null));
//	        System.out.println("[DEBUG] authDomain: " + props.getProperty("firebase.authDomain"));
	        
	        Map<String, String> AblyConfigMap = new HashMap<>();
	        AblyConfigMap.put("pubKey", props.getProperty("ably.pubkey"));

	        String configJson = new Gson().toJson(AblyConfigMap);
	        
	        System.out.println(configJson);
	        request.setAttribute("ablyConfigJson", configJson);
//	        System.out.println("[DEBUG] JSP로 전달된 JSON: " + configJson);
	    } else {
	        request.setAttribute("ablyConfigJson", "{}");
//	        System.err.println("[ERROR] Firebase 설정 로드 실패: JSP에 빈 설정 전달됨.");
	    }
	}

}
