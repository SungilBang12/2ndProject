package utils.s3;
//
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.GetMapping;
//import org.springframework.web.bind.annotation.PostMapping;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//import org.springframework.web.multipart.MultipartFile;
//
//import java.io.IOException;
//
//@RequiredArgsConstructor
//@Controller
//public class S3Controller {
//    private final S3Uploader s3Uploader;
//
//    @GetMapping("/test")
//    public String index() {
//        return "test";
//    }
//
//    @PostMapping("/s3/image/upload")
//    @ResponseBody
//    public String upload(@RequestParam("data") MultipartFile multipartFile) throws IOException {
//        return s3Uploader.upload(multipartFile, "album");
//    }
//}