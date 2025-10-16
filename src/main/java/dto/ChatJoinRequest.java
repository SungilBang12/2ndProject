// ChatJoinRequest.java
package dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
// 채팅에 넣을 정보
public class ChatJoinRequest {
		private int postId;
	    private String userId;
}
