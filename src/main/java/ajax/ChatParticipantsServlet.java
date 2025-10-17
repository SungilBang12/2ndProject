package ajax;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import com.google.gson.Gson;
import dto.Users;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.chat.ChatService;

/**
 * /chat/participants
 * - GET : postId 기준 현재 참가자 수 반환
 */
@WebServlet("/chat/participants")
 public class ChatParticipantsServlet extends HttpServlet {

	    private final ChatService service = new ChatService();

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

	        String postIdParam = req.getParameter("postId");
	        if (postIdParam == null || postIdParam.isEmpty()) {
	            res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
	            res.getWriter().write("{\"error\":\"postId가 필요합니다.\"}");
	            return;
	        }

	        int postId = Integer.parseInt(postIdParam);
	        int currentPeople = service.getParticipantCount(postId);

	        Map<String, Object> result = new HashMap<>();
	        result.put("currentPeople", currentPeople);

	        new Gson().toJson(result, res.getWriter());
	    }
	}
