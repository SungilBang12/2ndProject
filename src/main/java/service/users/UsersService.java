package service.users;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

import org.mindrot.jbcrypt.BCrypt;

import dao.UsersDao;
import dto.Users;
// import utils.DBUtil;                    // ❌ 제거
import utils.ConnectionPoolHelper;          // ✅ 추가

public class UsersService {
	
	private final UsersDao usersDao = new UsersDao();
	
	/**
	 * 사용자 정의 예외 클래스
	 */
	public static class ServiceException extends Exception {
		private static final long serialVersionUID = 1L;
		
		public ServiceException(String message) {
			super(message);
		}
	}
	
	/**
	 * 1. 회원가입 처리
	 */
	public boolean joinUser(Users user) throws ServiceException {
		Connection conn = null;
		
		try {
			conn = ConnectionPoolHelper.getConnection();
			conn.setAutoCommit(false); // 트랜잭션 시작
			
			// 1. ID 중복 확인
			if (usersDao.isUserIdExists(conn, user.getUserId())) {
				throw new ServiceException("이미 존재하는 아이디입니다.");
			}
			
			// 2. 이메일 중복 확인
			if (usersDao.isEmailExists(conn, user.getEmail())) {
				throw new ServiceException("이미 가입된 이메일입니다.");
			}
			
			// 3. 비밀번호 암호화
			String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
			user.setPassword(hashedPassword);
			
			// 4. 사용자 등록
			int result = usersDao.insertUser(conn, user);
			
			if (result > 0) {
				conn.commit(); // 성공 시 커밋
				return true;
			} else {
				conn.rollback(); // 실패 시 롤백
				return false;
			}
			
		} catch (SQLException e) {
			if (conn != null) {
				try {
					conn.rollback();
				} catch (SQLException ex) {
					ex.printStackTrace();
				}
			}
			throw new ServiceException("회원가입 처리 중 오류가 발생했습니다.");
		} finally {
			ConnectionPoolHelper.close(conn);
		}
	}
	
	/**
	 * 2. 로그인 처리
	 */
	public Optional<Users> loginUser(String userId, String password) {
		Connection conn = null;
		
		try {
			conn = ConnectionPoolHelper.getConnection();
			
			// 사용자 정보 조회
			Optional<Users> userOpt = usersDao.selectUserByUserId(conn, userId);
			
			if (userOpt.isPresent()) {
				Users user = userOpt.get();
				
				// 비밀번호 검증 (BCrypt 사용)
				if (BCrypt.checkpw(password, user.getPassword())) {
					return Optional.of(user);
				}
			}
			
			return Optional.empty();
			
		} catch (SQLException e) {
			e.printStackTrace();
			return Optional.empty();
		} finally {
			ConnectionPoolHelper.close(conn);
		}
	}
	
	/**
	 * 3. 사용자 정보 조회 (ID로)
	 */
	public Optional<Users> getUserById(String userId) throws ServiceException {
		Connection conn = null;
		
		try {
			conn = ConnectionPoolHelper.getConnection();
			return usersDao.selectUserByUserId(conn, userId);
		} catch (SQLException e) {
			throw new ServiceException("사용자 정보 조회 중 오류가 발생했습니다.");
		} finally {
			ConnectionPoolHelper.close(conn);
		}
	}
	
	/**
	 * 4. 사용자 정보 수정
	 */
	public boolean updateUser(Users user, String currentPassword) throws ServiceException {
		Connection conn = null;
		
		try {
			conn = ConnectionPoolHelper.getConnection();
			conn.setAutoCommit(false);
			
			// 1. 현재 비밀번호 검증
			Optional<Users> existingUserOpt = usersDao.selectUserByUserId(conn, user.getUserId());
			
			if (!existingUserOpt.isPresent()) {
				throw new ServiceException("사용자를 찾을 수 없습니다.");
			}
			
			Users existingUser = existingUserOpt.get();
			
			// 현재 비밀번호 확인
			if (!BCrypt.checkpw(currentPassword, existingUser.getPassword())) {
				throw new ServiceException("현재 비밀번호가 일치하지 않습니다.");
			}
			
			// 2. 이메일 변경 시 중복 확인
			if (!existingUser.getEmail().equals(user.getEmail())) {
				if (usersDao.isEmailExists(conn, user.getEmail())) {
					throw new ServiceException("이미 사용 중인 이메일입니다.");
				}
			}
			
			// 3. 새 비밀번호가 있다면 암호화
			if (user.getPassword() != null && !user.getPassword().isEmpty()) {
				String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
				user.setPassword(hashedPassword);
			} else {
				// 비밀번호 변경이 없으면 null로 설정
				user.setPassword(null);
			}
			
			// 4. 사용자 정보 업데이트
			int result = usersDao.updateUser(conn, user);
			
			if (result > 0) {
				conn.commit();
				return true;
			} else {
				conn.rollback();
				return false;
			}
			
		} catch (SQLException e) {
			if (conn != null) {
				try {
					conn.rollback();
				} catch (SQLException ex) {
					ex.printStackTrace();
				}
			}
			throw new ServiceException("사용자 정보 수정 중 오류가 발생했습니다.");
		} finally {
			ConnectionPoolHelper.close(conn);
		}
	}
	
	/**
	 * 5. 회원 탈퇴
	 */
	public boolean deleteUser(String userId, String password) throws ServiceException {
		Connection conn = null;
		
		try {
			conn = ConnectionPoolHelper.getConnection();
			conn.setAutoCommit(false);
			
			// 비밀번호 확인
			Optional<Users> userOpt = usersDao.selectUserByUserId(conn, userId);
			
			if (!userOpt.isPresent()) {
				throw new ServiceException("사용자를 찾을 수 없습니다.");
			}
			
			Users user = userOpt.get();
			
			if (!BCrypt.checkpw(password, user.getPassword())) {
				throw new ServiceException("비밀번호가 일치하지 않습니다.");
			}
			
			// 회원 탈퇴
			int result = usersDao.deleteUser(conn, userId);
			
			if (result > 0) {
				conn.commit();
				return true;
			} else {
				conn.rollback();
				return false;
			}
			
		} catch (SQLException e) {
			if (conn != null) {
				try {
					conn.rollback();
				} catch (SQLException ex) {
					ex.printStackTrace();
				}
			}
			throw new ServiceException("회원 탈퇴 처리 중 오류가 발생했습니다.");
		} finally {
			ConnectionPoolHelper.close(conn);
		}
	}
	
	/**
	 * 6. ID 중복 확인
	 */
	public boolean isUserIdExists(String userId) {
		Connection conn = null;
		
		try {
			conn = ConnectionPoolHelper.getConnection();
			return usersDao.isUserIdExists(conn, userId);
		} catch (SQLException e) {
			e.printStackTrace();
			return true; // 오류 시 안전하게 중복으로 처리
		} finally {
			ConnectionPoolHelper.close(conn);
		}
	}
	
	/**
	 * 7. 이메일 중복 확인
	 */
	public boolean isEmailExists(String email) {
		Connection conn = null;
		
		try {
			conn = ConnectionPoolHelper.getConnection();
			return usersDao.isEmailExists(conn, email);
		} catch (SQLException e) {
			e.printStackTrace();
			return true; // 오류 시 안전하게 중복으로 처리
		} finally {
			ConnectionPoolHelper.close(conn);
		}
	}
	
	/**
	 * 8. 이메일 인증 상태 확인
	 */
	public boolean isEmailVerified(String email) {
		Connection conn = null;
		
		try {
			conn = ConnectionPoolHelper.getConnection();
			return usersDao.isEmailVerified(conn, email);
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		} finally {
			ConnectionPoolHelper.close(conn);
		}
	}
}
