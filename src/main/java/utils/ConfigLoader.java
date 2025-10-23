package utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigLoader {

    /**
     * 클래스패스 또는 절대경로에서 properties 파일을 읽습니다.
     * (현재 구조: WEB-INF/classes/ 에 바로 존재)
     */
    public static Properties load(String fileName) throws IOException {
        Properties props = new Properties();
        InputStream in = null;

        // ✅ 1️⃣ classpath 기준으로 시도 (WEB-INF/classes)
        in = ConfigLoader.class.getClassLoader().getResourceAsStream(fileName);

        if (in == null) {
            // ✅ 2️⃣ fallback: 톰캣 실행 디렉토리 기준으로 수동 탐색
            String basePath = System.getProperty("catalina.base")
                    + "/webapps/ROOT/WEB-INF/classes/" + fileName;
            File f = new File(basePath);
            if (f.exists()) {
                in = new FileInputStream(f);
                System.out.println("[ConfigLoader] External file loaded: " + basePath);
            } else {
                throw new IOException("[ConfigLoader] 설정 파일을 찾을 수 없습니다: " + fileName +
                        "\n경로: " + f.getAbsolutePath());
            }
        } else {
            System.out.println("[ConfigLoader] Loaded from classpath: " + fileName);
        }

        props.load(in);
        in.close();
        return props;
    }
}
