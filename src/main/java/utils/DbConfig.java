package utils;

import org.apache.tomcat.jdbc.pool.DataSource;
import org.apache.tomcat.jdbc.pool.PoolProperties;

import jakarta.servlet.ServletContext;
import java.io.InputStream;
import java.util.Properties;

public class DbConfig {

    public static DataSource createDataSource(ServletContext context) {
        try (InputStream in = context.getResourceAsStream("/META-INF/keys/db-config.properties")) {
            Properties props = new Properties();
            props.load(in);

            PoolProperties p = new PoolProperties();
            p.setUrl(props.getProperty("DB_URL"));
            p.setDriverClassName(props.getProperty("DB_DRIVER"));
            p.setUsername(props.getProperty("DB_USER"));
            p.setPassword(props.getProperty("DB_PASS"));
            p.setInitialSize(3);
            p.setMaxActive(20);
            p.setMaxIdle(10);
            p.setMinIdle(3);
            p.setTestOnBorrow(true);
            p.setValidationQuery("SELECT 1 FROM DUAL");

            DataSource datasource = new DataSource();
            datasource.setPoolProperties(p);

            return datasource;

        } catch (Exception e) {
            throw new RuntimeException("커넥션풀 생성 실패", e);
        }
    }
}
