<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<button data-cmd="textStyle">TextStyle</button>
		<script type="module">
import * as TextStyleModule from "./js/text-style.js";
window.openHighlightPicker = TextStyleModule.openHighlightPicker;
window.openTextStyleModal = TextStyleModule.openTextStyleModal;
</script>