<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<link rel="stylesheet" href="./css/post-create-edit.css" />

<div class="container">
	<div id="toolbar" class="toolbar">
		<button data-cmd="bold">
			<strong>B</strong>
		</button>
		<button data-cmd="italic">
			<i>I</i>
		</button>
		<button data-cmd="strike">
			<s>S</s>
		</button>
		<button data-cmd="underline">U</button>
		<jsp:include page="/WEB-INF/template/text-style-btn.jsp"></jsp:include>

		<button data-cmd="heading1">H1</button>
		<button data-cmd="heading2">H2</button>
		<button data-cmd="heading3">H3</button>

		<button data-cmd="bulletList">● List</button>
		<button data-cmd="orderedList">1. List</button>
		<jsp:include page="/WEB-INF/include/image-modal.jsp" />
		<jsp:include page="/WEB-INF/include/map-modal.jsp" />
		<jsp:include page="/WEB-INF/include/schedule-modal.jsp" />
		<jsp:include page="/WEB-INF/include/emoji-picker.jsp" />
		<jsp:include page="/WEB-INF/template/link-btn.jsp"></jsp:include>
	</div>

	<div id="board" class="board"></div>

	<div class="actions">
		<button class="btn-primary" onclick="savePost()">저장</button>
		<button class="btn-secondary" onclick="cancelPost()">취소</button>
	</div>
</div>

<script type="module">
    import { initEditor } from "./js/editor-init.js";
    // 유일하게 emoji기능 사용 안할꺼면 빼야하는 부분
    import * as EmojiModule from "./js/emoji.js"; 

    // 에디터 초기화
    const editor = initEditor(
        document.getElementById("board"),
        document.getElementById("toolbar")
    );

    // [이모지 기능] 유일하게 emoji기능 사용 안할꺼면 빼야하는 부분
    window.openEmojiPicker = EmojiModule.openPicker;
    // 이모지 자동완성 기능
    EmojiModule.setupEmojiSuggestion(editor);


    // ---------------------------------------------------
// [AJAX] 게시글 저장 함수 (create.postasync 호출)
// ---------------------------------------------------
window.savePost = function() {
    if (!editor) {
        alert("에디터가 초기화되지 않았습니다.");
        return;
    }
    
    // [ID 수정 반영] 제목 입력값 가져오기
    const title = $("#title").val(); 

    // 유효성 검사
    if (!title || !title.trim()) {
        alert("제목을 입력해주세요.");
        return;
    }
    
    // 현재 URL (작성 실패 시 돌아갈 주소)
    const failureRedirectUrl = window.location.href; 

    const data = {
        title: title,
        content: editor.getJSON(),
        // 서버에 실패 시 돌아갈 경로 명시적으로 전달
        failureRedirect: failureRedirectUrl 
    };

    $.ajax({
        // [경로 확인] PostAjaxController의 create 매핑 URL
        url: "${pageContext.request.contextPath}/create.postasync", 
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify(data),
        
        success: function(result) {
            console.log("서버 응답:", result);
            
            // 🔑 성공 시: 서버가 보낸 JSON의 redirectUrl로 클라이언트가 직접 이동
            if (result.status === "success" && result.redirectUrl) {
                alert("게시글이 성공적으로 저장되었습니다!");
                window.location.href = result.redirectUrl; 
            } else if (result.status === "error") {
                // 실패 시: 서버가 보낸 오류 메시지 출력
                alert("게시글 저장 실패: " + (result.message || "알 수 없는 오류"));
                // 필요하다면 실패 시 failureRedirectUrl로 이동하는 로직 추가 가능
                // window.location.href = result.failureRedirectUrl;
            } else {
                alert("알 수 없는 서버 응답 형식입니다.");
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.error("AJAX 전송 오류:", textStatus, errorThrown);
            alert("게시글 저장 중 서버 통신 오류가 발생했습니다.");
        }
    });
};

    window.cancelPost = function() {
        if (confirm("작성을 취소하시겠습니까?")) {
            history.back(); // 이전 페이지(목록)로 돌아감
        }
    };
</script>