import { Node, mergeAttributes } from "https://esm.sh/@tiptap/core";

// ✅ 전역 ID 읽기
const userId = document.getElementById("userId")?.value || `guest-${Math.random().toString(36).substr(2, 6)}`;
const postId = document.getElementById("hiddenPostId")?.value || null;
window.userId = userId;
window.postId = postId;

// Ably 연결 대기
async function waitForAblyConnection() {
  if (!window.ably) throw new Error("Ably 미설정");
  return new Promise((resolve, reject) => {
    const check = () => {
      const state = window.ably.connection?.state;
      if (state === "connected") resolve(window.ably);
      else if (state === "failed") reject("Ably 연결 실패");
      else setTimeout(check, 150);
    };
    check();
  });
}

// Ably Presence 참가 helper
async function enterPresence(channel, userId) {
  return new Promise((resolve) => {
    channel.presence.enter({ user: userId }, () => resolve());
  });
}

// 서버 참가 요청
async function joinSchedule(postId, userId) {
  if (!postId || !userId) {
    alert("참가 정보를 확인할 수 없습니다.");
    return null;
  }
  try {
    const res = await fetch('/chat/join', {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
      body: new URLSearchParams({ postId: String(postId), userId, action: "join" }),
    });
    if (!res.ok) throw new Error(`서버 응답 오류: ${res.status}`);
    const data = await res.json();
    if (!data.success) throw new Error(data.message || "참가 실패");
    return data;
  } catch (err) {
    console.error("참가 요청 실패:", err);
    alert("참가 실패: " + (err.message || "알 수 없는 오류"));
    return null;
  }
}

// 스케줄 블록 생성
export const ScheduleBlock = Node.create({
  name: "scheduleBlock",
  group: "block",
  atom: true,
  draggable: false,
  addAttributes() {
    return {
      title: { default: "" },
      meetDate: { default: "" },
      meetTime: { default: "" },
      currentPeople: { default: 0 },
      maxPeople: { default: 2 },
      editMode: { default: false },
      postId: { default: null },
    };
  },

  addNodeView() {
    return ({ node, getPos, editor }) => {
      const dom = document.createElement("div");
      dom.className = "schedule-block";
      dom.setAttribute("contenteditable", "false");

      const { title = "미정 모임", maxPeople, currentPeople: initPeople, editMode, postId } = node.attrs;
      let currentPeople = initPeople;

      dom.innerHTML = `
        <div class="schedule-title">📅 ${title}</div>
        <div class="schedule-date">🕐 ${node.attrs.meetDate} ${node.attrs.meetTime}</div>
        <div class="schedule-info-item">👥 <span class="currentPeople">${currentPeople}</span>/${maxPeople}명 모집</div>
        <div class="schedule-btns" style="display:flex; justify-content:${editMode ? "flex-end" : "space-between"}; margin-top:5px;">
          ${!editMode ? '<button class="schedule-join-btn">참가하기</button>' : ""}
          ${editMode ? '<button class="schedule-cancel-btn btn-cancel">취소</button>' : ""}
        </div>
      `;

      const joinBtn = dom.querySelector(".schedule-join-btn");
      const cancelBtn = dom.querySelector(".schedule-cancel-btn");
      const currentPeopleSpan = dom.querySelector(".currentPeople");
      let joined = false;

      const updatePresenceCount = (membersLength) => {
        currentPeople = membersLength;
        currentPeopleSpan.textContent = currentPeople;
        document.dispatchEvent(new CustomEvent("schedulePresenceUpdate", { detail: { postId, currentPeople } }));
        if (!editMode && joinBtn) joinBtn.disabled = currentPeople >= maxPeople;
      };

      // 비동기 Ably 연결 및 Presence 처리
      (async () => {
        try {
          const ably = await waitForAblyConnection();
          const channelName = window.chatChannelName || `channel-${postId}`;
          const channel = ably.channels.get(channelName);
          window.chatChannelName = channelName;

          // 초기 참가자 수 조회
          channel.presence.get((err, members) => {
            if (!err) updatePresenceCount(members?.length || 0);
          });

          // 참가자 변화 구독
          channel.presence.subscribe(["enter", "leave"], (member) => {
            channel.presence.get((err, members) => { if (!err) updatePresenceCount(members?.length || 0); });
          });

          // EditMode이면 자동 참가
          if (editMode && !joined) {
            await enterPresence(channel, userId);
            joined = true;
          }

          // 버튼 이벤트
          joinBtn?.addEventListener("click", async (e) => {
            e.stopPropagation();
            if (joined || currentPeople >= maxPeople) return;
            const result = await joinSchedule(postId, userId);
            if (!result) return;
            await enterPresence(channel, userId);
            joined = true;
            alert(`${title} 모임에 참가했습니다!`);
          });

          cancelBtn?.addEventListener("click", (e) => {
            e.stopPropagation();
            if (!confirm("이 블록을 삭제하시겠습니까?")) return;
            const pos = getPos();
            if (pos != null) editor.view.dispatch(editor.state.tr.delete(pos, pos + node.nodeSize));
            if (joined) {
              channel.presence.leave();
              joined = false;
              updatePresenceCount(currentPeople - 1);
            }
          });

        } catch (err) {
          console.warn("Ably 연결/참가 오류:", err);
        }
      })();

      return { dom };
    };
  },
});
