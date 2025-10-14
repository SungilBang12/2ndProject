package Interface;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

import dto.Users;

public interface UsersInterface {
	// Connection 객체를 인수로 받아 트랜잭션 관리를 Service 계층에 위임합니다.

    // 회원가입 (Create)
    int insertUser(Connection conn, Users user) throws SQLException;

    // 사용자 ID로 조회 (Read - 로그인, 정보 수정 전)
    Optional<Users> selectUserByUserId(Connection conn, String userId) throws SQLException;
    
    // 전체 사용자 목록 조회 (관리자용)
    List<Users> selectAllUsers(Connection conn) throws SQLException;

    // 회원정보수정 (Update)
    int updateUser(Connection conn, Users user) throws SQLException;

    // 회원탈퇴 (Delete)
    int deleteUser(Connection conn, String userId) throws SQLException;

    // ID 존재 여부 확인 (비동기 중복 체크용)
    boolean isUserIdExists(Connection conn, String userId) throws SQLException;

}
