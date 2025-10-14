package service.post;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import dao.PostDao;
import dto.Post;
import jakarta.servlet.AsyncContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class PostAsyncService {

	// 싱글톤 패턴 또는 static으로 ExecutorService 관리
	private static final ExecutorService executor = Executors.newCachedThreadPool();

	private final PostDao postDao;
	private final Gson gson;

	public PostAsyncService() {
		this.postDao = new PostDao();
		this.gson = new Gson();
	}

	public void createPostAsync(final AsyncContext asyncContext, final String jsonData) {

		executor.execute(() -> {

			HttpServletRequest request = (HttpServletRequest) asyncContext.getRequest();
			HttpServletResponse response = (HttpServletResponse) asyncContext.getResponse();

			// JSON 응답을 위한 Map 및 실패 시 리다이렉트 URL 변수
			Map<String, Object> responseMap = new HashMap<>();
			String failureRedirectUrl = null;

			try {
				// 1. JSON 파싱 및 Post 객체 생성 (비즈니스 로직)
				Map<String, Object> jsonMap = gson.fromJson(jsonData, Map.class);

				// [핵심] 실패 시 돌아갈 경로를 JSON에서 추출
				failureRedirectUrl = (String) jsonMap.get("failureRedirect");

				String title = (String) jsonMap.get("title");
				Object content = jsonMap.get("content");

				// Post 객체 빌드 (실제로는 세션에서 userId를 가져와야 함)
				Post post = new Post().builder().userId("user001").listId(2).title(title).content(gson.toJson(content))
						.hit(0).build();

				// 2. DAO 호출 (DB 접근)
				int postId = postDao.createPost(post);

				// 3. 커스텀 노드 처리 (추가 DB 작업)
				if (postId > 0) {
					JsonObject jsonObject = gson.fromJson(jsonData, JsonObject.class);
					JsonObject contentObj = jsonObject.getAsJsonObject("content");
					JsonArray contentArray = contentObj.getAsJsonArray("content");
					parseAndSaveCustomNodes(contentArray, postId);
				}

				// 4. JSON 응답 결과 설정
				String msg;
				if (postId > 0) {
					msg = "insert success";
					String url = request.getContextPath() + "/post-detail.post?postId=" + postId; // 생성된 상세 페이지

					// 성공 시 JSON 응답 Map 구성
					responseMap.put("status", "success");
					responseMap.put("message", msg);
					responseMap.put("redirectUrl", url); // ⬅️ 클라이언트에게 이동할 URL 전달

				} else {
					// 실패 시 응답 Map 구성
					msg = "insert fail";

					responseMap.put("status", "error");
					responseMap.put("message", msg + " (DB 처리 실패)");
					// 실패 시 URL을 전달하여 클라이언트가 history.back() 대신 특정 URL로 이동하게 할 수도 있음
					responseMap.put("failureRedirectUrl", failureRedirectUrl);
				}

				// 5. JSON 응답 전송 및 컨텍스트 종료
				response.setContentType("application/json");
				response.setCharacterEncoding("UTF-8");
				response.getWriter().write(gson.toJson(responseMap));
				asyncContext.complete();

			} catch (Exception e) {
				e.printStackTrace();

				// 오류 발생 시 JSON 응답 처리
				responseMap.put("status", "error");
				responseMap.put("message", "서버 내부 오류: " + e.getMessage());
				responseMap.put("failureRedirectUrl", failureRedirectUrl);

				try {
					response.setContentType("application/json");
					response.setCharacterEncoding("UTF-8");
					response.getWriter().write(gson.toJson(responseMap));
				} catch (IOException ioE) {
					// 응답 쓰기 오류는 무시
				}
				asyncContext.complete();
			}
		});
	}

	/**
	 * [Update] 게시글 수정 작업을 비동기로 처리
	 */
	public void updatePostAsync(final AsyncContext asyncContext, final String jsonData) {
		// 비동기 스레드에서 수정 로직 수행
		executor.execute(() -> {
			HttpServletRequest request = (HttpServletRequest) asyncContext.getRequest();
			HttpServletResponse response = (HttpServletResponse) asyncContext.getResponse();

			// JSON 응답을 위한 Map
			Map<String, Object> responseMap = new HashMap<>();

			try {
				// JSON 파싱 및 Post 객체 생성
				Post postToUpdate = gson.fromJson(jsonData, Post.class);
				// int loggedInUserId = (Integer) request.getSession().getAttribute("userId");
				// // 사용자 ID 확인
				int loggedInUserId = 1; // 임시 ID

				// 서비스 로직 수행
				int result = postDao.updatePost(postToUpdate); // DAO 직접 호출 대신 service.updatePost(postToUpdate,
																// loggedInUserId) 권장

				if (result > 0) {
					responseMap.put("status", "success");
					responseMap.put("message", "수정 완료");
					// 비동기 AJAX 요청이므로, 클라이언트 리다이렉트를 유도하기 위한 URL을 JSON으로 반환
					responseMap.put("redirectUrl",
							request.getContextPath() + "/post/detail?postId=" + postToUpdate.getPostId());
				} else {
					responseMap.put("status", "error");
					responseMap.put("message", "수정 실패 또는 권한 없음.");
				}

				// JSON 응답 전송 및 컨텍스트 종료
				response.setContentType("application/json");
				response.getWriter().write(gson.toJson(responseMap));
				asyncContext.complete();

			} catch (Exception e) {
				// 오류 처리
				e.printStackTrace();
				responseMap.put("status", "error");
				responseMap.put("message", "서버 오류: " + e.getMessage());
				try {
					response.setContentType("application/json");
					response.getWriter().write(gson.toJson(responseMap));
				} catch (IOException ioE) {
					/* ignore */ }
				asyncContext.complete();
			}
		});
	}

	/**
	 * 게시글 삭제 서비스
	 * 
	 * @param postId        삭제할 게시글 ID
	 * @param requestUserId 현재 요청한 사용자 ID (권한 확인용)
	 */
	// ------------------------------------------------------------------
	/**
	 * [Delete] 게시글 삭제 작업을 비동기로 처리하고, JSON 응답을 반환합니다.
	 */
	public void deletePostAsync(final AsyncContext asyncContext, final String jsonData) {

		executor.execute(() -> {

			HttpServletRequest request = (HttpServletRequest) asyncContext.getRequest();
			HttpServletResponse response = (HttpServletResponse) asyncContext.getResponse();

			// JSON 응답을 위한 Map
			Map<String, Object> responseMap = new HashMap<>();

			try {
				// 1. JSON 데이터 파싱: { "postId": 123 } 형태를 가정
				// postId를 Map으로 파싱하거나 DTO를 사용할 수 있으나, 여기선 Map을 사용합니다.
				Map<String, Double> map = gson.fromJson(jsonData, Map.class);

				// Gson은 숫자를 Double로 파싱하므로, Integer로 변환합니다.
				int postId = map.get("postId").intValue();

				// [필수] 로그인된 사용자 ID를 세션에서 가져와 권한 확인에 사용
				// int loggedInUserId = (Integer) request.getSession().getAttribute("userId");
				int loggedInUserId = 1; // 임시 ID

				// 2. 서비스/DAO 로직 수행 (Service 계층에 권한 확인 로직이 있다고 가정)
				// 현재 DAO만 있으므로 DAO를 호출하지만, 실제로는 Service를 통해 권한 확인을 거쳐야 합니다.
				int deletedRows = postDao.deletePost(postId);

				if (deletedRows > 0) {
					responseMap.put("status", "success");
					responseMap.put("message", "게시글이 성공적으로 삭제되었습니다.");
					// 삭제 성공 후 클라이언트가 이동할 URL을 제공할 수도 있지만,
					// 일반적으로 AJAX 삭제 후에는 클라이언트 JS가 목록 페이지로 이동을 처리합니다.
				} else {
					responseMap.put("status", "error");
					// 실제 애플리케이션에서는 권한 없음(-2) 또는 게시글 없음(0) 등의 코드를 분리해야 합니다.
					responseMap.put("message", "삭제에 실패했거나 게시글이 존재하지 않습니다. (권한 확인 필요)");
				}

				// 3. JSON 응답 전송 및 컨텍스트 종료
				response.setContentType("application/json");
				response.getWriter().write(gson.toJson(responseMap));
				asyncContext.complete(); // 비동기 처리 종료

			} catch (Exception e) {
				// 오류 처리
				e.printStackTrace();
				responseMap.put("status", "error");
				responseMap.put("message", "서버 오류: 삭제 처리 중 예외 발생.");

				try {
					response.setContentType("application/json");
					response.getWriter().write(gson.toJson(responseMap));
				} catch (IOException ioE) {
					// 응답 전송 실패는 무시
				}
				asyncContext.complete();
			}
		});
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
