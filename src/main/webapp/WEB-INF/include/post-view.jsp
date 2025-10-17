<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- CSS -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/post-create-edit.css" />
<style>
.ProseMirror {
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 16px;
    background-color: #fafafa;
    min-height: 300px;
    line-height: 1.6;
    word-break: break-word;
}

.post-header {
    margin-bottom: 20px;
}

.post-header h1 {
    margin: 0 0 8px 0;
}

.post-meta {
    font-size: 0.9em;
    color: #555;
}

.post-meta-item {
    margin-right: 15px;
}

.header-actions {
    margin-bottom: 20px;
}

.header-actions .btn {
    padding: 8px 16px;
    border: 1px solid #ddd;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    background-color: white;
    transition: background-color 0.2s;
}

.header-actions .btn:hover {
    background-color: #f5f5f5;
}

.action-buttons {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid #eee;
}

.action-buttons .btn {
    padding: 8px 16px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    transition: all 0.2s;
}

.action-buttons .btn-primary {
    background-color: #007bff;
    color: white;
}

.action-buttons .btn-primary:hover {
    background-color: #0056b3;
}

.action-buttons .btn-danger {
    background-color: #dc3545;
    color: white;
}

.action-buttons .btn-danger:hover {
    background-color: #c82333;
}
</style>

<!-- 목록으로 버튼 -->
<div class="header-actions">
    <button onclick="goToList()" class="btn">← 목록으로</button>
</div>

<!-- 게시글 정보 -->
<div class="post-header">
    <h1 class="post-title">${post.title}</h1>
    <div class="post-meta">
        <span class="post-meta-item"><strong>작성자:</strong> ${post.userId}</span>
        <span class="post-meta-item"><strong>작성일:</strong> ${post.createdAt}</span>
        <c:if test="${not empty post.listId}">
            <span class="post-meta-item"><strong>카테고리:</strong> 
                <c:choose>
                    <c:when test="${post.listId == 1}">노을</c:when>
                    <c:when test="${post.listId == 2}">맛집 추천</c:when>
                    <c:when test="${post.listId == 3}">맛집 후기</c:when>
                    <c:when test="${post.listId == 4}">촬영 TIP</c:when>
                    <c:when test="${post.listId == 5}">장비 추천</c:when>
                    <c:when test="${post.listId == 6}">중고 거래</c:when>
                    <c:when test="${post.listId == 7}">'해'쳐 모여</c:when>
                    <c:when test="${post.listId == 8}">장소 추천</c:when>
                </c:choose>
            </span>
        </c:if>
    </div>
</div>

<!-- Hidden inputs -->
<input type="hidden" id="hiddenPostId" value="${post.postId}">
<input type="hidden" id="hiddenListId" value="${param.listId != null ? param.listId : post.listId}">

<!-- 게시글 본문 -->
<div id="board" class="ProseMirror"></div>

<!-- 액션 버튼 (작성자만 표시) -->
<c:if test="${not empty sessionScope.user.userId && sessionScope.user.userId == post.userId}">
    <div class="action-buttons">
        <button onclick="editPost()" class="btn btn-primary">수정</button>
        <button onclick="deletePost()" class="btn btn-danger">삭제</button>
    </div>
</c:if>

<!-- 권한 없는 사용자에게 메시지 표시 -->
<c:if test="${not empty sessionScope.user.userId && sessionScope.user.userId != post.userId}">
    <div class="action-buttons">
        <p style="color: #666; font-size: 14px;">본인이 작성한 게시글만 수정/삭제할 수 있습니다.</p>
    </div>
</c:if>

<!-- 스크립트 -->
<script type="module">
    import { initViewer } from "${pageContext.request.contextPath}/js/editor-view.js";

    console.log("=== post-view.jsp 모듈 스크립트 실행 ===");

    // ===== 파라미터 가져오기 =====
    const postId = document.getElementById('hiddenPostId').value;
    const listId = document.getElementById('hiddenListId').value;
    
    console.log("postId:", postId);
    console.log("listId:", listId);

    // ===== 전역 변수로 저장 =====
    window.CURRENT_POST_ID = postId || null;
    window.CURRENT_LIST_ID = listId || null;

    // ===== 게시글 내용 로드 =====
    const jsonData = `${post.content}`;
    let content;

    try {
        content = JSON.parse(jsonData);
    } catch (err) {
        console.error("JSON 파싱 오류:", err);
        content = {
            type: "doc",
            content: [{
                type: "paragraph",
                content: [{ type: "text", text: "내용을 불러올 수 없습니다." }]
            }]
        };
    }

    // TipTap 뷰어 초기화
    const editor = initViewer(document.getElementById("board"), content);
    console.log("=== 에디터 초기화 완료 ===");
</script>

<script>
    // ===== 목록으로 돌아가기 =====
    function goToList() {
        const listId = document.getElementById('hiddenListId').value;
        
        console.log('목록으로 이동 - listId:', listId);
        
        if (listId && listId !== 'null' && listId !== '') {
            // listId가 있으면 해당 리스트로 이동
            window.location.href = '${pageContext.request.contextPath}/post-list-view.post?listId=' + listId;
        } else {
            // listId가 없으면 그냥 뒤로가기
            history.back();
        }
    }

    // ===== 게시글 수정 =====
    function editPost() {
        const postId = document.getElementById('hiddenPostId').value;
        const listId = document.getElementById('hiddenListId').value;
        
        console.log('수정 버튼 클릭');
        console.log('- postId:', postId);
        console.log('- listId:', listId);
        
        if (!postId) {
            alert('게시글 ID를 찾을 수 없습니다.');
            return;
        }
        
        // ✅ 컨트롤러의 /post-edit-form.post 호출
        let url = '${pageContext.request.contextPath}/post-edit-form.post?postId=' + postId;
        
        // listId가 있으면 파라미터로 전달
        if (listId && listId !== 'null' && listId !== '') {
            url += '&listId=' + listId;
        }
        
        console.log('수정 페이지로 이동:', url);
        window.location.href = url;
    }

    // ===== 게시글 삭제 =====
    function deletePost() {
        if (!confirm('정말로 이 게시글을 삭제하시겠습니까?')) {
            return;
        }

        const postId = document.getElementById('hiddenPostId').value;
        const listId = document.getElementById('hiddenListId').value;

        console.log('삭제 시작 - postId:', postId);

        // ✅ 삭제 API 호출
        fetch('${pageContext.request.contextPath}/delete.post', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'postId=' + postId
        })
        .then(response => {
            console.log('삭제 응답 상태:', response.status);
            if (response.ok) {
                return response.json();
            }
            throw new Error('삭제 요청 실패: ' + response.status);
        })
        .then(data => {
            console.log('삭제 응답 데이터:', data);
            if (data.success) {
                alert('게시글이 삭제되었습니다.');
                goToList();
            } else {
                alert('게시글 삭제에 실패했습니다: ' + (data.message || '알 수 없는 오류'));
            }
        })
        .catch(error => {
            console.error('삭제 오류:', error);
            alert('게시글 삭제 중 오류가 발생했습니다: ' + error.message);
        });
    }
</script>