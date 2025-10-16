package ajax;

import java.io.IOException;

import com.google.gson.Gson;

import dto.ChatJoinRequest;
import dto.ChatJoinResponse;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.chat.ChatService;

/**
 * Servlet implementation class ChatJoinServlet
 */
@WebServlet("/chat/join")
public class ChatJoinServlet extends HttpServlet {
    private ChatService service = new ChatService();

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
    	System.out.println("채팅 요청");
        int postId = Integer.parseInt(req.getParameter("postId"));
        String userId = (String) req.getSession().getAttribute("userId");

        ChatJoinResponse result = service.joinChat(new ChatJoinRequest(postId, userId));

        res.setContentType("application/json;charset=UTF-8");
        new Gson().toJson(result, res.getWriter());
    }
}
