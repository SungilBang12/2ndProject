// text-style.js

// Highlight 색상 선택기
export function openHighlightPicker(editor, buttonEl) {
  const colors = [
    { name: '노랑', value: '#ffeb3b' },
    { name: '초록', value: '#8bc34a' },
    { name: '파랑', value: '#03a9f4' },
    { name: '분홍', value: '#f48fb1' },
    { name: '주황', value: '#ff9800' },
    { name: '보라', value: '#ce93d8' },
    { name: '없음', value: null }
  ];

  const picker = document.createElement("div");
  picker.className = "color-picker-popup";
  picker.style.position = "fixed";
  picker.style.background = "white";
  picker.style.border = "1px solid #ccc";
  picker.style.borderRadius = "6px";
  picker.style.padding = "8px";
  picker.style.display = "flex";
  picker.style.flexDirection = "column";
  picker.style.gap = "4px";
  picker.style.zIndex = "10000";
  picker.style.boxShadow = "0 2px 8px rgba(0,0,0,0.15)";

  if (buttonEl) {
    const rect = buttonEl.getBoundingClientRect();
    picker.style.top = `${rect.bottom + 5}px`;
    picker.style.left = `${rect.left}px`;
  }

  colors.forEach(color => {
    const btn = document.createElement("button");
    btn.className = "color-option";
    btn.style.display = "flex";
    btn.style.alignItems = "center";
    btn.style.gap = "8px";
    btn.style.padding = "6px 12px";
    btn.style.border = "none";
    btn.style.background = "transparent";
    btn.style.cursor = "pointer";
    btn.style.borderRadius = "4px";
    btn.style.fontSize = "14px";
    btn.style.width = "100%";
    btn.style.textAlign = "left";

    if (color.value) {
      const swatch = document.createElement("span");
      swatch.style.width = "16px";
      swatch.style.height = "16px";
      swatch.style.borderRadius = "2px";
      swatch.style.background = color.value;
      swatch.style.border = "1px solid #ddd";
      btn.appendChild(swatch);
    }

    const label = document.createElement("span");
    label.textContent = color.name;
    btn.appendChild(label);

    btn.addEventListener("mouseenter", () => {
      btn.style.background = "#f0f0f0";
    });
    btn.addEventListener("mouseleave", () => {
      btn.style.background = "transparent";
    });

    btn.addEventListener("click", () => {
      if (color.value) {
        editor.chain().focus().setHighlight({ color: color.value }).run();
      } else {
        editor.chain().focus().unsetHighlight().run();
      }
      picker.remove();
    });

    picker.appendChild(btn);
  });

  document.body.appendChild(picker);

  // 외부 클릭 시 닫기
  setTimeout(() => {
    const closeHandler = (e) => {
      if (picker && !picker.contains(e.target) && e.target !== buttonEl) {
        picker.remove();
        document.removeEventListener("click", closeHandler);
      }
    };
    document.addEventListener("click", closeHandler);
  }, 0);
}

// 텍스트 스타일 조정 모달 (글자 색상, 크기 등)
export function openTextStyleModal(editor) {
  const modal = document.createElement("div");
  modal.className = "modal";
  modal.innerHTML = `
    <div class="modal-content" style="max-width: 400px;">
      <span class="modal-close">&times;</span>
      <h3>텍스트 스타일</h3>
      
      <div style="margin-bottom: 16px;">
        <label style="display: block; margin-bottom: 8px; font-weight: 500;">글자 색상</label>
        <div style="display: flex; flex-wrap: wrap; gap: 8px;" id="textColorOptions">
          <button class="color-btn" data-color="#000000" style="background: #000000;"></button>
          <button class="color-btn" data-color="#e74c3c" style="background: #e74c3c;"></button>
          <button class="color-btn" data-color="#3498db" style="background: #3498db;"></button>
          <button class="color-btn" data-color="#2ecc71" style="background: #2ecc71;"></button>
          <button class="color-btn" data-color="#f39c12" style="background: #f39c12;"></button>
          <button class="color-btn" data-color="#9b59b6" style="background: #9b59b6;"></button>
          <button class="color-btn" data-color="#95a5a6" style="background: #95a5a6;"></button>
          <button class="color-btn reset-btn" data-color="reset">초기화</button>
        </div>
      </div>

      <div style="margin-bottom: 16px;">
        <label style="display: block; margin-bottom: 8px; font-weight: 500;">글자 크기</label>
        <div style="display: flex; gap: 8px;" id="fontSizeOptions">
          <button class="size-btn" data-size="12px">12px</button>
          <button class="size-btn" data-size="14px">14px</button>
          <button class="size-btn" data-size="16px">16px</button>
          <button class="size-btn" data-size="18px">18px</button>
          <button class="size-btn" data-size="24px">24px</button>
          <button class="size-btn" data-size="32px">32px</button>
        </div>
      </div>

      <div style="margin-bottom: 16px;">
        <label style="display: block; margin-bottom: 8px; font-weight: 500;">배경 색상</label>
        <div style="display: flex; flex-wrap: wrap; gap: 8px;" id="bgColorOptions">
          <button class="color-btn" data-bgcolor="#ffeb3b" style="background: #ffeb3b;"></button>
          <button class="color-btn" data-bgcolor="#8bc34a" style="background: #8bc34a;"></button>
          <button class="color-btn" data-bgcolor="#03a9f4" style="background: #03a9f4;"></button>
          <button class="color-btn" data-bgcolor="#f48fb1" style="background: #f48fb1;"></button>
          <button class="color-btn" data-bgcolor="#ff9800" style="background: #ff9800;"></button>
          <button class="color-btn" data-bgcolor="#ce93d8" style="background: #ce93d8;"></button>
          <button class="color-btn reset-btn" data-bgcolor="reset">초기화</button>
        </div>
      </div>

      <button id="closeTextStyleModal" class="btn-primary" style="width: 100%;">닫기</button>
    </div>
  `;
  document.body.appendChild(modal);
  modal.style.display = "block";

  // 스타일 추가
  const style = document.createElement('style');
  style.textContent = `
    .color-btn {
      width: 32px;
      height: 32px;
      border: 2px solid #ddd;
      border-radius: 4px;
      cursor: pointer;
      transition: transform 0.2s, border-color 0.2s;
    }
    .color-btn:hover {
      transform: scale(1.1);
      border-color: #999;
    }
    .color-btn.reset-btn {
      background: white !important;
      width: auto;
      padding: 0 12px;
      font-size: 12px;
    }
    .size-btn {
      padding: 6px 12px;
      border: 1px solid #ddd;
      background: white;
      border-radius: 4px;
      cursor: pointer;
      font-size: 14px;
      transition: background 0.2s, border-color 0.2s;
    }
    .size-btn:hover {
      background: #f5f5f5;
      border-color: #999;
    }
  `;
  document.head.appendChild(style);

  modal.querySelector(".modal-close").onclick = () => modal.remove();
  modal.querySelector("#closeTextStyleModal").onclick = () => modal.remove();

  // 글자 색상 변경
  modal.querySelectorAll("#textColorOptions .color-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      const color = btn.dataset.color;
      if (color === "reset") {
        editor.chain().focus().unsetColor().run();
      } else {
        editor.chain().focus().setColor(color).run();
      }
    });
  });

  // 글자 크기 변경
  modal.querySelectorAll("#fontSizeOptions .size-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      const size = btn.dataset.size;
      editor.chain().focus().setMark('textStyle', { fontSize: size }).run();
    });
  });

  // 배경 색상 변경 (하이라이트)
  modal.querySelectorAll("#bgColorOptions .color-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      const bgcolor = btn.dataset.bgcolor;
      if (bgcolor === "reset") {
        editor.chain().focus().unsetHighlight().run();
      } else {
        editor.chain().focus().setHighlight({ color: bgcolor }).run();
      }
    });
  });
}