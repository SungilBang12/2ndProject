package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.SchedulePostDto;

public class ChatDao {

    /** 🔹 단일 스케줄 조회 */
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

    /** 🔹 참가자 수 업데이트 */
    public void updateCurrentPeople(Connection conn, int postId, int newCount) throws SQLException {
        String sql = "UPDATE DATE_POST SET current_people = ? WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, newCount);
            pstmt.setInt(2, postId);
            pstmt.executeUpdate();
        }
    }

    /** 🔹 참가자 추가 */
    public void insertChatParticipant(Connection conn, int postId, String userId) throws SQLException {
        String channelName = "channel-" + postId;
        String sql = "INSERT INTO chat_participants (post_id, user_id, channel_name) VALUES (?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, userId);
            pstmt.setString(3, channelName);
            pstmt.executeUpdate();
        }
    }

    /** 🔹 참가자 삭제 */
    public void deleteChatParticipant(Connection conn, int postId, String userId) throws SQLException {
        String sql = "DELETE FROM chat_participants WHERE post_id = ? AND user_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, userId);
            pstmt.executeUpdate();
        }
    }

    /** 🔹 이미 참여했는지 확인 */
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

    /** 🔹 특정 게시글의 현재 참가자 수 조회 */
    public int getParticipantCount(Connection conn, int postId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM chat_participants WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /** 🔹 유저가 참여 중인 모든 방 조회 */
    public List<SchedulePostDto> getUserJoinedRooms(Connection conn, String userId) throws SQLException {
        String sql = "SELECT dp.* FROM DATE_POST dp " +
                     "INNER JOIN chat_participants cp ON dp.post_id = cp.post_id " +
                     "WHERE cp.user_id = ?";
        List<SchedulePostDto> rooms = new ArrayList<>();
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    SchedulePostDto dto = new SchedulePostDto();
                    dto.setPostId(rs.getInt("post_id"));
                    dto.setTitle(rs.getString("title"));
                    dto.setMeetDate(rs.getString("meet_date"));
                    dto.setMeetTime(rs.getString("meet_time"));
                    dto.setMaxPeople(rs.getInt("max_people"));
                    dto.setCurrentPeople(rs.getInt("current_people"));
                    rooms.add(dto);
                }
            }
        }
        return rooms;
    }
}
