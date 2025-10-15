<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>${post.title}</title>

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- 전역 변수 및 함수 설정 -->
<script>
// ✅ 전역 contextPath 설정
window.contextPath = "${pageContext.request.contextPath}";
console.log("=== 전역 contextPath 설정:", window.contextPath);

// ✅ 전역 postId 설정
window.getPostIdFromUrl = function() {
    const params = new URLSearchParams(window.location.search);
    const postId = params.get("postId");
    console.log("=== URL에서 추출한 postId:", postId);
    return postId ? parseInt(postId, 10) : null;
};

window.currentPostId = window.getPostIdFromUrl();
console.log("=== 전역 postId 설정:", window.currentPostId);

// ✅ 전역 수정 함수
window.editPost = function() {
    console.log("=== editPost 함수 호출 ===");
    
    const postId = window.currentPostId || document.getElementById('hiddenPostId')?.value;
    const contextPath = window.contextPath;
    
    console.log("postId:", postId);
    console.log("contextPath:", contextPath);
    
    if (!postId || isNaN(postId) || postId <= 0) {
        alert("게시글 번호 정보가 누락되었습니다.");
        console.error("유효하지 않은 postId:", postId);
        return;
    }
    
    if (!contextPath) {
        alert("시스템 오류: contextPath가 설정되지 않았습니다.");
        console.error("contextPath가 비어있습니다.");
        return;
    }
    
    const editUrl = contextPath + "/post-edit-form.post?postId=" + postId;
    console.log("=== 이동할 URL:", editUrl);
    
    window.location.href = editUrl;
};

// ✅ 전역 삭제 함수
window.deletePost = function() {
    console.log("=== deletePost 함수 호출 ===");
    
    const postId = window.currentPostId || document.getElementById('hiddenPostId')?.value;
    const contextPath = window.contextPath;
    
    console.log("postId:", postId);
    
    if (!postId || isNaN(postId) || postId <= 0) {
        alert("게시글 번호 정보가 누락되었습니다.");
        return;
    }

    if (!confirm("정말로 이 게시글을 삭제하시겠습니까?")) return;

    $.ajax({
        url: contextPath + "/delete.postasync",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({ postId: parseInt(postId) }),
        dataType: "json",
        success: function(result) {
            if (result.status === "success") {
                alert("게시글이 성공적으로 삭제되었습니다.");
                
                const previousUrl = document.referrer;
                const redirectUrl = (previousUrl && previousUrl !== window.location.href) 
                    ? previousUrl 
                    : contextPath + "/index.jsp";
                
                window.location.href = redirectUrl;
            } else {
                alert("삭제 실패: " + (result.message || "알 수 없는 오류"));
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.error("AJAX 오류:", textStatus, errorThrown);
            alert("서버 통신 오류로 삭제에 실패했습니다.");
        }
    });
};

console.log("=== 전역 함수 등록 완료 ===");
</script>
</head>

<body>
<jsp:include page="/WEB-INF/include/header.jsp" />

<main class="main grid-14x5">
<div class="slot-nav">
<jsp:include page="/WEB-INF/include/nav.jsp" />
</div>

<div class="slot-board">
<jsp:include page="/WEB-INF/include/post-view.jsp"></jsp:include>
<jsp:include page="/WEB-INF/include/post-comment.jsp"></jsp:include>
</div>

<div class="slot-extra">
<!-- 추가 기능 영역 -->
</div>
</main>
</body>
</html>