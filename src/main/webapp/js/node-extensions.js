// node-extensions.js
import { Node, mergeAttributes } from "https://esm.sh/@tiptap/core";

export const KakaoMapNode = Node.create({
  name: "kakaoMap",
  group: "block",
  atom: true,
  addAttributes() {
    return { lat: { default: 0 }, lng: { default: 0 }, id: { default: "" }, label: { default: "" } };
  },
  parseHTML() { return [{ tag: "div.kakao-map-wrapper" }]; },
  renderHTML({ node }) {
    return [
      "div",
      mergeAttributes({ class: "kakao-map-wrapper", "data-lat": node.attrs.lat, "data-lng": node.attrs.lng, id: node.attrs.id }),
      `<div class="kakao-map-container">${node.attrs.label}</div>`
    ];
  },
  addNodeView() {
    return ({ node }) => {
      // Wrapper는 TipTap drag용
      const wrapper = document.createElement("div");
      wrapper.className = "kakao-map-wrapper";
      wrapper.setAttribute("contenteditable", "false");
      wrapper.style.width = "100%";
      wrapper.style.position = "relative";
      wrapper.style.pointerEvents = "auto"; // drag 가능

      // 실제 map container
      const container = document.createElement("div");
      container.className = "kakao-map-container";
      container.style.width = "100%";
      container.style.height = "300px";
      container.style.pointerEvents = "none"; // 기본 map 이벤트 방해 안함
      container.innerHTML = node.attrs.label || "";

      wrapper.appendChild(container);
	  
	  // ghost image: 투명 img
	        wrapper.getBoundingClientRect(); // TipTap drag 초기화용
	        wrapper.addEventListener("dragstart", (event) => {
	          const ghost = document.createElement("img");
	          ghost.src = "data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs="; // 1x1 투명
	          ghost.style.width = "100%";
	          ghost.style.height = "100%";
	          event.dataTransfer.setDragImage(ghost, 0, 0);
	        });

      setTimeout(() => {
        const map = new kakao.maps.Map(container, {
          center: new kakao.maps.LatLng(node.attrs.lat, node.attrs.lng),
          level: 3,
		  scrollwheel: false,
          draggable: false, // 모달 삽입 시에는 true로 변경 가능
          disableDoubleClickZoom: false
        });

        const marker = new kakao.maps.Marker({
          position: new kakao.maps.LatLng(node.attrs.lat, node.attrs.lng),
          map
        });

        if (node.attrs.label) {
          const label = new kakao.maps.CustomOverlay({
            position: marker.getPosition(),
            content: `<div class="kakao-map-label">${node.attrs.label}</div>`,
            yAnchor: 1
          });
          label.setMap(map);
        }

        // Wrapper drag 시 map 이벤트 방해 방지
        wrapper.addEventListener("mousedown", () => {
          container.style.pointerEvents = "none";
        });
        wrapper.addEventListener("mouseup", () => {
          container.style.pointerEvents = "auto";
        });

      }, 0);

      return { dom: wrapper };
    };
  }
});
