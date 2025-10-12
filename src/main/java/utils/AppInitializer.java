package utils;

import javax.sql.DataSource;

import org.apache.tomcat.jdbc.pool.DataSourceProxy;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import utils.s3.R2Helper;

import java.io.InputStream;

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