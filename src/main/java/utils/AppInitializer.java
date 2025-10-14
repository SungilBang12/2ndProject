package utils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import javax.sql.DataSource;

import org.apache.tomcat.jdbc.pool.DataSourceProxy;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import utils.s3.R2Helper;

@WebListener
public class AppInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        
        // SSL/TLS 설정 (R2 연결용)
        System.setProperty("https.protocols", "TLSv1.2,TLSv1.3");
        System.setProperty("jdk.tls.client.protocols", "TLSv1.2,TLSv1.3");
        
        // DataSource 생성 후 ServletContext에 저장
        ctx.setAttribute("datasource", DbConfig.createDataSource(ctx));
        System.out.println("DataSource 초기화 완료");
        
        // ConnectionPoolHelper 초기화 (있다면)
        try {
            ConnectionPoolHelper.init(ctx);
            System.out.println("ConnectionPoolHelper 초기화 완료");
        } catch (Exception e) {
            System.err.println("ConnectionPoolHelper 초기화 실패: " + e.getMessage());
            e.printStackTrace();
        }
        
        // R2Helper 초기화
        try (InputStream in = ctx.getResourceAsStream("/META-INF/keys/db-config.properties")) {
            R2Helper.init(in);
        } catch (Exception e) {
            System.err.println("R2Helper 초기화 실패: " + e.getMessage());
            e.printStackTrace();
        }
        
     // 🚨 [추가된 로직] Firebase 설정 로드 및 ServletContext에 저장
        // 이로써 API Key는 코드 외부에서 로드되어 메모리에만 존재합니다.
        try {
            Properties firebaseConfig = loadProperties(ctx, "/META-INF/keys/firebase-config.properties");
            ctx.setAttribute("firebaseConfig", firebaseConfig);
            System.out.println("Firebase 설정 로드 완료: ServletContext에 저장");
        } catch (IOException e) {
            System.err.println("Firebase 설정 파일 로드 실패!");
            e.printStackTrace();
        }
    }

    /**
     * 지정된 경로에서 Properties 파일을 로드하는 헬퍼 메서드
     */
    private Properties loadProperties(ServletContext ctx, String path) throws IOException {
        Properties props = new Properties();
        try (InputStream in = ctx.getResourceAsStream(path)) {
            if (in == null) {
                throw new IOException("설정 파일 경로를 찾을 수 없습니다: " + path);
            }
            props.load(in);
        }
        return props;
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        DataSource ds = (DataSource) ctx.getAttribute("datasource");
        if (ds != null) {
            ((DataSourceProxy) ds).close();
            System.out.println("DataSource 종료 완료");
        }
    }
}