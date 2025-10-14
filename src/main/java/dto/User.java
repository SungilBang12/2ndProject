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
public class User {
    private String userId;
    private String password;
    private String username;
    private String email;
    private String role;
    private LocalDate createdAt;
    private LocalDate updatedAt;
}
