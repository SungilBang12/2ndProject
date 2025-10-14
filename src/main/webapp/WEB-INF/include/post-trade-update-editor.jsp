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
<div class="container">
	<div class="header-actions">
		<a href="${pageContext.request.contextPath}/meeting-gather.jsp"
			class="btn">← 목록으로</a>
	</div>

	<h2>게시글 수정</h2>

	<input type="text" id="post-title-input" class="input-title"
		value="${post.title}" placeholder="제목을 입력하세요." />
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
	<div id="board" class="ProseMirror"></div>

	<div class="action-buttons">
		<div class="btn-group">
			<button onclick="editPost()" class="btn btn-primary">수정 완료</button>
			<a
				href="${pageContext.request.contextPath}/post-detail.post?postId=${post.postId}"
				class="btn btn-secondary">수정 취소</a>
		</div>
	</div>

</div>

<script type="module">
    // 🔑 [통합] 모든 로직을 이 모듈 스코프 내에서 처리합니다.
    import { initEditor } from "./js/editor-init.js"; // 수정용 에디터 초기화 스크립트
    
    // 1. 서버에서 전달받은 데이터 (JSP 변수)
    // 🔑 postId와 content는 이 모듈 스코프에서만 정의됩니다.
    const postId = ${post.postId}; 
    const initialContent = `${post.content}`; // DB에서 가져온 JSON 문자열
    
    let editor; // TipTap Editor 객체를 저장할 변수
    
    // 2. 초기화 및 에디터 생성
    try {
        const contentJson = JSON.parse(initialContent);
        
        // initEditor(boardEl, toolbarEl, initialContent)를 호출
        editor = initEditor(
            document.getElementById("board"),
            document.getElementById("toolbar"), // 툴바 DOM 정확히 전달
            contentJson // 초기 내용 설정
        );
        
        // 🔑 [핵심] editor 객체를 window 전역에 노출시켜 onclick에서 접근 가능하게 합니다.
        window.editor = editor; 
        window.postId = postId; // postId도 전역에 노출하여 아래 함수에서 접근 보장
        
    } catch (err) {
        console.error("JSON 파싱 오류: 초기 에디터 내용을 불러올 수 없습니다.", err);
        // 오류 발생 시에도 최소한의 editor 객체와 postId를 전역에 할당합니다.
        const defaultEditor = initEditor(
            document.getElementById("board"),
            document.getElementById("toolbar"),
            {}
        );
        window.editor = defaultEditor; 
        window.postId = postId; 
    }

    // ---------------------------------------------------
    // 3. 수정 완료 함수 (AJAX 처리)
    // ---------------------------------------------------
    // 함수 자체는 window 전역에 정의되어 onclick 이벤트에서 호출될 수 있습니다.
	window.editPost = function() {
		// 전역에 노출된 editor와 postId를 사용합니다.
		if (!window.editor) {
			alert("에디터가 초기화되지 않았습니다.");
			return;
		}

		// 현재 URL (수정 실패 시 돌아갈 주소)
		const failureRedirectUrl = window.location.href;
        
        const titleValue = $("#post-title-input").val();

		if (!titleValue || !titleValue.trim()) {
			alert("제목을 입력해주세요.");
			return;
		}
        
        // content는 getJSON() 호출 결과입니다.
        let editorContent;
        try {
            editorContent = JSON.stringify(window.editor.getJSON());
        } catch(e) {
            console.error("Content 추출 오류:", e);
            alert("내용 추출 중 오류가 발생했습니다.");
            return;
        }

		const data = {
			postId : window.postId, // 전역 변수 사용
			title : titleValue,
			content : editorContent, // JSON 문자열
			failureRedirect : failureRedirectUrl
		};

		// AJAX 요청 (jQuery는 이미 로드되어 있습니다)
		$.ajax({
			url : "${pageContext.request.contextPath}/update.postasync",
			type : "POST",
			contentType : "application/json",
			data : JSON.stringify(data),

			success : function(result) {
				console.log("서버 응답:", result);
				if (result.status === "success" && result.redirectUrl) {
					alert("게시글 수정 완료!");
					// 서버가 전달한 성공 리다이렉트 URL로 이동
					window.location.href = result.redirectUrl;
				} else {
					alert("수정 실패: " + (result.message || "알 수 없는 오류"));
				}
			},
			error : function(jqXHR, textStatus, errorThrown) {
				console.error("AJAX 전송 오류:", textStatus, errorThrown);
				alert("게시글 수정 중 서버 통신 오류가 발생했습니다.");
			}
		});
	};
</script>