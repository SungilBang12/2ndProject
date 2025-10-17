<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>댓글 - Sunset Community</title>
<style>
/* ========== Sunset Theme Color Variables ========== */
:root {
    --bg-primary: #1a1a2e;
    --bg-secondary: #16213e;
    --bg-tertiary: #0f1624;
    --text-primary: #e8e8f0;
    --text-secondary: #a8a8b8;
    --text-tertiary: #7a7a8a;
    --accent-coral: #ff6b6b;
    --accent-orange: #ffa45c;
    --accent-pink: #ff6b9d;
    --accent-purple: #c44569;
    --gradient-sunset: linear-gradient(135deg, #ff6b6b 0%, #ffa45c 50%, #ff6b9d 100%);
    --gradient-dark: linear-gradient(135deg, #16213e 0%, #0f1624 100%);
    --shadow-soft: 0 8px 32px rgba(255, 107, 107, 0.15);
    --shadow-hover: 0 12px 48px rgba(255, 107, 107, 0.25);
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
    background: var(--bg-tertiary);
    background-image: 
        radial-gradient(ellipse at top, rgba(255, 107, 107, 0.1) 0%, transparent 50%),
        radial-gradient(ellipse at bottom, rgba(255, 164, 92, 0.08) 0%, transparent 50%);
    min-height: 100vh;
    padding: 20px;
    color: var(--text-primary);
}

.comment-container { 
    max-width: 900px;
    margin: 40px auto 0;
    padding: 0;
    background: rgba(22, 33, 62, 0.6);
    backdrop-filter: blur(20px);
    border-radius: 24px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
    overflow: hidden;
    border: 1px solid rgba(255, 107, 107, 0.1);
}

.comment-header { 
    display: flex; 
    justify-content: space-between; 
    align-items: center;
    padding: 24px 28px; 
    background: var(--gradient-dark);
    border-bottom: 1px solid rgba(255, 107, 107, 0.15);
}

.comment-stats {
    display: flex;
    gap: 24px;
    align-items: center;
}

.stat-item {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--text-secondary);
    font-size: 14px;
    padding: 8px 16px;
    background: rgba(255, 107, 107, 0.1);
    border-radius: 12px;
}

.stat-item .stat-icon {
    font-size: 18px;
}

.stat-item strong {
    color: var(--accent-coral);
    font-weight: 700;
}

#commentList {
    padding: 0;
    background: transparent;
}

.comment-item { 
    background: rgba(26, 26, 46, 0.4);
    padding: 20px 28px;
    border-bottom: 1px solid rgba(255, 107, 107, 0.08);
    transition: all 0.3s ease;
    position: relative;
}

.comment-item:hover {
    background: rgba(255, 107, 107, 0.05);
    transform: translateX(4px);
}

.comment-item-header { 
    display: flex; 
    justify-content: space-between; 
    align-items: flex-start;
    margin-bottom: 12px; 
}

.comment-author { 
    display: flex; 
    align-items: flex-start;
    gap: 14px;
    flex: 1;
}

.profile-img {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    object-fit: cover;
    flex-shrink: 0;
    border: 2px solid var(--accent-coral);
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
}

.comment-main-content {
    flex: 1;
    min-width: 0;
}

.author-info {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 10px;
}

.author-name { 
    font-weight: 700; 
    font-size: 15px; 
    color: var(--text-primary);
    text-shadow: 0 2px 8px rgba(255, 107, 107, 0.3);
}

.comment-content { 
    margin: 10px 0;
}

.comment-content .ProseMirror {
    border: none;
    padding: 0;
    background: transparent;
    min-height: auto;
    line-height: 1.7;
    word-break: break-word;
    font-size: 14px;
    color: var(--text-secondary);
}

.comment-content .ProseMirror p {
    margin: 0.5em 0;
}

.comment-content .ProseMirror img {
    max-width: 100%;
    border-radius: 12px;
    margin: 10px 0;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
}

.comment-time { 
    font-size: 12px; 
    color: var(--text-tertiary);
    margin-top: 10px;
    display: inline-block;
}

.comment-more-menu {
    position: absolute;
    right: 12px;
    top: 12px;
}

.btn-more {
    background: rgba(255, 107, 107, 0.1);
    border: 1px solid rgba(255, 107, 107, 0.2);
    cursor: pointer;
    padding: 6px 10px;
    color: var(--text-secondary);
    font-size: 22px;
    line-height: 1;
    border-radius: 8px;
    transition: all 0.3s ease;
}

.btn-more:hover {
    background: rgba(255, 107, 107, 0.2);
    color: var(--accent-coral);
    transform: scale(1.1);
}

.dropdown-menu {
    display: none;
    position: absolute;
    right: 0;
    top: 100%;
    background: var(--bg-secondary);
    border: 1px solid rgba(255, 107, 107, 0.2);
    border-radius: 12px;
    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.5);
    min-width: 140px;
    z-index: 1000;
    margin-top: 8px;
    overflow: hidden;
    backdrop-filter: blur(20px);
}

.dropdown-menu.show {
    display: block;
    animation: dropdownFadeIn 0.3s ease;
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
    padding: 14px 20px;
    cursor: pointer;
    border: none;
    background: transparent;
    width: 100%;
    text-align: left;
    font-size: 13px;
    color: var(--text-primary);
    transition: all 0.2s;
    font-weight: 600;
}

.dropdown-item:hover {
    background: rgba(255, 107, 107, 0.15);
}

.dropdown-item.danger {
    color: var(--accent-coral);
}

.dropdown-item.danger:hover {
    background: rgba(255, 107, 107, 0.25);
}

.comment-edit-form {
    margin-top: 12px;
}

.comment-edit-toolbar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 6px;
    padding: 10px 12px;
    background: rgba(26, 26, 46, 0.6);
    border: 1px solid rgba(255, 107, 107, 0.2);
    border-bottom: none;
    border-radius: 12px 12px 0 0;
}

.comment-edit-toolbar button {
    padding: 6px 10px;
    background: rgba(255, 107, 107, 0.1);
    border: 1px solid rgba(255, 107, 107, 0.2);
    border-radius: 6px;
    cursor: pointer;
    font-size: 11px;
    font-weight: 700;
    color: var(--text-secondary);
    min-width: 32px;
    height: 32px;
    transition: all 0.2s;
}

.comment-edit-toolbar button:hover {
    background: rgba(255, 107, 107, 0.2);
    color: var(--accent-coral);
}

.comment-edit-area {
    border: 1px solid rgba(255, 107, 107, 0.2);
    border-radius: 0 0 12px 12px;
    background: rgba(26, 26, 46, 0.4);
    min-height: 100px;
    padding: 14px;
}

.comment-edit-area .ProseMirror {
    min-height: 80px;
    outline: none;
    font-size: 14px;
    color: var(--text-secondary);
}

.edit-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 12px;
}

.btn-cancel-edit {
    padding: 10px 20px;
    background: rgba(168, 168, 184, 0.2);
    color: var(--text-primary);
    border: 1px solid rgba(168, 168, 184, 0.3);
    border-radius: 10px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 700;
    transition: all 0.3s;
}

.btn-cancel-edit:hover {
    background: rgba(168, 168, 184, 0.3);
}

.btn-save-edit {
    padding: 10px 20px;
    background: var(--gradient-sunset);
    color: white;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 700;
    box-shadow: 0 4px 16px rgba(255, 107, 107, 0.4);
    transition: all 0.3s;
}

.btn-save-edit:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 24px rgba(255, 107, 107, 0.6);
}

.loading, .empty-state { 
    text-align: center; 
    padding: 80px 20px; 
    color: var(--text-tertiary);
    font-size: 14px;
    background: transparent;
}

.comment-write-form { 
    padding: 28px;
    background: var(--gradient-dark);
    border-top: 1px solid rgba(255, 107, 107, 0.15);
}

.write-form-header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 16px;
}

.write-form-header .profile-img {
    width: 36px;
    height: 36px;
}

.write-form-header .author-name {
    font-weight: 700;
    font-size: 15px;
    color: var(--text-primary);
}

.toolbar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;
    padding: 12px 14px;
    background: rgba(26, 26, 46, 0.6);
    border: 1px solid rgba(255, 107, 107, 0.2);
    border-bottom: 1px solid rgba(255, 107, 107, 0.15);
    border-radius: 12px 12px 0 0;
    backdrop-filter: blur(10px);
}

.toolbar-group {
    display: flex;
    gap: 6px;
    align-items: center;
}

.toolbar-divider {
    width: 1px;
    height: 24px;
    background: rgba(255, 107, 107, 0.2);
    margin: 0 6px;
}

.toolbar-media {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
}

.toolbar-feature {
    display: inline-block;
}

.toolbar button {
    padding: 8px 12px;
    background: rgba(255, 107, 107, 0.1);
    border: 1px solid rgba(255, 107, 107, 0.2);
    border-radius: 8px;
    cursor: pointer;
    font-size: 12px;
    font-weight: 700;
    color: var(--text-secondary);
    transition: all 0.2s;
    min-width: 36px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.toolbar button:hover {
    background: rgba(255, 107, 107, 0.2);
    border-color: var(--accent-coral);
    color: var(--accent-coral);
    transform: translateY(-2px);
}

.toolbar button:active,
.toolbar button.is-active {
    background: rgba(255, 107, 107, 0.3);
    border-color: var(--accent-coral);
    color: var(--accent-coral);
}

#commentContent { 
    border: 1px solid rgba(255, 107, 107, 0.2);
    border-top: none;
    border-radius: 0 0 12px 12px; 
    background: rgba(26, 26, 46, 0.4);
    padding: 16px 18px;
    min-height: 120px;
    backdrop-filter: blur(10px);
}

#commentContent .ProseMirror {
    min-height: 90px;
    outline: none;
    font-size: 14px;
    line-height: 1.7;
    color: var(--text-secondary);
}

#commentContent .ProseMirror p.is-editor-empty:first-child::before {
    content: attr(data-placeholder);
    float: left;
    color: var(--text-tertiary);
    pointer-events: none;
    height: 0;
}

.comment-write-actions { 
    display: flex; 
    justify-content: flex-end; 
    align-items: center;
    margin-top: 16px; 
}

.btn-submit { 
    padding: 14px 32px; 
    background: var(--gradient-sunset);
    color: white; 
    border: none; 
    border-radius: 12px; 
    cursor: pointer; 
    font-size: 15px;
    font-weight: 700;
    transition: all 0.3s ease;
    box-shadow: var(--shadow-soft);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.btn-submit:hover {
    transform: translateY(-3px);
    box-shadow: var(--shadow-hover);
}

.btn-submit:disabled {
    background: rgba(168, 168, 184, 0.3);
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
}

.status-badge {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 14px;
    font-size: 11px;
    font-weight: 700;
    margin-left: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.status-badge.author {
    background: var(--gradient-sunset);
    color: white;
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
}

.status-badge.edited {
    background: rgba(255, 164, 92, 0.2);
    color: var(--accent-orange);
    border: 1px solid rgba(255, 164, 92, 0.3);
}

/* Login Prompt Styling */
.login-prompt {
    text-align: center;
    padding: 40px;
    background: var(--gradient-dark);
}

.login-prompt p {
    color: var(--text-secondary);
    margin-bottom: 20px;
    font-size: 15px;
}

.login-prompt a {
    display: inline-block;
    padding: 14px 32px;
    background: var(--gradient-sunset);
    color: white;
    text-decoration: none;
    border-radius: 12px;
    font-weight: 700;
    box-shadow: var(--shadow-soft);
    transition: all 0.3s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.login-prompt a:hover {
    transform: translateY(-3px);
    box-shadow: var(--shadow-hover);
}

@media (max-width: 768px) {
    .toolbar {
        gap: 4px;
        padding: 10px;
    }
    
    .toolbar-group {
        gap: 3px;
    }
    
    .toolbar button {
        padding: 6px 10px;
        font-size: 11px;
        min-width: 32px;
        height: 32px;
    }
    
    .comment-container {
        border-radius: 16px;
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
            <div style="font-size: 12px; color: var(--text-tertiary);">최신순</div>
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
            <div class="comment-write-form login-prompt">
                <p>댓글을 작성하려면 로그인이 필요합니다.</p>
                <a href="${pageContext.request.contextPath}/login.jsp">
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

        window.CURRENT_USER_ID = '${sessionScope.user.userId}' || null;
        window.POST_ID = parseInt('${param.postId}') || parseInt('${postId}') || 1;

        let commentEditor = null;
        const commentViewers = new Map();
        const editEditors = new Map();
        const commentDataCache = new Map();
        
        let toolbarTemplateHTML = '';

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

        function initWriteEditor() {
            const commentContent = document.getElementById('commentContent');
            const toolbar = document.getElementById('toolbar');
            
            if (!commentContent || !toolbar) {
                logError('작성 에디터 요소를 찾을 수 없음');
                return false;
            }

            try {
                if (commentEditor) {
                    try {
                        commentEditor.destroy();
                        log('기존 작성 에디터 파괴');
                    } catch (error) {
                        logError('작성 에디터 파괴 실패', error);
                    }
                }

                commentEditor = initEditor(commentContent, toolbar);
                
                window.openEmojiPicker = EmojiModule.openPicker;
                EmojiModule.setupEmojiSuggestion(commentEditor);
                
                log('작성 에디터 초기화 완료');
                return true;
            } catch (error) {
                logError('작성 에디터 초기화 실패', error);
                return false;
            }
        }

        jQuery(document).ready(function() {
            const toolbar = document.getElementById('toolbar');
            
            if (toolbar) {
                toolbarTemplateHTML = toolbar.outerHTML;
            }
            
            initWriteEditor();
            loadCommentList();
        });

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
            
            commentViewers.forEach(viewer => {
                try {
                    viewer.destroy();
                } catch (error) {
                    logError('뷰어 파괴 실패', error);
                }
            });
            commentViewers.clear();
            
            editEditors.forEach((editor, id) => {
                try {
                    editor.destroy();
                } catch (error) {
                    logError('수정 에디터 파괴 실패', error);
                }
            });
            editEditors.clear();
            
            commentDataCache.clear();
            comments.forEach(comment => {
                commentDataCache.set(comment.commentId, comment);
            });
            
            if (!comments || comments.length === 0) {
                commentList.html('<div class="empty-state">첫 댓글을 작성해보세요! 🌅</div>');
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
                        try {
                            commentEditor.destroy();
                        } catch (error) {
                            logError('에디터 파괴 실패', error);
                        }
                        
                        loadCommentList();
                        
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
            
            const viewer = commentViewers.get(commentId);
            if (viewer) {
                try {
                    viewer.destroy();
                } catch (error) {
                    logError('뷰어 파괴 실패', error);
                }
                commentViewers.delete(commentId);
            }
            
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