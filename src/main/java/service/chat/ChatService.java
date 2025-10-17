package service.chat;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

import dao.ChatDao;
import dto.ChatJoinRequest;
import dto.ChatJoinResponse;
import dto.SchedulePostDto;
import utils.ConnectionPoolHelper;

public class ChatService {

    private final ChatDao dao = new ChatDao();
    
    /** 🔹 게시글 상세 조회 */
    public SchedulePostDto getPostDetails(int postId) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            return dao.getSchedulePost(conn, postId);
        } catch (SQLException e) {
            logError("getPostDetails", e);
            return null;
        }
    }

    /** 🔹 참가 (join) */
    public ChatJoinResponse joinChat(ChatJoinRequest req) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            SchedulePostDto post = dao.getSchedulePost(conn, req.getPostId());
            if (post == null) return createResponse(false, "게시글 없음", req.getPostId(), 0, 0);

            if (post.getCurrentPeople() >= post.getMaxPeople())
                return createResponse(false, "정원 초과", req.getPostId(), post.getCurrentPeople(), post.getMaxPeople());

            boolean success = dao.joinParticipant(conn, req.getPostId(), req.getUserId());
            if (!success) return createResponse(false, "이미 참가중", req.getPostId(), post.getCurrentPeople(), post.getMaxPeople());

            // join 성공 시 현재 인원 갱신
            int updatedPeople = dao.getParticipantCount(conn, req.getPostId());
            return createResponse(true, "참가 성공", req.getPostId(), updatedPeople, post.getMaxPeople());

        } catch (SQLException e) {
            logError("joinChat", e);
            return createResponse(false, "DB 오류", req.getPostId(), 0, 0);
        }
    }

    /** 🔹 퇴장 (leave) */
    public ChatJoinResponse leaveChat(ChatJoinRequest req) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            SchedulePostDto post = dao.getSchedulePost(conn, req.getPostId());
            if (post == null) return createResponse(false, "게시글 없음", req.getPostId(), 0, 0);

            boolean success = dao.leaveParticipant(conn, req.getPostId(), req.getUserId());
            if (!success) return createResponse(false, "참가자가 아님", req.getPostId(), post.getCurrentPeople(), post.getMaxPeople());

            int updatedPeople = dao.getParticipantCount(conn, req.getPostId());
            return createResponse(true, "퇴장 성공", req.getPostId(), updatedPeople, post.getMaxPeople());

        } catch (SQLException e) {
            logError("leaveChat", e);
            return createResponse(false, "DB 오류", req.getPostId(), 0, 0);
        }
    }

    /** 🔹 유저가 참여중인 모든 방 조회 */
    public List<SchedulePostDto> getUserJoinedRooms(String userId) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            return dao.getUserJoinedRooms(conn, userId);
        } catch (SQLException e) {
            logError("getUserJoinedRooms", e);
            return Collections.emptyList();
        }
    }

    /** 🔹 유저가 특정 방에 참여중인지 확인 */
    public boolean isUserInChat(int postId, String userId) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            return dao.isAlreadyJoined(conn, postId, userId);
        } catch (SQLException e) {
            logError("isUserInChat", e);
            return false;
        }
    }

    /** 🔹 참가자 수 조회 */
    public int getParticipantCount(int postId) {
        try (Connection conn = ConnectionPoolHelper.getConnection()) {
            return dao.getParticipantCount(conn, postId);
        } catch (SQLException e) {
            logError("getParticipantCount", e);
            return 0;
        }
    }

    // ============================================================
    // 🔹 유틸
    // ============================================================

    private ChatJoinResponse createResponse(boolean success, String message, int postId, int currentPeople, int maxPeople) {
        return new ChatJoinResponse(success, message, success ? "channel-" + postId : null, currentPeople, maxPeople);
    }

    private void logError(String method, Exception e) {
        System.err.println("[ChatService::" + method + "] 오류 발생: " + e.getMessage());
        e.printStackTrace();
    }
}
