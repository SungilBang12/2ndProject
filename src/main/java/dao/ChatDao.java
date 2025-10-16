// ChatDao.java
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import dto.SchedulePostDto;
import utils.ConnectionPoolHelper;

public class ChatDao {

    public SchedulePostDto getSchedulePost(int postId) throws SQLException {
        String sql = "SELECT * FROM DATE_POST WHERE post_id = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            System.out.println();
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

    public void updateCurrentPeople(int postId, int newCount) throws SQLException {
        String sql = "UPDATE DATE_POST SET current_people = ? WHERE post_id = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, newCount);
            pstmt.setInt(2, postId);
            pstmt.executeUpdate();
        }
    }

    public void insertChatParticipant(int postId, String userName) throws SQLException {
    	String channelName = "channel-" + postId; // 각 게시글마다 고유 채널
        String sql = "INSERT INTO chat_participants (post_id, user_id, channel_name) VALUES (?, ?, ?)";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, userName);
            pstmt.setString(3, channelName);
            pstmt.executeUpdate();
        }
    }

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
