<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>

<button data-cmd="image">🖼️ 이미지</button>
<div id="imageModal" class="modal">
  <div class="modal-content">
    <span class="modal-close" id="imageModalClose">&times;</span>
    <h3>이미지 업로드 / 드래그 & 드롭</h3>
    <input type="file" id="imageFileInput" multiple accept="image/*"/>
    <div id="imagePreviewContainer" class="image-preview-container"></div>
    <button id="imageConfirmBtn">삽입</button>
  </div>
</div>

<script type="module">
import * as ImageModal from "./js/image-modal.js";
window.openImageModal = ImageModal.openModal;
</script>
