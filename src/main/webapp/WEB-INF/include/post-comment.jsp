<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<!-- 댓글 섹션 -->
<div class="comment-section">
	<h2>
		댓글 <span id="comment-count">(0)</span>
	</h2>

	<!-- 댓글 목록 -->
	<div class="comment-list" id="comment-list">
		<!-- JavaScript로 동적 생성 -->
	</div>

	<!-- 댓글 작성 폼 -->
	<div class="comment-form">
		<h3>댓글 작성</h3>
		<form id="comment-form">
			<div class="form-group">
				<label for="comment-author">작성자</label> <input type="text"
					id="comment-author" name="author" required
					placeholder="작성자명을 입력하세요">
			</div>
			<div class="form-group">
				<label for="comment-content">내용</label>
				<textarea id="comment-content" name="content" rows="4" required
					placeholder="댓글 내용을 입력하세요"></textarea>
			</div>
			<button type="submit" class="btn btn-primary">댓글 작성</button>
		</form>
	</div>

</div>
