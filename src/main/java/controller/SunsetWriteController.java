package controller;

import dao.PostDao;
import dto.Post;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.lang.reflect.Method;

/**
 * 노을(앨범) 글쓰기 폼 + 저장
 * GET  /post/write   -> 폼 표시
 * POST /post/create  -> 저장 후 /sunset.jsp로 이동
 *
 * 기존 MVC2 구조 유지 + AjaxController(*.async)와 충돌 없음
 */
@WebServlet({"/post/write", "/post/create"})
public class SunsetWriteController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 실제 노을 게시판 listId로 교체 가능
    private static final int SUNSET_LIST_ID = 11;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("listId", SUNSET_LIST_ID);
        RequestDispatcher rd = req.getRequestDispatcher("/WEB-INF/view/post/sunset-write.jsp");
        rd.forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String title    = nvl(req.getParameter("title"));
        String content  = nvl(req.getParameter("content"));
        String thumbUrl = nvl(req.getParameter("thumbUrl"));
        Integer listId  = parseIntOr(req.getParameter("listId"), SUNSET_LIST_ID);

        try {
            Post p = new Post();
            // dto.Post 세터명이 프로젝트마다 다를 수 있어 안전하게 리플렉션으로 시도
            callSetter(p, "setTitle",        String.class,  title);
            callSetter(p, "setContent",      String.class,  content);
            callSetter(p, "setListId",       Integer.class, listId);
            callSetter(p, "setThumbnailUrl", String.class,  thumbUrl); // 없으면 무시됨

            PostDao dao = new PostDao();
            // PostDao 저장 메서드 명이 다를 수 있어 후보군 순차 시도
            if (!invokeOne(dao, "createPost", Post.class, p))
                if (!invokeOne(dao, "insertPost", Post.class, p))
                    if (!invokeOne(dao, "create", Post.class, p))
                        throw new NoSuchMethodException("PostDao에 createPost/insertPost/create 메서드를 찾을 수 없음");

            resp.sendRedirect(req.getContextPath() + "/sunset.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            // 실패 시 폼으로 되돌리되 입력 보존
            req.setAttribute("error", "저장 중 오류가 발생했습니다.");
            req.setAttribute("title", title);
            req.setAttribute("content", content);
            req.setAttribute("thumbUrl", thumbUrl);
            req.setAttribute("listId", listId);
            RequestDispatcher rd = req.getRequestDispatcher("/WEB-INF/view/post/sunset-write.jsp");
            rd.forward(req, resp);
        }
    }

    private String nvl(String s){ return (s == null) ? "" : s.trim(); }
    private Integer parseIntOr(String s, Integer def){
        try { return (s == null || s.isBlank()) ? def : Integer.parseInt(s); }
        catch (Exception e){ return def; }
    }

    private void callSetter(Object target, String name, Class<?> argType, Object value){
        try {
            Method m = target.getClass().getMethod(name, argType);
            m.invoke(target, value);
        } catch (Exception ignore) {}
    }
    private boolean invokeOne(Object target, String name, Class<?> argType, Object arg){
        try {
            Method m = target.getClass().getMethod(name, argType);
            m.invoke(target, arg);
            return true;
        } catch (Exception e) { return false; }
    }
}
