package utils;

import java.io.IOException;
import java.util.Properties;

public class AblyChatConfig {
    private static Properties props;

    static {
        try {
            props = ConfigLoader.load("ably-chat-config.properties");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static String get(String key) {
        return props.getProperty(key);
    }

    public static String getApiKey() { return get("api_key"); }
    public static String getAppId() { return get("app_id"); }
    public static String getRegion() { return get("region"); }
}
