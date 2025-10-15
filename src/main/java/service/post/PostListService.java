package service.post;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import dao.PostDao;
import dto.Post;

import java.util.List;

public class PostListService {

	public JsonObject getPostList(String sort, int page, int limit) {
	    PostDao dao = new PostDao();

	    List<Post> posts = dao.getPagedPosts(sort, page, limit);
	    int dataCount = dao.getTotalPostCount();

	    int totalPages = (int) Math.ceil((double) dataCount / limit);

	    JsonArray arr = new JsonArray();
	    for (Post p : posts) {
	        JsonObject obj = new JsonObject();
	        obj.addProperty("postId", p.getPostId());
	        obj.addProperty("userId", p.getUserId());
	        obj.addProperty("listId", p.getListId());
	        obj.addProperty("title", p.getTitle());
	        obj.addProperty("content", p.getContent());
	        obj.addProperty("hit", p.getHit());
	        obj.addProperty("createdAt", p.getCreatedAt() != null ? p.getCreatedAt().toString() : "-");

	        // ✅ 이름 + ID 모두 포함
	        obj.addProperty("postType", p.getPostType());
	        obj.addProperty("postTypeId", p.getPostTypeId());
	        obj.addProperty("category", p.getCategory());
	        obj.addProperty("categoryId", p.getCategoryId());

	        arr.add(obj);
	    }

	    JsonObject result = new JsonObject();
	    result.addProperty("currentPage", page);
	    result.addProperty("dataCount", dataCount);
	    result.addProperty("pageSize", limit);
	    result.addProperty("totalPages", totalPages);
	    result.add("posts", arr);

	    return result;
	}

}


