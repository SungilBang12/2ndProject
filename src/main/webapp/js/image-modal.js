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
	  <!-- 이미지 사이즈 선택 라디오 버튼 -->
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

	// 클릭으로 파일 선택
	dropZone.addEventListener("click", () => fileInput.click());

	// 드래그 앤 드롭 이벤트
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

	// 파일 선택 이벤트
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
	
	function resizeImagePromise(src, scale) {
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
	  const resizedImages = await Promise.all(files.map(src => resizeImagePromise(src, selectedSize)));

	  let chain = editor.chain().focus();
	  resizedImages.forEach(resizedSrc => {
	    chain = chain.setImage({ src: resizedSrc });
	  });
	  chain.run();

	  modal.remove();
	};
}