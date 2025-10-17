package service.chat;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import dao.ChatDao;
import dto.ChatJoinRequest;
import dto.ChatJoinResponse;
import dto.SchedulePostDto;
import utils.ConnectionPoolHelper;

public class ChatService {
    private final ChatDao dao = new ChatDao();

    /** 🔹 게시글 상세 (참가자, 정원 확인용) */
    public SchedulePostDto getPostDetails(int postId) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            return dao.getSchedulePost(conn, postId);
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    /** 🔹 참가 (join) */
    public ChatJoinResponse joinChat(ChatJoinRequest req) {
        Connection conn = null;
        try {
            conn = ConnectionPoolHelper.getConnection();
            conn.setAutoCommit(false);

            SchedulePostDto post = dao.getSchedulePost(conn, req.getPostId());
            if (post == null) {
                conn.rollback();
                return new ChatJoinResponse(false, "게시글 없음", null, 0, 0);
            }

            if (dao.isAlreadyJoined(conn, req.getPostId(), req.getUserId())) {
                conn.rollback();
                return new ChatJoinResponse(false, "이미 참가중", "channel-" + req.getPostId(),
                        post.getCurrentPeople(), post.getMaxPeople());
            }

            if (post.getCurrentPeople() >= post.getMaxPeople()) {
                conn.rollback();
                return new ChatJoinResponse(false, "정원 초과", null,
                        post.getCurrentPeople(), post.getMaxPeople());
            }

            dao.insertChatParticipant(conn, req.getPostId(), req.getUserId());
            dao.updateCurrentPeople(conn, req.getPostId(), post.getCurrentPeople() + 1);

            conn.commit();
            return new ChatJoinResponse(true, "참가 성공", "channel-" + req.getPostId(),
                    post.getCurrentPeople() + 1, post.getMaxPeople());

        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return new ChatJoinResponse(false, "DB 오류", null, 0, 0);
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    /** 🔹 퇴장 (leave) */
    public ChatJoinResponse leaveChat(ChatJoinRequest req) {
        Connection conn = null;
        try {
            conn = ConnectionPoolHelper.getConnection();
            conn.setAutoCommit(false);

            SchedulePostDto post = dao.getSchedulePost(conn, req.getPostId());
            if (post == null) {
                conn.rollback();
                return new ChatJoinResponse(false, "게시글 없음", null, 0, 0);
            }

            if (!dao.isAlreadyJoined(conn, req.getPostId(), req.getUserId())) {
                conn.rollback();
                return new ChatJoinResponse(false, "참가자가 아님", null,
                        post.getCurrentPeople(), post.getMaxPeople());
            }

            dao.deleteChatParticipant(conn, req.getPostId(), req.getUserId());
            dao.updateCurrentPeople(conn, req.getPostId(), Math.max(0, post.getCurrentPeople() - 1));

            conn.commit();
            return new ChatJoinResponse(true, "퇴장 성공", null,
                    Math.max(0, post.getCurrentPeople() - 1), post.getMaxPeople());

        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return new ChatJoinResponse(false, "DB 오류", null, 0, 0);
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    /** 🔹 특정 유저가 참여중인 모든 방 리스트 (rooms) */
    public List<SchedulePostDto> getUserJoinedRooms(String userId) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            return dao.getUserJoinedRooms(conn, userId);
        } catch (SQLException e) {
            e.printStackTrace();
            return List.of();
        }
    }

    /** 🔹 유저가 특정 방에 이미 참여중인지 확인 */
    public boolean isUserInChat(int postId, String userId) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            return dao.isAlreadyJoined(conn, postId, userId);
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** 🔹 참가자 수 조회 */
    public int getParticipantCount(int postId) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            return dao.getParticipantCount(conn, postId);
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }
}
