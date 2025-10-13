package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.sql.DataSource;

import jakarta.servlet.ServletContext;

public class ConnectionPoolHelper {
	private static DataSource ds;
	
	// ServletContext에서 DataSource 가져오기
	// DbConfig과 병합은 힘듦 => DataSource가 apache하고 sql에 둘 다 있음
    public static void init(ServletContext context) {
        ds = (DataSource) context.getAttribute("datasource");
        if (ds == null) {
            throw new RuntimeException("DataSource가 ServletContext에 설정되지 않았습니다.");
        }
    }

    public static Connection getConnection() throws SQLException {
        if (ds == null) {
            throw new RuntimeException("DataSource가 초기화되지 않았습니다. init() 호출 필요.");
        }
        Connection c = ds.getConnection();
     // ✅ 오토커밋 활성화
        c.setAutoCommit(true);
//        c.setAutoCommit(false);
        return c;
    }
    
	public static void close(ResultSet rs) {
		if(rs != null) {
			try {
				rs.close();
			}catch(Exception e) {
				
			}
		}
	}
	public static void close(PreparedStatement pstmt) {
		if(pstmt != null) {
			try {
				pstmt.close();
			}catch(Exception e) {
				
			}
		}
	}
	public static void close(Connection conn) {
		if(conn != null) {
			try {
				conn.close();
			}catch(Exception e) {
				
			}
		}
	}
}