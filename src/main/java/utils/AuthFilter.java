package utils;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

import action.ActionForward;
import dto.Users;

// Tomcat 10.1 (Servlet 6.0) 환경 호환을 위해 javax를 jakarta로 변경
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.post.CreatePostService;
import service.post.GetPostEditFormService;
import service.post.GetPostViewService;
import service.post.UpdatePostService;

/**
 * 사용자 인증(Authentication) 및 인가(Authorization)를 처리하는 필터입니다.
 * - 로그인 정보 (USER 역할)와 관리자 권한 (ADMIN 역할)을 체크합니다.
 * - urlPatterns는 인코딩 필터와 달리 접근 통제가 필요한 경로만 지정하는 것이 일반적입니다.
 * 현재는 /*로 설정하여 모든 요청을 가로채고 Map을 기반으로 체크합니다.
 */
@WebFilter(description = "접근 및 권한 확인 필터", urlPatterns = "/*")
public class AuthFilter implements Filter {

	// 페이지별 권한 정보를 저장할 Map: URI 패턴 -> 필요 ROLE (쉼표로 구분)
	private Map<String, String> pageRoles = new HashMap<>();

	@Override
	public void init(FilterConfig filterConfig) {
		// 🚨 권한이 필요한 페이지 및 필요한 ROLE 정의
        // /users/myInfo, /users/myPosts, /users/myComments 는 로그인(USER) 권한이 필요합니다.
        // 이 경로는 앞에서 LoginCheckFilter를 통해 별도 처리할 수 있지만, 여기서는 AuthFilter에 통합 처리합니다.
        pageRoles.put("/users/myInfo", "USER");
        pageRoles.put("/users/update", "USER");
		pageRoles.put("/users/myPosts", "USER,ADMIN");
		pageRoles.put("/users/myComments", "USER,ADMIN");
		pageRoles.put("/users/logout", "USER,ADMIN");
		
		// --- 동기(Synchronous) 게시글 처리 ---
        // 게시글 작성 폼 조회 (작성하려면 USER여야 함)
        pageRoles.put("/editor.post", "USER");
        // 게시글 상세 조회 (일반적으로 로그인 필요)
        pageRoles.put("/post-detail.post", "USER,ADMIN"); 
        // 게시글 수정 폼 조회
        pageRoles.put("/post-edit-form.post", "USER");
        // 게시글 수정 처리
        pageRoles.put("/update.post", "USER");
        // 노을 페이지 (일반적으로 게시판 관련 접근 시 로그인 필요)
        pageRoles.put("/ssp.post", "USER");
        // 게시글 생성 처리
        pageRoles.put("/create.post", "USER");
        
     // --- 비동기(Async) 게시글 처리 ---
        // 비동기 게시글 생성
        pageRoles.put("/create.postasync", "USER");
        // 비동기 게시글 수정
        pageRoles.put("/update.postasync", "USER");
        // 비동기 게시글 삭제
        pageRoles.put("/delete.postasync", "USER,ADMIN");

        // --- 비동기(Async) 댓글 처리 ---
        // 댓글 생성
        pageRoles.put("/CommentsCreate.async", "USER");
        // 댓글 수정
        pageRoles.put("/CommentsUpdate.async", "USER");
        // 댓글 삭제
        pageRoles.put("/CommentsDelete.async", "USER,ADMIN");

		
		pageRoles.put("/admin/editor", "ADMIN");
		// /admin/users (사용자 관리 페이지)는 "ADMIN" 권한이 필요합니다.
		pageRoles.put("/admin/users", "ADMIN");
	}

	@Override
	public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
			throws IOException, ServletException {
		
		HttpServletRequest httpRequest = (HttpServletRequest) req;
		HttpServletResponse httpResponse = (HttpServletResponse) res;

		// 1. 요청 URI 정리 (컨텍스트 경로 제거)
		String uri = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());

		// 2. 권한 체크가 필요한 URI인지 확인
		String requiredRole = null;
		for (Map.Entry<String, String> entry : pageRoles.entrySet()) {
			// URI가 정의된 패턴으로 시작하는지 확인 (정확한 매칭을 위해선 equalsIgnoreCase가 좋으나, startsWith 유지)
			if (uri.startsWith(entry.getKey())) {
				requiredRole = entry.getValue();
				break;
			}
		}
        
		// 권한 체크가 필요 없는 페이지 (예: 메인, 로그인, 회원가입)는 통과
		if (requiredRole == null) {
			chain.doFilter(req, res);
			return;
		}
        
		// 3. 권한 체크가 필요한 경우 세션 및 인가(Authorization) 처리 시작
		HttpSession session = httpRequest.getSession(false);
		boolean authorized = false;

		if (session != null) {
			// 로그인 세션 이름은 "user" 대신 "loggedInUser"를 사용한다고 가정합니다. (기존 코드 유지)
			Users user = (Users) session.getAttribute("user"); 
            
			if (user != null && user.getROLE() != null) {
				// 사용자의 권한(user.getROLE())이 페이지에 필요한 권한(requiredRole) 중 하나라도 포함되는지 확인
				String[] roles = requiredRole.split(",");
				for (String role : roles) {
					// 역할 비교 시 대소문자 구분 없이 처리 (equalsIgnoreCase)
					if (role.trim().equalsIgnoreCase(user.getROLE().trim())) {
						authorized = true;
						break;
					}
				}
			}
		}
        
		if (authorized) {
			// 권한이 있으면 페이지 계속 진행
			chain.doFilter(req, res);
		} else {
			// 4. 권한이 없으면 에러 메시지 출력 후 리다이렉트 (보안 가이드 준수)
			
			String redirectUrl = httpRequest.getContextPath() + "/users/login"; // 기본적으로 로그인 페이지로 유도
			String alertMessage = "접근 권한이 없습니다. 로그인이 필요합니다.";

			if (session != null && session.getAttribute("user") != null) {
				// 로그인되어 있지만 권한(ADMIN/USER)이 부족할 경우
				alertMessage = "접근 권한이 부족합니다. 관리자에게 문의하세요.";
                // 권한 부족 시 메인 페이지 또는 이전 페이지로 이동
				redirectUrl = httpRequest.getHeader("referer") != null 
                              ? httpRequest.getHeader("referer") 
                              : httpRequest.getContextPath() + "/"; 
			}
            
			httpResponse.setContentType("text/html; charset=UTF-8");
			PrintWriter out = null;
            
			try {
				out = httpResponse.getWriter();
				// 🚨 KISA 시큐어 코딩: HTML/JS 코드가 섞인 출력 시 XSS 방지 처리 필요
                // 여기서는 alert 메시지를 고정 문자열로 사용하므로 위험도가 낮지만, 
                // 사용자 입력이 포함된다면 반드시 인코딩해야 합니다.
				out.println("<script>");
				out.println("alert('" + alertMessage + "');");
				out.println("location.href='" + redirectUrl + "';");
				out.println("</script>");
				out.flush(); // 자원 반환
			} finally {
				if (out != null) {
					out.close(); // PrintWriter 닫기
				}
			}
		}
	}

	@Override
	public void destroy() {
		// 필요 시 자원 해제 로직 작성
	}
}
