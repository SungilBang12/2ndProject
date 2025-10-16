import { Node, mergeAttributes } from "https://esm.sh/@tiptap/core";
import { Plugin } from "https://esm.sh/prosemirror-state";

export const ScheduleBlock = Node.create({
	name: "scheduleBlock",
	group: "block",
	atom: true,
	draggable: false,

	addAttributes() {
		return {
			title: { default: "" },
			date: { default: "" },
			time: { default: "" },
			people: { default: 0 },
		};
	},

	addKeyboardShortcuts() {
		return {
			Backspace: ({ editor }) => {
				const { $from } = editor.state.selection;
				return $from.nodeAfter?.type.name === "scheduleBlock";
			},
			Delete: ({ editor }) => {
				const { $from } = editor.state.selection;
				return $from.nodeBefore?.type.name === "scheduleBlock";
			},
		};
	},

	addProseMirrorPlugins() {
		return [
			new Plugin({
				props: {
					handleKeyDown(view, event) {
						const { $from } = view.state.selection;

						// 노드 앞에 ScheduleBlock이 있거나, 커서가 0이면 isBeforeBlock
						const nodeAfter = $from.nodeAfter;
						const isBeforeBlock = nodeAfter?.type.name === "scheduleBlock" || $from.parentOffset === 0;

						if (isBeforeBlock) {
							// 허용 키
							if (
								event.key.startsWith("Arrow") ||
								event.key === "Tab" ||
								event.ctrlKey ||
								event.metaKey
							) return false;

							return true; // 나머지 모든 키 차단
						}

						return false; // 일반 블록 정상
					},

					handleTextInput(view, from, to, text) {
						const { $from } = view.state.selection;
						const nodeAfter = $from.nodeAfter;
						const isBeforeBlock = nodeAfter?.type.name === "scheduleBlock" || $from.parentOffset === 0;

						return isBeforeBlock; // 바로 앞 텍스트 입력 차단
					},
				},
			}),
		];
	},

	parseHTML() {
		return [{ tag: "div.schedule-block" }];
	},

	renderHTML({ HTMLAttributes }) {
		return ["div", mergeAttributes(HTMLAttributes, { class: "schedule-block" }), 0];
	},

	addNodeView() {
		return ({ node, getPos, editor }) => {
			const dom = document.createElement("div");
			dom.className = "schedule-block";
			dom.dataset.type = "schedule-block";
			dom.setAttribute("contenteditable", "false");

			dom.innerHTML = `
        <div class="schedule-title">📅 ${node.attrs.title}</div>
        <div class="schedule-date">🕐 ${node.attrs.date} ${node.attrs.time ?? ""}</div>
        <div class="schedule-info-item">👥 ${node.attrs.people}명 모집</div>
        <div class="schedule-btns">
          <button class="schedule-join-btn">참가하기</button>
          <button class="schedule-cancel-btn">취소</button>
        </div>
      `;

			// 드래그/드롭 방지
			dom.addEventListener("dragstart", e => { e.preventDefault(); e.stopPropagation(); });
			dom.addEventListener("drop", e => { e.preventDefault(); e.stopPropagation(); });
			dom.addEventListener("keydown", e => e.stopPropagation());

			// 참가 버튼
			dom.querySelector(".schedule-join-btn").addEventListener("click", e => {
				e.stopPropagation();
				alert(`'${node.attrs.title}' 모임에 참가 신청 완료!`);
			});

			// 취소 버튼
			dom.querySelector(".schedule-cancel-btn").addEventListener("click", e => {
				e.stopPropagation();
				const pos = getPos();
				if (pos != null && editor) {
					editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
				}
			});

			return { dom, contentDOM: null };
		};
	},
});
