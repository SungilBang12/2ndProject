<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- Kakao Map API -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=c72248c25fcfe17e7a6934e08908d1f4&libraries=services"></script>

<!-- CSS -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/post-create-edit.css" />
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

.action-buttons {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid #eee;
}

.action-buttons .btn {
    padding: 8px 16px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
}

.action-buttons .btn-primary {
    background-color: #007bff;
    color: white;
}

.action-buttons .btn-danger {
    background-color: #dc3545;
    color: white;
}

.action-buttons .btn:hover {
    opacity: 0.9;
}
</style>

<!-- 목록으로 버튼 -->
<div class="header-actions">
    <button onclick="history.back()" class="btn">← 목록으로</button>
</div>

<!-- 게시글 정보 -->
<div class="post-header">
    <h1 class="post-title">${post.title}</h1>
    <div class="post-meta">
        <span class="post-meta-item"><strong>작성자:</strong> ${post.userId}</span>
        <span class="post-meta-item"><strong>작성일:</strong> ${post.createdAt}</span>
    </div>
</div>

<!-- Hidden input으로 postId 저장 -->
<input type="hidden" id="hiddenPostId" value="${post.postId}">

<!-- 게시글 본문 -->
<div id="board" class="ProseMirror"></div>

<!-- 액션 버튼 (작성자만 표시) -->
<c:if test="${not empty sessionScope.userId && sessionScope.userId == post.userId}">
    <div class="action-buttons">
        <button onclick="editPost()" class="btn btn-primary">수정</button>
        <button onclick="deletePost()" class="btn btn-danger">삭제</button>
    </div>
</c:if>

<!-- 스크립트 -->
<script type="module">
import { initViewer } from "${pageContext.request.contextPath}/js/editor-view.js";

console.log("=== post-view.jsp 모듈 스크립트 실행 ===");

// ===== 게시글 내용 로드 =====
const jsonData = `${post.content}`;
let content;

try {
    content = JSON.parse(jsonData);
} catch (err) {
    console.error("JSON 파싱 오류:", err);
    content = {
        type: "doc",
        content: [{
            type: "paragraph",
            content: [{ type: "text", text: "내용을 불러올 수 없습니다." }]
        }]
    };
}

// TipTap 뷰어 초기화
const editor = initViewer(document.getElementById("board"), content);
console.log("=== 에디터 초기화 완료 ===");

<!-- 액션 버튼 (작성자만 표시) -->
<c:if test="${not empty sessionScope.userId && sessionScope.userId == post.userId}">
    <div class="action-buttons">
        <button onclick="editPost()" class="btn btn-primary">수정</button>
        <button onclick="deletePost()" class="btn btn-danger">삭제</button>
    </div>
</c:if>

<!-- 권한 없는 사용자에게 메시지 표시 (선택사항) -->
<c:if test="${not empty sessionScope.userId && sessionScope.userId != post.userId}">
    <div class="action-buttons">
        <p style="color: #666; font-size: 14px;">본인이 작성한 게시글만 수정/삭제할 수 있습니다.</p>
    </div>
</c:if>


</script>