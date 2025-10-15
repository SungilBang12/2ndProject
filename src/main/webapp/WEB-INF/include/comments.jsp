<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="postId" value="${postId}"/>
<c:set var="sessionUserId" value="${sessionScope.userId}"/>

<link rel="stylesheet" href="${ctx}/css/style.css?v=5"/>

<div id="comments" style="margin-top:24px;">
  <h3 style="margin:0 0 12px 0;">댓글</h3>

  <c:if test="${not empty sessionUserId}">
    <form id="cmtForm" style="display:grid; gap:8px; margin-bottom:16px;">
      <div>
        <label style="font-weight:600;">이미지(선택, 1개)</label>
        <input id="cmtImage" type="url" placeholder="이미지 URL" style="width:100%;padding:8px;border:1px solid #e5e7eb;border-radius:8px;" />
        <small style="color:#666;">이미지는 1개까지만. 표시 순서: 이미지 → 텍스트</small>
      </div>
      <div>
        <label style="font-weight:600;">내용</label>
        <textarea id="cmtText" rows="3" maxlength="300" placeholder="댓글을 입력하세요 (1~300자)"
                  style="width:100%;padding:8px;border:1px solid #e5e7eb;border-radius:8px;"></textarea>
      </div>
      <div style="text-align:right;">
        <button type="button" id="cmtSubmit" style="padding:8px 12px;border:0;border-radius:8px;background:#9A5ABF;color:#fff;">등록</button>
      </div>
    </form>
  </c:if>

  <div id="cmtList" style="display:grid; gap:12px;"></div>
  <div id="cmtPager" style="margin-top:12px; display:flex; justify-content:center;">
    <div id="cmtPages"></div>
  </div>
</div>

<script>
  (function(){
    const ctx = '${ctx}';
    const postId = parseInt('${postId}');
    let pageNo = 1, pageSize = 20, total = 0;

    function fetchList(p){
      pageNo = p || 1;
      const url = new URL(ctx + '/CommentsList.async', window.location.origin);
      url.searchParams.set('postId', postId);
      url.searchParams.set('pageno', pageNo);

      fetch(url, {headers:{'Accept':'application/json'}})
        .then(r=>r.json())
        .then(d=>{
          if(!d.ok) throw new Error(d.error||'load fail');
          total = d.total; pageNo = d.pageNo; pageSize = d.pageSize;
          renderList(d.items||[]);
          renderPager();
        }).catch(err=>{
          console.error(err);
          document.getElementById('cmtList').innerHTML =
            '<div style="padding:12px;border:1px solid #eee;border-radius:8px;">댓글을 불러오지 못했습니다.</div>';
        });
    }

    function renderList(items){
      const wrap = document.getElementById('cmtList');
      if (!items.length){
        wrap.innerHTML = '<div style="padding:12px;border:1px dashed #eee;border-radius:8px;color:#666;">첫 댓글을 남겨보세요.</div>';
        return;
      }
      wrap.innerHTML = items.map(item=>{
        const isDel  = item.deleted === true;
        const isEdit = item.edited === true;
        const mine   = ('${sessionUserId}' && '${sessionUserId}' === item.userId);
        const badge  = (item.author === true) ? '<strong style="margin-left:6px;color:#9A5ABF;">글쓴이</strong>' : '';

        let html = '<div style="padding:12px;border:1px solid #eee;border-radius:8px;">';
        html += '<div style="display:flex;gap:8px;align-items:center;margin-bottom:8px;">' +
                '<span style="font-weight:700;">'+ esc(item.userId||"익명") +'</span>'+ badge +
                '<span style="margin-left:auto;color:#999;font-size:12px;">'+ (item.createdAt||'') +(isEdit?' <em>(수정됨)</em>':'') +'</span>' +
                '</div>';

        if (isDel){
          html += '<div style="color:#999;">삭제된 댓글입니다.</div>';
        }else{
          if (item.imageUrl){
            html += '<div style="margin-bottom:8px;"><img src="'+ encodeURI(item.imageUrl) +'" alt="" style="max-width:100%;border-radius:8px;"/></div>';
          }
          if (item.text){
            html += '<div style="white-space:pre-wrap;">'+ esc(item.text) +'</div>';
          }
        }

        if (mine && !isDel){
          html += '<div style="display:flex;gap:8px;justify-content:flex-end;margin-top:8px;">' +
                  '<button data-id="'+item.commentId+'" class="cmt-edit" style="padding:6px 10px;border:1px solid #ddd;border-radius:8px;background:#fff;">수정</button>' +
                  '<button data-id="'+item.commentId+'" class="cmt-del"  style="padding:6px 10px;border:1px solid #ddd;border-radius:8px;background:#fff;">삭제</button>' +
                  '</div>';
        }

        html += '</div>';
        return html;
      }).join('');
      bindButtons();
    }

    function renderPager(){
      const pageCount = Math.max(1, Math.ceil(total / pageSize));
      const el = document.getElementById('cmtPages');
      if (pageCount <= 1){ el.innerHTML=''; return; }

      let html = '';
      if (pageNo > 1) html += '<a href="#" data-p="'+(pageNo-1)+'" style="margin:0 4px;">이전</a>';
      const maxPage = Math.min(pageCount, 10);
      for(let i=1;i<=maxPage;i++){
        const active = (i===pageNo) ? ' style="font-weight:700;text-decoration:underline;margin:0 4px;"' : ' style="margin:0 4px;"';
        html += '<a href="#" data-p="'+i+'"'+active+'>'+i+'</a>';
      }
      if (pageNo < pageCount) html += '<a href="#" data-p="'+(pageNo+1)+'" style="margin:0 4px;">다음</a>';
      el.innerHTML = html;
      el.querySelectorAll('a[data-p]').forEach(a=>{
        a.addEventListener('click', function(e){
          e.preventDefault();
          fetchList(parseInt(this.getAttribute('data-p')));
        });
      });
    }

    function bindButtons(){
      document.querySelectorAll('.cmt-edit').forEach(btn=>{
        btn.addEventListener('click', ()=>{
          const id = parseInt(btn.getAttribute('data-id'));
          const text = prompt('수정할 내용을 입력(1~300자, 이미지만 유지하려면 공백)', '');
          if (text === null) return;
          const imageUrl = prompt('이미지 URL(변경 없으면 취소/공백)', '');
          update(id, text||'', imageUrl||'');
        });
      });
      document.querySelectorAll('.cmt-del').forEach(btn=>{
        btn.addEventListener('click', ()=>{
          const id = parseInt(btn.getAttribute('data-id'));
          if (!confirm('삭제하시겠습니까?')) return;
          del(id);
        });
      });
    }

    function create(){
      const text = (document.getElementById('cmtText').value||'').trim();
      const imageUrl = (document.getElementById('cmtImage').value||'').trim();
      fetch(ctx + '/CommentsCreate.async', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body: JSON.stringify({ postId, text, imageUrl })
      }).then(r=>r.json()).then(d=>{
        if(!d.ok) throw new Error(d.error||'create fail');
        document.getElementById('cmtText').value='';
        document.getElementById('cmtImage').value='';
        fetchList(1);
      }).catch(err=> alert(err.message||err));
    }

    function update(commentId, text, imageUrl){
      fetch(ctx + '/CommentsUpdate.async', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body: JSON.stringify({ commentId, text, imageUrl })
      }).then(r=>r.json()).then(d=>{
        if(!d.ok) throw new Error(d.error||'update fail');
        fetchList(pageNo);
      }).catch(err=> alert(err.message||err));
    }

    function del(commentId){
      fetch(ctx + '/CommentsDelete.async', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body: JSON.stringify({ commentId })
      }).then(r=>r.json()).then(d=>{
        if(!d.ok) throw new Error(d.error||'delete fail');
        fetchList(pageNo);
      }).catch(err=> alert(err.message||err));
    }

    const btn = document.getElementById('cmtSubmit');
    if (btn) btn.addEventListener('click', create);

    function esc(s){ return (s||'').replace(/[&<>"']/g, m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])) }

    fetchList(1);
  })();
</script>
