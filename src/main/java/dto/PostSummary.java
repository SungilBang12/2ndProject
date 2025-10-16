package dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostSummary {
    private Integer postId;
    private String userId;
    private Integer listId;
    private String title;
    private String content;  // 미리보기 (200자)
    private Integer hit;
    private String createdAt; // JSON 직렬화용
    
    // ✅ 추가 필드 (all.jsp 스타일)
    private Integer categoryId;
    private Integer postTypeId;
    private String category;     // 카테고리명
    private String postType;     // 게시글 타입명
}