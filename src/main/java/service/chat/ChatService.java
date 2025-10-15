// ChatService.java
package service.chat;

import java.sql.SQLException;

import dao.ChatDao;
import dto.ChatJoinRequest;
import dto.ChatJoinResponse;
import dto.SchedulePostDto;

public class ChatService {
	private ChatDao dao = new ChatDao();

	public ChatJoinResponse joinChat(ChatJoinRequest req) {
		ChatJoinResponse res = null;
		try {
			SchedulePostDto post = dao.getSchedulePost(req.getPostId());

			if (post == null)
				return new ChatJoinResponse(false, "게시글 없음", null, 0, 0);

			if (dao.isAlreadyJoined(req.getPostId(), req.getUserId()))
				return new ChatJoinResponse(true, "이미 참가 중", "channel-" + req.getPostId(), post.getCurrentPeople(),
						post.getMaxPeople());

			if (post.getCurrentPeople() >= post.getMaxPeople())
				return new ChatJoinResponse(false, "정원 초과", null, post.getCurrentPeople(), post.getMaxPeople());

			dao.insertChatParticipant(post.getPostId(), req.getUserId());
			dao.updateCurrentPeople(req.getPostId(), post.getCurrentPeople() + 1);

			return new ChatJoinResponse(true, "참가 성공", "channel-" + req.getPostId(), post.getCurrentPeople() + 1,
					post.getMaxPeople());
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return res;
	}
}
