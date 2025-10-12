package utils.s3;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.ClientConfiguration;
import com.amazonaws.Protocol;

import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;

import javax.net.ssl.SSLContext;

import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.util.Properties;
import java.util.UUID;

public class R2Helper {
    
    private static AmazonS3 r2Client;
    private static String bucket;
    private static String publicUrl;
    private static boolean initialized = false;

    // private 생성자 (Singleton 패턴)
    private R2Helper() {}

    /**
     * R2 클라이언트 초기화
     * AppInitializer에서 한 번만 호출
     */
    public static synchronized void init(InputStream configStream) {
        if (initialized) {
            System.out.println("R2Helper already initialized");
            return;
        }

        try {
            if (configStream == null) {
                throw new RuntimeException("r2-config.properties 파일을 찾을 수 없습니다.");
            }

            Properties props = new Properties();
            props.load(configStream);

            // 필수 값 검증
            String accessKey = getRequiredProperty(props, "R2_ACCESS_KEY");
            String secretKey = getRequiredProperty(props, "R2_SECRET_KEY");
            String accountId = getRequiredProperty(props, "R2_ACCOUNT_ID");
            bucket = getRequiredProperty(props, "R2_BUCKET");
            publicUrl = props.getProperty("R2_PUBLIC_URL", "");

            BasicAWSCredentials credentials = new BasicAWSCredentials(accessKey, secretKey);
            String endpoint = String.format("https://%s.r2.cloudflarestorage.com", accountId);

            // SSL/TLS 설정 강화
            System.setProperty("https.protocols", "TLSv1.2,TLSv1.3");
            System.setProperty("jdk.tls.client.protocols", "TLSv1.2,TLSv1.3");

            ClientConfiguration clientConfig = new ClientConfiguration();
            clientConfig.setProtocol(Protocol.HTTPS);
            clientConfig.setConnectionTimeout(120000); // 120초
            clientConfig.setSocketTimeout(120000); // 120초
            clientConfig.setMaxErrorRetry(5);
            clientConfig.setUseGzip(false); // Gzip 비활성화

            r2Client = AmazonS3ClientBuilder.standard()
                    .withEndpointConfiguration(
                        new AwsClientBuilder.EndpointConfiguration(endpoint, "auto")
                    )
                    .withCredentials(new AWSStaticCredentialsProvider(credentials))
                    .withClientConfiguration(clientConfig)
                    .withPathStyleAccessEnabled(true)
                    .build();

            initialized = true;
            System.out.println("R2Helper 초기화 완료 - Bucket: " + bucket);

        } catch (Exception e) {
            throw new RuntimeException("R2Helper 초기화 실패", e);
        }
    }

    /**
     * 파일 업로드 (InputStream 버전)
     */
    public static String upload(InputStream inputStream, String originalFilename, 
                               long fileSize, String contentType, String dirName) {
        checkInitialized();
        
        try {
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String fileName = dirName + "/" + UUID.randomUUID() + extension;

            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(fileSize);
            metadata.setContentType(contentType);

            r2Client.putObject(new PutObjectRequest(bucket, fileName, inputStream, metadata));

            String fileUrl = getPublicUrl(fileName);
            System.out.println("File uploaded to R2: " + fileUrl);
            return fileUrl;

        } catch (Exception e) {
            throw new RuntimeException("R2 업로드 실패: " + originalFilename, e);
        }
    }

    /**
     * 파일 업로드 (byte[] 버전)
     */
    public static String upload(byte[] fileData, String originalFilename, 
                               String contentType, String dirName) {
        checkInitialized();
        
        try {
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String fileName = dirName + "/" + UUID.randomUUID() + extension;

            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(fileData.length);
            metadata.setContentType(contentType);

            ByteArrayInputStream bis = new ByteArrayInputStream(fileData);
            r2Client.putObject(new PutObjectRequest(bucket, fileName, bis, metadata));

            String fileUrl = getPublicUrl(fileName);
            System.out.println("File uploaded to R2: " + fileUrl);
            return fileUrl;

        } catch (Exception e) {
            throw new RuntimeException("R2 업로드 실패: " + originalFilename, e);
        }
    }

    /**
     * 파일 삭제
     */
    public static void deleteFile(String fileName) {
        checkInitialized();
        
        try {
            r2Client.deleteObject(bucket, fileName);
            System.out.println("File deleted from R2: " + fileName);
        } catch (Exception e) {
            System.err.println("R2 파일 삭제 실패: " + fileName);
            e.printStackTrace();
        }
    }

    /**
     * 파일 존재 여부 확인
     */
    public static boolean fileExists(String fileName) {
        checkInitialized();
        
        try {
            return r2Client.doesObjectExist(bucket, fileName);
        } catch (Exception e) {
            System.err.println("R2 파일 존재 확인 실패: " + fileName);
            return false;
        }
    }

    /**
     * Public URL 생성
     */
    private static String getPublicUrl(String fileName) {
        if (publicUrl != null && !publicUrl.isEmpty()) {
            return publicUrl + "/" + fileName;
        } else {
            return String.format("https://pub-%s.r2.dev/%s", bucket, fileName);
        }
    }

    /**
     * 초기화 여부 확인
     */
    private static void checkInitialized() {
        if (!initialized) {
            throw new IllegalStateException("R2Helper가 초기화되지 않았습니다. init() 메서드를 먼저 호출하세요.");
        }
    }

    /**
     * 필수 속성 값 가져오기
     */
    private static String getRequiredProperty(Properties props, String key) {
        String value = props.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            throw new RuntimeException("필수 R2 설정 값이 없습니다: " + key);
        }
        return value.trim();
    }

    /**
     * 초기화 상태 확인
     */
    public static boolean isInitialized() {
        return initialized;
    }
}