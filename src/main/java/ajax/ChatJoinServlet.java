package ajax;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Properties;

import com.google.gson.Gson;
import dto.ChatJoinRequest;
import dto.ChatJoinResponse;
import dto.Users;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.chat.ChatService;
import utils.AblyChatConfig;
import utils.ConfigLoader;

/**
 * /chat/join
 * - GET : Ably + Firebase 설정 및 유저정보 전달, postId 없으면 채팅 리스트 반환
 * - POST : 특정 채팅방 참가 처리 (join or leave)
 */
@WebServlet("/chat/join")
public class ChatJoinServlet extends HttpServlet {

    private final ChatService service = new ChatService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
    	String postIdParam = req.getParameter("postId");
        res.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null) {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            res.getWriter().write("{\"error\":\"로그인이 필요합니다.\"}");
            return;
        }

        String userId = user.getUserId();
        System.out.println("채팅 조인 리퀘스트로 들어온 postId"+postIdParam);

        // Ably/Firebase 설정 로딩
        Map<String, String> ablyConfig = loadAblyConfig();
        Map<String, String> firebaseConfig = loadFirebaseConfig();

        Map<String, Object> result = new HashMap<>();
        result.put("userId", userId);
        result.put("ablyConfig", ablyConfig);
        result.put("firebaseConfig", firebaseConfig);

        if (postIdParam == null || postIdParam.isEmpty() || "null".equals(postIdParam)) {
            // postId 없으면 채팅방 리스트 반환
        	System.out.println("postId가 없습니다. = " + postIdParam);
            result.put("rooms", new String[]{});
        } else {
            int postId = Integer.parseInt(postIdParam);
            result.put("postId", postId);
            result.put("channelName", "channel-" + postId);

            // DB에서 실제 maxPeople 조회
            var post = service.getPostDetails(postId);
            if (post != null) result.put("maxPeople", post.getMaxPeople());
        }

        new Gson().toJson(result, res.getWriter());
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

        String userId = user.getUserId();
        int postId = Integer.parseInt(req.getParameter("postId"));
        String action = req.getParameter("action"); // join / leave

        ChatJoinRequest reqDto = new ChatJoinRequest(postId, userId);
        ChatJoinResponse result;

        if ("leave".equalsIgnoreCase(action)) {
            result = service.leaveChat(reqDto);
        } else {
            result = service.joinChat(reqDto);
        }

        new Gson().toJson(result, res.getWriter());
    }

    // 🔹 Ably 설정 로딩
    private Map<String, String> loadAblyConfig() {
        Map<String, String> ablyConfig = new HashMap<>();
        Optional<Properties> ablyPropsOpt = AblyChatConfig.getAblyConfig(getServletContext());
        ablyPropsOpt.ifPresent(props -> {
            String pubKey = props.getProperty("ably.pubkey", "");
            if (!pubKey.isEmpty()) ablyConfig.put("pubKey", pubKey);
        });
        return ablyConfig;
    }

    // 🔹 Firebase 설정 로딩
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
