package utils;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

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
		@WebInitParam(name = "encoding", value = "UTF-8"), })
public class EncodingFilter implements Filter {
	private String encoding;
	
	// 페이지별 권한 정보를 저장할 Map
    private Map<String, String> pageRoles = new HashMap<>();

	@Override
	public void init(FilterConfig filterConfig) {
		this.encoding =  filterConfig.getInitParameter("encoding");
		
		// TODO Main에 릴리즈용 권한 변경된 내용 올려두기
		 // web.xml에서 설정한 초기 파라미터나, DB에서 페이지별 권한 정보를 가져와 설정
        // 예시: /adminPage.jsp는 "admin" 권한 필요, /userPage.jsp는 "user" 권한 필요
//        pageRoles.put("/adminPage.jsp", "admin");
//        pageRoles.put("/userPage.jsp", "user");
//        pageRoles.put("/commonPage.jsp", "user,admin"); // 여러 권한 허용 시 쉼표로 구분
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

//		System.out.println("웹 접근시 urlPatterns = /* , 통과");

		
		HttpServletRequest httpRequest = (HttpServletRequest) req;
        HttpServletResponse httpResponse = (HttpServletResponse) res;
        String uri = httpRequest.getRequestURI();

        // 권한 체크가 필요한 페이지인지 확인
        String requiredRole = pageRoles.get(uri);
        
        // 권한 체크가 필요 없는 페이지 (예: 로그인, 메인, 회원가입 페이지)는 통과
        //필터체인 추가
        if (requiredRole == null) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        boolean authorized = false;
        
        // TODO Main에 릴리즈용 권한 변경된 내용 올려두기
        /* 세션체크
        if (session != null) {
            MemberDTO user = (MemberDTO) session.getAttribute("user");
            if (user != null) {
                // 사용자의 권한이 페이지에 필요한 권한 중 하나라도 포함되는지 확인
                String[] roles = requiredRole.split(",");
                for (String role : roles) {
                    if (role.trim().equals(user.getRole())) {
                        authorized = true;
                        break;
                    }
                }
            }
        }
        */

        if (authorized) {
            // 권한이 있으면 페이지 계속 진행
            chain.doFilter(req, res);
        } else {
            // 권한이 없으면 에러 메시지 출력 후 로그인 페이지로 이동
            httpResponse.setContentType("text/html; charset=UTF-8");
            httpResponse.getWriter().println("<script>alert('접근 권한이 없습니다.'); location.href='/index.jsp';</script>");
        }
	}
	
	@Override
	public void destroy() {
		// 필요 시 자원 해제 로직 작성
	}
}