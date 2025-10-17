// editor-init.js
import { Editor } from "https://esm.sh/@tiptap/core";
import StarterKit from "https://esm.sh/@tiptap/starter-kit";
import { TextStyleKit } from "https://esm.sh/@tiptap/extension-text-style";
import Highlight from "https://esm.sh/@tiptap/extension-highlight";
import { KakaoMapNode } from "./node-extensions.js";
import Image from "https://esm.sh/@tiptap/extension-image";
import { ScheduleBlock } from "./schedule-block.js";
import { openScheduleModal } from "./schedule-modal.js";

// ✨ 제거: import { openKakaoMapModal } from "./kakaomap.js"; 
// kakaomap.js가 window.openKakaoMapModal로 직접 등록됩니다

// 🔑 [수정] 세 번째 인자 'initialContent' 추가
export function initEditor(boardEl, toolbarEl, initialContent) {
	const editor = new Editor({
		element: boardEl,
		extensions: [
			StarterKit.configure({
				Document: false,
				// Configure an included extension
				Link: {
					openOnClick: false,
					HTMLAttributes: {
						class: 'editor-link',
					},
				},
			}),
			Image,
			TextStyleKit,
			Highlight.configure({ multicolor: true }),
			KakaoMapNode,
			ScheduleBlock
		],
		// 🔑 초기 내용이 전달되면 사용하고, 아니면 기본값 "<p>에디터 시작!</p>" 사용
		content: initialContent && Object.keys(initialContent).length > 0 ? initialContent : "<p>에디터 시작!</p>",
		onUpdate: ({ editor }) => {
			updateButtonStates(editor, toolbarEl);
		},
		onSelectionUpdate: ({ editor }) => {
			updateButtonStates(editor, toolbarEl);
		}
	});
	window.openScheduleModal = openScheduleModal;
	window.currentEditor = editor;

	if (!toolbarEl) return editor;

	// 툴바 엘리먼트가 제대로 전달되었다면 querySelectorAll은 작동합니다.
	const buttons = toolbarEl.querySelectorAll("button[data-cmd]"); // [수정] data-cmd 속성 가진 버튼만 선택
	if (!buttons || buttons.length === 0) return editor;

	buttons.forEach(btn => {
		btn.addEventListener("click", () => {
			const cmd = btn.dataset.cmd;
			if (!cmd) return;
			const chain = editor.chain().focus();

			switch (cmd) {
				case "bold": chain.toggleBold().run(); break;
				case "italic": chain.toggleItalic().run(); break;
				case "strike": chain.toggleStrike().run(); break;
				case "underline": chain.toggleUnderline().run(); break;
				case "highlight": window.openHighlightPicker(editor, btn); break;
				case "textStyle": window.openTextStyleModal(editor); break;
				case "heading1": chain.toggleHeading({ level: 1 }).run(); break;
				case "heading2": chain.toggleHeading({ level: 2 }).run(); break;
				case "heading3": chain.toggleHeading({ level: 3 }).run(); break;
				case "bulletList": chain.toggleBulletList().run(); break;
				case "orderedList": chain.toggleOrderedList().run(); break;
				case "image": window.openImageModal(editor); break;
				case "kakaoMap": window.openKakaoMapModal(editor); break; // ✨ 수정: window.openKakaoMapModal 사용
				case "schedule": window.openScheduleModal(editor); break;
				case "emoji": window.openEmojiPicker(editor, btn); break;
				case "setLink": window.setLink(editor); break;
				case "unsetLink": window.unsetLink(editor); break;
			}

			updateButtonStates(editor, toolbarEl);
		});
	});

	// 초기 버튼 상태 업데이트
	updateButtonStates(editor, toolbarEl);

	return editor;
}

function updateButtonStates(editor, toolbarEl) {
	if (!toolbarEl) return;

	const buttons = toolbarEl.querySelectorAll("button[data-cmd]");

	buttons.forEach(btn => {
		const cmd = btn.dataset.cmd;
		btn.classList.remove('is-active');
		btn.disabled = false;

		switch (cmd) {
			case "bold":
				if (editor.isActive('bold')) btn.classList.add('is-active');
				break;
			case "italic":
				if (editor.isActive('italic')) btn.classList.add('is-active');
				break;
			case "strike":
				if (editor.isActive('strike')) btn.classList.add('is-active');
				break;
			case "underline":
				if (editor.isActive('underline')) btn.classList.add('is-active');
				break;
			case "highlight":
				if (editor.isActive('highlight')) btn.classList.add('is-active');
				break;
			case "heading1":
				if (editor.isActive('heading', { level: 1 })) btn.classList.add('is-active');
				break;
			case "heading2":
				if (editor.isActive('heading', { level: 2 })) btn.classList.add('is-active');
				break;
			case "heading3":
				if (editor.isActive('heading', { level: 3 })) btn.classList.add('is-active');
				break;
			case "bulletList":
				if (editor.isActive('bulletList')) btn.classList.add('is-active');
				break;
			case "orderedList":
				if (editor.isActive('orderedList')) btn.classList.add('is-active');
				break;
			case "setLink":
				if (editor.isActive('link')) {
					btn.classList.add('is-active');
				}
				break;
			case "unsetLink":
				if (!editor.isActive('link')) {
					btn.disabled = true;
				}
				break;
		}
	});
}

export function activateEditMode(editor) {
  editor.state.doc.descendants((node, pos) => {
    if (node.type.name === "scheduleBlock") {
      const tr = editor.state.tr.setNodeMarkup(pos, undefined, { ...node.attrs, editMode: true });
      editor.view.dispatch(tr);
    }
  });
}