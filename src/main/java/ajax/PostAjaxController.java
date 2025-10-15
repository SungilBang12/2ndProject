package ajax;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.stream.Collectors;

import jakarta.servlet.AsyncContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.post.PostAsyncService;

//모든 비동기 POST 요청을 처리
@WebServlet(urlPatterns = "*.postasync", asyncSupported = true)

public class PostAjaxController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private final PostAsyncService postAsyncService = new PostAsyncService();

    protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws IOException {
        
        // 1. AsyncContext 시작
        final AsyncContext asyncContext = request.startAsync();
        
        // 2. 요청 데이터 읽기 (메인 스레드에서 처리)
        final String jsonData;
        try (BufferedReader reader = request.getReader()) {
            jsonData = reader.lines().collect(Collectors.joining(System.lineSeparator()));
        } catch (IOException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Failed to read request data.");
            asyncContext.complete();
            return;
        }

        // 3. 요청 URI 분석 및 Service 위임
        String requestURI = request.getRequestURI();
        
        if (requestURI.endsWith("/create.postasync")) {
            postAsyncService.createPostAsync(asyncContext, jsonData);
            
        } else if (requestURI.endsWith("/update.postasync")) {
            postAsyncService.updatePostAsync(asyncContext, jsonData);
            
        } else if (requestURI.endsWith("/delete.postasync")) {
            postAsyncService.deletePostAsync(asyncContext, jsonData);
            
        } else {
            // 매핑된 작업이 없는 경우
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Async action not found.");
            asyncContext.complete();
        }
        
        // Controller의 doPost 메서드는 즉시 리턴됩니다.
    }

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}

}
