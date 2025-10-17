package ajax;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

import dao.CommentsDao;
import dao.PostDao;
import dto.Comments;
import dto.Post;
import dto.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.users.UsersService;
import service.users.UsersService.ServiceException; // 💡 ServiceException import
import utils.ConnectionPoolHelper;

@WebServlet("/users/ajax/*")
public class UsersAjaxController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UsersService usersService = new UsersService();
    private final PostDao postDao = new PostDao();
    private final CommentsDao commentsDao = new CommentsDao();
    
    // 💡 더 견고한 이메일 정규식 사용
    private static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";
    
    // ✅ LocalDate/LocalDateTime 직렬화 지원하는 Gson 생성
    private final Gson gson = new GsonBuilder()
        .registerTypeAdapter(LocalDate.class, new JsonSerializer<LocalDate>() {
            @Override
            public JsonElement serialize(LocalDate src, java.lang.reflect.Type typeOfSrc, 
                                       JsonSerializationContext context) {
                return new JsonPrimitive(src.format(DateTimeFormatter.ISO_LOCAL_DATE));
            }
        })
        .registerTypeAdapter(LocalDateTime.class, new JsonSerializer<LocalDateTime>() {
            @Override
            public JsonElement serialize(LocalDateTime src, java.lang.reflect.Type typeOfSrc, 
                                       JsonSerializationContext context) {
                return new JsonPrimitive(src.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            }
        })
        .create();

    @Override
    public void init() throws ServletException {
        ConnectionPoolHelper.init(getServletContext());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        response.setContentType("application/json; charset=UTF-8");
        
        // 💡 GET: ID 중복, 이메일 중복, 이메일 인증 상태 확인 (조회 작업)
        if ("/checkId".equals(pathInfo)) {
            try {
				handleCheckId(request, response);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (ServiceException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        } else if ("/checkEmail".equals(pathInfo)) {
            try {
				handleCheckEmail(request, response);
			} catch (IOException e) {
				e.printStackTrace();
			} catch (ServiceException e) {
				e.printStackTrace();
			}
        } else if ("/checkEmailAuthStatus".equals(pathInfo)) {
             try {
				handleCheckEmailAuthStatus(request, response);
			 } catch (IOException e) {
				e.printStackTrace();
			 } catch (ServiceException e) {
				e.printStackTrace();
			 }
        } else if ("/stats".equals(pathInfo)) {
            handleGetStats(request, response);
        } else if ("/recentPosts".equals(pathInfo)) {
            handleGetRecentPosts(request, response);
        } else if ("/recentComments".equals(pathInfo)) {
            handleGetRecentComments(request, response);
        } else if ("/allPosts".equals(pathInfo)) {
            handleGetAllPosts(request, response);
        } else if ("/allComments".equals(pathInfo)) {
            handleGetAllComments(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        response.setContentType("application/json; charset=UTF-8");
        
        if ("/checkId".equals(pathInfo)) {
            try {
				handleCheckId(request, response);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (ServiceException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        } else if ("/delete".equals(pathInfo)) {
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

        try (Connection conn = ConnectionPoolHelper.getConnection()) {

            int postCount = postDao.countPostsByUserId(conn, user.getUserId());
            int commentCount = commentsDao.countByUserId(conn, user.getUserId());

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

    	 HttpSession session = request.getSession(false);
         if (session == null || session.getAttribute("user") == null) {
             response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
             return;
         }

         Users user = (Users) session.getAttribute("user");

         try (Connection conn = ConnectionPoolHelper.getConnection()) {

             List<Comments> posts = postDao.selectCommentsByUserId(conn, user.getUserId());

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
     * 전체 작성한 게시글 조회
     */
    private void handleGetAllPosts(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Users user = (Users) session.getAttribute("user");

        try (Connection conn = ConnectionPoolHelper.getConnection()) {

            List<Post> posts = postDao.selectPostsByUserId(conn, user.getUserId());

            PrintWriter out = response.getWriter();
            out.print(gson.toJson(posts));
            out.flush();

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * 전체 작성한 댓글 조회
     */
    private void handleGetAllComments(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Users user = (Users) session.getAttribute("user");

        try (Connection conn = ConnectionPoolHelper.getConnection()) {

            List<Comments> comments = postDao.selectCommentsByUserId(conn, user.getUserId());

            PrintWriter out = response.getWriter();
            out.print(gson.toJson(comments));
            out.flush();

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
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
    
    
    /**
     * 1. ID 중복 체크 (비동기)
     * 💡 응답 포맷: {"isAvailable": true/false}
     */
    private void handleCheckId(HttpServletRequest request, HttpServletResponse response) throws IOException, ServiceException {
        String userId = request.getParameter("userId");
        boolean exists = false;
        
        // 🚨 시큐어 코딩: 입력값 제한 (서버 측에서도 ID 형식 검사)
        if (userId != null && userId.matches("^[a-zA-Z0-9]{5,20}$")) {
            // Service 호출, 실패 시 ServiceException 발생 가능
			exists = usersService.isUserIdExists(userId);
        } else {
            // ID 형식 유효성 검사 실패 시 HTTP 400 Bad Request
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                 out.print("{\"error\": true, \"message\": \"ID 형식이 올바르지 않습니다.\"}");
            }
            return;
        }
        
        // 🚨 시큐어 코딩: 응답 Content-Type 지정 (XSS 방지)
        response.setContentType("application/json;charset=UTF-8");
        
        // 💡 응답 포맷 통일: exists가 true면 이미 존재하므로, isAvailable은 false가 됨
        String jsonResponse = "{\"isAvailable\": " + !exists + "}";

        // 💡 try-with-resources를 사용하여 flush와 close를 자동 처리
        try (PrintWriter out = response.getWriter()) {
            out.print(jsonResponse);
            out.flush();
        }
    }
    
    /**
     * 2. 이메일 중복 체크 (비동기)
     * 💡 응답 포맷: {"isAvailable": true/false}
     */
    private void handleCheckEmail(HttpServletRequest request, HttpServletResponse response) throws IOException, ServiceException {
        String email = request.getParameter("email");
        boolean exists = false;
        
        if (email == null || email.trim().isEmpty()) {
             // 이메일 값이 아예 없을 경우 (400 Bad Request)
             response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
             response.setContentType("application/json;charset=UTF-8");
             try (PrintWriter out = response.getWriter()) {
                 out.print("{\"error\": true, \"message\": \"이메일 주소를 입력해 주세요.\"}");
             }
             return;
        }
        
        // 🚨 시큐어 코딩: 입력값 제한 (이메일 형식 검사)
        if (email.matches(EMAIL_REGEX)) {
            exists = usersService.isEmailExists(email);
        } else {
             // 이메일 형식이 유효하지 않은 경우 (400 Bad Request)
             response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
             response.setContentType("application/json;charset=UTF-8");
             try (PrintWriter out = response.getWriter()) {
                 out.print("{\"error\": true, \"message\": \"유효한 이메일 형식으로 입력해 주세요.\"}");
             }
             return;
        }
        
        response.setContentType("application/json;charset=UTF-8");
        
        // 💡 응답 포맷 통일: exists가 true면 이미 존재하므로, isAvailable은 false가 됨
        String jsonResponse = "{\"isAvailable\": " + !exists + "}";
        
        // 💡 try-with-resources를 사용하여 flush와 close를 자동 처리
        try (PrintWriter out = response.getWriter()) {
            out.print(jsonResponse);
        }
    }
    
    /**
     * 3. 이메일 인증 상태 체크 (비동기 - join.jsp의 타이머에서 호출)
     * 💡 응답 포맷: {"isVerified": true/false}
     */
    private void handleCheckEmailAuthStatus(HttpServletRequest request, HttpServletResponse response) throws IOException, ServiceException {
        String email = request.getParameter("email");
        boolean isVerified = false;
        
        if (email == null || email.trim().isEmpty() || !email.matches(EMAIL_REGEX)) {
            // 이메일 유효성 검사 실패 시 400 Bad Request
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                 out.print("{\"error\": true, \"message\": \"유효하지 않은 이메일 주소입니다.\"}");
            }
            return;
        }

        // Service를 통해 DB에서 해당 이메일의 is_email_verified 상태를 조회
		isVerified = usersService.isEmailVerified(email);
        
        response.setContentType("application/json;charset=UTF-8");
        
        // JSON 응답 생성
        String jsonResponse = "{\"isVerified\": " + isVerified + "}";
        
        // 💡 try-with-resources를 사용하여 flush와 close를 자동 처리
        try (PrintWriter out = response.getWriter()) {
            out.print(jsonResponse);
        }
    }
}