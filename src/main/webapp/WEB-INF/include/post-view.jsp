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
  	initViewer(
      document.getElementById("board"),
      content
  	);

//postId 필요

window.editPost = function() {
  const content = editor.getJSON(); // tiptap은 JSON 구조로 교환 가능
  const data = {
    title: document.querySelector("#title").value,
    content: content
  };

  fetch("/editor-update.post", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data)
  })
  .then(res => res.json())
  .then(result => {
    console.log("서버 응답:", result);
	console.log(JSON.stringify(data));
    alert("게시글이 저장되었습니다!");
  })
  .catch(err => console.error("전송 오류:", err));
};
//postId 필요
window.deletePost = function() {
  fetch("/editor-delete.post", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(postId)
  })
  .then(res => res.json())
  .then(result => {
    console.log("서버 응답:", result);
    alert("게시글이 삭제되었습니다!");
  })
  .catch(err => console.error("전송 오류:", err));
};

</script>



