package service.post;

import java.io.IOException;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;

import action.Action;
import action.ActionForward;
import dao.PostDao;
import dto.Post;
import dto.Users;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class CreatePostService implements Action {

    @Override
    public ActionForward excute(HttpServletRequest request, HttpServletResponse response) {
        
        // 1. Get form data from the request
        String title = request.getParameter("title");
        String contentJson = request.getParameter("content"); // The editor's content (JSON string)
        String listIdStr = request.getParameter("listId");

        // Basic validation
        if (title == null || title.trim().isEmpty() || 
            contentJson == null || contentJson.trim().isEmpty() ||
            listIdStr == null || listIdStr.isEmpty()) {
            
            // Handle error - maybe redirect back with an error message
            try {
				response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Title, content, and category are required.");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            return null; // Stop processing
        }
        
        int listId = Integer.parseInt(listIdStr);

        // 2. Get user ID from the session (assuming it's stored as "userId")
        // 로그인 성공 후
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");
        System.out.println("user" + user);

        if (user == null) {
            // If the user is not logged in, redirect to the login page
            ActionForward forward = new ActionForward();
            forward.setRedirect(true);
            forward.setPath(request.getContextPath() + "/login.jsp"); // Adjust login path if needed
            return forward;
        }

        // 3. Build the Post DTO
        Post post = Post.builder()
                      .userId(user.getUserId())
                      .listId(listId)
                      .title(title)
                      .content(contentJson) // Store the raw JSON content
                      .hit(0) // Initialize hit count
                      .build();

        PostDao dao = new PostDao();
        
        // 4. Call the DAO to create the post
        // This inserts the main post record and returns the new post's ID
        int newPostId = dao.createPost(post);

        ActionForward forward = new ActionForward();

        // 5. Check if the post was created successfully
        if (newPostId > 0) {
            System.out.println("게시글 생성 성공, ID: " + newPostId);

            // 6. Process special content (images, maps, schedules) from the JSON
            try {
                Gson gson = new Gson();
                JsonObject contentObject = gson.fromJson(contentJson, JsonObject.class);
                
                // TipTap editor's main content is in a "content" array
                if (contentObject != null && contentObject.has("content")) {
                    JsonArray contentArray = contentObject.getAsJsonArray("content");
                    
                    // Use the existing DAO method to parse and save these nodes
                    dao.parseAndSaveCustomNodes(contentArray, newPostId);
                }
            } catch (JsonSyntaxException e) {
                // Log the error if JSON is malformed
                System.err.println("JSON parsing error for post ID " + newPostId + ": " + e.getMessage());
                // Decide if you want to delete the post or leave it as is
            }

            // 7. Redirect to the newly created post's detail page (Post-Redirect-Get pattern)
            forward.setRedirect(true);
            forward.setPath(request.getContextPath() + "/post-detail.post?postId=" + newPostId);

        } else {
            // If creation failed, redirect back to the editor page with an error flag
            System.out.println("게시글 생성 실패");
            forward.setRedirect(true);
            forward.setPath(request.getContextPath() + "/editor.post?error=true");
        }

        return forward;
    }
}