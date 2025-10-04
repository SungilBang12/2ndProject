package utils;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;

public class EncodingFilter implements Filter {
private String encoding = "UTF-8";
@Override public void init(FilterConfig filterConfig) { String e = filterConfig.getInitParameter("encoding"); if (e != null) encoding = e; }
@Override public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
req.setCharacterEncoding(encoding); res.setCharacterEncoding(encoding); chain.doFilter(req, res);
}
}