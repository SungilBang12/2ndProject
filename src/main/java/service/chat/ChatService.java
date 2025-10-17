// ChatService.java
package service.chat;

import java.sql.Connection;
import java.sql.SQLException;

import dao.ChatDao;
import dto.ChatJoinRequest;
import dto.ChatJoinResponse;
import dto.SchedulePostDto;
import utils.ConnectionPoolHelper; // ConnectionPoolHelper 임포트 추가

public class ChatService {
	private ChatDao dao = new ChatDao();

	public ChatJoinResponse joinChat(ChatJoinRequest req) {
		Connection conn = null;
		try {
			// 1. 트랜잭션 시작
			conn = ConnectionPoolHelper.getConnection();
			conn.setAutoCommit(false);

			// 2. FOR UPDATE 락이 걸린 상태로 게시글 정보 조회
			SchedulePostDto post = dao.getSchedulePost(conn, req.getPostId());
			
			if (post == null) {
				conn.rollback();
				return new ChatJoinResponse(false, "게시글 없음", null, 0, 0);
			}

            // 3. 이미 참가 중인지 확인 (데이터 정합성 때문에 트랜잭션 내에서 다시 확인하는 것이 안전)
            // Note: isAlreadyJoined는 dao에서 새로운 커넥션을 사용하므로 여기서는 joinChat 로직에 병합하는 것이 효율적일 수 있음.
            // 하지만 현재는 isAlreadyJoined가 Connection을 받지 않으므로, 아래 정원 체크 로직에 집중합니다.
            
			if (post.getCurrentPeople() >= post.getMaxPeople()) {
				conn.rollback(); // 정원 초과 시 롤백
				return new ChatJoinResponse(false, "정원 초과", null, post.getCurrentPeople(), post.getMaxPeople());
			}

			// 4. 참가자 삽입 및 인원 업데이트
			dao.insertChatParticipant(conn, post.getPostId(), req.getUserId());
			dao.updateCurrentPeople(conn, req.getPostId(), post.getCurrentPeople() + 1);

			// 5. 트랜잭션 커밋
			conn.commit();

			return new ChatJoinResponse(true, "참가 성공", "channel-" + req.getPostId(), post.getCurrentPeople() + 1,
					post.getMaxPeople());
		} catch (SQLException e) {
			e.printStackTrace();
			// 6. 예외 발생 시 롤백
			if (conn != null) {
				try {
					conn.rollback();
				} catch (SQLException rollbackEx) {
					rollbackEx.printStackTrace();
				}
			}
			return new ChatJoinResponse(false, "데이터베이스 오류로 참가 실패", null, 0, 0);
		} finally {
			// 7. 커넥션 반환 및 AutoCommit 설정 복구
			if (conn != null) {
				try {
					conn.setAutoCommit(true);
					conn.close();
				} catch (SQLException closeEx) {
					closeEx.printStackTrace();
				}
			}
		}
	}
}
