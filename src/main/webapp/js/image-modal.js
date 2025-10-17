// image-modal.js
export function openModal(editor) {
  const modal = document.createElement("div");
  modal.className = "modal";
  modal.innerHTML = `
    <div class="modal-content">
      <span class="modal-close">&times;</span>
      <h3>이미지 업로드</h3>
      <div id="dropZone" class="drop-zone">
        <p>이미지를 드래그 앤 드롭하거나 클릭하여 선택하세요</p>
        <input type="file" id="imageFile" multiple accept="image/*" style="display:none;">
      </div>
      <div id="imagePreview" class="image-preview-container"></div>
      <div class="image-size-options">
        <label><input type="radio" name="imgSize" value="100" checked> 원본</label>
        <label><input type="radio" name="imgSize" value="75"> 75%</label>
        <label><input type="radio" name="imgSize" value="50"> 50%</label>
        <label><input type="radio" name="imgSize" value="25"> 25%</label>
      </div>
      <button id="confirmImage" class="btn-primary">삽입</button>
    </div>
  `;
  document.body.appendChild(modal);
  modal.style.display = "block";

  const dropZone = modal.querySelector("#dropZone");
  const fileInput = modal.querySelector("#imageFile");
  const preview = modal.querySelector("#imagePreview");
  const files = [];

  dropZone.addEventListener("click", () => fileInput.click());

  dropZone.addEventListener("dragover", (e) => {
    e.preventDefault();
    dropZone.classList.add("drag-over");
  });

  dropZone.addEventListener("dragleave", () => {
    dropZone.classList.remove("drag-over");
  });

  dropZone.addEventListener("drop", (e) => {
    e.preventDefault();
    dropZone.classList.remove("drag-over");
    const droppedFiles = Array.from(e.dataTransfer.files).filter(f => f.type.startsWith('image/'));
    handleFiles(droppedFiles);
  });

  fileInput.addEventListener("change", (e) => {
    handleFiles(Array.from(e.target.files));
  });

  function handleFiles(selectedFiles) {
    selectedFiles.forEach(file => {
      const reader = new FileReader();
      reader.onload = evt => {
        const imgData = evt.target.result;

        const wrapper = document.createElement("div");
        wrapper.className = "image-preview-wrapper";

        const img = document.createElement("img");
        img.src = imgData;
        img.className = "image-preview";

        const removeBtn = document.createElement("button");
        removeBtn.textContent = "×";
        removeBtn.className = "remove-image-btn";
        removeBtn.onclick = () => {
          const index = files.indexOf(imgData);
          if (index > -1) files.splice(index, 1);
          wrapper.remove();
        };

        wrapper.appendChild(img);
        wrapper.appendChild(removeBtn);
        preview.appendChild(wrapper);
        files.push(imgData);
      };
      reader.readAsDataURL(file);
    });
  }

  modal.querySelector(".modal-close").onclick = () => modal.remove();

  function resizeImage(src, scale) {
    return new Promise(resolve => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        canvas.width = img.width * (scale / 100);
        canvas.height = img.height * (scale / 100);
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
        resolve(canvas.toDataURL('image/png'));
      };
      img.src = src;
    });
  }

  modal.querySelector("#confirmImage").onclick = async () => {
    const selectedSize = Number(modal.querySelector('input[name="imgSize"]:checked').value);
    if (files.length === 0) {
      alert("이미지를 선택해주세요.");
      return;
    }

    const resizedImages = await Promise.all(files.map(src => resizeImage(src, selectedSize)));

    // ✅ 현재 커서 위치 저장
    const { from } = editor.state.selection;
    const docSize = editor.state.doc.content.size;
    
    // 커서 위치가 유효하면 그 위치에, 아니면 문서 끝에 삽입
    let insertPos = from > 0 && from < docSize ? from : docSize - 1;
    
    // 이미지를 순차적으로 삽입
    resizedImages.forEach(resizedSrc => {
      editor.chain()
        .insertContentAt(insertPos, {
          type: 'image',
          attrs: { src: resizedSrc }
        })
        .run();
      
      // 다음 이미지는 현재 이미지 뒤에 삽입
      insertPos += 1;
    });
    
    // 마지막 이미지 뒤에 포커스
    editor.chain().focus(insertPos).run();
	
    modal.remove();
  };
}
