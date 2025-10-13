package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;

import javax.sql.DataSource;

import dto.Post;
import jakarta.servlet.http.HttpServletRequest;

public class PostDaoImpl {
    private final DataSource ds;

    public PostDaoImpl(DataSource ds) { this.ds = ds; }

    public Integer insert(HttpServletRequest req) {
        // 1) 요청 → DTO 매핑 (세션 포함)
        Post post = buildPostFromRequest(req);
        // 2) 실제 INSERT
        return insert(post);
    }

    private Post buildPostFromRequest(HttpServletRequest req) {
        // 파라미터 수집
        String title   = trim(req.getParameter("title"));
        String content = req.getParameter("content"); // HTML 그대로 저장 전제
        String listId  = req.getParameter("listId");

        // 세션 사용자
        String userId = (String) req.getSession().getAttribute("LOGIN_USER_ID");
        if (userId == null) {
            throw new IllegalStateException("로그인이 필요합니다.");
        }

        // 유효성 체크 (필요 최소)
        if (title == null || title.isEmpty()) {
            throw new IllegalArgumentException("제목은 필수입니다.");
        }
        if (title.length() > 100) {
            throw new IllegalArgumentException("제목은 100자 이내여야 합니다.");
        }
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("내용은 필수입니다.");
        }

        // DTO 구성 (서버 책임 필드 세팅)
        Post p = new Post();
        p.setUserId(userId);
        p.setListId(parseOrDefault(listId, 1));
        p.setTitle(title);
        p.setContent(content);
        p.setHit(0);
        p.setCreatedAt(LocalDate.now());
        p.setUpdatedAt(LocalDate.now());
        return p;
    }

    private static String trim(String s) { return s == null ? null : s.trim(); }
    private static int parseOrDefault(String s, int def) {
        try { return s == null ? def : Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    public Integer insert(Post post) {
        String sql = "INSERT INTO posts (user_id, list_id, title, content, hit, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection c = ds.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, post.getUserId());
            ps.setInt(2, post.getListId());
            ps.setString(3, post.getTitle());
            ps.setString(4, post.getContent());
            ps.setInt(5, post.getHit() == null ? 0 : post.getHit());
            ps.setDate(6, Date.valueOf(post.getCreatedAt()));
            ps.setDate(7, Date.valueOf(post.getUpdatedAt()));
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Post insert failed", e);
        }
    }
}

