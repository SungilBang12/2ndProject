package	dto;
 
import java.sql.Date;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Generated;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor

public class Board {
	
	//Place_Post
	private int place_id; // 식별 번호
	private float longitude; // 경도
	private float lat; // 위도
	
	//Image_Data
	private int image_id; // 식별 번호
	private String name; // 이미지 이름
	private String image_src; // 이미지 주소 
	
	// Date_Post
	private int date_id; // 식별번호
	private Date date; // 날짜 
	
	
	// API_Info
	private int api_id; // API 고유 ID
	private String title_api; // API 이름 
	private String content_api; // 설명 
	private String url; // API 주소 
	private Date created_at_api; // 등록 날짜
	
	// Chart_Data
	private int chart_id; // 차트 ID
	//private ??? data_json; // 차트 데이터 원본

	//Post
	private int post_id; // 글 번호
	
	private String title_post; // 제목
	private String content_post; // 내용
	private int hit; // 조회수 
	private Date created_at_post; // 작성날짜
	private Date updated_at_post; // 수정 날짜 
	
	
	//User
	private String user_id; // 사용자 고유 ID
	private String username; // 사용자 이름
	private String password; // 암호화 된 비밀번호
	private String email;// 사용자 이메일
	private String role; // ADMIN / USER 
	private Date created_at_user; // 가입 날짜 
	
	//Post_List 
	private int list_id; //게시글
	private String listname; // 게시글 이름 
	
	// Comment
	
	
	
	
	// Post_Type
	private int type_id; // 게시판 형식 ID
	private String typename; // 게시판 형식 이름
	
	//Category
	private int category_id; // 카테고리 고유 ID
	private int parent_id; // 카테고리 고유 ID
	private String categoryname; // 카테고리 이름
	
	
	
}
