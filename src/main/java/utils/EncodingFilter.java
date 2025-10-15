package utils;

import java.io.IOException;

// Tomcat 10.1 (Servlet 6.0) 환경 호환을 위해 javax를 jakarta로 변경
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.annotation.WebInitParam;

/**
 * 모든 요청에 대해 기본 인코딩(UTF-8)을 설정하는 필터입니다.
 * - @WebFilter(urlPatterns = "/*")로 모든 요청을 가로챕니다.
 */
@WebFilter(description = "요청 및 응답 인코딩 설정 필터", 
           urlPatterns = "/*", 
           initParams = { @WebInitParam(name = "encoding", value = "UTF-8") })
public class EncodingFilter implements Filter {
	private String encoding;

	@Override
	public void init(FilterConfig filterConfig) {
		// web.xml이나 @WebInitParam에서 설정된 인코딩 값을 읽어옵니다.
		this.encoding = filterConfig.getInitParameter("encoding");
	}

	@Override
	public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
			throws IOException, ServletException {
        
        // 요청 인코딩 설정
		if (req.getCharacterEncoding() == null) {
			// System.out.println("req 인코딩 추가: " + this.encoding);
			req.setCharacterEncoding(this.encoding);
		}
        
        // 응답 인코딩 설정 (응답 ContentType 설정 전 실행되어야 합니다.)
		if (res.getCharacterEncoding() == null) {
			// System.out.println("res 인코딩 추가: " + this.encoding);
			res.setCharacterEncoding(this.encoding);
		}

		// 다음 필터 또는 서블릿으로 요청을 전달합니다.
		chain.doFilter(req, res);
	}

	@Override
	public void destroy() {
		// 필터 종료 시 자원 해제 로직 (없음)
	}
}
