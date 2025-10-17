package ajax;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Properties;

import com.google.gson.Gson;

import dto.ChatJoinRequest;
import dto.ChatJoinResponse;
import dto.SchedulePostDto;
import dto.Users;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.chat.ChatService;
import utils.AblyChatConfig;
import utils.ConfigLoader;

@WebServlet("/chat/*")
public class ChatJoinServlet extends HttpServlet {

    private final ChatService service = new ChatService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null) {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            res.getWriter().write("{\"error\":\"로그인이 필요합니다.\"}");
            return;
        }

        String path = req.getPathInfo();
        if (path == null) path = "";

        switch (path) {
            case "/init": handleInit(req, res, user); break;
            case "/status": handleStatus(req, res, user); break;
            default:
                res.setStatus(HttpServletResponse.SC_NOT_FOUND);
                res.getWriter().write("{\"error\":\"Invalid endpoint\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null) {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            res.getWriter().write("{\"error\":\"로그인이 필요합니다.\"}");
            return;
        }

        String path = req.getPathInfo();
        if (path == null) path = "";

        switch (path) {
            case "/update": handleUpdate(req, res, user); break;
            default:
                res.setStatus(HttpServletResponse.SC_NOT_FOUND);
                res.getWriter().write("{\"error\":\"Invalid endpoint\"}");
        }
    }

    // ===========================
    // 1️⃣ /chat/init
    // ===========================
    private void handleInit(HttpServletRequest req, HttpServletResponse res, Users user) throws IOException {
        String postIdParam = req.getParameter("postId");

        Map<String,String> ablyConfig = loadAblyConfig();
        Map<String,String> firebaseConfig = loadFirebaseConfig();

        Map<String,Object> result = new HashMap<>();
        result.put("userId", user.getUserId());
        result.put("ablyConfig", ablyConfig);
        result.put("firebaseConfig", firebaseConfig);

        if (postIdParam == null || postIdParam.isEmpty() || "null".equals(postIdParam)) {
            List<SchedulePostDto> joinedRooms = service.getUserJoinedRooms(user.getUserId());
            result.put("rooms", joinedRooms);
        } else {
            int postId = Integer.parseInt(postIdParam);
            result.put("postId", postId);
            result.put("channelName", "channel-" + postId);

            SchedulePostDto post = service.getPostDetails(postId);
            if (post != null) {
                result.put("maxPeople", post.getMaxPeople());
                result.put("currentPeople", post.getCurrentPeople());
            }
        }

        gson.toJson(result, res.getWriter());
    }

    // ===========================
    // 2️⃣ /chat/update
    // ===========================
    private void handleUpdate(HttpServletRequest req, HttpServletResponse res, Users user) throws IOException {
        int postId = Integer.parseInt(req.getParameter("postId"));
        String action = req.getParameter("action"); // join / leave

        ChatJoinRequest dto = new ChatJoinRequest(postId, user.getUserId());
        Map<String, Object> result = new HashMap<>();

        ChatJoinResponse chatResult;
        if ("leave".equalsIgnoreCase(action)) {
            chatResult = service.leaveChat(dto);
        } else {
            chatResult = service.joinChat(dto);
        }

        // 결과 객체 포함
        result.put("chatResult", chatResult);

        // Ably 설정 포함 (선택적으로 전달)
        Map<String, String> ablyConfig = loadAblyConfig();
        result.put("ablyConfig", ablyConfig);

        gson.toJson(result, res.getWriter());
    }

    // ===========================
    // 3️⃣ /chat/status
    // ===========================
    private void handleStatus(HttpServletRequest req, HttpServletResponse res, Users user) throws IOException {
        int postId = Integer.parseInt(req.getParameter("postId"));
        Map<String,Object> result = new HashMap<>();

        boolean joined = service.isUserInChat(postId, user.getUserId());
        SchedulePostDto post = service.getPostDetails(postId);

        result.put("joined", joined);
        if (post != null) {
            result.put("maxPeople", post.getMaxPeople());
            result.put("currentPeople", post.getCurrentPeople());
        }

        gson.toJson(result, res.getWriter());
    }

    // ===========================
    // 🔹 Ably 설정 로딩
    // ===========================
    private Map<String, String> loadAblyConfig() {
        Map<String, String> ablyConfig = new HashMap<>();
        Optional<Properties> ablyPropsOpt = AblyChatConfig.getAblyConfig(getServletContext());
        ablyPropsOpt.ifPresent(props -> {
            String pubKey = props.getProperty("ably.pubkey", "");
            if (!pubKey.isEmpty()) ablyConfig.put("pubKey", pubKey);
        });
        return ablyConfig;
    }

    // ===========================
    // 🔹 Firebase 설정 로딩
    // ===========================
    private Map<String, String> loadFirebaseConfig() {
        Map<String, String> firebaseConfig = new HashMap<>();
        Optional<Properties> firebasePropsOpt = ConfigLoader.getFirebaseConfig(getServletContext());
        firebasePropsOpt.ifPresent(props -> {
            firebaseConfig.put("apiKey", props.getProperty("firebase.apiKey"));
            firebaseConfig.put("authDomain", props.getProperty("firebase.authDomain"));
            firebaseConfig.put("projectId", props.getProperty("firebase.projectId"));
            firebaseConfig.put("storageBucket", props.getProperty("firebase.storageBucket"));
            firebaseConfig.put("messagingSenderId", props.getProperty("firebase.messagingSenderId"));
            firebaseConfig.put("appId", props.getProperty("firebase.appId"));
            firebaseConfig.put("measurementId", props.getProperty("firebase.measurementId"));
            firebaseConfig.put("databaseURL", props.getProperty("firebase.databaseURL"));
        });
        return firebaseConfig;
    }
}
