package service.post;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.Map;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import action.Action;
import action.ActionForward;
import dao.PostDao;
import dto.Post;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class CreateTradePostSyncService implements Action {

	@Override
	public ActionForward excute(HttpServletRequest request, HttpServletResponse response) throws IOException {
		ActionForward forward = null;
		try {
			PostDao service = new PostDao();

			BufferedReader reader = request.getReader();
			StringBuilder sb = new StringBuilder();
			String line;
			while ((line = reader.readLine()) != null) {
				sb.append(line);
			}

			String jsonData = sb.toString();
			System.out.println("수신된 JSON 데이터: " + jsonData);

			// Gson 파싱
			Gson gson = new Gson();
			Map<String, Object> map = gson.fromJson(jsonData, Map.class);

			// 처리 로직
			String title = (String) map.get("title");
			Object content = map.get("content");

			System.out.println("제목: " + title);
			System.out.println("내용: " + content);

			// create시 postId 자동생성, created_at 자동생성
			Post post = new Post().builder().userId("user001").listId(Integer.valueOf(2)).title(title)
					.content(gson.toJson(content)).hit(Integer.valueOf(123)).build();

			int postId = service.createPost(post);
			
			System.out.println("생성된 postId = " + postId);

			// 커스텀 노드 파싱
			JsonObject jsonObject = gson.fromJson(sb.toString(), JsonObject.class);
			JsonObject contentObj = jsonObject.getAsJsonObject("content");
			JsonArray contentArray = contentObj.getAsJsonArray("content");
			parseAndSaveCustomNodes(contentArray, postId);

			String msg = "";
			String url = "";
			if (postId > 0) {
				msg = "insert success";
				url = "index.jsp";
			} else {
				msg = "insert fail";
				url = "index.jsp";
			}

			request.setAttribute("board_msg", msg);
			request.setAttribute("board_url", url);

			forward = new ActionForward();
			forward.setRedirect(true);
			forward.setPath("/redirect.jsp");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return forward;
	}

	private void parseAndSaveCustomNodes(JsonArray contentArray, int postId) {
		PostDao dao = new PostDao();

		for (JsonElement element : contentArray) {
			JsonObject node = element.getAsJsonObject();
			String type = node.get("type").getAsString();

			switch (type) {
			case "kakaoMap":
				JsonObject mapAttrs = node.getAsJsonObject("attrs");
				dao.insertMap(postId, mapAttrs);
				break;

			case "scheduleBlock":
				JsonObject schedAttrs = node.getAsJsonObject("attrs");
				dao.insertSchedule(postId, schedAttrs);
				break;

			case "image":
				JsonObject imgAttrs = node.getAsJsonObject("attrs");
				try {
					dao.insertImage(postId, imgAttrs);
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				break;

			// 다른 블록이 추가되면 여기에 case 추가
			}

			// 하위 content 안에 nested node가 있으면 재귀 탐색
			if (node.has("content")) {
				parseAndSaveCustomNodes(node.getAsJsonArray("content"), postId);
			}
		}
	}
	
}
