package utils;

import javax.sql.DataSource;

import org.apache.tomcat.jdbc.pool.DataSourceProxy;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        // DataSource 생성 후 ServletContext에 저장
        ctx.setAttribute("datasource", DbConfig.createDataSource(ctx));
        System.out.println("DataSource 초기화 완료");
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
