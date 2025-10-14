<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<link rel="stylesheet" href="./css/post-create-edit.css" />
<script
	src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=c72248c25fcfe17e7a6934e08908d1f4&libraries=services"></script>
<style>
.ProseMirror {
	border: 1px solid #ddd;
	border-radius: 8px;
	padding: 16px;
	background-color: #fafafa;
	min-height: 300px;
	line-height: 1.6;
	word-break: break-word;
}

.post-header {
	margin-bottom: 20px;
}

.post-header h1 {
	margin: 0 0 8px 0;
}

.post-meta {
	font-size: 0.9em;
	color: #555;
}
</style>
<!-- 목록으로 돌아가기 버튼 , history back 이용-->
<div class="header-actions">
	<a href="${pageContext.request.contextPath}/meeting-gather.jsp"
		class="btn">← 목록으로</a>
</div>

<!-- 게시글 상세 정보 -->
<div class="post-header">
	<h1 class="post-title" id="post-title">${post.title}</h1>
	<div class="post-meta">
		<span class="post-meta-item"> <strong>작성자:
				${post.userId}</strong> <span id="post-author">-</span>
		</span> <span class="post-meta-item"> <strong>작성일:
				${post.createdAt}</strong> <span id="post-date">-</span>
		</span>
	</div>
</div>

<div id="board" class="ProseMirror"></div>

<!-- 액션 버튼 el&jstl 으로 서버쪽에서 미리 판단해서 뿌려주기 -->
<div class="action-buttons">
	<div class="btn-group">
		<a href="${pageContext.request.contextPath}/meeting-gather.jsp"
			class="btn">목록</a>
		<button onclick="editPost()" class="btn btn-primary">수정</button>
	</div>
	<div class="btn-group">
		<button onclick="deletePost()" class="btn btn-danger">삭제</button>
	</div>
</div>

<script type="module">
	import { initViewer } from "./js/editor-view.js";
	// 서버에서 전달받은 JSON 문자열 (게시글 내용)
    const jsonData = `${post.content}`;
    let content;
	try {
	      content = JSON.parse(jsonData);
    } catch (err) {
      console.error("JSON 파싱 오류:", err);
      content = { type: "doc", content: [{ type: "paragraph", content: [{ type: "text", text: "내용을 불러올 수 없습니다." }] }] };
    }
    
 	// TipTap viewer 초기화
  	const editor = initViewer(
      document.getElementById("board"),
      content
  	);


   // ---------------------------------------------------
    // 🔑 URL에서 쿼리 파라미터(postId)를 추출하는 헬퍼 함수
    // ---------------------------------------------------
    function getPostIdFromUrl() {
        // window.location.search는 "?postId=123"과 같은 문자열을 반환합니다.
        const params = new URLSearchParams(window.location.search);
        const postId = params.get("postId");
        
        // 숫자인지 확인하고, 유효하지 않으면 null 반환
        return postId ? parseInt(postId, 10) : null;
    }

    // URL에서 postId 값을 가져와 변수에 할당
    const postId = getPostIdFromUrl();


// 유효성 검사
    if (!postId) {
        console.error("오류: URL에서 유효한 postId를 찾을 수 없습니다.");
    }


// ---------------------------------------------------
// 수정 폼으로 이동 (동기 요청)
// ---------------------------------------------------
window.editPost = function() {
    if (!postId) {
        alert("게시글 번호 정보가 누락되었습니다.");
        return;
    }
    
    const contextPath = "${pageContext.request.contextPath}";
    
    // 동기 요청으로 수정 폼으로 이동 (Service에서 DB 데이터 로드)
    window.location.href = contextPath + "/post-edit-form.post?postId=" + postId;
};

// ---------------------------------------------------
// 🔑 삭제 요청 (비동기 AJAX: $.ajax 사용)
// ---------------------------------------------------
window.deletePost = function() {
    if (!postId) {
        alert("게시글 번호 정보가 누락되었습니다.");
        return;
    }

    if (confirm("정말로 이 게시글을 삭제하시겠습니까?")) {
        const data = { postId: postId }; 
        const contextPath = "${pageContext.request.contextPath}";
        
        // AJAX 요청 ($.ajax 사용으로 JSON Body 전송 보장)
        $.ajax({
            url: contextPath + "/delete.postasync", 
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify(data),
            dataType: "json", // 서버 응답을 JSON으로 예상

            success: function(result) {
                console.log("서버 응답:", result);
                if (result.status === "success") {
                    alert("게시글이 성공적으로 삭제되었습니다.");
                    
                    // 🔑 [핵심 수정] 이전 페이지(referrer)로 이동 시도
                    const previousUrl = document.referrer;
                    const currentUrl = window.location.href;
                    // 목록 페이지의 안전 대체 경로
                    const fallbackUrl = contextPath + "/index.jsp"; 

                    let redirectUrl;

                    // 이전 URL이 존재하고, 현재 상세 페이지 URL이 아니라면 이전 URL 사용
                    if (previousUrl && previousUrl !== currentUrl) {
                        redirectUrl = previousUrl;
                    } else {
                        // 이전 URL이 없거나 현재 페이지인 경우 (예: 북마크에서 바로 들어옴), 목록으로 이동
                        redirectUrl = fallbackUrl;
                    }
                    
                    window.location.href = redirectUrl; 
                    
                } else {
                    alert("삭제 실패: " + (result.message || "알 수 없는 오류"));
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.error("AJAX 전송 오류:", textStatus, errorThrown);
                alert("서버 통신 오류로 삭제에 실패했습니다.");
            }
        });
    }
};
</script>



