// ChatDao.java
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import dto.SchedulePostDto;
import utils.ConnectionPoolHelper;

public class ChatDao {

    // Connection을 받도록 수정하여 트랜잭션 제어 가능하게 함
    public SchedulePostDto getSchedulePost(Connection conn, int postId) throws SQLException {
        // SELECT FOR UPDATE 쿼리 사용 (비관적 락)
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
    
    // Connection을 받도록 수정
    public void updateCurrentPeople(Connection conn, int postId, int newCount) throws SQLException {
        String sql = "UPDATE DATE_POST SET current_people = ? WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
             pstmt.setInt(1, newCount);
             pstmt.setInt(2, postId);
             pstmt.executeUpdate();
        }
    }

    // Connection을 받도록 수정
    public void insertChatParticipant(Connection conn, int postId, String userName) throws SQLException {
    	String channelName = "channel-" + postId; // 각 게시글마다 고유 채널
        String sql = "INSERT INTO chat_participants (post_id, user_id, channel_name) VALUES (?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, userName);
            pstmt.setString(3, channelName);
            pstmt.executeUpdate();
        }
    }
    
    // 이 메서드는 트랜잭션 바깥에서 사용될 수 있으므로 기존대로 유지
    public boolean isAlreadyJoined(int postId, String userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM chat_participants WHERE post_id = ? AND user_id = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }
}
