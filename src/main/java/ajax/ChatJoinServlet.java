package ajax;

import java.io.IOException;
import java.util.*;

import com.google.gson.Gson;
import dto.ChatJoinRequest;
import dto.ChatJoinResponse;
import dto.SchedulePostDto;
import dto.Users;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import service.chat.ChatService;
import utils.AblyChatConfig;
import utils.ConfigLoader;

@WebServlet("/chat/*")
public class ChatJoinServlet extends HttpServlet {

    private final ChatService service = new ChatService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        handleRequest(req, res, "GET");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        handleRequest(req, res, "POST");
    }

    // ==========================================
    // 🔹 공통 요청 핸들러
    // ==========================================
    private void handleRequest(HttpServletRequest req, HttpServletResponse res, String method) throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession(false);

        Users user = (session != null) ? (Users) session.getAttribute("user") : null;
        if (user == null) {
            writeError(res, HttpServletResponse.SC_UNAUTHORIZED, "로그인이 필요합니다.");
            return;
        }

        String path = Optional.ofNullable(req.getPathInfo()).orElse("");

        try {
            switch (path) {
                case "/init":
                    if ("GET".equals(method)) handleInit(req, res, user);
                    else writeError(res, 405, "Invalid method: use GET for /init");
                    break;

                case "/update":
                    if ("POST".equals(method)) handleUpdate(req, res, user);
                    else writeError(res, 405, "Invalid method: use POST for /update");
                    break;

                case "/status":
                    if ("GET".equals(method)) handleStatus(req, res, user);
                    else writeError(res, 405, "Invalid method: use GET for /status");
                    break;

                default:
                    writeError(res, 404, "Invalid endpoint: " + path);
            }
        } catch (Exception e) {
            e.printStackTrace();
            writeError(res, 500, "서버 오류가 발생했습니다: " + e.getMessage());
        }
    }

    // ==========================================
    // 1️⃣ /chat/init
    // ==========================================
    private void handleInit(HttpServletRequest req, HttpServletResponse res, Users user) throws IOException {
        Map<String, Object> result = new HashMap<>();
        result.put("userId", user.getUserId());
        result.put("ablyConfig", loadAblyConfig());
        result.put("firebaseConfig", loadFirebaseConfig());

        String postIdParam = req.getParameter("postId");

        if (postIdParam == null || postIdParam.isEmpty() || "null".equals(postIdParam)) {
            // 사용자가 참가한 전체 채팅방 조회
            List<SchedulePostDto> joinedRooms = service.getUserJoinedRooms(user.getUserId());
            result.put("rooms", joinedRooms);
        } else {
            int postId = Integer.parseInt(postIdParam);
            SchedulePostDto post = service.getPostDetails(postId);

            result.put("postId", postId);
            result.put("channelName", "channel-" + postId);
            result.put("maxPeople", Optional.ofNullable(post).map(SchedulePostDto::getMaxPeople).orElse(0));
            result.put("currentPeople", Optional.ofNullable(post).map(SchedulePostDto::getCurrentPeople).orElse(0));
        }

        gson.toJson(result, res.getWriter());
    }

    // ==========================================
    // 2️⃣ /chat/update
    // ==========================================
    private void handleUpdate(HttpServletRequest req, HttpServletResponse res, Users user) throws IOException {
        String postIdParam = req.getParameter("postId");
        String action = Optional.ofNullable(req.getParameter("action")).orElse("").toLowerCase();

        if (postIdParam == null || postIdParam.isEmpty()) {
            writeError(res, 400, "postId가 필요합니다.");
            return;
        }

        int postId = Integer.parseInt(postIdParam);
        ChatJoinRequest dto = new ChatJoinRequest(postId, user.getUserId());

        ChatJoinResponse chatResult = "leave".equals(action)
                ? service.leaveChat(dto)
                : service.joinChat(dto);

        Map<String, Object> result = new HashMap<>();
        result.put("chatResult", chatResult);
        result.put("ablyConfig", loadAblyConfig());

        gson.toJson(result, res.getWriter());
    }

    // ==========================================
    // 3️⃣ /chat/status
    // ==========================================
    private void handleStatus(HttpServletRequest req, HttpServletResponse res, Users user) throws IOException {
        String postIdParam = req.getParameter("postId");
        if (postIdParam == null || postIdParam.isEmpty()) {
            writeError(res, 400, "postId가 필요합니다.");
            return;
        }

        int postId = Integer.parseInt(postIdParam);
        boolean joined = service.isUserInChat(postId, user.getUserId());
        SchedulePostDto post = service.getPostDetails(postId);

        Map<String, Object> result = new HashMap<>();
        result.put("joined", joined);
        result.put("maxPeople", Optional.ofNullable(post).map(SchedulePostDto::getMaxPeople).orElse(0));
        result.put("currentPeople", Optional.ofNullable(post).map(SchedulePostDto::getCurrentPeople).orElse(0));

        gson.toJson(result, res.getWriter());
    }

    // ==========================================
    // 🔹 Ably 설정 로딩
    // ==========================================
    private Map<String, String> loadAblyConfig() {
        Map<String, String> config = new HashMap<>();
        AblyChatConfig.getAblyConfig(getServletContext())
            .ifPresent(props -> {
                String pubKey = props.getProperty("ably.pubkey", "");
                if (!pubKey.isEmpty()) config.put("pubKey", pubKey);
            });
        return config;
    }

    // ==========================================
    // 🔹 Firebase 설정 로딩
    // ==========================================
    private Map<String, String> loadFirebaseConfig() {
        Map<String, String> config = new HashMap<>();
        ConfigLoader.getFirebaseConfig(getServletContext())
            .ifPresent(props -> {
                List<String> keys = Arrays.asList(
                    "apiKey", "authDomain", "projectId", "storageBucket",
                    "messagingSenderId", "appId", "measurementId", "databaseURL"
                );
                for (String key : keys) {
                    config.put(key, props.getProperty("firebase." + key, ""));
                }
            });
        return config;
    }

    // ==========================================
    // 🔹 에러 응답 유틸
    // ==========================================
    private void writeError(HttpServletResponse res, int status, String message) throws IOException {
        res.setStatus(status);
        Map<String, Object> error = new HashMap<>();
        error.put("status", status);
        error.put("error", message);
        gson.toJson(error, res.getWriter());
    }
}
