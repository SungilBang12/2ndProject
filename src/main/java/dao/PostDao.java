package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp; // 사용처 존재
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate; // ✅ LocalDate 컴파일 에러 방지용 추가

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import dto.Comments;
import dto.Post;
import dto.PostSummary;
import utils.ConnectionPoolHelper;
import utils.s3.R2Helper;

public class PostDao {
    // CREATE
    public int createPost(Post post) {
        // SQL 문 수정: POST_ID를 시퀀스 대신 NULL로 넣어 트리거가 작동하게 함.
        // CREATED_AT은 트리거가 있다면 생략 가능하지만 명시적으로 SYSDATE 삽입
        String sql = "INSERT INTO POST (POST_ID, USER_ID, LIST_ID, TITLE, CONTENT, HIT, CREATED_AT) VALUES (NULL, ?, ?, ?, ?, ?, SYSDATE)";

        // Oracle에서 트리거로 생성된 ID를 가져오기 위해 "POST_ID"를 요청
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, new String[] { "POST_ID" })) {

            System.out.println(post.toString());

            // 1. USER_ID
            pstmt.setString(1, post.getUserId());

            // 2. LIST_ID
            if (post.getListId() != null) {
                pstmt.setInt(2, post.getListId());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }

            // 3. TITLE
            pstmt.setString(3, post.getTitle());

            // 4. CONTENT
            pstmt.setString(4, post.getContent());

            // 5. HIT
            if (post.getHit() != null) {
                pstmt.setInt(5, post.getHit());
            } else {
                pstmt.setInt(5, 0);
            }

            int affectedRows = pstmt.executeUpdate();
            int postId = 0;

            // DB에서 생성된 POST_ID 가져오기
            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    postId = rs.getInt(1); // 첫 번째 컬럼(POST_ID)의 값을 가져옴
                }
            }
            return postId;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // READ - 단건 조회
    public Post getPostById(int postId) {
        // SQL 문 수정: 따옴표 제거
        String sql = "SELECT * FROM POST WHERE POST_ID = ?";
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
        // SQL 문 수정: 따옴표 제거
        String sql = "SELECT * FROM POST ORDER BY CREATED_AT DESC";
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

    public List<Post> getPostsByNewest(int limit) {
        // POST_ID가 AUTO_INCREMENT거나 SEQUENCE 기반이면 최신순 정렬과 동일
        String sql = "SELECT * FROM (SELECT * FROM POST ORDER BY POST_ID DESC) WHERE ROWNUM <= ?";
        return getPostsByQuery(sql, limit);
    }

    public List<Post> getPostsByOldest(int limit) {
        String sql = "SELECT * FROM (SELECT * FROM POST ORDER BY POST_ID ASC) WHERE ROWNUM <= ?";
        return getPostsByQuery(sql, limit);
    }

    public List<Post> getPostsByViews(int limit) {
        String sql = "SELECT * FROM (SELECT * FROM POST ORDER BY HIT DESC, POST_ID DESC) WHERE ROWNUM <= ?";
        return getPostsByQuery(sql, limit);
    }

    private List<Post> getPostsByQuery(String sql) {
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

    private List<Post> getPostsByQuery(String sql, int limit) {
        List<Post> posts = new ArrayList<>();
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limit); // ✅ LIMIT 바인딩
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    posts.add(mapRowToPost(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    // ✅ 전체 게시글 수 조회
    public int getTotalPostCount() {
        String sql = "SELECT COUNT(*) FROM POST";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Post> getPagedPosts(String sort, int page, int limit) {
        String orderBy;
        switch (sort) {
            case "views":
                orderBy = "ORDER BY P.HIT DESC";
                break;
            case "oldest":
                orderBy = "ORDER BY P.POST_ID ASC";
                break;
            default:
                orderBy = "ORDER BY P.POST_ID DESC";
        }

        int start = (page - 1) * limit + 1;
        int end = start + limit - 1;

        // ✅ categoryId, typeId, categoryName, postTypeName까지 전부 조회
        String sql =
            "SELECT * FROM ( " +
            "  SELECT ROWNUM AS rnum, inner_query.* " +
            "  FROM ( " +
            "    SELECT " +
            "      P.POST_ID, " +
            "      P.USER_ID, " +
            "      P.TITLE, " +
            "      P.CONTENT, " +
            "      P.HIT, " +
            "      P.CREATED_AT, " +
            "      PL.LIST_ID, " +
            "      PL.CATEGORY_ID, " +
            "      PL.TYPE_ID, " +
            "      C.CATEGORY_NAME AS CATEGORY, " +
            "      PT.TYPE_NAME AS POST_TYPE " +
            "    FROM POST P " +
            "    LEFT JOIN POST_LIST PL ON P.LIST_ID = PL.LIST_ID " +
            "    LEFT JOIN CATEGORY C ON PL.CATEGORY_ID = C.CATEGORY_ID " +
            "    LEFT JOIN POST_TYPE PT ON PL.TYPE_ID = PT.TYPE_ID " +
                 orderBy + " " +
            "  ) inner_query " +
            "  WHERE ROWNUM <= ? " +
            ") WHERE rnum >= ?";

        List<Post> posts = new ArrayList<>();

        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, end);
            pstmt.setInt(2, start);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Post post = Post.builder()
                        .postId(rs.getInt("POST_ID"))
                        .userId(rs.getString("USER_ID"))
                        .title(rs.getString("TITLE"))
                        .content(rs.getString("CONTENT"))
                        .hit(rs.getInt("HIT"))
                        .createdAt(rs.getDate("CREATED_AT").toLocalDate())
                        .listId(rs.getInt("LIST_ID"))
                        .categoryId(rs.getInt("CATEGORY_ID"))
                        .postTypeId(rs.getInt("TYPE_ID"))
                        .category(rs.getString("CATEGORY"))
                        .postType(rs.getString("POST_TYPE"))
                        .build();

                    posts.add(post);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return posts;
    }

    public List<Post> searchPosts(String keyword) {
        String sql =
            "SELECT P.POST_ID, P.USER_ID, P.TITLE, P.CONTENT, P.HIT, P.CREATED_AT, " +
            "       PL.LIST_ID, PL.CATEGORY_ID, PL.TYPE_ID, " +
            "       C.CATEGORY_NAME AS CATEGORY, PT.TYPE_NAME AS POST_TYPE " +
            "FROM POST P " +
            "LEFT JOIN POST_LIST PL ON P.LIST_ID = PL.LIST_ID " +
            "LEFT JOIN CATEGORY C ON PL.CATEGORY_ID = C.CATEGORY_ID " +
            "LEFT JOIN POST_TYPE PT ON PL.TYPE_ID = PT.TYPE_ID " +
            "WHERE LOWER(P.TITLE) LIKE LOWER(?) OR LOWER(P.CONTENT) LIKE LOWER(?) " +
            "ORDER BY P.CREATED_AT DESC";

        List<Post> posts = new ArrayList<>();

        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            String pattern = "%" + keyword + "%";
            pstmt.setString(1, pattern);
            pstmt.setString(2, pattern);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    posts.add(Post.builder()
                        .postId(rs.getInt("POST_ID"))
                        .userId(rs.getString("USER_ID"))
                        .title(rs.getString("TITLE"))
                        .content(rs.getString("CONTENT"))
                        .hit(rs.getInt("HIT"))
                        .createdAt(rs.getDate("CREATED_AT").toLocalDate())
                        .listId(rs.getInt("LIST_ID"))
                        .categoryId(rs.getInt("CATEGORY_ID"))
                        .postTypeId(rs.getInt("TYPE_ID"))
                        .category(rs.getString("CATEGORY"))
                        .postType(rs.getString("POST_TYPE"))
                        .build());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    // 아래 부분만 기존 PostDao.java 하단에 추가해줘도 돼.

    public int getSearchPostCount(String keyword) {
        String sql = "SELECT COUNT(*) FROM POST WHERE LOWER(TITLE) LIKE LOWER(?) OR LOWER(CONTENT) LIKE LOWER(?)";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            pstmt.setString(1, pattern);
            pstmt.setString(2, pattern);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Post> getPagedPostsByKeyword(String sort, int page, int limit, String keyword) {
        String orderBy;
        switch (sort) {
            case "views":
                orderBy = "ORDER BY P.HIT DESC";
                break;
            case "oldest":
                orderBy = "ORDER BY P.POST_ID ASC";
                break;
            default:
                orderBy = "ORDER BY P.POST_ID DESC";
        }

        int start = (page - 1) * limit + 1;
        int end = start + limit - 1;

        String sql =
            "SELECT * FROM ( " +
            "  SELECT ROWNUM AS rnum, inner_query.* " +
            "  FROM ( " +
            "    SELECT P.POST_ID, P.USER_ID, P.TITLE, P.CONTENT, P.HIT, P.CREATED_AT, " +
            "           PL.LIST_ID, PL.CATEGORY_ID, PL.TYPE_ID, " +
            "           C.CATEGORY_NAME AS CATEGORY, PT.TYPE_NAME AS POST_TYPE " +
            "    FROM POST P " +
            "    LEFT JOIN POST_LIST PL ON P.LIST_ID = PL.LIST_ID " +
            "    LEFT JOIN CATEGORY C ON PL.CATEGORY_ID = C.CATEGORY_ID " +
            "    LEFT JOIN POST_TYPE PT ON PL.TYPE_ID = PT.TYPE_ID " +
            "    WHERE LOWER(P.TITLE) LIKE LOWER(?) OR LOWER(P.CONTENT) LIKE LOWER(?) " +
                 orderBy + " " +
            "  ) inner_query " +
            "  WHERE ROWNUM <= ? " +
            ") WHERE rnum >= ?";

        List<Post> posts = new ArrayList<>();
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            pstmt.setString(1, pattern);
            pstmt.setString(2, pattern);
            pstmt.setInt(3, end);
            pstmt.setInt(4, start);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    posts.add(Post.builder()
                        .postId(rs.getInt("POST_ID"))
                        .userId(rs.getString("USER_ID"))
                        .title(rs.getString("TITLE"))
                        .content(rs.getString("CONTENT"))
                        .hit(rs.getInt("HIT"))
                        .createdAt(rs.getDate("CREATED_AT").toLocalDate())
                        .listId(rs.getInt("LIST_ID"))
                        .categoryId(rs.getInt("CATEGORY_ID"))
                        .postTypeId(rs.getInt("TYPE_ID"))
                        .category(rs.getString("CATEGORY"))
                        .postType(rs.getString("POST_TYPE"))
                        .build());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    /**
     * 게시글을 수정합니다. (TITLE, CONTENT, LIST_ID, UPDATED_AT 갱신)
     */
    // UPDATE
    public int updatePost(Post post) {
        // HIT는 수정 시 갱신하지 않고, UPDATED_AT만 갱신
        String sql = "UPDATE POST SET TITLE = ?, CONTENT = ?, LIST_ID = ?, UPDATED_AT = SYSDATE WHERE POST_ID = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, post.getTitle());
            pstmt.setString(2, post.getContent());

            // LIST_ID 처리 (null 가능)
            if (post.getListId() != null && post.getListId() > 0) {
                pstmt.setInt(3, post.getListId());
            } else {
                pstmt.setNull(3, Types.INTEGER);
            }
            pstmt.setInt(4, post.getPostId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // DELETE
    /**
     * 주어진 postId에 연결된 모든 자식 레코드(DATE_POST, IMAGE_DATA, MAP_DATA)를 삭제한 후, 부모
     * 레코드(POST)를 삭제합니다. 모든 작업은 단일 트랜잭션으로 처리됩니다. * @param postId 삭제할 게시글 ID
     *
     * @return 삭제된 POST 테이블의 행 수 (성공 시 1, 실패 시 0)
     */
    public int deletePost(int postId) {
        int deletedRows = 0;
        Connection conn = null;

        try {
            // 1. Connection 획득 및 트랜잭션 시작 (Auto Commit 비활성화)
            conn = ConnectionPoolHelper.getConnection();
            conn.setAutoCommit(false);

            // ------------------------------------------
            // 2. [핵심] 자식 데이터 먼저 삭제 (POST_ID 기준)
            // ------------------------------------------

            // 2-1. DATE_POST 테이블 삭제 (일정 데이터)
            String deleteDateSql = "DELETE FROM DATE_POST WHERE POST_ID = ?";
            try (PreparedStatement pstmtDate = conn.prepareStatement(deleteDateSql)) {
                pstmtDate.setInt(1, postId);
                pstmtDate.executeUpdate();
            }

            // 2-2. IMAGE_DATA 테이블 삭제 (이미지 데이터)
            String deleteImageSql = "DELETE FROM IMAGE_DATA WHERE POST_ID = ?";
            try (PreparedStatement pstmtImage = conn.prepareStatement(deleteImageSql)) {
                pstmtImage.setInt(1, postId);
                pstmtImage.executeUpdate();
            }

            // 2-3. MAP_DATA 테이블 삭제 (지도 데이터)
            String deleteMapDataSql = "DELETE FROM MAP_DATA WHERE POST_ID = ?";
            try (PreparedStatement pstmtMap = conn.prepareStatement(deleteMapDataSql)) {
                pstmtMap.setInt(1, postId);
                pstmtMap.executeUpdate();
            }

            // ------------------------------------------
            // 3. 부모 데이터 (POST) 삭제
            // ------------------------------------------
            String deletePostSql = "DELETE FROM POST WHERE POST_ID = ?";
            try (PreparedStatement pstmtParent = conn.prepareStatement(deletePostSql)) {
                pstmtParent.setInt(1, postId);
                deletedRows = pstmtParent.executeUpdate(); // POST 테이블 삭제 결과 저장
            }

            // 4. 모든 작업이 성공했다면 Commit
            conn.commit();

        } catch (SQLException e) {
            e.printStackTrace();

            // 5. 오류 발생 시 Rollback (트랜잭션 되돌리기)
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackE) {
                    rollbackE.printStackTrace();
                }
            }
            deletedRows = 0; // 실패 시 0 반환

        } finally {
            // 6. [필수] 트랜잭션 종료 및 리소스 반환
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Auto Commit 상태 복구
                    conn.close();
                } catch (SQLException closeE) {
                    closeE.printStackTrace();
                }
            }
        }
        return deletedRows;
    }

    // ResultSet → Post 매핑
    private Post mapRowToPost(ResultSet rs) throws SQLException {
        Post post = new Post();
        // 컬럼명 대문자로 변경 (따옴표 없이 DB 컬럼명 대문자 사용)
        post.setPostId(rs.getInt("POST_ID"));
        post.setUserId(rs.getString("USER_ID"));
        int listId = rs.getInt("LIST_ID");
        if (!rs.wasNull()) post.setListId(listId);
        post.setTitle(rs.getString("TITLE"));
        post.setContent(rs.getString("CONTENT"));
        post.setHit(rs.getInt("HIT"));
        post.setCreatedAt(rs.getDate("CREATED_AT").toLocalDate());
//      post.setUpdatedAt(rs.getDate("UPDATED_AT").toLocalDate());
        return post;
    }

    public void insertMap(int postId, JsonObject attrs) {
        // SQL 문 수정: 따옴표 제거 및 MAP_DATA에 맞게 컬럼명 수정
        String sql = "INSERT INTO MAP_DATA (POST_ID, MAP_ID, LABEL, LONGITUDE, LATITUDE) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            // lng은 LONGITUDE, lat은 LATITUDE에 매핑
            pstmt.setString(2, attrs.get("id").getAsString());
            pstmt.setString(3, attrs.get("label").getAsString());
            pstmt.setDouble(4, attrs.get("lat").getAsDouble()); // 주: 필요 시 lat/lng 스왑 검토
            pstmt.setDouble(5, attrs.get("lng").getAsDouble());
            pstmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // DATE_POST 테이블에 정모/일정 정보 삽입
    public void insertSchedule(int postId, JsonObject attrs) {

        // SQL 문 수정: post_schedule -> DATE_POST, 컬럼명 일치
        String sql = "INSERT INTO DATE_POST (POST_ID, TITLE, MEET_DATE, MEET_TIME, PEOPLE) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, postId);

            // JSON 필드를 DATE_POST 컬럼에 맞게 바인딩
            pstmt.setString(2, attrs.get("title").getAsString());
            pstmt.setString(3, attrs.get("date").getAsString());
            pstmt.setString(4, attrs.get("time").getAsString());

            // people 필드 처리
            String peopleValue = attrs.get("people").isJsonPrimitive()
                ? attrs.get("people").getAsJsonPrimitive().getAsString()
                : String.valueOf(attrs.get("people"));
            pstmt.setString(5, peopleValue);

            pstmt.executeUpdate();

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

        // SQL 문 수정: 따옴표 제거, IMAGE_DATA에 맞게 컬럼명 수정
        String sql = "INSERT INTO IMAGE_DATA (IMAGE_ID,POST_ID, IMAGE_SRC) VALUES (SEQ_IMAGE.NEXTVAL ,?, ?)";

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
            String extension = mimeType.split("/")[1];
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

    public void parseAndSaveCustomNodes(JsonArray contentArray, int postId) {
        PostDao dao = new PostDao();

        for (JsonElement element : contentArray) {
            JsonObject node = element.getAsJsonObject();
            String type = node.get("type").getAsString();

            switch (type) {
                case "kakaoMap":
                    JsonObject mapAttrs = node.getAsJsonObject("attrs");
                    dao.insertMap(postId, mapAttrs);
                    break;

                case "scheduleBlock":
                    JsonObject schedAttrs = node.getAsJsonObject("attrs");
                    dao.insertSchedule(postId, schedAttrs);
                    break;

                case "image":
                    JsonObject imgAttrs = node.getAsJsonObject("attrs");
                    try {
                        dao.insertImage(postId, imgAttrs);
                    } catch (SQLException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                    break;

                // 다른 블록이 추가되면 여기에 case 추가
            }

            // 하위 content 안에 nested node가 있으면 재귀 탐색
            if (node.has("content")) {
                parseAndSaveCustomNodes(node.getAsJsonArray("content"), postId);
            }
        }
    }

    private Connection getConn() throws SQLException {
        // TODO: 커넥션 풀/DS로 교체
        // return dataSource.getConnection();
        throw new UnsupportedOperationException("Implement getConn()");
    }

    public int getListIdByPostId(int postId) {
        String sql = "SELECT LIST_ID FROM POST WHERE POST_ID = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, postId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("LIST_ID");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ✅ Oracle POST 테이블 단독, CLOB 검색(dbms_lob.instr) 사용
    public int countPosts(String q, Integer listId){
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) " +
            "FROM POST p " +
            "WHERE 1=1 "
        );
        if (listId != null) sql.append("AND p.LIST_ID = ? ");
        if (q != null && !q.isBlank()) {
            sql.append("AND ( LOWER(p.TITLE) LIKE ? OR dbms_lob.instr(p.CONTENT, ?) > 0 ) ");
        }

        try (Connection con = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int idx = 1;
            if (listId != null) ps.setInt(idx++, listId);
            if (q != null && !q.isBlank()){
                String like = "%" + q.toLowerCase() + "%";
                ps.setString(idx++, like);  // TITLE LIKE
                ps.setString(idx++, q);     // CONTENT CLOB INSTR
            }

            try (ResultSet rs = ps.executeQuery()){
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ✅ Oracle OFFSET/FETCH 페이지네이션, POST 테이블만 사용, 정렬: newest|views|oldest
    public List<Post> listPosts(String sort, int limit, int offset, String q, Integer listId){
        String orderBy;
        switch (sort == null ? "newest" : sort) {
            case "views":  orderBy = "p.HIT DESC, p.CREATED_AT DESC"; break;
            case "oldest": orderBy = "p.CREATED_AT ASC";              break;
            default:       orderBy = "p.CREATED_AT DESC";             break; // newest
        }

        StringBuilder sql = new StringBuilder(
            "SELECT " +
            "  p.POST_ID, p.USER_ID, p.LIST_ID, p.TITLE, p.CONTENT, p.HIT, " +
            "  p.CREATED_AT, p.UPDATED_AT " +
            "FROM POST p " +
            "WHERE 1=1 "
        );
        if (listId != null) sql.append("AND p.LIST_ID = ? ");
        if (q != null && !q.isBlank()) {
            sql.append("AND ( LOWER(p.TITLE) LIKE ? OR dbms_lob.instr(p.CONTENT, ?) > 0 ) ");
        }
        sql.append("ORDER BY ").append(orderBy).append(" ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<Post> list = new ArrayList<>();
        try (Connection con = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int idx = 1;
            if (listId != null) ps.setInt(idx++, listId);
            if (q != null && !q.isBlank()){
                String like = "%" + q.toLowerCase() + "%";
                ps.setString(idx++, like);  // TITLE LIKE
                ps.setString(idx++, q);     // CONTENT CLOB INSTR
            }
            ps.setInt(idx++, offset);
            ps.setInt(idx,   limit);

            try (ResultSet rs = ps.executeQuery()){
                while (rs.next()){
                    Post p = new Post();
                    p.setPostId(rs.getInt("POST_ID"));
                    p.setUserId(rs.getString("USER_ID"));

                    int li = rs.getInt("LIST_ID");
                    if (!rs.wasNull()) p.setListId(li);

                    p.setTitle(rs.getString("TITLE"));
                    // CONTENT이 CLOB이어도 Oracle JDBC는 getString 가능 (대용량/성능 이슈는 별도 고려)
                    p.setContent(rs.getString("CONTENT"));

                    int hit = rs.getInt("HIT");
                    if (!rs.wasNull()) p.setHit(hit);

                    // createdAt / updatedAt: DTO 타입에 맞춰 변환 (LocalDate)
                    java.sql.Date created = rs.getDate("CREATED_AT");
                    if (created != null) p.setCreatedAt(created.toLocalDate());

                    java.sql.Date updated = rs.getDate("UPDATED_AT");
                    if (updated != null) p.setUpdatedAt(updated.toLocalDate());

                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ✅ Oracle 11g 호환 PostSummary 조회 (JOIN 포함)
    public List<PostSummary> listPostSummaries(String sort, int limit, int offset, String q, Integer listId){
        String orderBy;
        switch (sort == null ? "newest" : sort) {
            case "views":  orderBy = "p.HIT DESC, p.CREATED_AT DESC"; break;
            case "oldest": orderBy = "p.CREATED_AT ASC";              break;
            default:       orderBy = "p.CREATED_AT DESC";             break;
        }

        // ✅ ROWNUM 방식 페이징 + JOIN으로 카테고리/타입 정보 포함
        int startRow = offset + 1;
        int endRow = offset + limit;

        StringBuilder sql = new StringBuilder(
            "SELECT * FROM ( " +
            "  SELECT ROWNUM AS rnum, inner_query.* FROM ( " +
            "    SELECT " +
            "      p.POST_ID, p.USER_ID, p.LIST_ID, p.TITLE, " +
            "      SUBSTR(p.CONTENT, 1, 200) AS CONTENT, " +
            "      p.HIT, " +
            "      TO_CHAR(p.CREATED_AT, 'YYYY-MM-DD HH24:MI:SS') AS CREATED_AT, " +
            "      pl.CATEGORY_ID, pl.TYPE_ID AS POST_TYPE_ID, " +
            "      c.CATEGORY_NAME AS CATEGORY, " +
            "      pt.TYPE_NAME AS POST_TYPE " +
            "    FROM POST p " +
            "    LEFT JOIN POST_LIST pl ON p.LIST_ID = pl.LIST_ID " +
            "    LEFT JOIN CATEGORY c ON pl.CATEGORY_ID = c.CATEGORY_ID " +
            "    LEFT JOIN POST_TYPE pt ON pl.TYPE_ID = pt.TYPE_ID " +
            "    WHERE 1=1 "
        );

        if (listId != null) sql.append("AND p.LIST_ID = ? ");
        if (q != null && !q.isBlank()) {
            sql.append("AND (LOWER(p.TITLE) LIKE ? OR dbms_lob.instr(LOWER(p.CONTENT), LOWER(?)) > 0) ");
        }

        sql.append("    ORDER BY ").append(orderBy).append(" ");
        sql.append("  ) inner_query ");
        sql.append("  WHERE ROWNUM <= ? ");
        sql.append(") WHERE rnum >= ?");

        List<PostSummary> list = new ArrayList<>();
        try (Connection con = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int idx = 1;
            if (listId != null) ps.setInt(idx++, listId);
            if (q != null && !q.isBlank()){
                String like = "%" + q.toLowerCase() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, q);
            }
            ps.setInt(idx++, endRow);
            ps.setInt(idx,   startRow);

            try (ResultSet rs = ps.executeQuery()){
                while (rs.next()){
                    PostSummary p = PostSummary.builder()
                        .postId(rs.getInt("POST_ID"))
                        .userId(rs.getString("USER_ID"))
                        .title(rs.getString("TITLE"))
                        .content(rs.getString("CONTENT"))
                        .hit(rs.getInt("HIT"))
                        .createdAt(rs.getString("CREATED_AT"))
                        .category(rs.getString("CATEGORY"))
                        .postType(rs.getString("POST_TYPE"))
                        .build();

                    // NULL 체크
                    int li = rs.getInt("LIST_ID");
                    if (!rs.wasNull()) p.setListId(li);

                    int catId = rs.getInt("CATEGORY_ID");
                    if (!rs.wasNull()) p.setCategoryId(catId);

                    int typeId = rs.getInt("POST_TYPE_ID");
                    if (!rs.wasNull()) p.setPostTypeId(typeId);

                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private static final String SELECT_POSTS_BY_USER_SQL =
        "SELECT POST_ID, USER_ID, LIST_ID, TITLE, CONTENT, HIT, CREATED_AT, UPDATED_AT " +
        "FROM POST WHERE USER_ID = ? ORDER BY CREATED_AT DESC";
    
    private static final String SELECT_COMMENTS_BY_USER_SQL =
    	    "SELECT COMMENT_ID, POST_ID, USER_ID, CONTENT, CREATED_AT " +
    	    "FROM COMMENTS " +
    	    "WHERE USER_ID = ? " +
    	    "ORDER BY CREATED_AT DESC";

    private static final String COUNT_POSTS_BY_USER_SQL =
        "SELECT COUNT(*) FROM POST WHERE USER_ID = ?";

    /**
     * 특정 사용자가 작성한 게시글 목록 조회
     */
    public List<Post> selectPostsByUserId(Connection conn, String userId) throws SQLException {
        List<Post> postList = new ArrayList<>();

        try (PreparedStatement pstmt = conn.prepareStatement(SELECT_POSTS_BY_USER_SQL)) {
            pstmt.setString(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    // 날짜 컬럼: DATE든 TIMESTAMP든 LocalDate로 안전 변환
                    LocalDate createdAt = toLocalDate(rs, "CREATED_AT");
                    LocalDate updatedAt = toLocalDate(rs, "UPDATED_AT");

                    Post post = Post.builder()
                        // 드라이버에 따라 getObject(String, Integer.class) 미지원 시 getInt/wasNull로 교체 가능
                        .postId(rs.getObject("POST_ID", Integer.class))
                        .userId(rs.getString("USER_ID"))
                        .listId(rs.getObject("LIST_ID", Integer.class))
                        .title(rs.getString("TITLE"))
                        .content(rs.getString("CONTENT"))
                        .hit(rs.getObject("HIT", Integer.class))
                        .createdAt(createdAt)
                        .updatedAt(updatedAt)
                        // 필요 시 조인으로 가져왔다면 아래들도 매핑
                        // .postType(rs.getString("TYPE_NAME"))
                        // .category(rs.getString("CATEGORY_NAME"))
                        // .postTypeId(rs.getObject("TYPE_ID", Integer.class))
                        // .categoryId(rs.getObject("CATEGORY_ID", Integer.class))
                        .build();

                    postList.add(post);
                }
            }
        }

        return postList;
    }
    
    public List<Comments> selectCommentsByUserId(Connection conn, String userId) throws SQLException {
        List<Comments> commentList = new ArrayList<>();

        try (PreparedStatement pstmt = conn.prepareStatement(SELECT_COMMENTS_BY_USER_SQL)) {
            pstmt.setString(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    // ✅ CREATED_AT만 조회 (UPDATED_AT 제거)
                    LocalDate createdAt = toLocalDate(rs, "CREATED_AT");

                    Comments comment = Comments.builder()
                        .commentId(rs.getInt("COMMENT_ID"))
                        .postId(rs.getInt("POST_ID"))
                        .userId(rs.getString("USER_ID"))
                        .contentRaw(rs.getString("CONTENT"))
                        .createdAt(createdAt)
                        // ✅ updatedAt 제거 (COMMENTS 테이블에 없음)
                        .deleted(false)
                        .edited(false) // TODO: UPDATED_AT 컬럼 추가 시 수정
                        .build();
                        
                    commentList.add(comment);
                }
            }
        }

        return commentList;
    }
    
    /** DATE/TIMESTAMP 모두 대응해서 LocalDate로 반환 */
    private static LocalDate toLocalDate(ResultSet rs, String column) throws SQLException {
        java.sql.Date d = rs.getDate(column);
        if (d != null) return d.toLocalDate();

        java.sql.Timestamp ts = rs.getTimestamp(column);
        if (ts != null) return ts.toLocalDateTime().toLocalDate();

        return null;
    }

    /**
     * 특정 사용자의 게시글 수 조회
     */
    public int countPostsByUserId(Connection conn, String userId) throws SQLException {
        try (PreparedStatement pstmt = conn.prepareStatement(COUNT_POSTS_BY_USER_SQL)) {
            pstmt.setString(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }
}
