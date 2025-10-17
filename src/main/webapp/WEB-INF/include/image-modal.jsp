<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>

<button type="button" data-cmd="image" onclick="event.preventDefault(); openImageModal(window.currentEditor);">🖼️ 이미지</button>

<script type="module">
import * as ImageModal from "${pageContext.request.contextPath}/js/image-modal.js";

// 전역 함수로 등록
window.openImageModal = function(editor) {
  if (!editor) {
    console.error('에디터가 초기화되지 않았습니다.');
    return;
  }
  ImageModal.openModal(editor);
};

console.log('이미지 모달 스크립트 로드 완료');
</script>
