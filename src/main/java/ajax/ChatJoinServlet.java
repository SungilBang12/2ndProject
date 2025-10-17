package ajax;

import com.google.gson.Gson;
import dto.ChatJoinRequest;
import dto.ChatJoinResponse;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import service.chat.ChatService;
import vo.Users;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;

/**
 * /chat/join
 * - GET : Ably 설정 및 유저정보 전달, postId 없으면 채팅 리스트 반환
 * - POST : 특정 채팅방 참가 처리
 */
@WebServlet("/chat/join")
public class ChatJoinServlet extends HttpServlet {

    private final ChatService service = new ChatService();
    private static final String ABLY_API_KEY = "YOUR_ABLY_API_KEY"; // 🔹 Chat용 API Key

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

        String userId = user.getUserId();
        String postIdParam = req.getParameter("postId");

        // ✅ postId가 없으면: Ably Chat API로 채팅방 목록 가져오기
        if (postIdParam == null || postIdParam.isEmpty() || "null".equals(postIdParam)) {
            try {
                URL url = new URL("https://chat.ably.io/v1/conversations");
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("GET");
                conn.setRequestProperty("Authorization", "Bearer " + ABLY_API_KEY);

                BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String response = in.lines().reduce("", (a, b) -> a + b);
                in.close();

                res.getWriter().write(response);
            } catch (Exception e) {
                e.printStackTrace();
                res.setStatus(500);
                res.getWriter().write("{\"error\":\"Ably Chat API 요청 실패\"}");
            }
            return;
        }

        // ✅ postId가 있으면: Realtime 채팅 초기 설정 반환
        int postId = Integer.parseInt(postIdParam);
        Map<String, Object> result = new HashMap<>();
        result.put("userId", userId);
        result.put("postId", postId);
        result.put("maxPeople", 5);

        Map<String, String> ablyConfig = new HashMap<>();
        ablyConfig.put("pubKey", "YOUR_ABLY_REALTIME_KEY");
        result.put("ablyConfig", ablyConfig);

        new Gson().toJson(result, res.getWriter());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json;charset=UTF-8");

        int postId = Integer.parseInt(req.getParameter("postId"));
        String userId = (String) req.getSession().getAttribute("user.userId");

        ChatJoinResponse result = service.joinChat(new ChatJoinRequest(postId, userId));
        new Gson().toJson(result, res.getWriter());
    }
}
