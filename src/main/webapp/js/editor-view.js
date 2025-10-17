//editor-view.js

import { Editor } from "https://esm.sh/@tiptap/core";
import StarterKit from "https://esm.sh/@tiptap/starter-kit";
import { TextStyleKit } from "https://esm.sh/@tiptap/extension-text-style";
import Highlight from "https://esm.sh/@tiptap/extension-highlight";
import { KakaoMapNode } from "./node-extensions.js";
import { ScheduleBlock } from "./schedule-block.js";
import Image from "https://esm.sh/@tiptap/extension-image";

export function initViewer(boardEl, JSONcontent) {
	const editor = new Editor({
		element: boardEl,
		editable: false, // 읽기 전용
		extensions: [
			StarterKit.configure({
				Document: false,
				// Configure an included extension
				Link: {
					openOnClick: true,
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
		content: JSONcontent,
	});
	// 읽기 전용에서도 postId 채워서 참가 버튼 활성화
	if (postId) {
		editor.state.doc.descendants((node, pos) => {
			if (node.type.name === "scheduleBlock") {
				const tr = editor.state.tr.setNodeMarkup(pos, undefined, { ...node.attrs, postId });
				editor.view.dispatch(tr);
			}
		});
	}
	return editor;
}

export function deactivateEditMode(editor) {
  editor.state.doc.descendants((node, pos) => {
    if (node.type.name === "scheduleBlock") {
      const tr = editor.state.tr.setNodeMarkup(pos, undefined, { ...node.attrs, editMode: false });
      editor.view.dispatch(tr);
    }
  });
}