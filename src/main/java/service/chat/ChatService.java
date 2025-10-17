package service.chat;

import java.sql.Connection;
import java.sql.SQLException;

import dao.ChatDao;
import dto.ChatJoinRequest;
import dto.ChatJoinResponse;
import dto.SchedulePostDto;
import utils.ConnectionPoolHelper;

public class ChatService {
    private final ChatDao dao = new ChatDao();

    public SchedulePostDto getPostDetails(int postId) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            return dao.getSchedulePost(conn, postId);
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

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
                return new ChatJoinResponse(false, "이미 참가중", "channel-" + req.getPostId(), post.getCurrentPeople(), post.getMaxPeople());
            }

            if (post.getCurrentPeople() >= post.getMaxPeople()) {
                conn.rollback();
                return new ChatJoinResponse(false, "정원 초과", null, post.getCurrentPeople(), post.getMaxPeople());
            }

            dao.insertChatParticipant(conn, req.getPostId(), req.getUserId());
            dao.updateCurrentPeople(conn, req.getPostId(), post.getCurrentPeople() + 1);

            conn.commit();
            return new ChatJoinResponse(true, "참가 성공", "channel-" + req.getPostId(), post.getCurrentPeople() + 1, post.getMaxPeople());

        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return new ChatJoinResponse(false, "DB 오류", null, 0, 0);
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException e) { e.printStackTrace(); }
        }
    }

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
                return new ChatJoinResponse(false, "참가자가 아님", null, post.getCurrentPeople(), post.getMaxPeople());
            }

            dao.deleteChatParticipant(conn, req.getPostId(), req.getUserId());
            dao.updateCurrentPeople(conn, req.getPostId(), post.getCurrentPeople() - 1);

            conn.commit();
            return new ChatJoinResponse(true, "퇴장 성공", null, post.getCurrentPeople() - 1, post.getMaxPeople());

        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return new ChatJoinResponse(false, "DB 오류", null, 0, 0);
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}
