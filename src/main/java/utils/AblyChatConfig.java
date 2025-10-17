//AblyChatConfig.java
package utils;

import java.util.Optional;
import java.util.Properties;

import jakarta.servlet.ServletContext;

public class AblyChatConfig {
	public static final String ABLY_ATTRIBUTE = "ablyConfig";

    /**
     * ServletContext에서 Firebase Properties 객체를 가져옵니다.
     */
	public static Optional<Properties> getAblyConfig(ServletContext ctx) {
	    Object config = ctx.getAttribute(ABLY_ATTRIBUTE);
	    
	    System.out.println("GetAblyConfig 의 config 자료= " + config);
	    if (config instanceof Properties) {
	        return Optional.of((Properties) config);
	    }
	    
	    System.err.println("ably 설정(Properties)을 ServletContext에서 찾을 수 없습니다.");
	    return Optional.empty();
	}
}
