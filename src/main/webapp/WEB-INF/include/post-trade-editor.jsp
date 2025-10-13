<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<link rel="stylesheet" href="./css/post-create-edit.css" />
<!-- toolbar에서 필요한 버튼 추가 제거 -->
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
// 에디터 초기화
  const editor = initEditor(
      document.getElementById("board"),
      document.getElementById("toolbar")
  );

window.savePost = function() {
    const content = editor.getJSON();
    const data = {
        title: document.querySelector("#title").value,
        content: content
    };

    fetch("/editor-create.post", {
        method: "POST",
        headers: { "Content-Type": "application/json",
// 💡 비동기 요청임을 서버에 알리는 헤더
"X-Requested-With": "XMLHttpRequest" },
        body: JSON.stringify(data)
    })
    .then(res => {
        // HTTP 응답 상태 확인
        if (!res.ok) {
            throw new Error('Server returned an error: ' + res.status);
        }
        return res.json(); // 서버가 보낸 JSON 응답을 파싱
    })
    .then(result => {
        console.log("서버 응답:", result);
        
        // 🔑 핵심: 서버에서 받은 URL을 이용해 클라이언트에서 페이지 전환
        if (result.success && result.redirectUrl) {
            alert("게시글이 저장되었습니다!");
            // 클라이언트가 상세 페이지 URL로 직접 이동
           //window.location.href = result.redirectUrl; 

//클라이언트가 글쓰기 이전(리스트) 로 이동
history.back();
        } else {
            // 서버가 성공했으나 redirectUrl이 없는 경우의 처리
            alert("게시글 저장에 성공했으나 이동할 페이지 정보가 없습니다.");
        }
    })
    .catch(err => {
        console.error("전송 오류:", err);
        alert("게시글 저장 중 오류가 발생했습니다.");
    });
};
window.cancelPost = function() {
    if (confirm("작성을 취소하시겠습니까?")) {
      history.back();
    }
  };


//유일하게 emoji기능 사용 안할꺼면 빼야하는 부분
import * as EmojiModule from "./js/emoji.js";
  window.openEmojiPicker = EmojiModule.openPicker;
// 이모지 자동완성 기능
  EmojiModule.setupEmojiSuggestion(editor);
</script>
