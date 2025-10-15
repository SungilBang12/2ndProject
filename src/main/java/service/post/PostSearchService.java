package service.post;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import dao.PostDao;
import dto.Post;
import java.util.List;

public class PostSearchService {

    public JsonObject getSearchResults(String keyword) {
        PostDao dao = new PostDao();
        List<Post> posts = dao.searchPosts(keyword);

        JsonArray arr = new JsonArray();
        for (Post p : posts) {
            JsonObject obj = new JsonObject();
            obj.addProperty("postId", p.getPostId());
            obj.addProperty("userId", p.getUserId());
            obj.addProperty("title", p.getTitle());
            obj.addProperty("content", p.getContent());
            obj.addProperty("createdAt", p.getCreatedAt() != null ? p.getCreatedAt().toString() : "-");
            obj.addProperty("hit", p.getHit());
            obj.addProperty("postType", p.getPostType());
            obj.addProperty("postTypeId", p.getPostTypeId());
            obj.addProperty("category", p.getCategory());
            obj.addProperty("categoryId", p.getCategoryId());
            arr.add(obj);
        }

        JsonObject result = new JsonObject();
        result.addProperty("count", posts.size());
        result.add("posts", arr);
        return result;
    }
}
