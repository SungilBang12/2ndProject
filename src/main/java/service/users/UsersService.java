package service.users;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Optional;

import org.mindrot.jbcrypt.BCrypt;

import dao.UsersDao;
import dto.Users;
import utils.ConnectionPoolHelper; // ConnectionPoolHelper를 사용하도록 가정

/**
 * 사용자 관련 비즈니스 로직 및 트랜잭션 관리를 수행하는 Service 계층입니다.
 */
public class UsersService {

	private final UsersDao usersDao;

	// DAO 인스턴스는 한 번만 생성
	public UsersService() {
		this.usersDao = new UsersDao();
	}

	/**
	 * 사용자 정의 RuntimeException 클래스 (트랜잭션 롤백 유도용)
	 */
	public static class ServiceException extends RuntimeException {
		public ServiceException(String message) {
			super(message);
		}
	}

	/**
	 * 1. 회원가입 처리 (트랜잭션 관리)
	 * 
	 * @param user 회원 정보 (비밀번호는 평문)
	 * @return 성공 여부
	 */
	public boolean joinUser(Users user) {
		Connection conn = null;
		try {
			conn = ConnectionPoolHelper.getConnection();
			// 🚨 트랜잭션 시작
			conn.setAutoCommit(false);

			// 🚨🚨 시큐어 코딩: 서버 측 입력값 검증 (클라이언트 검증 우회 방지)
			if (user.getUserId() == null || !user.getUserId().matches("^[a-zA-Z0-9]{5,20}$")) {
				throw new ServiceException("ID 형식이 올바르지 않거나 길이가 부족합니다.");
			}
			if (!user.getPassword().matches("^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$")) {
				throw new ServiceException("비밀번호는 8자 이상, 대/소문자, 숫자, 특수문자를 포함해야 합니다.");
			}

			// 💡 ID 중복 확인
			if (usersDao.isUserIdExists(conn, user.getUserId())) {
				throw new ServiceException("이미 존재하는 사용자 ID입니다.");
			}

			// 💡 추가된 로직: 이메일 중복 확인
			if (usersDao.isEmailExists(conn, user.getEmail())) {
				throw new ServiceException("이미 사용 중인 이메일 주소입니다.");
			}

			// 💡 비밀번호 해싱은 Service에서 진행 (DAO에 넘기기 전에)
			String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());

			// 삽입할 사용자 정보 DTO 생성 및 해시된 비밀번호 설정
			Users userToInsert = Users.builder().userId(user.getUserId()).username(user.getUsername())
					.password(hashedPassword) // 해시된 비밀번호 사용
					.email(user.getEmail()).ROLE(user.getROLE() != null ? user.getROLE() : "USER").isEmailVerified(true) // 이메일
					// Firebase UID는 Controller에서 설정되어 넘어와야 함 (현재는 user DTO에 설정되어 있다고 가정)
					.uid(user.getUid()).build();

			// DAO 호출
			int result = usersDao.insertUser(conn, userToInsert);

			if (result > 0) {
				conn.commit(); // 🚨 커밋
				return true;
			} else {
				conn.rollback();
				return false;
			}

		} catch (ServiceException e) {
			System.err.println("Join Service Error: " + e.getMessage());
			if (conn != null)
				try {
					conn.rollback();
				} catch (SQLException rollbackEx) {
					rollbackEx.printStackTrace();
				}
			return false;
		} catch (SQLException e) {
			System.err.println("DB Transaction Error: " + e.getMessage());
			if (conn != null)
				try {
					conn.rollback();
				} catch (SQLException rollbackEx) {
					rollbackEx.printStackTrace();
				}
			// 🚨 KISA: 에러 처리 - DB 예외를 RuntimeException으로 던져 사용자에게 노출 방지
			throw new ServiceException("데이터베이스 처리 중 오류가 발생했습니다.");
		} finally {
			if (conn != null)
				try {
					conn.setAutoCommit(true); // 커넥션 풀 반환 전 AutoCommit 복구
					ConnectionPoolHelper.close(conn); // 💡 개선: ConnectionPoolHelper를 사용하여 연결 닫기
				} catch (SQLException e) {
					e.printStackTrace();
				}
		}
	}

	/**
	 * 2. 로그인 처리 (보안: 비밀번호 비교) 💡 개선: Connection 관리 및 예외 처리 강화
	 */
	public Optional<Users> loginUser(String userId, String password) {
		// try-with-resources를 사용하여 Connection을 자동으로 닫도록 개선
		try (Connection conn = ConnectionPoolHelper.getConnection()) {

			Optional<Users> userOpt = usersDao.selectUserByUserId(conn, userId);

			if (userOpt.isPresent()) {
				Users user = userOpt.get();

				// 🚨 필수: 이메일 인증 상태 체크 (이전 버전에서 추가된 로직)
				if (!user.isEmailVerified()) {
					throw new ServiceException("이메일 인증을 완료해야 로그인할 수 있습니다.");
				}

				// DB에서 가져온 해시 값에 혹시 모를 공백 제거
				String dbHashedPassword = user.getPassword().trim();

				// 사용자가 입력한 평문 비밀번호에 혹시 모를 공백 제거
				String plainPassword = password.trim();

				boolean match = BCrypt.checkpw(plainPassword, dbHashedPassword);
				if (match) {
					return userOpt;
				}
			}
			return Optional.empty(); // 사용자 없거나 비밀번호 불일치

		} catch (

		ServiceException e) {
			// 이메일 미인증 등의 사용자 오류 메시지를 Controller로 전달하기 위해 ServiceException 재던지기
			throw e;
		} catch (SQLException e) {
			System.err.println("DB Access Error: " + e.getMessage());
			// 🚨 KISA: 에러 처리 - DB 예외를 RuntimeException으로 던져 사용자에게 노출 방지
			throw new ServiceException("데이터베이스 처리 중 오류가 발생했습니다.");
		}
	}

	// 다른 Service 메서드 (update, delete 등)도 동일하게 트랜잭션 처리를 적용해야 함

	/**
	 * 3. ID 중복 확인 (비동기 처리용) 💡 개선: DAO의 isUserIdExists(COUNT(*)) 메서드를 사용하여 효율적으로 중복
	 * 확인
	 */
	public boolean isUserIdExists(String userId) {
		// try-with-resources를 사용하여 Connection을 자동으로 닫도록 개선
		try (Connection conn = ConnectionPoolHelper.getConnection()) {
			// DAO의 COUNT(*) 쿼리 사용으로 성능 개선
			return usersDao.isUserIdExists(conn, userId);
		} catch (SQLException e) {
			System.err.println("DB Access Error: " + e.getMessage());
			// 🚨 KISA: 에러 처리 - DB 예외를 ServiceException으로 감싸서 일관되게 처리
			throw new ServiceException("ID 중복 확인 중 데이터베이스 오류가 발생했습니다.");
		}
	}

	/**
	 * 4. 이메일 인증 상태 확인 (Controller의 최종 체크용)
	 */
	public boolean isEmailVerified(String email) {
		try (Connection conn = ConnectionPoolHelper.getConnection()) {
			return usersDao.isEmailVerified(conn, email);
		} catch (SQLException e) {
			System.err.println("DB Access Error: " + e.getMessage());
			throw new ServiceException("이메일 인증 상태 확인 중 데이터베이스 오류가 발생했습니다.");
		}
	}

	/**
	 * 5. 이메일 인증 완료 상태로 DB 업데이트
	 */
	public boolean updateEmailVerified(String email) {
		try (Connection conn = ConnectionPoolHelper.getConnection()) {
			int result = usersDao.updateEmailVerified(conn, email);
			return result > 0;
		} catch (SQLException e) {
			System.err.println("DB Access Error: " + e.getMessage());
			throw new ServiceException("이메일 인증 업데이트 중 데이터베이스 오류가 발생했습니다.");
		}
	}

	/**
	 * 6. 이메일 존재 여부 확인 (비동기 및 회원가입 중복 체크용) 💡 새로 추가된 기능
	 */

	public boolean isEmailExists(String email) {
		// try-with-resources를 사용하여 Connection을 자동으로 닫도록 개선
		try (Connection conn = ConnectionPoolHelper.getConnection()) {
			// DAO의 COUNT(*) 쿼리 사용으로 성능 개선
			return usersDao.isEmailExists(conn, email);
		} catch (SQLException e) {
			System.err.println("DB Access Error: " + e.getMessage());
			// 🚨 KISA: 에러 처리 - DB 예외를 ServiceException으로 감싸서 일관되게 처리
			throw new ServiceException("이메일 중복 확인 중 데이터베이스 오류가 발생했습니다.");
		}
	}
}
