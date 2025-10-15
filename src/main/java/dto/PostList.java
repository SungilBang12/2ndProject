package dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PostList {
    private int listId;
    private int categoryId;
    private int typeId;
}
