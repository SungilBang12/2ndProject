package ajax;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.users.UsersService;
import service.users.UsersService.ServiceException; // 💡 ServiceException import

@WebServlet("/users/ajax/*")
public class UsersAjaxController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UsersService usersService = new UsersService();
    
    // 💡 더 견고한 이메일 정규식 사용
    private static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        // 💡 GET: ID 중복, 이메일 중복, 이메일 인증 상태 확인 (조회 작업)
        if ("/checkId".equals(pathInfo)) {
            handleCheckId(request, response);
        } else if ("/checkEmail".equals(pathInfo)) {
            handleCheckEmail(request, response);
        } else if ("/checkEmailAuthStatus".equals(pathInfo)) {
             handleCheckEmailAuthStatus(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 💡 POST: 이 곳은 일반적으로 실제 데이터를 변경하는 작업에 사용되며, 
        // 중복 체크는 GET으로 처리하는 것이 RESTful 원칙에 맞음.
        // checkId만 POST를 허용하도록 유지합니다.
        String pathInfo = request.getPathInfo();
        
        if ("/checkId".equals(pathInfo)) {
            handleCheckId(request, response);
        } else {
            // 다른 AJAX POST 요청은 지원하지 않음
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * 1. ID 중복 체크 (비동기)
     * 💡 응답 포맷: {"isAvailable": true/false}
     */
    private void handleCheckId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String userId = request.getParameter("userId");
        boolean exists = false;
        
        // 🚨 시큐어 코딩: 입력값 제한 (서버 측에서도 ID 형식 검사)
        if (userId != null && userId.matches("^[a-zA-Z0-9]{5,20}$")) {
            try {
                // Service 호출, 실패 시 ServiceException 발생 가능
                exists = usersService.isUserIdExists(userId);
            } catch (ServiceException e) {
                // 💡 DB 오류 등의 ServiceException 발생 시 HTTP 500 반환 (에러 메시지 포함)
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("application/json;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"error\": true, \"message\": \"" + e.getMessage() + "\"}");
                }
                return;
            }
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
    private void handleCheckEmail(HttpServletRequest request, HttpServletResponse response) throws IOException {
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
            try {
                exists = usersService.isEmailExists(email); 
            } catch (ServiceException e) {
                 // 💡 DB 오류 등의 ServiceException 발생 시 HTTP 500 반환
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("application/json;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"error\": true, \"message\": \"" + e.getMessage() + "\"}");
                }
                return;
            }
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
    private void handleCheckEmailAuthStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
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

        try {
            // Service를 통해 DB에서 해당 이메일의 is_email_verified 상태를 조회
            isVerified = usersService.isEmailVerified(email); 
        } catch (ServiceException e) {
             // 💡 DB 오류 등의 ServiceException 발생 시 HTTP 500 반환
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\": true, \"message\": \"" + e.getMessage() + "\"}");
            }
            return;
        }
        
        response.setContentType("application/json;charset=UTF-8");
        
        // JSON 응답 생성
        String jsonResponse = "{\"isVerified\": " + isVerified + "}";
        
        // 💡 try-with-resources를 사용하여 flush와 close를 자동 처리
        try (PrintWriter out = response.getWriter()) {
            out.print(jsonResponse);
        }
    }
}
