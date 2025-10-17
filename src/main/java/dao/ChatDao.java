package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.SchedulePostDto;

public class ChatDao {

    /** 🔹 ResultSet → DTO 매핑 유틸 */
    private SchedulePostDto mapToDto(ResultSet rs) throws SQLException {
        SchedulePostDto dto = new SchedulePostDto();
        dto.setPostId(rs.getInt("post_id"));
        dto.setTitle(rs.getString("title"));
        dto.setMeetDate(rs.getString("meet_date"));
        dto.setMeetTime(rs.getString("meet_time"));
        dto.setMaxPeople(rs.getInt("max_people"));
        dto.setCurrentPeople(rs.getInt("current_people"));
        return dto;
    }

    /** 🔹 단일 스케줄 조회 (FOR UPDATE) */
    public SchedulePostDto getSchedulePost(Connection conn, int postId) throws SQLException {
        String sql = "SELECT * FROM DATE_POST WHERE post_id = ? FOR UPDATE";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? mapToDto(rs) : null;
            }
        }
    }

    /** 🔹 특정 게시글의 현재 참가자 수 조회 */
    public int getParticipantCount(Connection conn, int postId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM chat_participants WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** 🔹 이미 참여했는지 확인 */
    public boolean isAlreadyJoined(Connection conn, int postId, String userId) throws SQLException {
        String sql = "SELECT 1 FROM chat_participants WHERE post_id = ? AND user_id = ? AND ROWNUM = 1";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** 🔹 참가자 추가 + current_people 업데이트 (트랜잭션) */
    public boolean joinParticipant(Connection conn, int postId, String userId) throws SQLException {
        boolean success = false;
        boolean originalAutoCommit = conn.getAutoCommit();
        try {
            conn.setAutoCommit(false);

            // 중복 참여 체크
            if (isAlreadyJoined(conn, postId, userId)) {
                conn.rollback();
                return false;
            }

            // 참가자 추가
            String insertSql = "INSERT INTO chat_participants (post_id, user_id, channel_name) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(insertSql)) {
                pstmt.setInt(1, postId);
                pstmt.setString(2, userId);
                pstmt.setString(3, "channel-" + postId);
                pstmt.executeUpdate();
            }

            // current_people 업데이트
            String updateSql = "UPDATE DATE_POST SET current_people = (SELECT COUNT(*) FROM chat_participants WHERE post_id = ?) WHERE post_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                pstmt.setInt(1, postId);
                pstmt.setInt(2, postId);
                pstmt.executeUpdate();
            }

            conn.commit();
            success = true;
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(originalAutoCommit);
        }
        return success;
    }

    /** 🔹 참가자 삭제 + current_people 업데이트 (트랜잭션) */
    public boolean leaveParticipant(Connection conn, int postId, String userId) throws SQLException {
        boolean success = false;
        boolean originalAutoCommit = conn.getAutoCommit();
        try {
            conn.setAutoCommit(false);

            // 참가자 삭제
            String deleteSql = "DELETE FROM chat_participants WHERE post_id = ? AND user_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteSql)) {
                pstmt.setInt(1, postId);
                pstmt.setString(2, userId);
                pstmt.executeUpdate();
            }

            // current_people 업데이트
            String updateSql = "UPDATE DATE_POST SET current_people = (SELECT COUNT(*) FROM chat_participants WHERE post_id = ?) WHERE post_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                pstmt.setInt(1, postId);
                pstmt.setInt(2, postId);
                pstmt.executeUpdate();
            }

            conn.commit();
            success = true;
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(originalAutoCommit);
        }
        return success;
    }

    /** 🔹 유저가 참여 중인 모든 방 조회 */
    public List<SchedulePostDto> getUserJoinedRooms(Connection conn, String userId) throws SQLException {
        String sql = "SELECT dp.* FROM DATE_POST dp INNER JOIN chat_participants cp ON dp.post_id = cp.post_id WHERE cp.user_id = ?";
        List<SchedulePostDto> rooms = new ArrayList<>();
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    rooms.add(mapToDto(rs));
                }
            }
        }
        return rooms;
    }
}
