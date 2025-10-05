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
	if(msg != null && url != null){
		alert(msg);		
	    location.href= url;
	}
	</script>
