package ajax;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;

import dao.PostDao;
import dto.Post;
import dto.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.users.UsersService;
// ❌ import utils.DBUtil;  // 제거
import utils.ConnectionPoolHelper;         // ✅ 추가

@WebServlet("/users/ajax/*")
public class UsersAjaxController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UsersService usersService = new UsersService();
    private final PostDao postDao = new PostDao();
    private final Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        // ✅ 컨텍스트에 심어둔 DataSource를 기반으로 헬퍼 초기화
        // (리스너나 스타트업에서 DbConfig.createDataSource(...) 후 context.setAttribute("datasource", ds) 되어 있어야 함)
        ConnectionPoolHelper.init(getServletContext());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        response.setContentType("application/json; charset=UTF-8");

        if ("/stats".equals(pathInfo)) {
            handleGetStats(request, response);
        } else if ("/recentPosts".equals(pathInfo)) {
            handleGetRecentPosts(request, response);
        } else if ("/recentComments".equals(pathInfo)) {
            handleGetRecentComments(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        response.setContentType("application/json; charset=UTF-8");

        if ("/delete".equals(pathInfo)) {
            handleDeleteUser(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * 사용자 통계 조회
     */
    private void handleGetStats(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Users user = (Users) session.getAttribute("user");

        // ✅ try-with-resources로 자동 반납
        try (Connection conn = ConnectionPoolHelper.getConnection()) {

            int postCount = postDao.countPostsByUserId(conn, user.getUserId());
            // TODO: 댓글 수 조회 (CommentDao 구현 필요)
            int commentCount = 0;

            Map<String, Integer> stats = new HashMap<>();
            stats.put("postCount", postCount);
            stats.put("commentCount", commentCount);

            PrintWriter out = response.getWriter();
            out.print(gson.toJson(stats));
            out.flush();

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * 최근 작성한 글 조회
     */
    private void handleGetRecentPosts(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Users user = (Users) session.getAttribute("user");

        // ✅ try-with-resources로 자동 반납
        try (Connection conn = ConnectionPoolHelper.getConnection()) {

            List<Post> posts = postDao.selectPostsByUserId(conn, user.getUserId());

            // 최근 5개만
            if (posts.size() > 5) {
                posts = posts.subList(0, 5);
            }

            PrintWriter out = response.getWriter();
            out.print(gson.toJson(posts));
            out.flush();

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * 최근 작성한 댓글 조회
     */
    private void handleGetRecentComments(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // TODO: CommentDao 구현 후 작성
        PrintWriter out = response.getWriter();
        out.print("[]");
        out.flush();
    }

    /**
     * 회원 탈퇴 처리
     */
    private void handleDeleteUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Users user = (Users) session.getAttribute("user");
        String password = request.getParameter("password");

        Map<String, Object> result = new HashMap<>();

        try {
            if (usersService.deleteUser(user.getUserId(), password)) {
                session.invalidate();
                result.put("success", true);
                result.put("message", "회원 탈퇴가 완료되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "회원 탈퇴 처리에 실패했습니다.");
            }
        } catch (UsersService.ServiceException e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }

        PrintWriter out = response.getWriter();
        out.print(gson.toJson(result));
        out.flush();
    }
}
