package utils;

import org.apache.tomcat.jdbc.pool.DataSource;
import org.apache.tomcat.jdbc.pool.PoolProperties;

import jakarta.servlet.ServletContext;
import java.io.InputStream;
import java.util.Properties;

public class DbConfig {

    public static DataSource createDataSource(ServletContext context) {
        try (InputStream in = context.getResourceAsStream("/META-INF/keys/db-config.properties")) {
            if (in == null) {
                throw new RuntimeException("db-config.properties 파일을 찾을 수 없습니다.");
            }

            Properties props = new Properties();
            props.load(in);

            // 필수 값 검증
            String dbUrl = getRequiredProperty(props, "DB_URL");
            String dbDriver = getRequiredProperty(props, "DB_DRIVER");
            String dbUser = getRequiredProperty(props, "DB_USER");
            String dbPass = getRequiredProperty(props, "DB_PASS");

            PoolProperties p = new PoolProperties();
            p.setUrl(dbUrl);
            p.setDriverClassName(dbDriver);
            p.setUsername(dbUser);
            p.setPassword(dbPass);
            p.setInitialSize(3);
            p.setMaxActive(20);
            p.setMaxIdle(10);
            p.setMinIdle(3);
            p.setTestOnBorrow(true);
            p.setValidationQuery("SELECT 1 FROM DUAL");

            DataSource datasource = new DataSource();
            datasource.setPoolProperties(p);

            System.out.println("DataSource 생성 완료: " + dbUrl);
            return datasource;

        } catch (Exception e) {
            throw new RuntimeException("커넥션풀 생성 실패", e);
        }
    }

    // 필수 속성 값 가져오기 (null 체크)
    private static String getRequiredProperty(Properties props, String key) {
        String value = props.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            throw new RuntimeException("필수 설정 값이 없습니다: " + key);
        }
        return value.trim();
    }

    // 선택적 속성 값 가져오기 (기본값 제공)
    private static String getProperty(Properties props, String key, String defaultValue) {
        String value = props.getProperty(key);
        return (value != null && !value.trim().isEmpty()) ? value.trim() : defaultValue;
    }
}