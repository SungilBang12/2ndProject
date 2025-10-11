<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<button data-cmd="emoji">😊</button>
<div id="emojiModal" class="modal">
	<div class="modal-content">
		<span class="modal-close" id="emojiModalClose">&times;</span>
		<h3>이모지 선택</h3>
		<input type="text" id="emojiSearchInput"
			placeholder="검색 (: 입력 시 자동완성)" />
		<div id="emojiListContainer" class="emoji-list-container"></div>
	</div>
</div>