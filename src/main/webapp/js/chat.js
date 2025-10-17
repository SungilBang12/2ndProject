/* ========================================================================
   전역 변수 및 설정
   ======================================================================== */
window.ably = window.ably || null;
let channel = null;
let participantCount = 0;
let firebaseDb = null;
let messagesRef = null;
let isMinimized = false;

const CONTEXT = window.APP_CONTEXT || "";

/* ========================================================================
   DOM 요소
   ======================================================================== */
const chatModule = document.getElementById("chatModule");
if (!chatModule) console.warn("⚠️ chatModule not found.");

const postId = chatModule?.dataset.postId || null;
const userId = chatModule?.dataset.userId;
window.userId = userId;
window.postId = postId;

const maxPeople = parseInt(chatModule?.dataset.maxPeople || "5", 10);

const $chatWidget = $("#chatWidget");
const $chatToggleBtn = $("#chatToggleBtn");
const $minimizeBtn = $("#minimizeBtn");
const $backToListBtn = $("#backToListBtn");
const $joinBtn = $("#joinBtn");
const $leaveBtn = $("#leaveBtn");
const $chatPanel = $("#chatPanel");
const $chatListPanel = $("#chatListPanel");
const $chatList = $("#chatList");
const $chatMessages = $("#chatMessages");
const $chatInput = $("#chatInput");
const $sendBtn = $("#sendBtn");
const $participantCount = $("#participantCount");

/* ========================================================================
   초기화
   ======================================================================== */
async function init() {
  if (!chatModule) return;

  $chatWidget.hide();
  $chatToggleBtn.on("click", toggleChatWidget);
  $minimizeBtn.on("click", minimizeChatWidget);
  $backToListBtn.on("click", showChatList);

  try {
    const res = await $.getJSON(`${CONTEXT}/chat/init`, { postId: postId || "" });
    const { ablyConfig, firebaseConfig, userId: serverUserId } = res;

    if (ablyConfig?.pubKey) {
      window.ably = new Ably.Realtime({ 
        key: ablyConfig.pubKey, 
        clientId: userId || serverUserId 
      });

      window.ably.connection.on("connected", async () => {
        console.log("✅ Ably 연결 성공");
        initFirebase(firebaseConfig);

        if (postId) {
          await checkUserParticipation();
        } else {
          loadChatList();
        }
      });

      window.ably.connection.on("failed", () => {
        console.error("❌ Ably 연결 실패");
        displayMessage('<div class="system-message error">Ably 연결 실패</div>');
      });
    } else console.error("❌ Ably 설정 누락");
  } catch (err) {
    console.error("❌ /chat/init 요청 실패:", err);
  }
}

/* ========================================================================
   위젯 토글/최소화
   ======================================================================== */
function toggleChatWidget() {
  if ($chatWidget.is(":visible")) $chatWidget.fadeOut(200);
  else {
    $chatWidget.fadeIn(200);
    if (isMinimized) {
      isMinimized = false;
      $chatPanel.show();
      $chatListPanel.show();
    }
  }
}

function minimizeChatWidget() {
  isMinimized = true;
  $chatPanel.hide();
  $chatListPanel.hide();
  $chatWidget.fadeOut(200);
}

/* ========================================================================
   채팅 리스트 로드
   ======================================================================== */
function loadChatList() {
  $chatListPanel.show();
  $chatPanel.hide();
  $backToListBtn.hide();

  $.getJSON(`${CONTEXT}/chat/init`, (res) => {
    const rooms = res.rooms || [];
    if (!rooms.length) {
      $chatList.html("<li class='no-rooms'>참여 가능한 채팅방이 없습니다.</li>");
      return;
    }

    const listHtml = rooms
      .map(
        (room) => `<li class="chat-room-item" data-id="${room.postId}">
            <strong>${room.title || `채팅방 #${room.postId}`}</strong><br>
            <span class="room-info">참여자: ${room.currentPeople || 0}/${room.maxPeople || 0}</span>
        </li>`
      )
      .join("");
    $chatList.html(listHtml);

    $chatList.off("click").on("click", ".chat-room-item", function () {
      const roomId = $(this).data("id");
      window.location.href = `${CONTEXT}/chat?postId=${roomId}`;
    });
  }).fail((err) => {
    console.error("❌ 채팅방 리스트 로드 실패:", err);
    $chatList.html("<li class='error-message'>리스트를 불러올 수 없습니다.</li>");
  });
}

function showChatList() {
  if (channel) {
    channel.presence.leave();
    channel.unsubscribe();
    channel.presence.unsubscribe();
    channel = null;
  }

  $chatMessages.empty();
  loadChatList();
}

/* ========================================================================
   유저 참여 확인 (postId 있을 때)
   ======================================================================== */
async function checkUserParticipation() {
  try {
    const res = await $.getJSON(`${CONTEXT}/chat/status`, { postId });
    const { joined } = res;

    await updateParticipantCount(); // DB 기준 참가자 수

    if (joined) initChatRoom();
    else {
      $chatWidget.hide();
      console.log("ℹ️ 사용자가 이 채팅방에 참여하지 않았습니다.");
    }
  } catch (err) {
    console.error("❌ 참여 상태 확인 실패:", err);
  }
}

/* ========================================================================
   채팅방 초기화
   ======================================================================== */
function initChatRoom() {
  $chatListPanel.hide();
  $chatPanel.show();
  $backToListBtn.show();

  const channelName = `channel-${postId}`;
  window.chatChannelName = channelName;

  setupChannel(channelName);
  setupJoinLeaveButtons();
}

/* ========================================================================
   Firebase 초기화
   ======================================================================== */
function initFirebase(firebaseConfig) {
  if (!firebaseConfig?.apiKey) return;

  if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);

  firebaseDb = firebase.database();
  messagesRef = firebaseDb.ref(`chat/${postId}/messages`);

  messagesRef.once("value", (snap) => {
    const messages = snap.val();
    if (messages) {
      Object.values(messages).forEach((msg) => {
        const cls = msg.user === userId ? "chat-message-mine" : "chat-message-other";
        const userName = msg.user === userId ? "나" : msg.user;
        displayMessage(`<div class="${cls}"><strong>${userName}</strong>: ${msg.text}</div>`);
      });
    }
  });

  messagesRef.on("child_added", (snap) => {
    const msg = snap.val();
    if (!msg || msg.user === userId) return;
    displayMessage(`<div class="chat-message-other"><strong>${msg.user}</strong>: ${msg.text}</div>`);
  });
}

/* ========================================================================
   Ably 채널 구독
   ======================================================================== */
function setupChannel(channelName) {
  if (!window.ably) return;

  channel = window.ably.channels.get(channelName);

  channel.subscribe("message", (msg) => {
    const mine = msg.data.user === userId;
    const cls = mine ? "chat-message-mine" : "chat-message-other";
    const userName = mine ? "나" : msg.data.user;
    displayMessage(`<div class="${cls}"><strong>${userName}</strong>: ${msg.data.text}</div>`);

    if (mine && firebaseDb) {
      firebaseDb.ref(`chat/${postId}/messages`).push({
        user: msg.data.user,
        text: msg.data.text,
        timestamp: Date.now(),
      });
    }
  });

  channel.presence.subscribe(["enter", "leave"], async (member) => {
    const actionText = member.action === "enter" ? "참가했습니다." : "퇴장했습니다.";
    displayMessage(`<div class="system-message">${member.clientId} 님이 ${actionText}</div>`);
    await updateParticipantCount(); // DB 기준 참가자 수 반영
  });

  $sendBtn.prop("disabled", false);
}

/* ========================================================================
   참가/나가기 버튼
   ======================================================================== */
function setupJoinLeaveButtons() {
  let joined = false;

  $joinBtn.off("click").on("click", async () => {
    if (joined) return;

    try {
      const res = await $.post(`${CONTEXT}/chat/update`, { postId, action: "join" });
      if (!res.chatResult?.success) {
        displayMessage(`<div class="system-message error">참가 실패: ${res.chatResult?.message}</div>`);
        return;
      }

      channel.presence.enter({ user: userId });
      joined = true;
      $joinBtn.hide();
      $leaveBtn.show();
      displayMessage('<div class="system-message">채팅방에 참가했습니다.</div>');

      await updateParticipantCount(); // DB 기준 참가자 수 반영
    } catch (err) {
      console.error("❌ 참가 요청 실패:", err);
      displayMessage('<div class="system-message error">참가 실패</div>');
    }
  });

  $leaveBtn.off("click").on("click", async () => {
    if (!joined || !channel) return;

    try {
      await $.post(`${CONTEXT}/chat/update`, { postId, action: "leave" });
      channel.presence.leave();
      joined = false;
      $chatMessages.empty();
      $joinBtn.show();
      $leaveBtn.hide();
      displayMessage('<div class="system-message">채팅방에서 나갔습니다.</div>');

      await updateParticipantCount(); // DB 기준 참가자 수 반영
    } catch (err) {
      console.error("❌ 나가기 요청 실패:", err);
    }
  });

  $sendBtn.off("click").on("click", sendMessage);
  $chatInput.off("keypress").on("keypress", (e) => { if (e.key === "Enter") sendMessage(); });
}

function sendMessage() {
  const text = $chatInput.val().trim();
  if (!text || !channel) return;
  channel.publish("message", { user: userId, text });
  $chatInput.val("").focus();
}

/* ========================================================================
   화면 업데이트
   ======================================================================== */
function displayMessage(content) {
  $chatMessages.append(content);
  $chatMessages.scrollTop($chatMessages[0].scrollHeight);
}

function updateCountDisplay() {
  $participantCount.text(`${participantCount}/${maxPeople}`);
}

/* ========================================================================
   DB 기준 참가자 수 업데이트
   ======================================================================== */
async function updateParticipantCount() {
  if (!postId) return;
  try {
    const res = await $.getJSON(`${CONTEXT}/chat/participants`, { postId });
    participantCount = res.currentPeople || 0;
    updateCountDisplay();
  } catch (err) {
    console.error("❌ 참가자 수 업데이트 실패:", err);
  }
}

/* ========================================================================
   초기화 실행
   ======================================================================== */
$(document).ready(() => {
  init();
});
