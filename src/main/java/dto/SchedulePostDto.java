package dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SchedulePostDto {
	private int postId;
    private String title;
    private LocalDateTime dateTime;
    private int maxPeople;
    private int currentPeople;
    private String creatorId;

    // 생성자, getter/setter
}