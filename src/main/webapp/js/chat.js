// ==============================
// 전역 Ably / Firebase 변수
// ==============================
window.ably = window.ably || null;
let channel = null;
let participantCount = 0;
let firebaseDb = null;
let messagesRef = null;

// ==============================
// 서버 Context 경로
// ==============================
const CONTEXT = window.APP_CONTEXT || "";

// ==============================
// DOM 요소
// ==============================
const chatModule = document.getElementById("chatModule");
if (!chatModule) throw new Error("❌ chatModule not found.");

const postId = chatModule.dataset.postId || null;
const userId = chatModule.dataset.userId;
window.userId = userId;

const maxPeople = parseInt(chatModule.dataset.maxPeople || "5", 10);

const $joinBtn = $("#joinBtn");
const $leaveBtn = $("#leaveBtn");
const $chatPanel = $("#chatPanel");
const $chatListPanel = $("#chatListPanel");
const $chatList = $("#chatList");
const $chatMessages = $("#chatMessages");
const $chatInput = $("#chatInput");
const $sendBtn = $("#sendBtn");
const $participantCount = $("#participantCount");

$chatPanel.hide();
$chatListPanel.hide();

// ==============================
// 초기 로드
// ==============================
if (!postId) loadChatList();
else initChatRoom();

// ==============================
// 채팅 리스트 로드
// ==============================
function loadChatList() {
  $chatListPanel.show();
  $.getJSON(`${CONTEXT}/chat/init`, (res) => {
    const rooms = res.rooms || [];
    if (!rooms.length) {
      $chatList.html("<li>참여 가능한 채팅방이 없습니다.</li>");
      return;
    }

    const listHtml = rooms
      .map(
        (room) => `<li data-id="${room.postId}">
            <strong>${room.title || room.postId}</strong><br>
            참여자: ${room.currentPeople || 0}/${room.maxPeople || 0}
        </li>`
      )
      .join("");
    $chatList.html(listHtml);

    $chatList.off("click").on("click", "li", function () {
      const convId = $(this).data("id");
      window.location.href = `${CONTEXT}/chat?postId=${convId}`;
    });
  }).fail((err) => {
    console.error("❌ 채팅방 리스트 로드 실패:", err.responseText || err);
    $chatList.html("<li>리스트를 불러올 수 없습니다.</li>");
  });
}

// ==============================
// 채팅방 초기화
// ==============================
async function initChatRoom() {
  try {
    const res = await $.getJSON(`${CONTEXT}/chat/init`, { postId });

    const { ablyConfig, firebaseConfig, channelName, currentPeople } = res;

    participantCount = currentPeople || 0;
    updateCountDisplay();

    if (!ablyConfig?.pubKey) {
      displayMessage('<div class="system-message" style="color:red;">Ably 설정 누락</div>');
      return;
    }

    window.ably = new Ably.Realtime({ key: ablyConfig.pubKey, clientId: userId });
    window.ably.connection.on("connected", () => {
      setupChannel(`channel-${postId}`);
      setupJoinLeaveButtons();
      initFirebase(firebaseConfig);
    });
    window.ably.connection.on("failed", () => {
      displayMessage('<div class="system-message" style="color:red;">Ably 연결 실패</div>');
    });
  } catch (err) {
    console.error("❌ /chat/init 요청 실패:", err);
    displayMessage('<div class="system-message" style="color:red;">채팅방 초기화 실패</div>');
  }
}

// ==============================
// Firebase 초기화
// ==============================
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
        displayMessage(`<div class="${cls}"><strong>${msg.user === userId ? "나" : msg.user}</strong>: ${msg.text}</div>`);
      });
    }
  });

  messagesRef.on("child_added", (snap) => {
    const msg = snap.val();
    if (!msg || msg.user === userId) return;
    displayMessage(`<div class="chat-message-other"><strong>${msg.user}</strong>: ${msg.text}</div>`);
  });
}

// ==============================
// Ably 채널 구독
// ==============================
function setupChannel(channelName) {
  channel = window.ably.channels.get(channelName);

  channel.subscribe("message", (msg) => {
    const mine = msg.data.user === userId;
    const cls = mine ? "chat-message-mine" : "chat-message-other";
    displayMessage(`<div class="${cls}"><strong>${mine ? "나" : msg.data.user}</strong>: ${msg.data.text}</div>`);

    if (!mine && firebaseDb) {
      firebaseDb.ref(`chat/${postId}/messages`).push({
        user: msg.data.user,
        text: msg.data.text,
        timestamp: Date.now(),
      });
    }
  });

  channel.presence.subscribe(["enter", "leave"], (member) => {
    participantCount = Math.max(0, member.action === "enter" ? participantCount + 1 : participantCount - 1);
    updateCountDisplay();
    const actionText = member.action === "enter" ? "참가했습니다." : "퇴장했습니다.";
    displayMessage(`<div class="system-message">${member.clientId} 님이 ${actionText}</div>`);
  });

  channel.presence.get((err, members) => {
    if (!err) {
      participantCount = members.length;
      updateCountDisplay();
    }
  });

  $sendBtn.prop("disabled", false);
  $chatPanel.show();
}

// ==============================
// 참가 / 나가기 버튼
// ==============================
function setupJoinLeaveButtons() {
  let joined = false;

  $joinBtn.off("click").on("click", async () => {
    if (joined) return;
    const res = await $.post(`${CONTEXT}/chat/update`, { postId, action: "join" });
    if (!res.success) {
      displayMessage(`<div class="system-message" style="color:red;">참가 실패: ${res.message}</div>`);
      return;
    }
    channel.presence.enter({ user: userId });
    joined = true;
    $joinBtn.hide();
    $leaveBtn.show();
  });

  $leaveBtn.off("click").on("click", async () => {
    if (!joined || !channel) return;
    const res = await $.post(`${CONTEXT}/chat/update`, { postId, action: "leave" });
    channel.presence.leave();
    channel.unsubscribe();
    channel.presence.unsubscribe();
    channel = null;

    $chatMessages.empty();
    $joinBtn.show();
    $leaveBtn.hide();
    joined = false;

    displayMessage('<div class="system-message">채팅방에서 나갔습니다.</div>');
  });

  $sendBtn.off("click").on("click", () => {
    const text = $chatInput.val().trim();
    if (!text || !channel) return;
    channel.publish("message", { user: userId, text });

    if (firebaseDb) {
      firebaseDb.ref(`chat/${postId}/messages`).push({ user: userId, text, timestamp: Date.now() });
    }

    $chatInput.val("").focus();
  });
}

// ==============================
// 화면 업데이트
// ==============================
function displayMessage(content) {
  $chatMessages.append(content);
  $chatMessages.scrollTop($chatMessages[0].scrollHeight);
}

function updateCountDisplay() {
  $participantCount.text(`${participantCount}/${maxPeople}`);
}
