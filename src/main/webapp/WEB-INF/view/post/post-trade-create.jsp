<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>TipTap + Kakao Map Editor</title>
  <link rel="stylesheet" href="./css/post-create-edit.css" />

  <!-- Kakao 지도 SDK -->
  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=c72248c25fcfe17e7a6934e08908d1f4&libraries=services"></script>
</head>
<body>
<div class="container">
    <div id="toolbar" class="toolbar">
        <jsp:include page="/WEB-INF/include/editor-toolbar-buttons.jsp"/>
    </div>

    <div id="board" class="board"></div>

    <div class="actions">
        <button class="btn-primary" onclick="savePost()">저장</button>
        <button class="btn-secondary" onclick="cancelPost()">취소</button>
    </div>

    <!-- 모달 Include -->
    <jsp:include page="/WEB-INF/include/image-modal.jsp"/>
    <jsp:include page="/WEB-INF/include/map-modal.jsp"/>
    <jsp:include page="/WEB-INF/include/schedule-modal.jsp"/>
    <jsp:include page="/WEB-INF/include/emoji-picker.jsp"/>
</div>

<script type="module" src="./js/utils.js"></script>
<script type="module" src="./js/node-extensions.js"></script>
<script type="module" src="./js/emoji.js"></script>
<script type="module" src="./js/text-style.js"></script>
<script type="module" src="./js/image-modal.js"></script>
<script type="module" src="./js/map-modal.js"></script>
<script type="module" src="./js/schedule-modal.js"></script>
<script type="module" src="./js/link.js"></script>
<script type="module" src="./js/editor-init.js"></script>

<script type="module">
  import { initEditor } from "./js/editor-init.js";
  import * as MapModal from "./js/map-modal.js";
  import * as EmojiModule from "./js/emoji.js";
  import * as TextStyleModule from "./js/text-style.js";
  import * as ImageModal from "./js/image-modal.js";
  import * as ScheduleModal from "./js/schedule-modal.js";
  import * as LinkModule from "./js/link.js";

  // 전역 함수로 연결
  window.openKakaoMapModal = MapModal.openModal;
  window.openEmojiPicker = EmojiModule.openPicker;
  window.openHighlightPicker = TextStyleModule.openHighlightPicker;
  window.openTextStyleModal = TextStyleModule.openTextStyleModal;
  window.openImageModal = ImageModal.openModal;
  window.openScheduleModal = ScheduleModal.openModal;
  window.setLink = LinkModule.setLink;
  window.unsetLink = LinkModule.unsetLink;

  // 에디터 초기화
  const editor = initEditor(
      document.getElementById("board"),
      document.getElementById("toolbar")
  );

  // 이모지 자동완성 기능 활성화
  EmojiModule.setupEmojiSuggestion(editor);

  // 저장/취소 함수
  window.savePost = function() {
    const content = editor.getHTML();
    console.log("저장된 내용:", content);
    // TODO: 서버로 전송
    alert("게시글이 저장되었습니다.");
  };

  window.cancelPost = function() {
    if (confirm("작성을 취소하시겠습니까?")) {
      history.back();
    }
  };
</script>
</body>
</html>