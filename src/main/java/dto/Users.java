package dto;

import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * 사용자 정보를 담는 POJO (Plain Old Java Object) 클래스입니다.
 * Lombok을 사용하여 getter, setter, 생성자 등을 자동 생성합니다.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Users {
    // DB의 Primary Key (auto-increment)가 있다면 Long id를 추가하는 것이 일반적이나,
    // 여기서는 userId를 PK 겸 식별자로 사용한다고 가정합니다.
	private String userId;
	private String username;
	private String password;
	private String email;
	private String ROLE; // 관리자(ADMIN), 일반 사용자(USER) 등의 역할
	private boolean isEmailVerified; // 💡 추가됨: 이메일 인증 여부
	private String uid; // 💡 추가됨: Firebase UID UID는 오라클에서 에러뜸
	private LocalDateTime createdAt; // DB: CREATED_AT
}


/*
  "USER_ID" VARCHAR2(50) NOT NULL,
    "USERNAME" VARCHAR2(100),
    "PASSWORD" VARCHAR2(200),
    "EMAIL" VARCHAR2(100),
    "ROLE" VARCHAR2(10),
    "CREATED_AT" DATE,
 */
