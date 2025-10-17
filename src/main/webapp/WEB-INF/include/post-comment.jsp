<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>댓글</title>
<style>
/* 기존 CSS 유지 */
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
    margin: 8px 0;
}

.comment-content .ProseMirror {
    border: none;
    padding: 0;
    background: transparent;
    min-height: auto;
    line-height: 1.6;
    word-break: break-word;
    font-size: 14px;
    color: #444;
}

.comment-content .ProseMirror p {
    margin: 0.5em 0;
}

.comment-content .ProseMirror img {
    max-width: 100%;
    border-radius: 8px;
    margin: 8px 0;
}

.comment-time { 
    font-size: 12px; 
    color: #999; 
    margin-top: 8px;
    display: inline-block;
}

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

.comment-edit-form {
    margin-top: 10px;
}

.comment-edit-toolbar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 6px;
    padding: 8px 10px;
    background: white;
    border: 1px solid #e0e0e0;
    border-bottom: none;
    border-radius: 8px 8px 0 0;
}

.comment-edit-toolbar button {
    padding: 4px 8px;
    background: white;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    cursor: pointer;
    font-size: 11px;
    font-weight: 600;
    color: #666;
    min-width: 28px;
    height: 28px;
}

.comment-edit-toolbar button:hover {
    background: #f5f5f5;
}

.comment-edit-area {
    border: 1px solid #e0e0e0;
    border-radius: 0 0 8px 8px;
    background: white;
    min-height: 100px;
    padding: 12px;
}

.comment-edit-area .ProseMirror {
    min-height: 80px;
    outline: none;
    font-size: 14px;
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

.toolbar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 6px;
    padding: 10px 12px;
    background: white;
    border: 2px solid #e8e8e8;
    border-bottom: 1px solid #e8e8e8;
    border-radius: 10px 10px 0 0;
}

.toolbar-group {
    display: flex;
    gap: 4px;
    align-items: center;
}

.toolbar-divider {
    width: 1px;
    height: 20px;
    background: #ddd;
    margin: 0 4px;
}

.toolbar-media {
    display: flex;
    gap: 4px;
    flex-wrap: wrap;
}

.toolbar-feature {
    display: inline-block;
}

.toolbar button {
    padding: 6px 10px;
    background: white;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    cursor: pointer;
    font-size: 12px;
    font-weight: 600;
    color: #666;
    transition: all 0.2s;
    min-width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.toolbar button:hover {
    background: #f5f5f5;
    border-color: #ccc;
    color: #333;
}

.toolbar button:active,
.toolbar button.is-active {
    background: #e8f4ff;
    border-color: #4facfe;
    color: #4facfe;
}

.toolbar button strong {
    font-weight: 700;
}

.toolbar button i {
    font-style: italic;
}

.toolbar button s {
    text-decoration: line-through;
}

#commentContent { 
    border: 2px solid #e8e8e8;
    border-top: none;
    border-radius: 0 0 10px 10px; 
    background: white;
    padding: 14px 16px;
    min-height: 100px;
}

#commentContent .ProseMirror {
    min-height: 80px;
    outline: none;
    font-size: 14px;
    line-height: 1.6;
}

#commentContent .ProseMirror p.is-editor-empty:first-child::before {
    content: attr(data-placeholder);
    float: left;
    color: #adb5bd;
    pointer-events: none;
    height: 0;
}

.comment-write-actions { 
    display: flex; 
    justify-content: flex-end; 
    align-items: center;
    margin-top: 14px; 
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

.status-badge {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 700;
    margin-left: 6px;
}

.status-badge.author {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.status-badge.edited {
    background: #FFD89B;
    color: #333;
}

@media (max-width: 768px) {
    .toolbar {
        gap: 4px;
        padding: 8px;
    }
    .toolbar-group {
        gap: 2px;
    }
    .toolbar button {
        padding: 6px 8px;
        font-size: 11px;
        min-width: 28px;
        height: 28px;
    }
}
</style>
</head>
<body>
    <div class="comment-container">
        <div class="comment-header">
            <div class="comment-stats">
                <div class="stat-item">
                    <span class="stat-icon">💬</span>
                    <span>댓글 <strong id="commentTotalCount">0</strong></span>
                </div>
            </div>
            <div style="font-size: 12px; color: #999;">최신순</div>
        </div>
        
        <div id="commentList">
            <div class="loading">댓글을 불러오는 중...</div>
        </div>
        
        <c:if test="${not empty sessionScope.user}">
            <div class="comment-write-form">
                <div class="write-form-header">
                    <img src="${pageContext.request.contextPath}/images/default-avatar.png" 
                         alt="프로필" class="profile-img">
                    <span class="author-name">${sessionScope.user.userId}</span>
                </div>
                
                <div id="toolbar" class="toolbar">
                    <div class="toolbar-group">
                        <button type="button" data-cmd="bold" title="굵게"><strong>B</strong></button>
                        <button type="button" data-cmd="italic" title="기울임"><i>I</i></button>
                        <button type="button" data-cmd="strike" title="취소선"><s>S</s></button>
                        <button type="button" data-cmd="underline" title="밑줄">U</button>
                        <jsp:include page="/WEB-INF/template/text-style-btn.jsp" />
                    </div>

                    <div class="toolbar-divider"></div>

                    <div class="toolbar-group toolbar-media">
                        <div class="toolbar-feature" data-feature="image">
                            <jsp:include page="/WEB-INF/include/image-modal.jsp" />
                        </div>
                        <div class="toolbar-feature" data-feature="emoji">
                            <jsp:include page="/WEB-INF/include/emoji-picker.jsp" />
                        </div>
                        <div class="toolbar-feature" data-feature="link">
                            <jsp:include page="/WEB-INF/template/link-btn.jsp" />
                        </div>
                    </div>
                </div>
                
                <div id="commentContent"></div>
                
                <div class="comment-write-actions">
                    <button class="btn-submit" onclick="writeComment()">댓글 작성</button>
                </div>
            </div>
        </c:if>
        
        <c:if test="${empty sessionScope.user}">
            <div class="comment-write-form" style="text-align: center; padding: 30px;">
                <p style="color: #999; margin-bottom: 15px;">댓글을 작성하려면 로그인이 필요합니다.</p>
                <a href="${pageContext.request.contextPath}/login.jsp" 
                   style="display: inline-block; padding: 12px 28px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-decoration: none; border-radius: 8px; font-weight: 700;">
                    로그인하기
                </a>
            </div>
        </c:if>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script type="module">
        import { initEditor } from "${pageContext.request.contextPath}/js/editor-init.js";
        import { initViewer } from "${pageContext.request.contextPath}/js/editor-view.js";
        import * as EmojiModule from "${pageContext.request.contextPath}/js/emoji.js";

        // ===== 전역 변수 =====
        window.CURRENT_USER_ID = '${sessionScope.user.userId}' || null;
        window.POST_ID = parseInt('${param.postId}') || parseInt('${postId}') || 1;

        let commentEditor = null;
        const commentViewers = new Map();
        const editEditors = new Map();
        const commentDataCache = new Map();
        
        // ✅ toolbar 템플릿을 HTML 문자열로 저장 (DOM 노드가 아닌 문자열)
        let toolbarTemplateHTML = '';

        // ===== 유틸리티 함수 =====
        
        function log(msg, data) {
            console.log(`[Comment] ${msg}`, data || '');
        }

        function logError(msg, error) {
            console.error(`[Comment ERROR] ${msg}`, error);
        }

        window.formatDateTime = function(dateStr) {
            if (!dateStr) return '';
            const date = new Date(dateStr);
            const y = date.getFullYear();
            const m = String(date.getMonth() + 1).padStart(2, '0');
            const d = String(date.getDate()).padStart(2, '0');
            const h = String(date.getHours()).padStart(2, '0');
            const mi = String(date.getMinutes()).padStart(2, '0');
            return `${y}.${m}.${d} ${h}:${mi}`;
        };

        function parseTipTapContent(contentRaw) {
            try {
                if (!contentRaw) {
                    return { type: "doc", content: [{ type: "paragraph" }] };
                }

                let outerJson = contentRaw;
                if (typeof contentRaw === 'string') {
                    outerJson = JSON.parse(contentRaw);
                }

                let textField = outerJson.text || '';

                if (typeof textField === 'string' && textField.trim()) {
                    return JSON.parse(textField);
                }

                return { type: "doc", content: [{ type: "paragraph" }] };
            } catch (error) {
                logError('parseTipTapContent 실패', error);
                return { 
                    type: "doc", 
                    content: [{ 
                        type: "paragraph", 
                        content: [{ type: "text", text: "내용을 불러올 수 없습니다." }] 
                    }] 
                };
            }
        }

        // ✅ 작성 에디터 초기화 함수
        function initWriteEditor() {
            const commentContent = document.getElementById('commentContent');
            const toolbar = document.getElementById('toolbar');
            
            if (!commentContent || !toolbar) {
                logError('작성 에디터 요소를 찾을 수 없음');
                return false;
            }

            try {
                // 기존 에디터 파괴
                if (commentEditor) {
                    try {
                        commentEditor.destroy();
                        log('기존 작성 에디터 파괴');
                    } catch (error) {
                        logError('작성 에디터 파괴 실패', error);
                    }
                }

                // 새 에디터 생성
                commentEditor = initEditor(commentContent, toolbar);
                
                // 이모지 기능 설정
                window.openEmojiPicker = EmojiModule.openPicker;
                EmojiModule.setupEmojiSuggestion(commentEditor);
                
                log('작성 에디터 초기화 완료');
                return true;
            } catch (error) {
                logError('작성 에디터 초기화 실패', error);
                return false;
            }
        }

        // ===== 초기화 =====
        
        jQuery(document).ready(function() {
            const toolbar = document.getElementById('toolbar');
            
            // ✅ toolbar HTML을 문자열로 저장
            if (toolbar) {
                toolbarTemplateHTML = toolbar.outerHTML;
            }
            
            // 작성 에디터 초기화
            initWriteEditor();
            
            loadCommentList();
        });

        // ===== 댓글 목록 =====
        
        function loadCommentList() {
            jQuery.ajax({
                url: '${pageContext.request.contextPath}/CommentsList.async',
                type: 'GET',
                dataType: 'json',
                data: {
                    postId: window.POST_ID,
                    pageno: 1
                },
                beforeSend: function() {
                    jQuery('#commentList').html('<div class="loading">댓글을 불러오는 중...</div>');
                },
                success: function(response) {
                    if (response && response.ok) {
                        displayCommentList(response.items || []);
                        jQuery('#commentTotalCount').text(response.total ?? 0);
                        
                        // ✅ 댓글 목록 로드 후 작성 에디터 상태 확인
                        setTimeout(() => {
                            if (!commentEditor || commentEditor.isDestroyed) {
                                log('작성 에디터가 손상됨. 재초기화 시도');
                                initWriteEditor();
                            }
                        }, 100);
                    } else {
                        jQuery('#commentList').html('<div class="empty-state">오류가 발생했습니다</div>');
                    }
                },
                error: function(xhr, status, error) {
                    logError('댓글 목록 로드 실패', error);
                    jQuery('#commentList').html('<div class="empty-state">댓글을 불러올 수 없습니다</div>');
                }
            });
        }

        function displayCommentList(comments) {
            const commentList = jQuery('#commentList');
            commentList.empty();
            
            // 기존 뷰어 정리
            commentViewers.forEach(viewer => {
                try {
                    viewer.destroy();
                } catch (error) {
                    logError('뷰어 파괴 실패', error);
                }
            });
            commentViewers.clear();
            
            // 기존 수정 에디터 정리
            editEditors.forEach((editor, id) => {
                try {
                    editor.destroy();
                } catch (error) {
                    logError('수정 에디터 파괴 실패', error);
                }
            });
            editEditors.clear();
            
            // 데이터 캐시 갱신
            commentDataCache.clear();
            comments.forEach(comment => {
                commentDataCache.set(comment.commentId, comment);
            });
            
            if (!comments || comments.length === 0) {
                commentList.html('<div class="empty-state">첫 댓글을 작성해보세요! 📝</div>');
                return;
            }
            
            let visibleCount = 0;
            for (let i = 0; i < comments.length; i++) {
                if (!comments[i].deleted) {
                    const commentHtml = createCommentHtml(comments[i]);
                    commentList.append(commentHtml);
                    initCommentViewer(comments[i]);
                    visibleCount++;
                }
            }
            
            if (visibleCount === 0) {
                commentList.html('<div class="empty-state">댓글이 없습니다.</div>');
            }
        }

        function createCommentHtml(comment) {
            const contextPath = '${pageContext.request.contextPath}';
            const profileImgSrc = contextPath + '/images/default-avatar.png';
            const timeText = window.formatDateTime(comment.createdAt);
            
            const isAuthor = window.CURRENT_USER_ID && comment.userId && 
                            (window.CURRENT_USER_ID === comment.userId);
            
            const authorBadge = isAuthor ? 
                ' <span class="status-badge author">글쓴이</span>' : '';
            
            const editedBadge = comment.edited ? 
                ' <span class="status-badge edited">수정됨</span>' : '';
            
            let actionButtons = '';
            
            if (isAuthor) {
                actionButtons = 
                    '<div class="comment-more-menu">' +
                    '<button class="btn-more" onclick="toggleDropdown(event, ' + comment.commentId + ')">⋮</button>' +
                    '<div class="dropdown-menu" id="dropdown' + comment.commentId + '">' +
                    '<button class="dropdown-item" onclick="startEditComment(' + comment.commentId + ')">수정</button>' +
                    '<button class="dropdown-item danger" onclick="deleteComment(' + comment.commentId + ')">삭제</button>' +
                    '</div></div>';
            }
            
            return '<div class="comment-item" data-comment-id="' + comment.commentId + '">' +
                '<div class="comment-item-header">' +
                '<div class="comment-author">' +
                '<img src="' + profileImgSrc + '" alt="프로필" class="profile-img">' +
                '<div class="comment-main-content">' +
                '<div class="author-info">' +
                '<span class="author-name">사용자 ' + comment.userId + '</span>' +
                authorBadge +
                editedBadge +
                '</div>' +
                '<div class="comment-content" id="commentContent' + comment.commentId + '"></div>' +
                '<span class="comment-time">' + timeText + '</span>' +
                '</div></div>' +
                actionButtons +
                '</div></div>';
        }

        function initCommentViewer(comment) {
            const viewerElement = document.getElementById('commentContent' + comment.commentId);
            if (!viewerElement) {
                logError('뷰어 엘리먼트를 찾을 수 없음', comment.commentId);
                return;
            }

            const doc = parseTipTapContent(comment.contentRaw);
            
            try {
                const viewer = initViewer(viewerElement, doc);
                commentViewers.set(comment.commentId, viewer);
            } catch (error) {
                logError('뷰어 초기화 실패', error);
            }
        }

        // ===== 댓글 작성 =====
        
        window.writeComment = function() {
            if (!commentEditor) {
                alert('에디터가 초기화되지 않았습니다.');
                return;
            }
            
            const content = commentEditor.getJSON();
            
            if (!content || !content.content || content.content.length === 0) {
                alert('댓글 내용을 입력해주세요.');
                return;
            }
            
            const firstBlock = content.content[0];
            if (content.content.length === 1 && 
                firstBlock.type === 'paragraph' && 
                (!firstBlock.content || firstBlock.content.length === 0)) {
                alert('댓글 내용을 입력해주세요.');
                return;
            }
            
            const requestData = {
                postId: window.POST_ID,
                text: JSON.stringify(content),
                imageUrl: null
            };
            
            jQuery.ajax({
                url: '${pageContext.request.contextPath}/CommentsCreate.async',
                type: 'POST',
                contentType: 'application/json; charset=UTF-8',
                dataType: 'json',
                data: JSON.stringify(requestData),
                beforeSend: function() {
                    jQuery('.btn-submit').prop('disabled', true).text('작성 중...');
                },
                success: function(response) {
                    if (response && response.ok) {
                        // ✅ 에디터 파괴 후 재생성
                        try {
                            commentEditor.destroy();
                        } catch (error) {
                            logError('에디터 파괴 실패', error);
                        }
                        
                        loadCommentList();
                        
                        // ✅ 댓글 목록 로드 후 에디터 재초기화
                        setTimeout(() => {
                            initWriteEditor();
                            alert('댓글이 작성되었습니다.');
                        }, 200);
                    } else {
                        alert((response && response.error) || '댓글 작성에 실패했습니다.');
                    }
                },
                error: function(xhr, status, error) {
                    logError('댓글 작성 실패', error);
                    alert('댓글 작성 중 오류가 발생했습니다.');
                },
                complete: function() {
                    jQuery('.btn-submit').prop('disabled', false).text('댓글 작성');
                }
            });
        };

        // ===== 댓글 수정 =====
        
        window.startEditComment = function(commentId) {
            log('수정 모드 진입', commentId);
            
            const comment = commentDataCache.get(commentId);
            if (!comment) {
                logError('캐시에서 댓글 데이터를 찾을 수 없음', commentId);
                alert('댓글 데이터를 불러올 수 없습니다.');
                return;
            }
            
            const contentDiv = jQuery('.comment-item[data-comment-id="' + commentId + '"] .comment-content');
            if (contentDiv.length === 0) {
                logError('댓글 컨테이너를 찾을 수 없음', commentId);
                return;
            }
            
            const parsed = parseTipTapContent(comment.contentRaw);
            log('파싱된 내용', parsed);
            
            // 기존 뷰어 제거
            const viewer = commentViewers.get(commentId);
            if (viewer) {
                try {
                    viewer.destroy();
                } catch (error) {
                    logError('뷰어 파괴 실패', error);
                }
                commentViewers.delete(commentId);
            }
            
            // ✅ HTML 문자열로 수정 폼 생성
            const editFormHTML = 
                '<div class="comment-edit-form">' +
                toolbarTemplateHTML.replace('id="toolbar"', 'id="editToolbar' + commentId + '"')
                                   .replace('class="toolbar"', 'class="comment-edit-toolbar"') +
                '<div class="comment-edit-area" id="editArea' + commentId + '"></div>' +
                '<div class="edit-actions">' +
                '<button class="btn-cancel-edit" onclick="cancelEdit(' + commentId + ')">취소</button>' +
                '<button class="btn-save-edit" onclick="saveEdit(' + commentId + ')">수정 완료</button>' +
                '</div></div>';
            
            contentDiv.html(editFormHTML);
            jQuery('.dropdown-menu').removeClass('show');
            
            // 에디터 초기화
            setTimeout(() => {
                const editArea = document.getElementById('editArea' + commentId);
                const editToolbar = document.getElementById('editToolbar' + commentId);
                
                if (!editArea || !editToolbar) {
                    logError('수정 에디터 엘리먼트를 찾을 수 없음', commentId);
                    return;
                }
                
                try {
                    const editEditor = initEditor(editArea, editToolbar);
                    editEditor.commands.setContent(parsed);
                    editEditor.commands.focus();
                    
                    // 이모지 기능 설정
                    try {
                        EmojiModule.setupEmojiSuggestion(editEditor);
                    } catch (error) {
                        logError('이모지 설정 실패', error);
                    }
                    
                    editEditors.set(commentId, editEditor);
                    
                    log('수정 에디터 초기화 완료', commentId);
                } catch (error) {
                    logError('수정 에디터 초기화 실패', error);
                    alert('에디터를 초기화할 수 없습니다.');
                }
            }, 150);
        };

        window.cancelEdit = function(commentId) {
            log('수정 취소', commentId);
            
            const editor = editEditors.get(commentId);
            if (editor) {
                try {
                    editor.destroy();
                } catch (error) {
                    logError('에디터 파괴 실패', error);
                }
                editEditors.delete(commentId);
            }
            
            loadCommentList();
        };

        window.saveEdit = function(commentId) {
            log('수정 저장 시작', commentId);
            
            const editor = editEditors.get(commentId);
            
            if (!editor) {
                logError('수정 에디터를 찾을 수 없음', commentId);
                alert('에디터가 준비되지 않았습니다.');
                return;
            }
            
            const content = editor.getJSON();
            log('저장할 내용', content);
            
            if (!content || !content.content || content.content.length === 0) {
                alert('댓글 내용을 입력해주세요.');
                return;
            }
            
            const firstBlock = content.content[0];
            if (content.content.length === 1 && 
                firstBlock.type === 'paragraph' && 
                (!firstBlock.content || firstBlock.content.length === 0)) {
                alert('댓글 내용을 입력해주세요.');
                return;
            }
            
            const requestData = {
                commentId: commentId,
                text: JSON.stringify(content),
                imageUrl: null
            };
            
            jQuery.ajax({
                url: '${pageContext.request.contextPath}/CommentsUpdate.async',
                type: 'POST',
                contentType: 'application/json; charset=UTF-8',
                dataType: 'json',
                data: JSON.stringify(requestData),
                beforeSend: function() {
                    jQuery('.btn-save-edit').prop('disabled', true).text('처리 중...');
                },
                success: function(response) {
                    if (response && response.ok) {
                        try {
                            editor.destroy();
                        } catch (error) {
                            logError('에디터 파괴 실패', error);
                        }
                        editEditors.delete(commentId);
                        
                        loadCommentList();
                        
                        // ✅ 작성 에디터 재초기화 확인
                        setTimeout(() => {
                            if (!commentEditor || commentEditor.isDestroyed) {
                                initWriteEditor();
                            }
                            alert('댓글이 수정되었습니다.');
                        }, 200);
                    } else {
                        alert((response && response.error) || '댓글 수정에 실패했습니다.');
                        jQuery('.btn-save-edit').prop('disabled', false).text('수정 완료');
                    }
                },
                error: function(xhr, status, error) {
                    logError('댓글 수정 실패', error);
                    alert('댓글 수정 중 오류가 발생했습니다.');
                    jQuery('.btn-save-edit').prop('disabled', false).text('수정 완료');
                }
            });
        };

        // ===== 댓글 삭제 =====
        
        window.deleteComment = function(commentId) {
            jQuery('.dropdown-menu').removeClass('show');
            
            if (!confirm('댓글을 삭제하시겠습니까?')) {
                return;
            }
            
            const requestData = {
                commentId: commentId
            };
            
            jQuery.ajax({
                url: '${pageContext.request.contextPath}/CommentsDelete.async',
                type: 'POST',
                contentType: 'application/json; charset=UTF-8',
                dataType: 'json',
                data: JSON.stringify(requestData),
                success: function(response) {
                    if (response && response.ok) {
                        loadCommentList();
                        alert('댓글이 삭제되었습니다.');
                    } else {
                        alert((response && response.error) || '댓글 삭제에 실패했습니다.');
                    }
                },
                error: function(xhr, status, error) {
                    logError('댓글 삭제 실패', error);
                    alert('댓글 삭제 중 오류가 발생했습니다.');
                }
            });
        };

        // ===== 드롭다운 =====
        
        window.toggleDropdown = function(event, commentId) {
            event.stopPropagation();
            const dropdown = jQuery('#dropdown' + commentId);
            const isVisible = dropdown.hasClass('show');
            jQuery('.dropdown-menu').removeClass('show');
            if (!isVisible) {
                dropdown.addClass('show');
            }
        };

        jQuery(document).on('click', function(e) {
            if (!jQuery(e.target).closest('.comment-more-menu').length) {
                jQuery('.dropdown-menu').removeClass('show');
            }
        });
    </script>
</body>
</html>