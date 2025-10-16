package service.post;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import dao.PostDao;
import dto.Post;
import java.util.List;

public class PostListService {

    public JsonObject getPostList(String sort, int page, int limit, String query) {
        PostDao dao = new PostDao();
        boolean hasQuery = (query != null && !query.trim().isEmpty());

        List<Post> posts;
        int dataCount;

        // ✅ 검색어 여부에 따라 분기
        if (hasQuery) {
            posts = dao.getPagedPostsByKeyword(sort, page, limit, query);
            dataCount = dao.getSearchPostCount(query);
        } else {
            posts = dao.getPagedPosts(sort, page, limit);
            dataCount = dao.getTotalPostCount();
        }

        int totalPages = (int) Math.ceil((double) dataCount / limit);

        JsonArray arr = new JsonArray();
        for (Post p : posts) {
            JsonObject obj = new JsonObject();
            obj.addProperty("postId", p.getPostId());
            obj.addProperty("userId", p.getUserId());
            obj.addProperty("title", p.getTitle());
            obj.addProperty("content", p.getContent());
            obj.addProperty("hit", p.getHit());
            obj.addProperty("createdAt", p.getCreatedAt() != null ? p.getCreatedAt().toString() : "-");
            obj.addProperty("category", p.getCategory());
            obj.addProperty("categoryId", p.getCategoryId());
            obj.addProperty("postType", p.getPostType());
            obj.addProperty("postTypeId", p.getPostTypeId());
            arr.add(obj);
        }

        JsonObject result = new JsonObject();
        result.addProperty("currentPage", page);
        result.addProperty("dataCount", dataCount);  // ✅ 전체 or 검색 결과 개수
        result.addProperty("pageSize", limit);
        result.addProperty("totalPages", totalPages);
        result.addProperty("hasQuery", hasQuery);    // ✅ 검색 여부 전달
        result.addProperty("query", hasQuery ? query : "");
        result.add("posts", arr);

        // ✅ 프론트에서 바로 표시할 수 있게 문구도 함께 전달
        String countLabel = hasQuery
                ? String.format("\"%s\" 관련 게시글 %d개", query, dataCount)
                : String.format("전체 게시글 %d개", dataCount);
        result.addProperty("countLabel", countLabel);

        return result;
    }
}




