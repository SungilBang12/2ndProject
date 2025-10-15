package utils;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

import dto.Users;
// FIX: Tomcat 10.1 (Servlet 6.0) 환경 호환을 위해 javax를 jakarta로 변경
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.annotation.WebInitParam;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(description = "어노테이션 활용 필터 처리", urlPatterns = "/*", initParams = {
		@WebInitParam(name = "encoding", value = "UTF-8"), }, asyncSupported = true)
public class EncodingFilter implements Filter {
	private String encoding;

	// 페이지별 권한 정보를 저장할 Map: URI 패턴 -> 필요 ROLE (쉼표로 구분)
	private Map<String, String> pageRoles = new HashMap<>();

	@Override
	public void init(FilterConfig filterConfig) {
		// 불필요한 공백 문자(Invisible character) 제거 및 정리
		this.encoding = filterConfig.getInitParameter("encoding");

		// 🚨 권한이 필요한 페이지 및 필요한 ROLE 정의 (대소문자 구분 확인 필요)
		// /admin/users (사용자 관리 페이지)는 "ADMIN" 권한이 필요합니다.
		pageRoles.put("/admin/users", "ADMIN");
		// /mypage, /update 등은 "USER" (로그인) 권한이 필요합니다.
		pageRoles.put("/mypage", "USER,ADMIN");
		pageRoles.put("/update", "USER,ADMIN");
		pageRoles.put("/withdraw", "USER,ADMIN");
	}

	@Override
	public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
			throws IOException, ServletException {
		if (req.getCharacterEncoding() == null) {
			System.out.println("req 인코딩 추가");
			req.setCharacterEncoding(this.encoding);
		}
		if (res.getCharacterEncoding() == null) {
			System.out.println("res 인코딩 추가");
			res.setCharacterEncoding(this.encoding);
		}

		HttpServletRequest httpRequest = (HttpServletRequest) req;
		HttpServletResponse httpResponse = (HttpServletResponse) res;

		// 1. 요청 URI 정리 (컨텍스트 경로 제거)
		String uri = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());

		// 2. 권한 체크가 필요한 URI인지 확인
		String requiredRole = null;
		for (Map.Entry<String, String> entry : pageRoles.entrySet()) {
			// URI가 정의된 패턴으로 시작하는지 확인
			if (uri.startsWith(entry.getKey())) {
				requiredRole = entry.getValue();
				break;
			}
		}
		// 권한 체크가 필요 없는 페이지 (예: 로그인, 메인, 회원가입)는 통과
		if (requiredRole == null) {
			chain.doFilter(req, res);
			return;
		}
		HttpSession session = httpRequest.getSession(false);
		boolean authorized = false;

		// 3. 세션 체크 및 인가(Authorization) 처리
		if (session != null) {
			Users user = (Users) session.getAttribute("loggedInUser"); // UsersController에서 설정한 세션 이름
			if (user != null && user.getROLE() != null) {
				// 사용자의 권한(user.getROLE())이 페이지에 필요한 권한(requiredRole) 중 하나라도 포함되는지 확인
				String[] roles = requiredRole.split(",");
				for (String role : roles) {
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
			// 4. 권한이 없으면 에러 메시지 출력 후 리다이렉트
			String redirectUrl = "/login"; // 기본적으로 로그인 페이지로 유도
			String alertMessage = "접근 권한이 없습니다. 로그인이 필요합니다.";

			if (session != null && session.getAttribute("loggedInUser") != null) {
				// 로그인되어 있지만 권한(ADMIN/USER)이 부족할 경우
				alertMessage = "관리자 권한이 필요합니다.";
				redirectUrl = "/index.jsp";
			}
			httpResponse.setContentType("text/html; charset=UTF-8");
			PrintWriter out = httpResponse.getWriter();
			out.println("<script>alert('" + alertMessage + "'); location.href='" + redirectUrl + "';</script>");

			// 시큐어 코딩: PrintWriter 사용 후 자원 반환(flush)
			out.flush();
		}
	}

	@Override
	public void destroy() {
		// 필요 시 자원 해제 로직 작성
	}
}
