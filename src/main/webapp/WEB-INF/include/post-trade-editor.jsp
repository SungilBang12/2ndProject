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
  const content = editor.getJSON(); // tiptap은 JSON 구조로 교환 가능
  const data = {
    title: document.querySelector("#title").value,
    content: content
  };

  fetch("/editor-create.test", {
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
