package dao;

public class BoardDao {

	<%
	BoardService service = BoardService.getInBoardService();
	
	//게시물 총 건수
	int totalboardcount = service.totalBoardCount();
	
	//상세보기 >> 다시  LIST 넘어올때  >> 현재 페이지 설정
	String ps = request.getParameter("ps"); //pagesize
	String cp = request.getParameter("cp"); //current page
	
	//List 페이지 처음 호출 ...
	if(ps == null || ps.trim().equals("")){
		//default 값 설정
		ps = "5"; //5개씩 
	}

	if(cp == null || cp.trim().equals("")){
		//default 값 설정
		cp = "1"; // 1번째 페이지 보겠다 
	}
	
	int pagesize = Integer.parseInt(ps);
	int cpage = Integer.parseInt(cp);
	int pagecount=0;
	
	//23건  % 5
	if(totalboardcount % pagesize == 0){
		pagecount = totalboardcount / pagesize; //  20 << 100/5
	}else{
		pagecount = (totalboardcount / pagesize) + 1; 
	}
	
	//102건 : pagesize=5 >> pagecount=21페이지
	
	//전체 목록 가져오기
	List<Board> list = service.list(cpage, pagesize); //list >> 1 , 20
	
%>

<%
	if(list == null || list.size() == 0){
		out.print("<tr><td colspan='5'>데이터가 없습니다</td></tr>");
	}
%>
}
