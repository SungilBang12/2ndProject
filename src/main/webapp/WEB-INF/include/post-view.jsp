<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- Kakao Map API -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=c72248c25fcfe17e7a6934e08908d1f4&libraries=services"></script>

<!-- CSS -->
<link rel="stylesheet" href="./css/post-create-edit.css" />
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

/* 액션 버튼 우측 하단 정렬 */
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
    <a href="${pageContext.request.contextPath}/meeting-gather.jsp" class="btn">← 목록으로</a>
</div>

<!-- 게시글 정보 -->
<div class="post-header">
    <h1 class="post-title">${post.title}</h1>
    <div class="post-meta">
        <span class="post-meta-item"><strong>작성자:</strong> ${post.userId}</span>
        <span class="post-meta-item"><strong>작성일:</strong> ${post.createdAt}</span>
    </div>
</div>

<!-- 게시글 본문 -->
<div id="board" class="ProseMirror"></div>

<!-- 액션 버튼 (우측 하단 일렬 정렬) -->
<div class="action-buttons">
    <button onclick="editPost()" class="btn btn-primary">수정</button>
    <button onclick="deletePost()" class="btn btn-danger">삭제</button>
</div>

<!-- 스크립트 -->
<script type="module">
import { initViewer } from "./js/editor-view.js";

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

// ===== URL에서 postId 추출 =====
function getPostIdFromUrl() {
    const params = new URLSearchParams(window.location.search);
    const postId = params.get("postId");
    return postId ? parseInt(postId, 10) : null;
}

const postId = getPostIdFromUrl();
const contextPath = "${pageContext.request.contextPath}";

if (!postId) {
    console.error("오류: URL에서 유효한 postId를 찾을 수 없습니다.");
}

// ===== 수정 페이지 이동 =====
window.editPost = function() {
    if (!postId) {
        alert("게시글 번호 정보가 누락되었습니다.");
        return;
    }
    window.location.href = `${contextPath}/post-edit-form.post?postId=${postId}`;
};

// ===== 삭제 처리 =====
window.deletePost = function() {
    if (!postId) {
        alert("게시글 번호 정보가 누락되었습니다.");
        return;
    }

    if (!confirm("정말로 이 게시글을 삭제하시겠습니까?")) return;

    $.ajax({
        url: `${contextPath}/delete.postasync`,
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({ postId: postId }),
        dataType: "json",
        success: function(result) {
            if (result.status === "success") {
                alert("게시글이 성공적으로 삭제되었습니다.");
                
                // 이전 페이지 또는 목록으로 이동
                const previousUrl = document.referrer;
                const redirectUrl = (previousUrl && previousUrl !== window.location.href) 
                    ? previousUrl 
                    : `${contextPath}/index.jsp`;
                
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
</script>