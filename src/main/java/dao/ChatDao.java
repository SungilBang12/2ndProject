package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import dto.SchedulePostDto;

public class ChatDao {

    /**
     * 게시글 정보 조회 (FOR UPDATE)
     * 트랜잭션 일관성을 위해 Connection을 Service에서 전달받음
     */
    public SchedulePostDto getSchedulePost(Connection conn, int postId) throws SQLException {
        String sql = "SELECT * FROM DATE_POST WHERE post_id = ? FOR UPDATE";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    SchedulePostDto dto = new SchedulePostDto();
                    dto.setPostId(rs.getInt("post_id"));
                    dto.setTitle(rs.getString("title"));
                    dto.setMeetDate(rs.getString("meet_date"));
                    dto.setMeetTime(rs.getString("meet_time"));
                    dto.setMaxPeople(rs.getInt("max_people"));
                    dto.setCurrentPeople(rs.getInt("current_people"));
                    return dto;
                }
            }
        }
        return null;
    }

    /**
     * 참가자 수 업데이트
     */
    public void updateCurrentPeople(Connection conn, int postId, int newCount) throws SQLException {
        String sql = "UPDATE DATE_POST SET current_people = ? WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, newCount);
            pstmt.setInt(2, postId);
            pstmt.executeUpdate();
        }
    }

    /**
     * 참가자 추가
     */
    public void insertChatParticipant(Connection conn, int postId, String userId) throws SQLException {
        String channelName = "channel-" + postId; // 게시글별 고유 채널
        String sql = "INSERT INTO chat_participants (post_id, user_id, channel_name) VALUES (?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, userId);
            pstmt.setString(3, channelName);
            pstmt.executeUpdate();
        }
    }
    public void deleteChatParticipant(Connection conn, int postId, String userId) throws SQLException {
        String sql = "DELETE FROM chat_participants WHERE post_id = ? AND user_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, userId);
            pstmt.executeUpdate();
        }
    }

    /**
     * 참가 여부 확인
     * - 트랜잭션 내에서 사용 시 Connection 전달받는 버전 사용 가능
     */
    public boolean isAlreadyJoined(Connection conn, int postId, String userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM chat_participants WHERE post_id = ? AND user_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }

    /**
     * 트랜잭션 밖에서 호출 가능한 기존 버전 유지 (Service 필요 없음)
     */
    public boolean isAlreadyJoined(int postId, String userId) throws SQLException {
        try (Connection conn = utils.ConnectionPoolHelper.getConnection()) {
            return isAlreadyJoined(conn, postId, userId);
        }
    }
}
