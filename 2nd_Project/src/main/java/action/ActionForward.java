package action;


/*
클라이언트 -> 서버 요청

1. 화면 보여주세요
2. 처리해 주세요 

화면 주거나 ... 로직 처리해서 결과 응답
*/
public class ActionForward {
	private boolean isRedirect = false; //뷰의 전환 ...
	private String path = null; //이동 경로 주소 (forward) viewpage
	
	public boolean isRedirect() {
		return isRedirect;
	}
	public void setRedirect(boolean isRedirect) {
		this.isRedirect = isRedirect;
	}
	public String getPath() {
		return path;
	}
	public void setPath(String path) {
		this.path = path;
	}
	
	
}

