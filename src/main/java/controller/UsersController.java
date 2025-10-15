package controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Properties;

import com.google.gson.Gson;

import dto.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.users.UsersService;
import service.users.UsersService.ServiceException;
import utils.ConfigLoader;

@WebServlet("/users/*")
public class UsersController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final UsersService usersService = new UsersService();

	/**
     * ServletContext에서 Firebase 설정 Properties를 로드하여 JSON으로 변환 후 request에 저장합니다.
     */
    private void setFirebaseConfigToRequest(HttpServletRequest request) {
        // ConfigLoader를 사용하여 ServletContext에서 설정값을 가져옵니다.
        Optional<Properties> configOpt = ConfigLoader.getFirebaseConfig(getServletContext());
        
        if (configOpt.isPresent()) {
            Properties props = configOpt.get();
            Map<String, String> firebaseConfigMap = new HashMap<>();

            // Properties에서 필요한 값들을 가져와 Map에 담습니다.
            firebaseConfigMap.put("apiKey", props.getProperty("firebase.apiKey"));
            firebaseConfigMap.put("authDomain", props.getProperty("firebase.authDomain"));
            firebaseConfigMap.put("projectId", props.getProperty("firebase.projectId"));
            firebaseConfigMap.put("storageBucket", props.getProperty("firebase.storageBucket"));
            firebaseConfigMap.put("messagingSenderId", props.getProperty("firebase.messagingSenderId"));
            firebaseConfigMap.put("appId", props.getProperty("firebase.appId"));

            // Map을 JSON 문자열로 변환하여 JSP로 전달합니다.
            String configJson = new Gson().toJson(firebaseConfigMap);
            request.setAttribute("firebaseConfigJson", configJson);
            
        } else {
            // 설정 로드 실패 시 빈 JSON 문자열 전달
            request.setAttribute("firebaseConfigJson", "{}");
            System.err.println("Firebase 설정 로드 실패: JSP에 빈 설정 전달됨.");
        }
    }
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String pathInfo = request.getPathInfo();

		// 간단한 페이지 이동 처리
		if ("/login".equals(pathInfo)) {
			request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
		} else if ("/join".equals(pathInfo)) {
			// 🚨 Firebase 설정 정보를 ServletContext에서 로드하여 JSP로 전달
            setFirebaseConfigToRequest(request); 
			request.getRequestDispatcher("/WEB-INF/view/join.jsp").forward(request, response);
		} else if ("/logout".equals(pathInfo)) {
			handleLogout(request, response);
		} else if ("/admin/users".equals(pathInfo)) {
			// 필터에서 ADMIN 권한 체크 완료 후 여기로 진입함
			// 여기서는 사용자 목록 조회 로직이 필요
			request.getRequestDispatcher("/WEB-INF/views/admin/user_management.jsp").forward(request, response);
		} else {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String pathInfo = request.getPathInfo();

		if ("/join".equals(pathInfo)) {
			handleJoin(request, response);
		} else if ("/login".equals(pathInfo)) {
			handleLogin(request, response);
		} else {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
		}
	}

	/**
	 * 1. 로그인 처리
	 */
	private void handleLogin(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// 🚨 시큐어 코딩: Null 및 Empty 체크
		String userId = request.getParameter("userId");
		String password = request.getParameter("password");

		if (userId == null || userId.isEmpty() || password == null || password.isEmpty()) {
			request.setAttribute("error", "ID와 비밀번호를 모두 입력해야 합니다.");
			request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
			return;
		}

		Optional<Users> userOpt = usersService.loginUser(userId, password);

		if (userOpt.isPresent()) {
			Users user = userOpt.get();

			// 🚨🚨 시큐어 코딩: 세션 고정 공격 방지 (Session Fixation Prevention)
			HttpSession session = request.getSession(true);
			session.invalidate(); // 기존 세션 무효화
			session = request.getSession(true); // 새로운 세션 생성

			// 새 세션에 사용자 정보 저장 (비밀번호는 저장하지 않음)
			session.setAttribute("loggedInUser", user);
			session.getId();
			System.out.println("로그인 성공");
			// 메인 페이지로 리다이렉트
			response.sendRedirect(request.getContextPath() + "/index.jsp");
		} else {
			request.setAttribute("error", "ID 또는 비밀번호가 일치하지 않습니다.");
			request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
		}
	}

	/**
	 * 회원가입 최종 처리 (동기)
	 */
	private void handleJoin(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// 🚨 시큐어 코딩: 모든 입력 데이터는 서버에서 다시 검증해야 합니다. (KISA: 입력 데이터 검증)
		String userId = request.getParameter("userId");
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String email = request.getParameter("email");

		try {
			// 1. 필수값 누락 체크
			if (userId == null || userId.isEmpty() || password == null || password.isEmpty() || email == null
					|| email.isEmpty()) {
				throw new ServiceException("필수 정보(아이디, 비밀번호, 이메일)를 모두 입력해야 합니다.");
			}

			// 2. 🚨 핵심 로직: 최종 회원가입 직전, 서버에서 이메일 인증 상태를 다시 확인합니다.
			if (!usersService.isEmailVerified(email)) {
				throw new ServiceException("이메일 인증이 완료되지 않았습니다. 메일함을 확인하고 인증 링크를 클릭한 후 다시 시도해 주세요.");
			}

			// 3. 사용자 객체 생성
			Users user = Users.builder().userId(userId).username(username).password(password).email(email).ROLE("USER")
					.isEmailVerified(true) // DB에 저장할 때 인증 상태 반영
					.build();

			if (usersService.joinUser(user)) {
				// 성공 시 로그인 페이지로 리다이렉트 (PRG 패턴 권장)
				response.sendRedirect(request.getContextPath() + "/users/login?msg=joinSuccess");
			} else {
				request.setAttribute("error", "회원가입 처리 중 오류가 발생했습니다.");
				request.getRequestDispatcher("/WEB-INF/view/join.jsp").forward(request, response);
			}
		} catch (ServiceException e) {
			request.setAttribute("error", e.getMessage());
			request.getRequestDispatcher("/WEB-INF/view/join.jsp").forward(request, response);
		}
	}

	/**
	 * 3. 로그아웃 처리
	 */
	private void handleLogout(HttpServletRequest request, HttpServletResponse response) throws IOException {
		HttpSession session = request.getSession(false);
		if (session != null) {
			// 🚨 시큐어 코딩: 세션 무효화
			session.invalidate();
		}
		response.sendRedirect(request.getContextPath() + "/index.jsp");
	}
}