package service.post;

import java.io.IOException;
import java.util.List;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import dao.PostDao;
import dto.Post;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import com.google.gson.JsonSerializer;
import com.google.gson.JsonDeserializer;

// ...
public class PostListService {

    public void getPostList(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");

        PostDao dao = new PostDao();
        List<Post> posts = dao.getAllPosts();

        // ✅ LocalDate 직렬화/역직렬화 등록
        Gson gson = new GsonBuilder()
                .registerTypeAdapter(LocalDate.class,
                    (JsonSerializer<LocalDate>) (date, type, jsonSerializationContext) ->
                        new com.google.gson.JsonPrimitive(date.format(DateTimeFormatter.ISO_LOCAL_DATE)))
                .registerTypeAdapter(LocalDate.class,
                    (JsonDeserializer<LocalDate>) (json, type, jsonDeserializationContext) ->
                        LocalDate.parse(json.getAsString(), DateTimeFormatter.ISO_LOCAL_DATE))
                .setPrettyPrinting()
                .create();

        String json = gson.toJson(posts);
        response.getWriter().write(json);
    }
}

