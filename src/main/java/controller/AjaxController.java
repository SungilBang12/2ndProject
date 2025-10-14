package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;


// 비동기 통신 컨트롤러
@WebServlet("*.async")
public class AjaxController extends HttpServlet {
	private static final long serialVersionUID = 1L;

    public AjaxController() {
        super();
    }
    private void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	
    	String requestUri = request.getRequestURI();
		String contextPath = request.getContextPath();
		String urlCommand = requestUri.substring(contextPath.length());

		System.out.println(urlCommand);
		
		/*
		public class CreateEmpService{
	public void createEmpService(HttpServletRequest request, HttpServletResponse response) throws IOException {
		try {
			EmpDao service = new EmpDao();
			String empno = request.getParameter("empno");
			String ename = request.getParameter("ename");
			String sal = request.getParameter("sal");
			String hiredate = request.getParameter("hiredate");
			String deptno = request.getParameter("deptno");
			String mgr = request.getParameter("mgr");
			System.out.println(empno);
			System.out.println(ename);
			System.out.println(sal);
			System.out.println(hiredate);
			System.out.println(deptno);
			System.out.println(empno);
			System.out.println(mgr);
			
			
			EmpDto emp = EmpDto.builder()
			.empno(Integer.parseInt(empno))
			.ename(ename)
			.sal(Integer.parseInt(sal))
			.hiredate(LocalDate.parse(hiredate))
			.deptno(Integer.parseInt(deptno))
			.mgr(Integer.parseInt(mgr))
			.build();

			System.out.println("Create SErvice 정보" + emp);
			
			int result = service.createEmp(emp);
			System.out.println(result);
		    // JSON 변환
			response.setContentType("application/json; charset=UTF-8");
		    Gson gson = new Gson();
		    String json = gson.toJson(result);
		    // 응답 세팅
		    response.getWriter().write(json);
		} catch (Exception e) {
			e.printStackTrace();
			// 예외 발생 시에도 JSON 응답
		    response.setContentType("application/json; charset=UTF-8");
		    response.getWriter().write("{\"success\":false, \"message\":\"서버 오류\"}");
		}
	}
}
		 */
		
		if(urlCommand.equals("/CreateReply.async")) {
//	    	CreateReplyService crs = new CreateReplyService();
//			crs.createReply(request, response);
    	}else if(urlCommand.equals("/postList.async")) {
    		new service.post.PostListService().getPostList(request, response);
    		return;
    		
    	}else if(urlCommand.equals("/ . async")) {
    	
    	}else if (urlCommand.equals("/CommentsList.async")) {
    	    new service.post.CommentsListAsyncService().handle(request, response);
    	    return;
    	} else if (urlCommand.equals("/CommentsCreate.async")) {
    	    new service.post.CreateCommentAsyncService().handle(request, response);
    	    return;
    	} else if (urlCommand.equals("/CommentsUpdate.async")) {
    	    new service.post.UpdateCommentAsyncService().handle(request, response);
    	    return;
    	} else if (urlCommand.equals("/CommentsDelete.async")) {
    	    new service.post.DeleteCommentAsyncService().handle(request, response);
    	    return;
    	}
    }

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}

}
