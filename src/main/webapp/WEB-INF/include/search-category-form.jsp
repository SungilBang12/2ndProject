<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>

<div class="site-search-wrap">
		<!-- ✅ 404 방지: /search.jsp 로 고정 -->
		<form class="site-search" action="<c:url value='/search.jsp'/>"
			method="get">
			<label for="q" class="sr-only">검색</label> <input id="q"
				class="search-input" type="search" name="q" placeholder="게시물 검색" />
			<hidden></hidden>
			<button type="submit" class="search-btn" aria-label="검색"></button>
		</form>
	</div>

</html>