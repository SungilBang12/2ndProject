<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>댓글</title>
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

/* 댓글 내용 - TipTap 뷰어 */
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

/* 댓글 Toolbar 스타일 */
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

/* 상태 표시 */
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
            
            <div style="font-size: 12px; color: #999;">최신순</div>
        </div>
        
        <!-- 댓글 목록 -->
        <div id="commentList">
            <div class="loading">댓글을 불러오는 중...</div>
        </div>
        
        <!-- 댓글 작성 폼 -->
        <c:if test="${not empty sessionScope.userId}">
            <div class="comment-write-form">
                <div class="write-form-header">
                    <img src="${pageContext.request.contextPath}/images/default-avatar.png" 
                         alt="프로필" class="profile-img">
                    <span class="author-name">${sessionScope.userId}</span>
                </div>
                
                <!-- 댓글 Toolbar -->
                <div id="toolbar" class="toolbar">
                    <!-- 기본 텍스트 스타일 -->
                    <div class="toolbar-group">
                        <button type="button" data-cmd="bold" title="굵게"><strong>B</strong></button>
                        <button type="button" data-cmd="italic" title="기울임"><i>I</i></button>
                        <button type="button" data-cmd="strike" title="취소선"><s>S</s></button>
                        <button type="button" data-cmd="underline" title="밑줄">U</button>
                        <jsp:include page="/WEB-INF/template/text-style-btn.jsp" />
                    </div>

                    <div class="toolbar-divider"></div>

                    <!-- 기능 버튼 -->
                    <div class="toolbar-group toolbar-media">
                        <!-- 이미지 -->
                        <div class="toolbar-feature" data-feature="image">
                            <jsp:include page="/WEB-INF/include/image-modal.jsp" />
                        </div>

                        <!-- 이모지 -->
                        <div class="toolbar-feature" data-feature="emoji">
                            <jsp:include page="/WEB-INF/include/emoji-picker.jsp" />
                        </div>

                        <!-- 링크 -->
                        <div class="toolbar-feature" data-feature="link">
                            <jsp:include page="/WEB-INF/template/link-btn.jsp" />
                        </div>
                    </div>
                </div>
                
                <!-- 댓글 작성 에디터 -->
                <div id="commentContent"></div>
                
                <div class="comment-write-actions">
                    <button class="btn-submit" onclick="writeComment()">댓글 작성</button>
                </div>
            </div>
        </c:if>
        
        <c:if test="${empty sessionScope.userId}">
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

        // postId를 request parameter 또는 attribute에서 가져오기
        window.POST_ID = parseInt('${param.postId}') || parseInt('${postId}') || 1;
        
        // 댓글 작성 에디터
        let commentEditor = null;
        
        // 댓글 뷰어들을 저장할 맵
        const commentViewers = new Map();

        // 유틸리티 함수들을 전역으로 선언
        window.escapeHtml = function(text) {
            if (text === null || text === undefined) return '';
            const div = document.createElement('div');
            div.textContent = String(text);
            return div.innerHTML;
        };

        // HTML 엔티티 → 실제 문자 (예: &quot; → ")
        window.htmlDecode = function(str) {
            if (str === null || str === undefined) return '';
            const div = document.createElement('div');
            div.innerHTML = String(str);
            return div.textContent || div.innerText || '';
        };

        // 평문을 TipTap 문서로 감싸기
        function toTipTapDocFromPlain(text) {
            const t = (text ?? '').toString();
            return {
                type: "doc",
                content: [{ type: "paragraph", content: t ? [{ type: "text", text: t }] : [] }]
            };
        }

        // 안전 파서: 객체/JSON/평문/HTML 모두 방어
        function safeParseTipTap(maybe) {
            // 이미 객체면 그대로
            if (maybe && typeof maybe === 'object') return maybe;

            if (typeof maybe === 'string') {
                let s = maybe.trim();

                // HTML 엔티티 복원
                if (s.includes('&quot;') || s.includes('&lt;') || s.includes('&#')) {
                    s = htmlDecode(s).trim();
                }

                // HTML 문서(로그인/에러 페이지 등) → 실패 처리
                const sLower = s.slice(0, 20).toLowerCase();
                if (sLower.startsWith('<!doctype') || sLower.startsWith('<html') || s.startsWith('<')) {
                    return null;
                }

                // JSON처럼 보이면 파싱 시도
                if (s.startsWith('{') || s.startsWith('[')) {
                    try {
                        return JSON.parse(s);
                    } catch (e) {
                        // JSON처럼 보였지만 깨짐 → 평문으로 감싸기
                        return toTipTapDocFromPlain(s);
                    }
                }

                // 완전 평문
                return toTipTapDocFromPlain(s);
            }

            // null/undefined 등
            return toTipTapDocFromPlain('');
        }

        // 수정 버튼 핸들러: data-*에서 안전하게 복원해 전달
        window.editCommentFromBtn = function(btnEl) {
            const id = parseInt(btnEl.dataset.commentId, 10);
            // data-content에는 HTML로 이스케이프되어 들어가므로 복원
            const raw = htmlDecode(btnEl.dataset.content || '');
            editComment(id, raw);
        };

        window.formatDateTime = function(dateStr) {
            if (!dateStr) return '';
            const date = new Date(dateStr);
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            const hours = String(date.getHours()).padStart(2, '0');
            const minutes = String(date.getMinutes()).padStart(2, '0');
            return year + '.' + month + '.' + day + ' ' + hours + ':' + minutes;
        };

        jQuery(document).ready(function() {
            // 댓글 작성 에디터 초기화
            const commentContent = document.getElementById('commentContent');
            const toolbar = document.getElementById('toolbar');
            
            if (commentContent && toolbar) {
                commentEditor = initEditor(commentContent, toolbar);
                
                // 이모지 기능 설정
                window.openEmojiPicker = EmojiModule.openPicker;
                EmojiModule.setupEmojiSuggestion(commentEditor);
                
                console.log('댓글 작성 에디터 초기화 완료');
            }
            
            loadCommentList();
        });

        /**
         * 댓글 목록 조회
         */
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
                success: function(response, status, xhr) {
                    // 디버깅: 응답 헤더/본문 머리 일부 로깅
                    try {
                        console.log('CommentsList.async content-type:', xhr && xhr.getResponseHeader && xhr.getResponseHeader('Content-Type'));
                        if (response && Array.isArray(response.items) && response.items.length > 0) {
                            const first = response.items[0];
                            const peek = (first.text || first.contentJson || first.contentRaw || '').toString();
                            console.log('First item head:', peek.slice(0, 120));
                        }
                    } catch(e) {}

                    if (response && response.ok) {
                        displayCommentList(response.items || []);
                        jQuery('#commentTotalCount').text(response.total ?? (response.items ? response.items.length : 0));
                    } else {
                        jQuery('#commentList').html('<div class="empty-state">' + (response?.error || '오류가 발생했습니다') + '</div>');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('댓글 목록 로드 실패:', error);
                    jQuery('#commentList').html('<div class="empty-state">댓글을 불러올 수 없습니다</div>');
                }
            });
        }

        /**
         * 댓글 작성
         */
        window.writeComment = function() {
            if (!commentEditor) {
                alert('에디터가 초기화되지 않았습니다.');
                return;
            }
            
            const content = commentEditor.getJSON();
            
            // 빈 내용 체크
            if (!content || !content.content || content.content.length === 0) {
                alert('댓글 내용을 입력해주세요.');
                return;
            }
            
            // 첫 번째 블록이 빈 paragraph인지 확인
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
                        commentEditor.commands.setContent('');
                        loadCommentList();
                        alert('댓글이 작성되었습니다.');
                    } else {
                        alert((response && response.error) || '댓글 작성에 실패했습니다.');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('댓글 작성 실패:', error);
                    alert('댓글 작성 중 오류가 발생했습니다.');
                },
                complete: function() {
                    jQuery('.btn-submit').prop('disabled', false).text('댓글 작성');
                }
            });
        }

        /**
         * 댓글 수정 모드
         * originalContent는 "문자열" (JSON 문자열/평문 모두 가능)
         */
        window.editComment = function(commentId, originalContent) {
            const contentDiv = jQuery('.comment-item[data-comment-id="' + commentId + '"] .comment-content');

            // 문자열을 안전하게 TipTap 문서로
            const parsed = safeParseTipTap(originalContent);
            if (!parsed) {
                console.error('수정 모드: 콘텐츠가 HTML 또는 비정상:', String(originalContent).slice(0,120));
                alert('댓글을 수정할 수 없습니다.');
                return;
            }
            
            // 수정 폼 생성
            const editFormId = 'editForm' + commentId;
            const editToolbarId = 'editToolbar' + commentId;
            const editAreaId = 'editArea' + commentId;
            
            const editFormHtml = 
                '<div class="comment-edit-form" id="' + editFormId + '">' +
                '<div class="comment-edit-toolbar" id="' + editToolbarId + '">' +
                '<button type="button" data-cmd="bold" title="굵게"><strong>B</strong></button>' +
                '<button type="button" data-cmd="italic" title="기울임"><i>I</i></button>' +
                '<button type="button" data-cmd="strike" title="취소선"><s>S</s></button>' +
                '</div>' +
                '<div class="comment-edit-area" id="' + editAreaId + '"></div>' +
                '<div class="edit-actions">' +
                '<button class="btn-cancel-edit" onclick="cancelEdit()">취소</button>' +
                '<button class="btn-save-edit" onclick="updateComment(' + commentId + ')">수정 완료</button>' +
                '</div></div>';
            
            contentDiv.html(editFormHtml);
            
            // 수정 에디터 초기화
            setTimeout(() => {
                const editArea = document.getElementById(editAreaId);
                const editToolbar = document.getElementById(editToolbarId);
                
                if (editArea && editToolbar) {
                    const editEditor = initEditor(editArea, editToolbar);
                    editEditor.commands.setContent(parsed);
                    
                    // 전역에 저장
                    window['editEditor' + commentId] = editEditor;
                }
            }, 50);
            
            jQuery('.dropdown-menu').removeClass('show');
        }

        window.cancelEdit = function() {
            loadCommentList();
        }

        /**
         * 댓글 수정
         */
        window.updateComment = function(commentId) {
            const editEditor = window['editEditor' + commentId];
            
            if (!editEditor) {
                alert('에디터를 찾을 수 없습니다.');
                return;
            }
            
            const content = editEditor.getJSON();
            
            // 빈 내용 체크
            if (!content || !content.content || content.content.length === 0) {
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
                        delete window['editEditor' + commentId];
                        loadCommentList();
                        alert('댓글이 수정되었습니다.');
                    } else {
                        alert((response && response.error) || '댓글 수정에 실패했습니다.');
                        jQuery('.btn-save-edit').prop('disabled', false).text('수정 완료');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('댓글 수정 실패:', error);
                    alert('댓글 수정 중 오류가 발생했습니다.');
                    jQuery('.btn-save-edit').prop('disabled', false).text('수정 완료');
                }
            });
        }

        /**
         * 댓글 삭제
         */
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
                    console.error('댓글 삭제 실패:', error);
                    alert('댓글 삭제 중 오류가 발생했습니다.');
                }
            });
        }

        window.toggleDropdown = function(event, commentId) {
            event.stopPropagation();
            const dropdown = jQuery('#dropdown' + commentId);
            const isVisible = dropdown.hasClass('show');
            jQuery('.dropdown-menu').removeClass('show');
            if (!isVisible) {
                dropdown.addClass('show');
            }
        }

        /**
         * 댓글 목록 렌더링
         */
        function displayCommentList(comments) {
            const commentList = jQuery('#commentList');
            commentList.empty();
            
            // 기존 뷰어들 정리
            commentViewers.clear();
            
            if (!comments || comments.length === 0) {
                commentList.html('<div class="empty-state">첫 댓글을 작성해보세요! 📝</div>');
                return;
            }
            
            let visibleCount = 0;
            for (let i = 0; i < comments.length; i++) {
                if (!comments[i].deleted) {
                    const commentHtml = createCommentHtml(comments[i]);
                    commentList.append(commentHtml);
                    
                    // TipTap 뷰어 초기화(안전 파서 사용)
                    initCommentViewer(comments[i]);
                    visibleCount++;
                }
            }
            
            if (visibleCount === 0) {
                commentList.html('<div class="empty-state">댓글이 없습니다.</div>');
            }
        }

        /**
         * 댓글 HTML 생성
         * - 수정 버튼: data-*로 안전하게 원문 전달
         */
        function createCommentHtml(comment) {
            const contextPath = '${pageContext.request.contextPath}';
            
            const profileImgSrc = contextPath + '/images/default-avatar.png';
            const profileImg = '<img src="' + profileImgSrc + '" alt="프로필" class="profile-img">';
            
            const timeText = window.formatDateTime(comment.createdAt);
            
            const authorBadge = comment.author ? 
                ' <span class="status-badge author">글쓴이</span>' : '';
            
            const editedBadge = comment.edited ? 
                ' <span class="status-badge edited">수정됨</span>' : '';
            
            let actionButtons = '';
            if (comment.author) {
                // 원문 후보: contentJson > text > contentRaw
                const raw = (comment.contentJson ?? comment.text ?? comment.contentRaw ?? '').toString();
                const forDataAttr = window.escapeHtml(raw); // data-*에 안전 삽입
                
                actionButtons = 
                    '<div class="comment-more-menu">' +
                    '<button class="btn-more" onclick="toggleDropdown(event, ' + comment.commentId + ')">⋮</button>' +
                    '<div class="dropdown-menu" id="dropdown' + comment.commentId + '">' +
                    '<button class="dropdown-item" data-comment-id="' + comment.commentId + '" data-content="' + forDataAttr + '" onclick="editCommentFromBtn(this)">수정</button>' +
                    '<button class="dropdown-item danger" onclick="deleteComment(' + comment.commentId + ')">삭제</button>' +
                    '</div></div>';
            }
            
            return '<div class="comment-item" data-comment-id="' + comment.commentId + '">' +
                '<div class="comment-item-header">' +
                '<div class="comment-author">' +
                profileImg +
                '<div class="comment-main-content">' +
                '<div class="author-info">' +
                '<span class="author-name">사용자 ' + window.escapeHtml(comment.userId) + '</span>' +
                authorBadge +
                editedBadge +
                '</div>' +
                '<div class="comment-content" id="commentContent' + comment.commentId + '"></div>' +
                '<span class="comment-time">' + timeText + '</span>' +
                '</div></div>' +
                actionButtons +
                '</div></div>';
        }

        /**
         * 댓글 뷰어 초기화 (핵심: 안전 파서 사용)
         */
        function initCommentViewer(comment) {
            const viewerElement = document.getElementById('commentContent' + comment.commentId);
            if (!viewerElement) {
                console.error('뷰어 엘리먼트를 찾을 수 없습니다:', comment.commentId);
                return;
            }

            // 서버가 무엇을 내려주든(현행/과거/평문/HTML) 후보를 정해 안전 파싱
            const candidate = (comment.contentJson ?? comment.text ?? comment.contentRaw ?? '').toString();
            let doc = safeParseTipTap(candidate);

            if (!doc) {
                console.error('댓글 콘텐츠가 JSON이 아닌 HTML일 가능성:', candidate.slice(0, 120));
                doc = toTipTapDocFromPlain('내용을 불러올 수 없습니다.');
            }
            
            const viewer = initViewer(viewerElement, doc);
            commentViewers.set(comment.commentId, viewer);
        }

        // 드롭다운 닫기
        jQuery(document).on('click', function(e) {
            if (!jQuery(e.target).closest('.comment-more-menu').length) {
                jQuery('.dropdown-menu').removeClass('show');
            }
        });
    </script>
</body>
</html>
