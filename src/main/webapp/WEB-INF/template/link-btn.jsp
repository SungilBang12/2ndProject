<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<button data-cmd="setLink">@Link</button>
		<button data-cmd="unsetLink">Unset</button>
				<script type="module">
import * as LinkModule from "./js/link.js";
window.setLink = LinkModule.setLink;
window.unsetLink = LinkModule.unsetLink;
</script>