package dto;

import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Post {
    Integer postId;
    String userId;
    Integer listId;
    String title;
    String content;
    Integer hit;
    LocalDate createdAt;
    LocalDate updatedAt;
    String postType;      // POST_TYPE.TYPE_NAME
    String category;      // CATEGORY.CATEGORY_NAME
    Integer postTypeId;   // POST_TYPE.TYPE_ID
    Integer categoryId;   // CATEGORY.CATEGORY_ID
}