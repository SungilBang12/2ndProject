package utils;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

public class AppInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[AppInitializer] 서버 시작 중... 설정 파일 초기화 (JNDI 모드)");

        try {
            // ✅ 톰캣 context.xml의 JNDI DataSource 초기화
            ConnectionPoolHelper.init();
            System.out.println("[AppInitializer] JNDI DataSource 초기화 완료 ✅");

        } catch (Exception e) {
            System.err.println("[AppInitializer] JNDI 초기화 실패 ❌: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("[AppInitializer] 초기화 완료 ✅");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[AppInitializer] 서버 종료 중...");
    }
}
