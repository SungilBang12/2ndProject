// emoji.js
const EMOJI_LIST = [
  "😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃",
  "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "😚", "😙",
  "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔",
  "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥",
  "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮",
  "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "😎", "🤓",
  "🧐", "😕", "😟", "🙁", "☹️", "😮", "😯", "😲", "😳", "🥺",
  "😦", "😧", "😨", "😰", "😥", "😢", "😭", "😱", "😖", "😣",
  "😞", "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬", "😈",
  "👿", "💀", "☠️", "💩", "🤡", "👹", "👺", "👻", "👽", "👾",
  "🤖", "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿", "😾",
  "👋", "🤚", "🖐️", "✋", "🖖", "👌", "🤏", "✌️", "🤞", "🤟",
  "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️", "👍", "👎",
  "✊", "👊", "🤛", "🤜", "👏", "🙌", "👐", "🤲", "🤝", "🙏",
  "✍️", "💅", "🤳", "💪", "🦾", "🦿", "🦵", "🦶", "👂", "🦻",
  "👃", "🧠", "🦷", "🦴", "👀", "👁️", "👅", "👄", "💋", "🩸"
];

let currentPicker = null;

export function openPicker(editor, buttonEl) {
  // 기존 피커가 있으면 닫기만 하고 새로 열지 않음
  if (currentPicker) {
    currentPicker.remove();
    currentPicker = null;
    return;
  }

  const picker = document.createElement("div");
  picker.className = "emoji-picker";
  picker.style.display = "grid";
  picker.style.gridTemplateColumns = "repeat(10, 1fr)";
  picker.style.gap = "4px";
  picker.style.maxWidth = "400px";
  
  EMOJI_LIST.forEach(emoji => {
    const btn = document.createElement("button");
    btn.textContent = emoji;
    btn.className = "emoji-btn";
    btn.style.fontSize = "20px";
    btn.style.padding = "8px";
    btn.style.border = "none";
    btn.style.background = "transparent";
    btn.style.cursor = "pointer";
    btn.style.borderRadius = "4px";
    btn.style.transition = "background 0.2s";
    
    btn.addEventListener("mouseenter", () => {
      btn.style.background = "#f0f0f0";
    });
    btn.addEventListener("mouseleave", () => {
      btn.style.background = "transparent";
    });
    
    btn.addEventListener("click", (e) => {
      e.stopPropagation(); // 이벤트 전파 중지
      editor.chain().focus().insertContent(emoji).run();
      // 피커는 닫지 않고 계속 사용 가능하도록 유지
    });
    
    picker.appendChild(btn);
  });

  // 버튼 위치 기준으로 피커 표시
  if (buttonEl) {
    const rect = buttonEl.getBoundingClientRect();
    picker.style.position = "fixed";
    picker.style.top = `${rect.bottom + 5}px`;
    picker.style.left = `${rect.left}px`;
  }

  document.body.appendChild(picker);
  currentPicker = picker;

  // 외부 클릭 시 닫기
  setTimeout(() => {
    document.addEventListener("click", closePickerOnClickOutside);
  }, 0);
}

function closePickerOnClickOutside(e) {
  if (currentPicker && !currentPicker.contains(e.target)) {
    currentPicker.remove();
    currentPicker = null;
    document.removeEventListener("click", closePickerOnClickOutside);
  }
}

// : 키 입력 시 이모지 제안 기능
export function setupEmojiSuggestion(editor) {
  const editorElement = editor.view.dom;
  let suggestionBox = null;

  editorElement.addEventListener("keyup", (e) => {
    const { state } = editor;
    const { selection } = state;
    const { $from } = selection;
    const textBefore = $from.parent.textContent.substring(0, $from.parentOffset);
    
    // : 키 감지
    if (textBefore.endsWith(":")) {
      showEmojiSuggestion(editor, editorElement);
    } else if (suggestionBox) {
      suggestionBox.remove();
      suggestionBox = null;
    }
  });

  function showEmojiSuggestion(editor, targetEl) {
    // 기존 제안 박스 제거
    if (suggestionBox) suggestionBox.remove();

    suggestionBox = document.createElement("div");
    suggestionBox.className = "emoji-suggestion-box";
    suggestionBox.style.position = "absolute";
    suggestionBox.style.background = "white";
    suggestionBox.style.border = "1px solid #ccc";
    suggestionBox.style.borderRadius = "6px";
    suggestionBox.style.padding = "8px";
    suggestionBox.style.display = "flex";
    suggestionBox.style.gap = "4px";
    suggestionBox.style.zIndex = "10000";
    suggestionBox.style.boxShadow = "0 2px 8px rgba(0,0,0,0.15)";

    // 자주 사용하는 이모지만 표시
    const frequentEmojis = ["😀", "😂", "😍", "👍", "🔥", "❤️", "🎉", "✨", "💯", "🙏"];
    
    frequentEmojis.forEach(emoji => {
      const btn = document.createElement("button");
      btn.textContent = emoji;
      btn.style.fontSize = "20px";
      btn.style.padding = "6px";
      btn.style.border = "none";
      btn.style.background = "transparent";
      btn.style.cursor = "pointer";
      btn.style.borderRadius = "4px";
      
      btn.addEventListener("mouseenter", () => {
        btn.style.background = "#f0f0f0";
      });
      btn.addEventListener("mouseleave", () => {
        btn.style.background = "transparent";
      });
      
      btn.addEventListener("click", () => {
        // : 문자 삭제하고 이모지 삽입
        editor.chain()
          .focus()
          .deleteRange({ from: editor.state.selection.from - 1, to: editor.state.selection.from })
          .insertContent(emoji)
          .run();
        suggestionBox.remove();
        suggestionBox = null;
      });
      
      suggestionBox.appendChild(btn);
    });

    // 커서 위치에 표시
    const coords = editor.view.coordsAtPos(editor.state.selection.from);
    suggestionBox.style.top = `${coords.bottom + 5}px`;
    suggestionBox.style.left = `${coords.left}px`;

    document.body.appendChild(suggestionBox);

    // 외부 클릭 시 닫기
    setTimeout(() => {
      document.addEventListener("click", closeSuggestionOnClickOutside);
    }, 0);
  }

  function closeSuggestionOnClickOutside(e) {
    if (suggestionBox && !suggestionBox.contains(e.target)) {
      suggestionBox.remove();
      suggestionBox = null;
      document.removeEventListener("click", closeSuggestionOnClickOutside);
    }
  }
}