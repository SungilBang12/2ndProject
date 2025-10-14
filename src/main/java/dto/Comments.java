package dto;
import java.time.LocalDate;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Comments {
	private Integer commentId;
    private Integer postId;
    private String  userId;
    private String  contentRaw; // DB의 CLOB: JSON 문자열 그대로 보관
    private LocalDate createdAt;

    // 파싱된 필드(표시/비즈 로직용) — DB 변경 없이 CONTENT(JSON)로 해결
    private String  text;       // 댓글 본문
    private String  imageUrl;   // 이미지 1개 (선택)
    private boolean edited;     // (수정됨)
    private boolean deleted;    // 삭제 여부
    private boolean author;     // 글쓴이 배지용 (서버에서 판별해 내려줌)
}
