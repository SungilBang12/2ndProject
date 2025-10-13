<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
    
    <!-- 
    2. request attribute 사용

서버에서 request.setAttribute("userId", "junsu"); 했다면:

<script>
    const userId = "${userId}";
    console.log("userId:", userId);
</script>
    
     -->
<script>
    const msg = "${board_msg}";
    const url = "${board_url}";
    
    if(msg && msg.trim() !== "" && url && url.trim() !== ""){
        alert(msg);
        
        // 💡 url 값이 'history.back'일 경우에만 뒤로 가기 실행
        if (url === "history.back") {
            window.history.back(); 
        } else {
            // 그 외의 경우 (상세 보기 URL 등)는 해당 URL로 이동
            location.href = url;
        }
    }
</script>
