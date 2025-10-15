package dao;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import dto.Comments;
import utils.ConnectionPoolHelper;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentsDao {

    private static final Gson GSON = new Gson();

    // 글쓴이(user_id) 조회 (댓글 목록에 '글쓴이' 배지용)
    public String getPostWriterId(int postId) throws SQLException {
        final String sql = "SELECT USER_ID FROM POST WHERE POST_ID = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString(1);
            }
        }
        return null;
    }

    // 등록
    public int create(int postId, String userId, String text, String imageUrl) throws SQLException {
        // CONTENT에 JSON 저장 (DB 변경 X)
        JsonObject json = new JsonObject();
        json.addProperty("text", text == null ? "" : text);
        if (imageUrl != null && !imageUrl.isBlank()) json.addProperty("imageUrl", imageUrl);
        json.addProperty("edited", false);
        json.addProperty("deleted", false);
        String contentJson = GSON.toJson(json);

        final String sql =
            "INSERT INTO COMMENTS (COMMENT_ID, POST_ID, USER_ID, CONTENT, CREATED_AT) " +
            "VALUES (SEQ_COMMENTS.NEXTVAL, ?, ?, ?, SYSDATE)";

        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, postId);
            ps.setString(2, userId);
            ps.setString(3, contentJson);
            ps.executeUpdate();

            // 트리거가 NEXTVAL 사용 → 같은 세션에서 CURRVAL로 회수
            try (Statement s = conn.createStatement();
                 ResultSet rs = s.executeQuery("SELECT SEQ_COMMENTS.CURRVAL FROM dual")) {
                if (rs.next()) {
                    int newId = rs.getInt(1);
                    conn.commit();
                    return newId;
                }
            }
            conn.commit();
            return 0;
        }
    }

    // 목록 (페이지네이션)
    public List<Comments> findByPost(int postId, int pageNo, int pageSize, String postWriterId) throws SQLException {
        int end   = pageNo * pageSize;
        int start = end - pageSize + 1;

        String base =
            "SELECT * FROM (" +
            "  SELECT a.*, ROWNUM rnum FROM (" +
            "    SELECT COMMENT_ID, POST_ID, USER_ID, CONTENT, CREATED_AT " +
            "      FROM COMMENTS WHERE POST_ID = ? " +
            "     ORDER BY COMMENT_ID DESC" +
            "  ) a WHERE ROWNUM <= ?" +
            ") WHERE rnum >= ?";

        List<Comments> list = new ArrayList<>();
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(base)) {

            ps.setInt(1, postId);
            ps.setInt(2, end);
            ps.setInt(3, start);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Comments c = map(rs);
                    c.setAuthor(postWriterId != null && postWriterId.equals(c.getUserId()));
                    list.add(c);
                }
            }
        }
        return list;
    }

    public int countByPost(int postId) throws SQLException {
        final String sql = "SELECT COUNT(*) FROM COMMENTS WHERE POST_ID = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    // 소유자 검증용 단건 조회
    public Comments findById(int commentId) throws SQLException {
        final String sql = "SELECT COMMENT_ID, POST_ID, USER_ID, CONTENT, CREATED_AT FROM COMMENTS WHERE COMMENT_ID = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    // 수정 (작성자 본인만). deleted==false 이어야 함
    public int update(int commentId, String userId, String newText, String newImageUrl) throws SQLException {
        Comments origin = findById(commentId);
        if (origin == null) return 0;
        if (!userId.equals(origin.getUserId())) return 0; // 권한

        // 삭제된 댓글이면 수정 불가
        JsonObject json = parseJson(origin.getContentRaw());
        if (json.has("deleted") && json.get("deleted").getAsBoolean()) return 0;

        json.addProperty("text", newText == null ? "" : newText);
        if (newImageUrl != null && !newImageUrl.isBlank()) json.addProperty("imageUrl", newImageUrl);
        else json.remove("imageUrl");
        json.addProperty("edited", true);

        final String sql = "UPDATE COMMENTS SET CONTENT = ? WHERE COMMENT_ID = ? AND USER_ID = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, GSON.toJson(json));
            ps.setInt(2, commentId);
            ps.setString(3, userId);
            int affected = ps.executeUpdate();
            conn.commit();
            return affected;
        }
    }

    // 삭제(소프트) — CONTENT JSON에 deleted=true, text 제거
    public int softDelete(int commentId, String userId) throws SQLException {
        Comments origin = findById(commentId);
        if (origin == null) return 0;
        if (!userId.equals(origin.getUserId())) return 0;

        JsonObject json = parseJson(origin.getContentRaw());
        json.addProperty("deleted", true);
        json.remove("text");     // 표시용 텍스트 제거
        json.remove("imageUrl"); // 이미지 제거

        final String sql = "UPDATE COMMENTS SET CONTENT = ? WHERE COMMENT_ID = ? AND USER_ID = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, GSON.toJson(json));
            ps.setInt(2, commentId);
            ps.setString(3, userId);
            int affected = ps.executeUpdate();
            conn.commit();
            return affected;
        }
    }

    // === 내부 유틸 ===
    private Comments map(ResultSet rs) throws SQLException {
        Comments c = new Comments();
        c.setCommentId(rs.getInt("COMMENT_ID"));
        c.setPostId(rs.getInt("POST_ID"));
        c.setUserId(rs.getString("USER_ID"));
        String raw = rs.getString("CONTENT");
        c.setContentRaw(raw);
        Date cd = rs.getDate("CREATED_AT");
        c.setCreatedAt(cd != null ? cd.toLocalDate() : null);

        // CONTENT 파싱 (과거 평문 대비)
        JsonObject json = parseJson(raw);
        c.setText(json.has("text") ? json.get("text").getAsString() : raw);
        c.setImageUrl(json.has("imageUrl") ? json.get("imageUrl").getAsString() : null);
        c.setEdited(json.has("edited") && json.get("edited").getAsBoolean());
        c.setDeleted(json.has("deleted") && json.get("deleted").getAsBoolean());
        return c;
    }

    private JsonObject parseJson(String raw) {
        try {
            JsonObject o = GSON.fromJson(raw, JsonObject.class);
            return (o == null || o.isJsonNull()) ? new JsonObject() : o;
        } catch (Exception e) {
            // 평문/기존 데이터 호환
            JsonObject o = new JsonObject();
            o.addProperty("text", raw == null ? "" : raw);
            o.addProperty("edited", false);
            o.addProperty("deleted", false);
            return o;
        }
    }
}
