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
	    // 🚨 디버깅: ServletContext 확인
	    System.out.println("[DEBUG] ServletContext: " + getServletContext());
	    
	    Optional<Properties> configOpt = ConfigLoader.getFirebaseConfig(getServletContext());
	    
	    // 🚨 디버깅: Properties 로드 여부 확인
	    System.out.println("[DEBUG] Firebase Config 로드 여부: " + configOpt.isPresent());

	    if (configOpt.isPresent()) {
	        Properties props = configOpt.get();
	        
	        // 🚨 디버깅: Properties 내용 확인 (apiKey는 일부만)
	        System.out.println("[DEBUG] apiKey 존재: " + (props.getProperty("firebase.apiKey") != null));
//	        System.out.println("[DEBUG] authDomain: " + props.getProperty("firebase.authDomain"));
	        
	        Map<String, String> firebaseConfigMap = new HashMap<>();
	        firebaseConfigMap.put("apiKey", props.getProperty("firebase.apiKey"));
	        firebaseConfigMap.put("authDomain", props.getProperty("firebase.authDomain"));
	        firebaseConfigMap.put("projectId", props.getProperty("firebase.projectId"));
	        firebaseConfigMap.put("storageBucket", props.getProperty("firebase.storageBucket"));
	        firebaseConfigMap.put("messagingSenderId", props.getProperty("firebase.messagingSenderId"));
	        firebaseConfigMap.put("appId", props.getProperty("firebase.appId"));

	        String configJson = new Gson().toJson(firebaseConfigMap);
	        request.setAttribute("firebaseConfigJson", configJson);
//	        System.out.println("[DEBUG] JSP로 전달된 JSON: " + configJson);
	    } else {
	        request.setAttribute("firebaseConfigJson", "{}");
//	        System.err.println("[ERROR] Firebase 설정 로드 실패: JSP에 빈 설정 전달됨.");
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
		} else if ("/myInfo".equals(pathInfo)) { // 🚨 내 정보 수정
			request.getRequestDispatcher("/WEB-INF/view/users/myInfo.jsp").forward(request, response);
		} else if ("/myPosts".equals(pathInfo)) { // 🚨 내가 단 사진
			request.getRequestDispatcher("/WEB-INF/view/users/myPosts.jsp").forward(request, response);
		} else if ("/myComments".equals(pathInfo)) { // 🚨 내가 단 댓글 보기
			request.getRequestDispatcher("/WEB-INF/view/users/myComments.jsp").forward(request, response);
		} else if ("/logout".equals(pathInfo)) {
			handleLogout(request, response);
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
			request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
			return;
		}

		Optional<Users> userOpt = usersService.loginUser(userId, password);
		
		

		if (userOpt.isPresent()) {
			Users user = userOpt.get();

			// 🚨🚨 시큐어 코딩: 세션 고정 공격 방지 (Session Fixation Prevention)
			HttpSession session = request.getSession(true);
			session.invalidate(); // 기존 세션 무효화
			session = request.getSession(true); // 새로운 세션 생성
			
			System.out.println("로그인 정보 = 비밀번호 확인" + user);
			// 패스워드 제거
			user.setPassword(null);

			// 새 세션에 사용자 정보 저장 (비밀번호는 저장하지 않음)
			session.setAttribute("loggedInUser", user);
			session.getId();
			System.out.println("로그인 성공");
			// 메인 페이지로 리다이렉트
			response.sendRedirect(request.getContextPath() + "/index.jsp");
		} else {
			System.out.println("id 비밀번호 오류");
			request.setAttribute("error", "ID 또는 비밀번호가 일치하지 않습니다.");
			request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
		}
	}

	/**
	 * 회원가입 최종 처리 (동기)
	 */
	private void handleJoin(HttpServletRequest request, HttpServletResponse response)
	        throws ServletException, IOException {
	    // 🚨 시큐어 코딩: 모든 입력 데이터는 서버에서 다시 검증해야 합니다.
	    String userId = request.getParameter("userId");
	    String username = request.getParameter("username");
	    String password = request.getParameter("password");
	    String email = request.getParameter("email");
	    String uid = request.getParameter("uid");
	    System.out.println("회원가입 경로 진입");

	    try {
	        // 1. 필수값 누락 체크
	        if (userId == null || userId.isEmpty() || password == null || password.isEmpty() || email == null
	                || email.isEmpty()) {
	            throw new ServiceException("필수 정보(아이디, 비밀번호, 이메일)를 모두 입력해야 합니다.");
	        }

//	     // ❌ 이전: DB에서 인증 상태 체크.
//	        if (!usersService.isEmailVerified(email)) {
//	            throw new ServiceException("이메일 인증이 완료되지 않았습니다. 메일함을 확인하고 인증 링크를 클릭한 후 다시 시도해 주세요.");
//	        }
	        String isEmailVerified = request.getParameter("isEmailVerified");
	        if (!"true".equals(isEmailVerified)) {
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
	        	System.out.println("회원가입 처리 중 오류");
	            request.setAttribute("error", "회원가입 처리 중 오류가 발생했습니다.");
	            
	            // 🚨 [추가] Firebase 설정 다시 로드
	            setFirebaseConfigToRequest(request);
	            
	            request.getRequestDispatcher("/WEB-INF/view/join.jsp").forward(request, response);
	        }
	    } catch (ServiceException e) {
	    	System.out.println(e.getMessage());
	        request.setAttribute("error", e.getMessage());
	        // 🚨 [추가] Firebase 설정 다시 로드
	        setFirebaseConfigToRequest(request);
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