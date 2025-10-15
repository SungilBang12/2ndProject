package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.mindrot.jbcrypt.BCrypt; // 비밀번호 암호화 라이브러리

import Interface.UsersInterface;
import dto.Users;

public class UsersDao implements UsersInterface {
	
	// SQL 쿼리 상수 추가 및 통합
    private static final String INSERT_USER_SQL = "INSERT INTO users (USER_ID, USERNAME, PASSWORD, EMAIL, ROLE, IS_EMAIL_VERIFIED, \"UID\", CREATED_AT) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
	private static final String SELECT_USER_BY_EMAIL_SQL = "SELECT * FROM users WHERE EMAIL = ?";
	private static final String UPDATE_EMAIL_VERIFIED_SQL = "UPDATE users SET IS_EMAIL_VERIFIED = TRUE WHERE EMAIL = ?";
	private static final String CHECK_EMAIL_EXISTS_SQL = "SELECT COUNT(*) FROM users WHERE EMAIL = ?";
	private static final String CHECK_ID_EXISTS_SQL = "SELECT COUNT(*) FROM users WHERE USER_ID = ?";
	private static final String SELECT_USER_BY_ID_SQL = "SELECT * FROM users WHERE USER_ID = ?";
	private static final String SELECT_ALL_USERS_SQL = "SELECT userId, username, email, ROLE, IS_EMAIL_VERIFIED, CREATED_AT FROM users ORDER BY CREATED_AT DESC";


	// 헬퍼 메서드: ResultSet을 Users 객체로 매핑 (필드 추가 및 테이블 컬럼명 통일)
	private Users mapResultSetToUser(ResultSet rs) throws SQLException {
	    Timestamp timestamp = rs.getTimestamp("CREATED_AT");
	    
	    boolean isEmailVerified = false;
	    
	    // 오라클은 boolean값이 없음
	    if(rs.getInt("IS_EMAIL_VERIFIED")==1) {
	    	isEmailVerified = true;
	    }
	    
		return Users.builder()
				.userId(rs.getString("USER_ID"))
				.username(rs.getString("USERNAME"))
				.password(rs.getString("PASSWORD"))
				.email(rs.getString("EMAIL"))
				.ROLE(rs.getString("ROLE"))
				.isEmailVerified(isEmailVerified) // 💡 추가됨: 이메일 인증 상태
				.uid(rs.getString("UID")) // 💡 추가됨: Firebase UID
				.createdAt(timestamp != null ? timestamp.toLocalDateTime() : null)
				.build();
	}

	/**
	 * 1. 회원가입 (INSERT) - 비밀번호 암호화 및 PreparedStatement 사용
     * 💡 IS_EMAIL_VERIFIED, FIREBASE_UID 저장 로직 통합
	 */
	@Override
	public int insertUser(Connection conn, Users user) throws SQLException {
			int result = 0;
		
		int isEmailVerified = 0;
		if(user.isEmailVerified()) {
			isEmailVerified = 1;
		}
		
		System.out.println("회원가입 user dto 정보" + user.toString());
		try (PreparedStatement pstmt = conn.prepareStatement(INSERT_USER_SQL)) {
			pstmt.setString(1, user.getUserId());
			pstmt.setString(2, user.getUsername()); 
			pstmt.setString(3, user.getPassword());// Bcrypt 해시된 비밀번호
			pstmt.setString(4, user.getEmail());
			pstmt.setString(5, user.getROLE() != null ? user.getROLE() : "USER");
			pstmt.setInt(6, isEmailVerified); // 💡 추가됨: 이메일 인증 상태
			pstmt.setString(7, user.getUid()); // 💡 추가됨: Firebase UID
			// DB 타입에 맞게 LocalDateTime을 Timestamp로 변환하여 저장
			pstmt.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));

			result = pstmt.executeUpdate();
		}
		return result;
	}

	/**
	 * 2. 사용자 ID로 사용자 정보 조회 (로그인 및 유효성 검증)
     * 💡 쿼리: SELECT_USER_BY_ID_SQL 사용
	 */
	@Override
	public Optional<Users> selectUserByUserId(Connection conn, String userId) throws SQLException {
		Users user = null;

		try (PreparedStatement pstmt = conn.prepareStatement(SELECT_USER_BY_ID_SQL)) {
			System.out.println();
			pstmt.setString(1, userId);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					// 헬퍼 메서드 mapResultSetToUser를 사용하여 코드 중복 제거
					user = mapResultSetToUser(rs);
				}
			}
		}
		return Optional.ofNullable(user);
	}

	/**
     * 3. 이메일 중복 확인
     * 💡 새로 추가된 기능입니다.
     * @param conn DB 연결
     * @param email 확인할 이메일
     * @return 존재하면 true
     */
    public boolean isEmailExists(Connection conn, String email) throws SQLException {
        try (PreparedStatement pstmt = conn.prepareStatement(CHECK_EMAIL_EXISTS_SQL)) {
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }
    
    /**
     * 4. 이메일 인증 상태 조회
     * 💡 새로 추가된 기능입니다.
     * @param conn DB 연결
     * @param email 이메일
     * @return 인증되었으면 true
     */
    public boolean isEmailVerified(Connection conn, String email) throws SQLException {
        try (PreparedStatement pstmt = conn.prepareStatement(SELECT_USER_BY_EMAIL_SQL)) {
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBoolean("IS_EMAIL_VERIFIED"); 
                }
            }
        }
        return false;
    }
    
    /**
     * 5. 이메일 인증 완료 상태로 업데이트 (Firebase 인증 성공 후 호출)
     * 💡 새로 추가된 기능입니다.
     * @param conn DB 연결
     * @param email 이메일
     * @return 업데이트된 행 수
     */
    public int updateEmailVerified(Connection conn, String email) throws SQLException {
        try (PreparedStatement pstmt = conn.prepareStatement(UPDATE_EMAIL_VERIFIED_SQL)) {
            pstmt.setString(1, email);
            return pstmt.executeUpdate();
        }
    }

	/**
	 * 6. 회원정보수정 (UPDATE)
	 */
	@Override
	public int updateUser(Connection conn, Users user) throws SQLException {
		// 비밀번호가 있다면 다시 해싱하여 업데이트
		String sql = "UPDATE users SET USERNAME = ?, EMAIL = ?"
				+ (user.getPassword() != null && !user.getPassword().isEmpty() ? ", PASSWORD = ?" : "")
				+ " WHERE USER_ID = ?";
		int result = 0;

		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, user.getUsername());
			pstmt.setString(2, user.getEmail());

			int paramIndex = 3;
			if (user.getPassword() != null && !user.getPassword().isEmpty()) {
				String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
				pstmt.setString(paramIndex++, hashedPassword);
			}
			pstmt.setString(paramIndex, user.getUserId());

			result = pstmt.executeUpdate();
		}
		return result;
	}

	/**
	 * 7. 회원탈퇴 (DELETE)
	 */
	@Override
	public int deleteUser(Connection conn, String userId) throws SQLException {
		// SQL 인젝션 방지를 위해 PreparedStatement 사용
		String sql = "DELETE FROM users WHERE USER_ID = ?";
		int result = 0;
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, userId);
			result = pstmt.executeUpdate();
		}
		return result;
	}

	/**
	 * 8. 전체 사용자 목록 조회 (관리자용)
	 * 💡 쿼리: SELECT_ALL_USERS_SQL 사용 및 컬럼명 통일
	 */
	@Override
	public List<Users> selectAllUsers(Connection conn) throws SQLException {
		List<Users> userList = new ArrayList<>();
		
		try (PreparedStatement pstmt = conn.prepareStatement(SELECT_ALL_USERS_SQL); ResultSet rs = pstmt.executeQuery()) {

			while (rs.next()) {
			    Timestamp timestamp = rs.getTimestamp("CREATED_AT");
				Users user = Users.builder()
						.userId(rs.getString("userId"))
						.username(rs.getString("username"))
						.email(rs.getString("email"))
						.ROLE(rs.getString("ROLE"))
						.isEmailVerified(rs.getBoolean("IS_EMAIL_VERIFIED"))
						.createdAt(timestamp != null ? timestamp.toLocalDateTime() : null)
						.build();
				userList.add(user);
			}
		}
		return userList;
	}

	/**
	 * 9. ID 존재 여부 확인 (중복 체크)
	 * 💡 쿼리: CHECK_ID_EXISTS_SQL 사용
	 */
	@Override
	public boolean isUserIdExists(Connection conn, String userId) throws SQLException {
		try (PreparedStatement pstmt = conn.prepareStatement(CHECK_ID_EXISTS_SQL)) {
			pstmt.setString(1, userId);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return rs.getInt(1) > 0;
				}
			}
		}
		return false;
	}
}
