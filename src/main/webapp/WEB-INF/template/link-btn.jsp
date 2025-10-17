<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<style>
  /* ====== 에디터 툴바 버튼 Sunset 테마 ====== */
  [data-cmd] {
    padding: 8px 16px;
    font-size: 14px;
    font-weight: 500;
    font-family: 'Noto Sans KR', -apple-system, sans-serif;
    border: 1px solid rgba(255, 139, 122, 0.3);
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
  }

  /* setLink 버튼 (주요 액션) */
  [data-cmd="setLink"] {
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8B7A 100%);
    color: #fff;
    box-shadow: 0 2px 8px rgba(255, 107, 107, 0.3);
  }

  [data-cmd="setLink"]::before {
    content: "🔗";
    margin-right: 6px;
  }

  [data-cmd="setLink"]:hover {
    background: linear-gradient(135deg, #FF8B7A 0%, #FFA07A 100%);
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.5);
    transform: translateY(-2px);
  }

  [data-cmd="setLink"]:active {
    transform: translateY(0);
    box-shadow: 0 2px 6px rgba(255, 107, 107, 0.4);
  }

  /* unsetLink 버튼 (보조 액션) */
  [data-cmd="unsetLink"] {
    background: rgba(42, 31, 26, 0.6);
    color: #e5e5e5;
    border-color: rgba(255, 139, 122, 0.2);
  }

  [data-cmd="unsetLink"]::before {
    content: "🔓";
    margin-right: 6px;
  }

  [data-cmd="unsetLink"]:hover {
    background: rgba(42, 31, 26, 0.8);
    border-color: rgba(255, 139, 122, 0.4);
    color: #FF8B7A;
    box-shadow: 0 2px 8px rgba(255, 139, 122, 0.2);
    transform: translateY(-2px);
  }

  [data-cmd="unsetLink"]:active {
    transform: translateY(0);
  }

  /* 버튼 비활성화 상태 */
  [data-cmd]:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none !important;
    box-shadow: none !important;
  }

  /* 포커스 스타일 (접근성) */
  [data-cmd]:focus-visible {
    outline: 2px solid #FF8B7A;
    outline-offset: 2px;
  }

  /* 반응형 */
  @media (max-width: 768px) {
    [data-cmd] {
      padding: 7px 12px;
      font-size: 13px;
    }
  }
</style>

<button data-cmd="setLink">Link</button>
<button data-cmd="unsetLink">Unset</button>

<script type="module">
  import * as LinkModule from "./js/link.js";
  window.setLink = LinkModule.setLink;
  window.unsetLink = LinkModule.unsetLink;
</script>