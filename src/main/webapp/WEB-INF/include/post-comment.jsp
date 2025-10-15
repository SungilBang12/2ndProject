<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>댓글 시스템 완전 테스트 (Comments DTO)</title>
<style>
/* 기본 스타일 */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    background: #f5f5f5;
    padding: 20px;
}

.comment-container { 
    max-width: 800px;
    margin: 40px auto 0;
    padding: 0;
    background: white; 
    border-radius: 20px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1), 0 1px 8px rgba(0, 0, 0, 0.06);
    overflow: hidden;
}

/* 테스트 정보 패널 */
.test-info {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    padding: 20px 25px;
    margin: 20px auto;
    border-radius: 15px;
    text-align: center;
    max-width: 800px;
    box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
}

.test-info h3 {
    margin: 0 0 15px 0;
    color: white;
    font-size: 22px;
    font-weight: 700;
    text-shadow: 0 2px 4px rgba(0,0,0,0.2);
}

.test-info p {
    margin: 10px 0;
    color: rgba(255, 255, 255, 0.95);
    font-size: 14px;
}

.test-input-group {
    display: flex;
    gap: 15px;
    justify-content: center;
    align-items: center;
    margin: 20px 0 15px;
    background: rgba(255, 255, 255, 0.15);
    padding: 15px;
    border-radius: 10px;
}

.test-input-group label {
    font-weight: 600;
    color: white;
}

.test-input-group input {
    width: 150px;
    padding: 8px 12px;
    border: 2px solid rgba(255, 255, 255, 0.3);
    border-radius: 8px;
    text-align: center;
    background: rgba(255, 255, 255, 0.9);
    font-weight: 600;
}

.test-input-group input:focus {
    outline: none;
    border-color: white;
    background: white;
}

.test-buttons {
    display: flex;
    gap: 10px;
    justify-content: center;
    margin-top: 15px;
    flex-wrap: wrap;
}

.test-btn {
    padding: 10px 18px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 600;
    transition: all 0.3s ease;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.test-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(0,0,0,0.15);
}

.test-btn:active {
    transform: translateY(0);
}

.test-btn.primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.test-btn.success {
    background: linear-gradient(135deg, #56ab2f 0%, #a8e063 100%);
    color: white;
}

.test-btn.info {
    background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
    color: white;
}

.test-btn.danger {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    color: white;
}

.test-btn.warning {
    background: linear-gradient(135deg, #FFD89B 0%, #FF9A56 100%);
    color: white;
}

/* 테스트 로그 */
.test-log {
    background: #1e1e1e;
    border: 2px solid #333;
    padding: 15px;
    margin: 20px auto;
    border-radius: 10px;
    max-height: 300px;
    overflow-y: auto;
    font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
    font-size: 12px;
    max-width: 800px;
    box-shadow: inset 0 2px 10px rgba(0,0,0,0.3);
}

.test-log .log-entry {
    padding: 6px 8px;
    margin: 3px 0;
    border-left: 3px solid #4facfe;
    padding-left: 12px;
    color: #e0e0e0;
    line-height: 1.4;
}

.test-log .log-success {
    border-left-color: #56ab2f;
    color: #a8e063;
    background: rgba(86, 171, 47, 0.1);
}

.test-log .log-error {
    border-left-color: #f5576c;
    color: #ff8a9b;
    background: rgba(245, 87, 108, 0.1);
}

.test-log .log-warning {
    border-left-color: #FFD89B;
    color: #FFE4B3;
    background: rgba(255, 216, 155, 0.1);
}

.test-log .log-info {
    border-left-color: #4facfe;
    color: #8dd0ff;
    background: rgba(79, 172, 254, 0.1);
}

/* 댓글 헤더 */
.comment-header { 
    display: flex; 
    justify-content: space-between; 
    align-items: center;
    padding: 20px 24px 16px; 
    border-bottom: 2px solid #f0f0f0;
}

.comment-stats {
    display: flex;
    gap: 20px;
    align-items: center;
}

.stat-item {
    display: flex;
    align-items: center;
    gap: 6px;
    color: #666;
    font-size: 14px;
}

.stat-icon {
    font-size: 16px;
}

/* 댓글 목록 */
#commentList {
    padding: 0;
    background: white;
}

.comment-item { 
    background: white; 
    padding: 15px 24px;
    border-bottom: 1px solid #f5f5f5;
    transition: background 0.2s;
    position: relative;
}

.comment-item:hover {
    background: #fafafa;
}

.comment-item-header { 
    display: flex; 
    justify-content: space-between; 
    align-items: flex-start;
    margin-bottom: 10px; 
}

.comment-author { 
    display: flex; 
    align-items: flex-start;
    gap: 12px;
    flex: 1;
}

.profile-img {
    width: 42px;
    height: 42px;
    border-radius: 50%;
    object-fit: cover;
    flex-shrink: 0;
    border: 2px solid #e0e0e0;
}

.comment-main-content {
    flex: 1;
    min-width: 0;
}

.author-info {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 8px;
}

.author-name { 
    font-weight: 700; 
    font-size: 14px; 
    color: #333;
}

.comment-content { 
    margin: 0;
    line-height: 1.6; 
    white-space: pre-wrap; 
    word-break: break-word;
    color: #444;
    font-size: 14px;
}

.comment-image {
    margin-top: 12px;
    max-width: 100%;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.comment-time { 
    font-size: 12px; 
    color: #999; 
    margin-right: 8px;
}

/* 더보기 메뉴 */
.comment-more-menu {
    position: absolute;
    right: 10px;
    top: 10px;
}

.btn-more {
    background: none;
    border: none;
    cursor: pointer;
    padding: 6px 10px;
    color: #d0d0d0;
    font-size: 22px;
    line-height: 1;
    border-radius: 6px;
    transition: all 0.2s;
}

.btn-more:hover {
    color: #666;
    background: #f0f0f0;
}

.dropdown-menu {
    display: none;
    position: absolute;
    right: 0;
    top: 100%;
    background: white;
    border: 1px solid #e0e0e0;
    border-radius: 10px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.15);
    min-width: 120px;
    z-index: 1000;
    margin-top: 6px;
    overflow: hidden;
}

.dropdown-menu.show {
    display: block;
    animation: dropdownFadeIn 0.2s ease;
}

@keyframes dropdownFadeIn {
    from {
        opacity: 0;
        transform: translateY(-10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.dropdown-item {
    padding: 12px 18px;
    cursor: pointer;
    border: none;
    background: none;
    width: 100%;
    text-align: left;
    font-size: 13px;
    color: #333;
    transition: background 0.2s;
    font-weight: 500;
}

.dropdown-item:hover {
    background: #f8f8f8;
}

.dropdown-item.danger {
    color: #f5576c;
}

.dropdown-item.danger:hover {
    background: #fff0f2;
}

/* 수정 모드 */
.comment-edit-form {
    margin-top: 10px;
}

.comment-textarea {
    width: 100%;
    min-height: 80px;
    padding: 12px;
    border: 2px solid #4facfe;
    border-radius: 8px;
    font-size: 14px;
    font-family: inherit;
    resize: vertical;
}

.comment-textarea:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(79, 172, 254, 0.1);
}

.edit-actions {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    margin-top: 10px;
}

.btn-cancel-edit {
    padding: 8px 16px;
    background: #868f96;
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 600;
}

.btn-cancel-edit:hover {
    background: #6c757d;
}

.btn-save-edit {
    padding: 8px 16px;
    background: #4facfe;
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 600;
}

.btn-save-edit:hover {
    background: #667eea;
}

.loading, .empty-state { 
    text-align: center; 
    padding: 80px 20px; 
    color: #aaa; 
    font-size: 14px;
    background: white;
}

/* 댓글 작성 폼 */
.comment-write-form { 
    padding: 24px;
    background: #fafbfc;
    border-top: 2px solid #f0f0f0;
}

.write-form-header {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 14px;
}

.write-form-header .profile-img {
    width: 32px;
    height: 32px;
}

.write-form-header .author-name {
    font-weight: 700;
    font-size: 14px;
    color: #333;
}

#commentContent { 
    width: 100%; 
    min-height: 90px; 
    padding: 14px 16px; 
    border: 2px solid #e8e8e8; 
    border-radius: 10px; 
    resize: vertical; 
    font-size: 14px;
    line-height: 1.6;
    font-family: inherit;
    background: white;
}

#commentContent:focus {
    outline: none;
    border-color: #56ab2f;
    box-shadow: 0 0 0 3px rgba(86, 171, 47, 0.1);
}

#commentContent::placeholder {
    color: #bbb;
}

.comment-write-actions { 
    display: flex; 
    justify-content: space-between; 
    align-items: center;
    margin-top: 14px; 
}

.char-count { 
    color: #999; 
    font-size: 12px;
    margin-left: auto;
    margin-right: 14px;
    font-weight: 500;
}

.btn-submit { 
    padding: 12px 28px; 
    background: linear-gradient(135deg, #56ab2f 0%, #a8e063 100%);
    color: white; 
    border: none; 
    border-radius: 8px; 
    cursor: pointer; 
    font-size: 14px;
    font-weight: 700;
    transition: all 0.3s;
    box-shadow: 0 4px 10px rgba(86, 171, 47, 0.3);
}

.btn-submit:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 15px rgba(86, 171, 47, 0.4);
}

.btn-submit:disabled {
    background: #e0e0e0;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
}

/* 상태 표시 */
.status-badge {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 700;
    margin-left: 6px;
}

.status-badge.enabled {
    background: linear-gradient(135deg, #56ab2f 0%, #a8e063 100%);
    color: white;
}

.status-badge.author {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.status-badge.edited {
    background: #FFD89B;
    color: #333;
}
</style>
</head>
<body>
    <!-- 테스트 정보 패널 -->
    <div class="test-info">
        <h3>🧪 댓글 시스템 완전 테스트 (Comments DTO)</h3>
        <p>
            <strong>활성화된 기능:</strong> 
            <span class="status-badge enabled">LIST</span>
            <span class="status-badge enabled">WRITE</span>
            <span class="status-badge enabled">UPDATE</span>
            <span class="status-badge enabled">DELETE</span>
        </p>
        <div class="test-input-group">
            <label>📌 게시글 ID (postId):</label>
            <input type="number" id="testPostId" value="1">
        </div>
        <p style="color: rgba(255,255,255,0.9); font-size: 13px; margin: 10px 0 0 0;">
            ✅ 현재 로그인: <c:if test="${not empty sessionScope.userId}">${sessionScope.userId}</c:if><c:if test="${empty sessionScope.userId}">없음 (test-login.jsp에서 로그인 필요)</c:if>
        </p>
        <p style="color: rgba(255,255,255,0.8); font-size: 12px; margin: 5px 0 0 0;">
            💡 로그인하려면 <a href="<c:url value='/test-login.jsp'/>" style="color: #FFE4B3; text-decoration: underline;">test-login.jsp</a>로 이동하세요
        </p>
        <div class="test-buttons">
            <button class="test-btn primary" onclick="testReloadAll()">🔄 새로고침</button>
            <button class="test-btn success" onclick="testQuickWrite()">✏️ 빠른 작성</button>
            <button class="test-btn info" onclick="testEditMode()">🔧 수정 안내</button>
            <button class="test-btn danger" onclick="testDeleteMode()">🗑️ 삭제 안내</button>
            <button class="test-btn warning" onclick="clearTestLog()">🧹 로그 초기화</button>
        </div>
    </div>

    <!-- 테스트 로그 -->
    <div class="test-log" id="testLog">
        <div class="log-entry">✅ 테스트 로그 준비 완료...</div>
    </div>

    <!-- 댓글 영역 -->
    <div class="comment-container">
        <!-- 댓글 통계 -->
        <div class="comment-header">
            <div class="comment-stats">
                <div class="stat-item">
                    <span class="stat-icon">💬</span>
                    <span>댓글 <strong id="commentTotalCount">0</strong></span>
                </div>
            </div>
            
            <div style="font-size: 12px; color: #999;">최신순 (고정)</div>
        </div>
        
        <!-- 댓글 목록 -->
        <div id="commentList">
            <div class="loading">댓글을 불러오는 중...</div>
        </div>
        
        <!-- 댓글 작성 폼 -->
        <div class="comment-write-form">
            <div class="write-form-header">
                <img src="${pageContext.request.contextPath}/images/default-avatar.png" 
                     alt="프로필" class="profile-img">
                <span class="author-name">테스트 사용자</span>
            </div>
            <textarea id="commentContent" placeholder="댓글을 입력하세요..." maxlength="300"></textarea>
            <div class="comment-write-actions">
                <span class="char-count"><span id="currentLength">0</span> / 300</span>
                <button class="btn-submit" onclick="writeComment()">✅ 댓글 작성</button>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        var POST_ID = 1;

        jQuery(document).ready(function() {
            POST_ID = parseInt(jQuery('#testPostId').val());
            
            addTestLog('✅ 테스트 시스템 초기화 완료', 'success');
            addTestLog('📍 게시글 ID: ' + POST_ID);
            addTestLog('🎯 전체 기능: LIST, WRITE, UPDATE, DELETE', 'info');
            addTestLog('💡 세션 기반 인증 (test-login.jsp에서 로그인)', 'info');
            
            loadCommentList();
            
            jQuery('#commentContent').on('input', function() {
                var len = jQuery(this).val().length;
                jQuery('#currentLength').text(len);
                if (len > 300) {
                    jQuery(this).val(jQuery(this).val().substring(0, 300));
                    jQuery('#currentLength').text(300);
                }
            });
            
            jQuery('#testPostId').on('change', function() {
                POST_ID = parseInt(jQuery(this).val());
                addTestLog('📌 게시글 ID 변경: ' + POST_ID, 'warning');
                testReloadAll();
            });
        });

        function addTestLog(message, type) {
            var logClass = type === 'success' ? 'log-success' : 
                          (type === 'error' ? 'log-error' : 
                          (type === 'warning' ? 'log-warning' : 
                          (type === 'info' ? 'log-info' : '')));
            var timestamp = new Date().toLocaleTimeString();
            var logEntry = '<div class="log-entry ' + logClass + '">[' + timestamp + '] ' + message + '</div>';
            jQuery('#testLog').append(logEntry);
            
            var logDiv = document.getElementById('testLog');
            logDiv.scrollTop = logDiv.scrollHeight;
        }

        function clearTestLog() {
            jQuery('#testLog').html('<div class="log-entry">🧹 로그 초기화됨</div>');
            addTestLog('테스트 로그가 초기화되었습니다');
        }

        function testReloadAll() {
            addTestLog('=== 🔄 전체 새로고침 시작 ===', 'warning');
            loadCommentList();
        }

        function testQuickWrite() {
            var testTexts = [
                '테스트 댓글입니다.',
                '댓글 작성 테스트 중!',
                'Comments DTO 완전 테스트 ✅',
                '자동 생성 테스트 댓글',
                '모든 기능 정상 작동 확인'
            ];
            
            var randomText = testTexts[Math.floor(Math.random() * testTexts.length)];
            var timestamp = new Date().toLocaleTimeString();
            var fullText = randomText + ' (' + timestamp + ')';
            
            jQuery('#commentContent').val(fullText);
            jQuery('#currentLength').text(fullText.length);
            
            addTestLog('⚡ 빠른 작성: ' + fullText, 'warning');
            
            setTimeout(function() {
                writeComment();
            }, 500);
        }

        function testEditMode() {
            alert('✅ 수정 모드 사용법\n\n1. 내 댓글의 "⋮" 버튼 클릭\n2. "수정" 선택\n3. 내용 변경 후 "수정 완료"');
        }

        function testDeleteMode() {
            alert('✅ 삭제 모드 사용법\n\n1. 내 댓글의 "⋮" 버튼 클릭\n2. "삭제" 선택\n3. 확인 버튼 클릭');
        }

        /**
         * ✅ 댓글 목록 조회
         */
        function loadCommentList() {
            addTestLog('--- 📋 댓글 목록 조회 ---');
            
            jQuery.ajax({
                url: '${pageContext.request.contextPath}/CommentsList.async',
                type: 'GET',
                dataType: 'json',
                data: {
                    postId: POST_ID,
                    pageno: 1
                },
                beforeSend: function() {
                    addTestLog('📡 URL: /CommentsList.async');
                    addTestLog('📤 postId=' + POST_ID);
                    jQuery('#commentList').html('<div class="loading">댓글을 불러오는 중...</div>');
                },
                success: function(response) {
                    addTestLog('✅ 목록 조회 성공!', 'success');
                    
                    if (response.ok) {
                        addTestLog('📊 총 ' + response.total + '개 댓글', 'success');
                        
                        displayCommentList(response.items || []);
                        jQuery('#commentTotalCount').text(response.total);
                    } else {
                        addTestLog('❌ ' + (response.error || '알 수 없는 오류'), 'error');
                        jQuery('#commentList').html('<div class="empty-state">' + (response.error || '오류 발생') + '</div>');
                    }
                },
                error: function(xhr, status, error) {
                    addTestLog('❌ Ajax 에러!', 'error');
                    addTestLog('상태: ' + status + ', 에러: ' + error, 'error');
                    addTestLog('응답: ' + xhr.responseText, 'error');
                    jQuery('#commentList').html('<div class="empty-state">서버 오류: ' + error + '</div>');
                }
            });
        }

        /**
         * ✅ 댓글 작성
         */
        function writeComment() {
            var content = jQuery('#commentContent').val().trim();
            
            if (!content) {
                alert('댓글 내용을 입력해주세요.');
                return;
            }
            
            addTestLog('=== ✏️ 댓글 작성 시작 ===', 'warning');
            
            var requestData = {
                postId: POST_ID,
                text: content,
                imageUrl: null
            };
            
            jQuery.ajax({
                url: '${pageContext.request.contextPath}/CommentsCreate.async',
                type: 'POST',
                contentType: 'application/json; charset=UTF-8',
                dataType: 'json',
                data: JSON.stringify(requestData),
                beforeSend: function() {
                    addTestLog('📡 URL: /CommentsCreate.async');
                    addTestLog('📝 JSON body: ' + JSON.stringify(requestData));
                    
                    jQuery('.btn-submit').prop('disabled', true).text('작성 중...');
                },
                success: function(response) {
                    addTestLog('✅ 서버 응답!', 'success');
                    
                    if (response.ok) {
                        addTestLog('✅ 댓글 작성 성공! ID: ' + response.commentId, 'success');
                        
                        jQuery('#commentContent').val('');
                        jQuery('#currentLength').text('0');
                        
                        loadCommentList();
                        alert('✅ 댓글이 작성되었습니다.');
                    } else {
                        addTestLog('❌ ' + (response.error || '알 수 없는 오류'), 'error');
                        alert('❌ ' + (response.error || '알 수 없는 오류'));
                    }
                },
                error: function(xhr, status, error) {
                    addTestLog('❌ Ajax 에러!', 'error');
                    addTestLog('응답: ' + xhr.responseText, 'error');
                    alert('서버 오류: ' + error);
                },
                complete: function() {
                    jQuery('.btn-submit').prop('disabled', false).text('✅ 댓글 작성');
                }
            });
        }

        /**
         * ✅ 댓글 수정 모드
         */
        function editComment(commentId, originalContent) {
            addTestLog('=== 🔧 수정 모드 활성화 ===', 'info');
            addTestLog('📌 댓글 ID: ' + commentId, 'info');
            
            var contentDiv = jQuery('.comment-item[data-comment-id="' + commentId + '"] .comment-content');
            
            var editForm = '<div class="comment-edit-form">' +
                '<textarea class="comment-textarea" id="editContent' + commentId + '" maxlength="300">' + escapeHtml(originalContent) + '</textarea>' +
                '<div class="edit-actions">' +
                '<button class="btn-cancel-edit" onclick="cancelEdit()">취소</button>' +
                '<button class="btn-save-edit" onclick="updateComment(' + commentId + ')">수정 완료</button>' +
                '</div></div>';
            
            contentDiv.html(editForm);
            jQuery('#editContent' + commentId).focus();
            jQuery('.dropdown-menu').removeClass('show');
            
            addTestLog('✅ 수정 폼 표시', 'info');
        }

        function cancelEdit() {
            addTestLog('❌ 수정 취소', 'warning');
            loadCommentList();
        }

        /**
         * ✅ 댓글 수정
         */
        function updateComment(commentId) {
            var content = jQuery('#editContent' + commentId).val().trim();
            
            if (!content) {
                alert('댓글 내용을 입력해주세요.');
                return;
            }
            
            addTestLog('=== 🔧 댓글 수정 시작 ===', 'info');
            
            var requestData = {
                commentId: commentId,
                text: content,
                imageUrl: null
            };
            
            jQuery.ajax({
                url: '${pageContext.request.contextPath}/CommentsUpdate.async',
                type: 'POST',
                contentType: 'application/json; charset=UTF-8',
                dataType: 'json',
                data: JSON.stringify(requestData),
                beforeSend: function() {
                    addTestLog('📡 URL: /CommentsUpdate.async');
                    addTestLog('📝 JSON body: ' + JSON.stringify(requestData));
                    
                    jQuery('.btn-save-edit').prop('disabled', true).text('처리 중...');
                },
                success: function(response) {
                    addTestLog('✅ 서버 응답!', 'success');
                    
                    if (response.ok) {
                        addTestLog('✅ 댓글 수정 성공!', 'success');
                        loadCommentList();
                        alert('✅ 댓글이 수정되었습니다.');
                    } else {
                        addTestLog('❌ ' + (response.error || '알 수 없는 오류'), 'error');
                        alert('❌ ' + (response.error || '알 수 없는 오류'));
                        jQuery('.btn-save-edit').prop('disabled', false).text('수정 완료');
                    }
                },
                error: function(xhr, status, error) {
                    addTestLog('❌ Ajax 에러!', 'error');
                    addTestLog('응답: ' + xhr.responseText, 'error');
                    alert('서버 오류: ' + error);
                    jQuery('.btn-save-edit').prop('disabled', false).text('수정 완료');
                }
            });
        }

        /**
         * ✅ 댓글 삭제
         */
        function deleteComment(commentId) {
            jQuery('.dropdown-menu').removeClass('show');
            
            if (!confirm('댓글을 삭제하시겠습니까?')) {
                return;
            }
            
            addTestLog('=== 🗑️ 댓글 삭제 시작 ===', 'warning');
            
            var requestData = {
                commentId: commentId
            };
            
            jQuery.ajax({
                url: '${pageContext.request.contextPath}/CommentsDelete.async',
                type: 'POST',
                contentType: 'application/json; charset=UTF-8',
                dataType: 'json',
                data: JSON.stringify(requestData),
                beforeSend: function() {
                    addTestLog('📡 URL: /CommentsDelete.async');
                    addTestLog('📝 JSON body: ' + JSON.stringify(requestData));
                },
                success: function(response) {
                    addTestLog('✅ 서버 응답!', 'success');
                    
                    if (response.ok) {
                        addTestLog('✅ 댓글 삭제 성공!', 'success');
                        loadCommentList();
                        alert('✅ 댓글이 삭제되었습니다.');
                    } else {
                        addTestLog('❌ ' + (response.error || '알 수 없는 오류'), 'error');
                        alert('❌ ' + (response.error || '알 수 없는 오류'));
                    }
                },
                error: function(xhr, status, error) {
                    addTestLog('❌ Ajax 에러!', 'error');
                    addTestLog('응답: ' + xhr.responseText, 'error');
                    alert('서버 오류: ' + error);
                }
            });
        }

        function toggleDropdown(event, commentId) {
            event.stopPropagation();
            var dropdown = jQuery('#dropdown' + commentId);
            var isVisible = dropdown.hasClass('show');
            jQuery('.dropdown-menu').removeClass('show');
            if (!isVisible) {
                dropdown.addClass('show');
            }
        }

        /**
         * ✅ 댓글 목록 렌더링
         */
        function displayCommentList(comments) {
            var commentList = jQuery('#commentList');
            commentList.empty();
            
            if (!comments || comments.length === 0) {
                commentList.html('<div class="empty-state">첫 댓글을 작성해보세요! 📝</div>');
                return;
            }
            
            var visibleCount = 0;
            for (var i = 0; i < comments.length; i++) {
                // deleted 댓글은 표시하지 않음
                if (!comments[i].deleted) {
                    commentList.append(createCommentHtml(comments[i]));
                    visibleCount++;
                }
            }
            
            // 모든 댓글이 삭제된 경우
            if (visibleCount === 0) {
                commentList.html('<div class="empty-state">댓글이 없습니다.</div>');
            }
        }

        /**
         * ✅ 댓글 HTML 생성
         */
        function createCommentHtml(comment) {
            var contextPath = '${pageContext.request.contextPath}';
            
            var profileImgSrc = contextPath + '/images/default-avatar.png';
            var profileImg = '<img src="' + profileImgSrc + '" alt="프로필" class="profile-img">';
            
            var timeText = formatDateTime(comment.createdAt);
            
            var authorBadge = comment.author ? 
                ' <span class="status-badge author">글쓴이</span>' : '';
            
            var editedBadge = comment.edited ? 
                ' <span class="status-badge edited">수정됨</span>' : '';
            
            var actionButtons = '';
            if (comment.author) {
                actionButtons = '<div class="comment-more-menu">' +
                    '<button class="btn-more" onclick="toggleDropdown(event, ' + comment.commentId + ')">⋮</button>' +
                    '<div class="dropdown-menu" id="dropdown' + comment.commentId + '">' +
                    '<button class="dropdown-item" onclick="editComment(' + comment.commentId + ', \'' + 
                    escapeHtml(comment.text).replace(/'/g, "\\'").replace(/\n/g, "\\n") + '\')">수정</button>' +
                    '<button class="dropdown-item danger" onclick="deleteComment(' + comment.commentId + ')">삭제</button>' +
                    '</div></div>';
            }
            
            var imageHtml = '';
            if (comment.imageUrl) {
                imageHtml = '<img src="' + escapeHtml(comment.imageUrl) + '" alt="첨부 이미지" class="comment-image">';
            }
            
            return '<div class="comment-item" data-comment-id="' + comment.commentId + '">' +
                '<div class="comment-item-header">' +
                '<div class="comment-author">' +
                profileImg +
                '<div class="comment-main-content">' +
                '<div class="author-info">' +
                '<span class="author-name">사용자 ' + escapeHtml(comment.userId) + '</span>' +
                authorBadge +
                editedBadge +
                '</div>' +
                '<div class="comment-content">' + escapeHtml(comment.text) + '</div>' +
                imageHtml +
                '<span class="comment-time">' + timeText + '</span>' +
                '</div></div>' +
                actionButtons +
                '</div></div>';
        }

        function escapeHtml(text) {
            if (!text) return '';
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        function formatDateTime(dateStr) {
            if (!dateStr) return '';
            var date = new Date(dateStr);
            var year = date.getFullYear();
            var month = String(date.getMonth() + 1).padStart(2, '0');
            var day = String(date.getDate()).padStart(2, '0');
            var hours = String(date.getHours()).padStart(2, '0');
            var minutes = String(date.getMinutes()).padStart(2, '0');
            return year + '.' + month + '.' + day + ' ' + hours + ':' + minutes;
        }

        jQuery(document).on('click', function(e) {
            if (!jQuery(e.target).closest('.comment-more-menu').length) {
                jQuery('.dropdown-menu').removeClass('show');
            }
        });
    </script>
</body>
</html>