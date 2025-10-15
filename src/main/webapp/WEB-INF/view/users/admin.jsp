<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="사용자 관리" />
<jsp:include page="/WEB-INF/include/header.jsp" />

<div class="form-card" style="max-width: 900px; width: 100%;">
<h2 style="color: var(--primary-color); margin-bottom: 1.5rem;">전체 사용자 목록</h2>

<c:if test="${userList != null and not empty userList}">
    <table class="user-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>이름</th>
                <th>이메일</th>
                <th>권한</th>
                <th>가입일</th>
                <th>관리</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="user" items="${userList}">
                <tr>
                    <td>${user.userId}</td>
                    <td>${user.username}</td>
                    <td>${user.email}</td>
                    <td>${user.ROLE}</td>
                    <td><fmt:formatDate value="${user.date}" pattern="yyyy-MM-dd HH:mm"/></td>
                    <td>
                        <button class="btn btn-secondary" style="flex: 0; padding: 0.5rem 0.8rem;" onclick="location.href='../update?userId=${user.userId}'">수정</button>
                        <button class="btn btn-primary" style="flex: 0; padding: 0.5rem 0.8rem; background-color: var(--error-color);" onclick="confirmWithdraw('${user.userId}')">삭제</button>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</c:if>
<c:if test="${empty userList}">
    <p style="text-align: center; color: #6b7280;">등록된 사용자 정보가 없습니다.</p>
</c:if>

<c:if test="${error != null}">
    <p class="error-message" style="text-align: center; margin-top: 1rem;">${error}</p>
</c:if>

</div>

<script>
function confirmWithdraw(userId) {
// alert 대신 간단한 커스텀 모달 또는 confirm() 대체 로직 사용 (여기서는 단순 confirm 사용)
if (confirm(userId + ' 사용자를 정말로 삭제하시겠습니까?')) {
// 실제로는 AJAX로 삭제 요청을 보내는 것이 일반적입니다.
// 여기서는 단순함을 위해 동기 요청을 사용합니다.
location.href = '../withdraw?userId=' + userId;
}
}
</script>

<jsp:include page="/WEB-INF/include/footer.jsp" />