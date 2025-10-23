package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class ConnectionPoolHelper {
    private static DataSource ds;

    // ✅ JNDI를 통해 DataSource 가져오기
    public static void init() {
        if (ds != null) return;
        try {
            Context initCtx = new InitialContext();
            Context envCtx = (Context) initCtx.lookup("java:comp/env");
            ds = (DataSource) envCtx.lookup("jdbc/oracle");
            System.out.println("[ConnectionPoolHelper] ✅ JNDI DataSource 초기화 완료");
        } catch (NamingException e) {
            e.printStackTrace();
            throw new RuntimeException("JNDI DataSource를 찾을 수 없습니다: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        if (ds == null) {
            throw new RuntimeException("DataSource가 초기화되지 않았습니다. init() 호출 필요.");
        }
        Connection c = ds.getConnection();
        c.setAutoCommit(true);
        return c;
    }

    public static void close(ResultSet rs) { if (rs != null) try { rs.close(); } catch (Exception ignored) {} }
    public static void close(PreparedStatement pstmt) { if (pstmt != null) try { pstmt.close(); } catch (Exception ignored) {} }
    public static void close(Connection conn) { if (conn != null) try { conn.close(); } catch (Exception ignored) {} }
}
