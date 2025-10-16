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
			System.out.println(req.getPostId());
			System.out.println(req.getClass());
			SchedulePostDto post = dao.getSchedulePost(req.getPostId());
			
			System.out.println("프론트 채팅 join 요청사항" + post);

			if (post == null)
				return new ChatJoinResponse(false, "게시글 없음", null, 0, 0);

			System.out.println("게시글 있음" + post);
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
		System.out.println("채팅 참가 널값 반환");
		return res;
	}
}
