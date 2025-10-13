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
}