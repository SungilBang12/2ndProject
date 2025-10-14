<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

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
.input-title {
    width: 100%;
    padding: 10px;
    margin-bottom: 20px;
    font-size: 1.5em;
    border: 1px solid #ccc;
    border-radius: 4px;
}
</style>

<div class="header-actions">
    <a href="${pageContext.request.contextPath}/meeting-gather.jsp" class="btn">← 목록으로</a>
</div>

<h2>게시글 수정</h2>

<input type="text" id="post-title-input" class="input-title" 
       value="${post.title}" placeholder="제목을 입력하세요." />

<div id="board" class="ProseMirror"></div>

<div class="action-buttons">
    <div class="btn-group">
        <button onclick="editPost()" class="btn btn-primary">수정 완료</button>
        <a href="${pageContext.request.contextPath}/post/detail?postId=${post.postId}" class="btn btn-secondary">수정 취소</a>
    </div>
</div>

<script type="module">
    // TipTap 에디터 초기화 함수와 확장 모듈을 임포트한다고 가정
    import { initEditor } from "./js/editor-init.js"; // 수정용 에디터 초기화 스크립트
    
    // 1. 서버에서 전달받은 데이터 (JSP 변수)
    const postId = ${post.postId}; 
    const initialContent = `${post.content}`; // DB에서 가져온 JSON 문자열
    
    let editor; // TipTap Editor 객체를 저장할 변수

    try {
        const contentJson = JSON.parse(initialContent);
        // 2. 에디터 초기화
        editor = initEditor(
            document.getElementById("board-editor"),
            contentJson // 초기 내용 설정
        );
    } catch (err) {
        console.error("JSON 파싱 오류: 초기 에디터 내용을 불러올 수 없습니다.", err);
        // 파싱 실패 시 기본 내용으로 초기화
        editor = initEditor(document.getElementById("board-editor"), {}); 
    }
</script>

<script>
// postId 변수는 위 <script type="module"> 블록에서 정의되었으므로 전역 범위에 있어야 접근 가능
// 또는 모듈 내에서 함수를 호출할 때 postId를 인자로 전달해야 합니다.
// 여기서는 postId를 전역 변수로 가정합니다.

window.editPost = function() {
    if (!editor) {
        alert("에디터가 초기화되지 않았습니다.");
        return;
    }
    
    // 현재 URL (수정 실패 시 돌아갈 주소)
    const failureRedirectUrl = window.location.href;

    const data = {
        postId: postId, 
        title: $("#post-title-input").val(),
        content: JSON.stringify(editor.getJSON()), // TipTap JSON 객체를 문자열로 변환
        // [핵심] 수정 실패 시 돌아갈 경로를 명시적으로 서버에 전달
        failureRedirect: failureRedirectUrl 
    };
    
    if (!data.title.trim()) {
        alert("제목을 입력해주세요.");
        return;
    }

    // AJAX 요청
    $.ajax({
        // PostAsyncController에 정의된 update URL 사용
        url: "${pageContext.request.contextPath}/update.postasync", 
        type: "POST", 
        contentType: "application/json", 
        data: JSON.stringify(data),
        
        success: function(result) {
            console.log("서버 응답:", result);
            if (result.status === "success") {
                alert("게시글 수정 완료!");
                // 서버가 전달한 성공 리다이렉트 URL로 이동
                window.location.href = result.redirectUrl; 
            } else {
                // 수정 실패 시 (유효성 검사 실패, 권한 없음 등)
                alert("수정 실패: " + (result.message || "알 수 없는 오류"));
                // 실패 시 특별히 리다이렉트가 필요 없으므로 현재 페이지에 머무름
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.error("AJAX 전송 오류:", textStatus, errorThrown);
            alert("게시글 수정 중 서버 통신 오류가 발생했습니다.");
        }
    });
};
</script>