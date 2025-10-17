<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:if test="${sessionScope.user == null}">
	<c:redirect url="/users/login?error=로그인이 필요합니다" />
</c:if>

<%-- 새로운 통합 페이지로 리다이렉트 --%>
<c:redirect url="/users/myActivity" />
