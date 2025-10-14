package service.post;

import java.io.IOException;
import java.util.List;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import dao.PostDao;
import dto.Post;
import utils.ThePager;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import com.google.gson.JsonObject;
import com.google.gson.JsonSerializer;
import com.google.gson.JsonDeserializer;

// ...
public class PostListService {

	public void getPostList(HttpServletRequest request, HttpServletResponse response) throws IOException {
	    response.setContentType("application/json; charset=UTF-8");

	    // 요청 파라미터
	    String sort = request.getParameter("sort");
	    int limit = parseOrDefault(request.getParameter("limit"), 10);
	    int page = parseOrDefault(request.getParameter("page"), 1);

	    PostDao dao = new PostDao();
	    int totalCount = dao.getTotalPostCount();

	    // ✅ ThePager로 전체 페이지 수 계산
	    ThePager pager = new ThePager(totalCount, page, limit, 5, "");
	    int totalPages = pager.getPageCount();

	    List<Post> posts = dao.getPagedPosts(sort, page, limit);

	 // ✅ JSON 응답 구성
	    Gson gson = new GsonBuilder()
	        .registerTypeAdapter(LocalDate.class,
	            (JsonSerializer<LocalDate>) (date, type, ctx) ->
	                new com.google.gson.JsonPrimitive(date.format(DateTimeFormatter.ISO_LOCAL_DATE)))
	        .registerTypeAdapter(LocalDate.class,
	            (JsonDeserializer<LocalDate>) (json, type, ctx) ->
	                LocalDate.parse(json.getAsString(), DateTimeFormatter.ISO_LOCAL_DATE))
	        .setPrettyPrinting()
	        .create();

	    JsonObject json = new JsonObject();
	    json.add("posts", gson.toJsonTree(posts));
	    json.addProperty("currentPage", page);
	    json.addProperty("totalPages", totalPages);
	    json.addProperty("pageSize", limit);
	    json.addProperty("dataCount", totalCount);

	    response.getWriter().write(gson.toJson(json));

	}

	private int parseOrDefault(String param, int defaultValue) {
	    try {
	        return (param != null) ? Integer.parseInt(param) : defaultValue;
	    } catch (NumberFormatException e) {
	        return defaultValue;
	    }
	}


}

