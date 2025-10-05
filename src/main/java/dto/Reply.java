package dto;

import java.sql.Date;
import java.sql.Date;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Generated;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Reply {
		private int comment_id; // 댓글 ID
		private String content_comment;	// 내용;
		private Date created_at_comment; // 작성 날짜
	   private int idx_fk;
}
