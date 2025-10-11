// utils.js
export function isValidUrl(url) {
  try {
    const parsed = new URL(url);
    return ["http:", "https:"].includes(parsed.protocol) && /\.[a-z]{2,63}$/i.test(parsed.hostname);
  } catch {
    return false;
  }
}

export function createEl(tag, attrs = {}, children = []) {
  const el = document.createElement(tag);
  Object.entries(attrs).forEach(([k, v]) => el.setAttribute(k, v));
  children.forEach(child => el.appendChild(child));
  return el;
}
