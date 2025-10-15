package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import com.google.gson.JsonObject;
import service.post.PostListService;
import service.post.PostSearchService;

@WebServlet("*.async")
public class AjaxController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public AjaxController() {
        super();
    }

    private void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String requestUri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String urlCommand = requestUri.substring(contextPath.length());

        System.out.println("[AjaxController] 요청: " + urlCommand);

        if (urlCommand.equals("/postList.async")) {
            String sort = request.getParameter("sort");
            int page = Integer.parseInt(request.getParameter("page"));
            int limit = Integer.parseInt(request.getParameter("limit"));
            String query = request.getParameter("q"); // ✅ 검색어 추가

            PostListService service = new PostListService();
            JsonObject result = service.getPostList(sort, page, limit, query);

            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write(result.toString());
            return;

        } else if (urlCommand.equals("/postSearch.async")) {
            String keyword = request.getParameter("q");
            PostSearchService searchService = new PostSearchService();
            JsonObject result = searchService.getSearchResults(keyword);

            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write(result.toString());
            return;
        }

        // 기타 비동기 서비스 (댓글 등)
        else if (urlCommand.equals("/CommentsList.async")) {
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

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doProcess(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doProcess(request, response);
    }
}
