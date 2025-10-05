package action;

import java.io.IOException;

//Tomcat 9.x javax
//Tomcat 10.x jakarta
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

//앞으로 생성되는 모든 서비스는 Action 인터페이스를 구현하게 하겠다.
public interface Action {
	ActionForward excute(HttpServletRequest request,HttpServletResponse response) throws IOException;
	/*
	내용물 포맷
		ActionForward forward = null;
		try {
			BoardDao service = new BoardDao();
			
			
		

			forward = new ActionForward();
			forward.setRedirect(false);
			forward.setPath("  ");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return forward;
	 */
}
