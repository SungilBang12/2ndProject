// link.js
import { isValidUrl } from "./utils.js";

export function setLink(editor) {
  const previousUrl = editor.getAttributes("link").href || "";
  const url = prompt("URL 입력", previousUrl);
  if (!url) return;

  if (!isValidUrl(url)) {
    alert("유효하지 않은 URL입니다 (http/https + 도메인 필요).");
    return;
  }

  editor.chain().focus().setLink({ href: url }).run();
}

export function unsetLink(editor) {
  editor.chain().focus().unsetLink().run();
}
