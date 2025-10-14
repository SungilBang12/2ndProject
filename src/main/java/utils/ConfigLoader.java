package utils;

import jakarta.servlet.ServletContext;
import java.util.Properties;
import java.util.Optional;

/**
 * ServletContext에 저장된 Firebase 설정값을 안전하게 가져오는 유틸리티 클래스입니다.
 */
public class ConfigLoader {
    
    public static final String FIREBASE_CONFIG_ATTRIBUTE = "firebaseConfig";

    /**
     * ServletContext에서 Firebase Properties 객체를 가져옵니다.
     */
    public static Optional<Properties> getFirebaseConfig(ServletContext ctx) {
        Object config = ctx.getAttribute(FIREBASE_CONFIG_ATTRIBUTE);
        
        if (config instanceof Properties) {
            return Optional.of((Properties) config);
        }
        
        System.err.println("Firebase 설정(Properties)을 ServletContext에서 찾을 수 없습니다.");
        return Optional.empty();
    }
}
