package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.google.gson.JsonObject;

import dto.Post;
import utils.ConnectionPoolHelper;
import utils.s3.R2Helper;

public class PostDao {

    // CREATE
    public int createPost(Post post) {
        String sql = "INSERT INTO Post (postId ,userId, listId, title, post_content, hit) VALUES (post_seq.NEXTVAL,?, ?, ?, ?, ?)";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql,  new String[]{"postId"})) {
        	System.out.println(post.toString());

            pstmt.setString(1, post.getUserId());
            if (post.getListId() != null) {
                pstmt.setInt(2, post.getListId());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            pstmt.setString(3, post.getTitle());
            pstmt.setString(4, post.getContent());
            if (post.getHit() != null) {
                pstmt.setInt(5, post.getHit());
            } else {
                pstmt.setInt(5, 0);
            }

            int affectedRows = pstmt.executeUpdate();
            int postId = 0;
            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    postId = rs.getInt(1);
                }
            }
            conn.commit();
            return postId;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // READ - 단건 조회
    public Post getPostById(int postId) {
        String sql = "SELECT * FROM Post WHERE postId = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToPost(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // READ - 전체 조회
    public List<Post> getAllPosts() {
        String sql = "SELECT * FROM Post ORDER BY created_at DESC";
        List<Post> posts = new ArrayList<>();

        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                posts.add(mapRowToPost(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return posts;
    }

    // UPDATE
    public int updatePost(Post post) {
        String sql = "UPDATE Post SET title = ?, content = ?, listId = ?, hit = ? WHERE postId = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, post.getTitle());
            pstmt.setString(2, post.getContent());
            if (post.getListId() != null) {
                pstmt.setInt(3, post.getListId());
            } else {
                pstmt.setNull(3, Types.INTEGER);
            }
            if (post.getHit() != null) {
                pstmt.setInt(4, post.getHit());
            } else {
                pstmt.setInt(4, 0);
            }
            pstmt.setInt(5, post.getPostId());

            return pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // DELETE
    public int deletePost(int postId) {
        String sql = "DELETE FROM Post WHERE postId = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, postId);
            return pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ResultSet → Post 매핑
    private Post mapRowToPost(ResultSet rs) throws SQLException {
        Post post = new Post();
        post.setUserId(rs.getString("userId"));
        int listId = rs.getInt("listId");
        if (!rs.wasNull()) post.setListId(listId);
        post.setTitle(rs.getString("title"));
        post.setContent(rs.getString("content"));
        post.setHit(rs.getInt("hit"));
        post.setCreatedAt(rs.getDate("created_at").toLocalDate());
        post.setUpdatedAt(rs.getDate("updated_at").toLocalDate());
        return post;
    }
    
    public void insertMap(int postId, JsonObject attrs) {
        String sql = "INSERT INTO post_map (postid, map_id, label, lat, lng) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = ConnectionPoolHelper.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, attrs.get("id").getAsString());
            pstmt.setString(3, attrs.get("label").getAsString());
            pstmt.setDouble(4, attrs.get("lat").getAsDouble());
            pstmt.setDouble(5, attrs.get("lng").getAsDouble());
            pstmt.executeUpdate();
            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void insertSchedule(int postId, JsonObject attrs) {
        String sql = "INSERT INTO post_schedule (postid, title, meet_date, meet_time, meet_location, people) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = ConnectionPoolHelper.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, attrs.get("title").getAsString());
            pstmt.setString(3, attrs.get("date").getAsString());
            pstmt.setString(4, attrs.get("time").getAsString());
            pstmt.setString(5, attrs.get("location").getAsString());
            String peopleValue = attrs.get("people").isJsonPrimitive()
            	    ? attrs.get("people").getAsJsonPrimitive().getAsString()
            	    : String.valueOf(attrs.get("people"));
            pstmt.setString(6, peopleValue); // attrs.get("people").getAsString()❌  people이 number일 경우 예외
            pstmt.executeUpdate();
            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

 // 이미지 삽입 (R2 업로드 포함)
    public void insertImage(int postId, JsonObject imgAttrs) throws SQLException {
        if (imgAttrs == null) {
            throw new IllegalArgumentException("imgAttrs가 null입니다.");
        }

        System.out.println("src 내용물 : " + imgAttrs.get("src").getAsString());

        String src = imgAttrs.has("src") ? imgAttrs.get("src").getAsString() : null;
        
        if (src == null || src.isEmpty()) {
            throw new IllegalArgumentException("src가 비어있습니다.");
        }

        String finalUrl = src;

        // Base64 이미지인 경우 R2에 업로드
        if (src.startsWith("data:image/")) {
            try {
                finalUrl = uploadBase64ImageToR2(src, postId);
                System.out.println("[insertImage] R2 업로드 성공: " + finalUrl);
            } catch (Exception e) {
                System.err.println("[insertImage] R2 업로드 실패: " + e.getMessage());
                throw new SQLException("이미지 업로드 실패", e);
            }
        }

        String sql = "INSERT INTO post_image (postid, src) VALUES (?, ?)";

        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, postId);
            pstmt.setString(2, finalUrl);
            int affected = pstmt.executeUpdate();

            if (affected == 0) {
                System.err.println("[insertImage] 이미지 삽입 실패: postId=" + postId + ", src=" + finalUrl);
            } else {
                System.out.println("[insertImage] 이미지 삽입 성공: postId=" + postId + ", src=" + finalUrl);
            }
            
            conn.commit();
        } catch (SQLException e) {
            System.err.println("[insertImage] DB 오류 발생: " + e.getMessage());
            throw e;
        }
    }

    /**
     * Base64 이미지를 R2에 업로드
     */
    private String uploadBase64ImageToR2(String base64Data, int postId) {
        try {
            // data:image/png;base64,iVBORw0KG... 형식에서 데이터 추출
            String[] parts = base64Data.split(",");
            if (parts.length != 2) {
                throw new IllegalArgumentException("잘못된 Base64 형식입니다.");
            }

            // MIME 타입 추출 (예: image/png)
            String mimeType = parts[0].split(";")[0].split(":")[1];
            
            // 확장자 추출
            String extension = mimeType.split("/")[1]; // png, jpeg, jpg, gif 등
            if (extension.equals("jpeg")) {
                extension = "jpg";
            }

            // Base64 디코딩
            String base64Image = parts[1];
            byte[] imageBytes = java.util.Base64.getDecoder().decode(base64Image);

            // 파일명 생성
            String fileName = "post_" + postId + "_" + System.currentTimeMillis() + "." + extension;

            // R2에 업로드
            String imageUrl = R2Helper.upload(imageBytes, fileName, mimeType, "posts");

            return imageUrl;

        } catch (Exception e) {
            throw new RuntimeException("Base64 이미지 업로드 실패", e);
        }
    }

    /**
     * 외부 URL 이미지를 R2에 복사 (선택사항)
     */
    private String uploadExternalImageToR2(String imageUrl, int postId) {
        try {
            // URL에서 이미지 다운로드
            java.net.URL url = new java.net.URL(imageUrl);
            java.io.InputStream inputStream = url.openStream();
            java.io.ByteArrayOutputStream buffer = new java.io.ByteArrayOutputStream();
            
            byte[] data = new byte[4096];
            int bytesRead;
            while ((bytesRead = inputStream.read(data, 0, data.length)) != -1) {
                buffer.write(data, 0, bytesRead);
            }
            inputStream.close();
            
            byte[] imageBytes = buffer.toByteArray();
            
            // 확장자 추출
            String extension = imageUrl.substring(imageUrl.lastIndexOf(".") + 1);
            if (extension.contains("?")) {
                extension = extension.substring(0, extension.indexOf("?"));
            }
            
            // MIME 타입 결정
            String mimeType = "image/" + extension;
            
            // 파일명 생성
            String fileName = "post_" + postId + "_" + System.currentTimeMillis() + "." + extension;
            
            // R2에 업로드
            return R2Helper.upload(imageBytes, fileName, mimeType, "posts");
            
        } catch (Exception e) {
            throw new RuntimeException("외부 이미지 업로드 실패: " + imageUrl, e);
        }
    }

}