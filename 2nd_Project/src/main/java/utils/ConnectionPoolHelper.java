package utils;

import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class ConnectionPoolHelper {
	private static DataSource ds;
	static {
		try {
			Context context = new InitialContext();
			ds = (DataSource) context.lookup("java:comp/env/jdbc/oracle");
		} catch (Exception e) {
			throw new RuntimeException("JNDI DataSource lookup failed: " + e.getMessage(), e);
		}
	}

	public static Connection getConnection() throws SQLException {
		return ds.getConnection();
	}
}