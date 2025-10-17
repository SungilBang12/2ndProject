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
			meetDate: { default: "" },
			meetTime: { default: "" },
			currentPeople: { default: 0 },
			maxPeople: { default: 2 },
			// 편집 모드 플래그는 Tiptap에서 필요 시 사용
			editMode: { default: false }
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

			// 편집 모드 판단: 현재 editor가 블록 수정 중이면 editMode = true
			// 블록이 포커스되면 edit 모드라고 가정
			const editMode = node.attrs.editMode === true;

			
			// Ably 구독
			if (!window.ably) console.warn("Ably 미초기화");
			const channel = window.ably?.channels.get(`schedule-${blockId}`);
			// 실시간 참가자 동기화
			channel.presence.subscribe(presence => {
				currentPeople = presence.length;
				currentPeopleSpan.textContent = currentPeople;
				if (currentPeople >= maxPeople) {
					joinBtn?.setAttribute("disabled", true);
				} else {
					joinBtn?.removeAttribute("disabled");
				}
			});
			// DOM 구성
			dom.innerHTML = `
			     <div class="schedule-title">📅 ${node.attrs.title}</div>
			     <div class="schedule-date">🕐 ${node.attrs.meetDate} ${node.attrs.meetTime}</div>
			     <div class="schedule-info-item">👥 <span class="currentPeople">${currentPeople}</span>/${maxPeople}명 모집</div>
			     <div class="schedule-btns" style="display:flex; justify-content: ${editMode ? "flex-end" : "space-between"};">
			       ${!editMode ? '<button class="schedule-join-btn">참가하기</button>' : ''}
			       <button class="schedule-cancel-btn">취소</button>
			     </div>
			`;
			const joinBtn = dom.querySelector(".schedule-join-btn");
			const cancelBtn = dom.querySelector(".schedule-cancel-btn");
			const currentPeopleSpan = dom.querySelector(".currentPeople");


			if (channel) {
				// 이미 참가 상태이면 버튼 비활성화
				let joined = false;
				channel.presence.get((err, members) => {
					if (err) return console.error(err);
					currentPeople = members.length;
					currentPeopleSpan.textContent = currentPeople;
					if (currentPeople >= maxPeople) joinBtn?.setAttribute("disabled", true);
				});
			}

			// 참가하기 버튼 이벤트 (편집 모드에서는 없음)
			if (joinBtn) {
				joinBtn.addEventListener("click", e => {
					e.stopPropagation();
					alert(`'${node.attrs.title}' 모임에 참가 신청 완료!`);
				});
			}

			// 취소 버튼
			cancelBtn.addEventListener("click", e => {
				e.stopPropagation();

				// 참가자 1명 이상(참가자가 있는 상태) 확인 필요
				const reallyDelete = currentPeople > 1
					? confirm("참가자가 1명입니다. 정말 삭제하시겠습니까?") && confirm("정말로 삭제하시겠습니까?")
					: confirm("블록을 삭제하시겠습니까?");

				if (!reallyDelete) return;

				const pos = getPos();
				if (pos != null) {
					editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
				}

				// Ably 참가 상태 제거
				if (channel) channel.presence.leave();
			});

			return { dom, contentDOM: null };
		};

		return { dom, contentDOM: null };


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
		cancelBtn.addEventListener("click", e => {
			e.stopPropagation();

			// 참가자 1명인 상태라면 두 번 확인
			const reallyDelete = currentPeople > 1
				? confirm("참가자가 존재합니다. 정말 삭제하시겠습니까?") && confirm("정말로 삭제하시겠습니까?")
				: confirm("블록을 삭제하시겠습니까?");

			if (!reallyDelete) return;

			const pos = getPos();
			if (pos != null) {
				editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
			}

			// Ably 참가 상태 제거
			if (channel) channel.presence.leave();
		});

		return { dom, contentDOM: null };
	},
})
