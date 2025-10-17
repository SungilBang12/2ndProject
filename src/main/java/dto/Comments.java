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
    private Integer listId;      // ✅ 추가
    private String  userId;
    private String  contentRaw;
    private LocalDate createdAt;
    
    // 파싱된 필드
    private String  text;
    private String  imageUrl;
    private boolean edited;
    private boolean deleted;
}