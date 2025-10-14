package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import dto.User;
import utils.ConnectionPoolHelper;

public class UserDao {

    // ✅ 로그인 검증
    public User login(String userId, String password) {
        String sql = "SELECT * FROM USERS WHERE USER_ID = ? AND PASSWORD = ?";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setString(2, password); // 나중에 bcrypt 비교로 변경 예정

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getString("USER_ID"));
                    user.setPassword(rs.getString("PASSWORD"));
                    user.setUsername(rs.getString("USERNAME"));
                    user.setEmail(rs.getString("EMAIL"));
                    user.setRole(rs.getString("ROLE"));
                    user.setCreatedAt(rs.getDate("CREATED_AT").toLocalDate());
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ✅ 회원가입 (INSERT)
    public int register(User user) {
        String sql = "INSERT INTO USERS (USER_ID, PASSWORD, USERNAME, EMAIL, ROLE, CREATED_AT) VALUES (?, ?, ?, ?, ?, SYSDATE)";
        try (Connection conn = ConnectionPoolHelper.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, user.getUserId());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getUsername());
            pstmt.setString(4, user.getEmail());
            pstmt.setString(5, user.getRole());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
