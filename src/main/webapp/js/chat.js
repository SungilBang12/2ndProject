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
if (!chatModule) {
  console.warn("⚠️ chatModule not found. 채팅 기능을 건너뜁니다.");
}

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

  // 위젯 초기 상태: 숨김
  $chatWidget.hide();

  // 토글 버튼 클릭
  $chatToggleBtn.on("click", toggleChatWidget);

  // 최소화 버튼 클릭
  $minimizeBtn.on("click", minimizeChatWidget);

  // 리스트로 돌아가기 버튼
  $backToListBtn.on("click", showChatList);

  try {
    // /chat/init 호출하여 설정 가져오기
    const res = await $.getJSON(`${CONTEXT}/chat/init`, { postId: postId || "" });
    const { ablyConfig, firebaseConfig, userId: serverUserId } = res;

    // Ably 초기화
    if (ablyConfig?.pubKey) {
      window.ably = new Ably.Realtime({ 
        key: ablyConfig.pubKey, 
        clientId: userId || serverUserId 
      });

      window.ably.connection.on("connected", () => {
        console.log("✅ Ably 연결 성공");
        initFirebase(firebaseConfig);
        
        // postId 있으면 채팅방, 없으면 리스트
        if (postId) {
          checkUserParticipation();
        } else {
          loadChatList();
        }
      });

      window.ably.connection.on("failed", () => {
        console.error("❌ Ably 연결 실패");
        displayMessage('<div class="system-message error">Ably 연결 실패</div>');
      });
    } else {
      console.error("❌ Ably 설정 누락");
    }
  } catch (err) {
    console.error("❌ /chat/init 요청 실패:", err);
  }
}

/* ========================================================================
   위젯 토글/최소화
   ======================================================================== */
function toggleChatWidget() {
  if ($chatWidget.is(":visible")) {
    $chatWidget.fadeOut(200);
  } else {
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
  // 현재 채팅방에서 나가기
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
    const { joined, currentPeople: serverCount } = res;

    participantCount = serverCount || 0;
    updateCountDisplay();

    if (joined) {
      // 참여 중이면 채팅방 표시
      initChatRoom();
    } else {
      // 참여 안 했으면 위젯 숨김 (리스트만 표시)
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
  if (!firebaseConfig?.apiKey) {
    console.warn("⚠️ Firebase 설정 누락");
    return;
  }

  if (!firebase.apps.length) {
    firebase.initializeApp(firebaseConfig);
  }

  firebaseDb = firebase.database();
  messagesRef = firebaseDb.ref(`chat/${postId}/messages`);

  // 기존 메시지 로드
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

  // 새 메시지 실시간 수신
  messagesRef.on("child_added", (snap) => {
    const msg = snap.val();
    if (!msg || msg.user === userId) return; // 내가 보낸 메시지는 Ably로 이미 표시됨
    displayMessage(`<div class="chat-message-other"><strong>${msg.user}</strong>: ${msg.text}</div>`);
  });
}

/* ========================================================================
   Ably 채널 구독
   ======================================================================== */
function setupChannel(channelName) {
  if (!window.ably) {
    console.error("❌ Ably가 초기화되지 않았습니다.");
    return;
  }

  channel = window.ably.channels.get(channelName);

  // 메시지 수신
  channel.subscribe("message", (msg) => {
    const mine = msg.data.user === userId;
    const cls = mine ? "chat-message-mine" : "chat-message-other";
    const userName = mine ? "나" : msg.data.user;
    displayMessage(`<div class="${cls}"><strong>${userName}</strong>: ${msg.data.text}</div>`);

    // 내가 보낸 메시지만 Firebase에 저장 (중복 방지)
    if (mine && firebaseDb) {
      firebaseDb.ref(`chat/${postId}/messages`).push({
        user: msg.data.user,
        text: msg.data.text,
        timestamp: Date.now(),
      });
    }
  });

  // Presence 변화 감지
  channel.presence.subscribe(["enter", "leave"], (member) => {
    const actionText = member.action === "enter" ? "참가했습니다." : "퇴장했습니다.";
    displayMessage(`<div class="system-message">${member.clientId} 님이 ${actionText}</div>`);

    // 실시간 참여자 수 업데이트
    channel.presence.get((err, members) => {
      if (!err) {
        participantCount = members.length;
        updateCountDisplay();
      }
    });
  });

  // 초기 참여자 수 가져오기
  channel.presence.get((err, members) => {
    if (!err) {
      participantCount = members.length;
      updateCountDisplay();
    }
  });

  $sendBtn.prop("disabled", false);
}

/* ========================================================================
   참가/나가기 버튼
   ======================================================================== */
function setupJoinLeaveButtons() {
  let joined = false;

  // 참가하기
  $joinBtn.off("click").on("click", async () => {
    if (joined) return;

    try {
      const res = await $.post(`${CONTEXT}/chat/update`, { 
        postId, 
        action: "join" 
      });

      if (!res.chatResult?.success) {
        displayMessage(`<div class="system-message error">참가 실패: ${res.chatResult?.message}</div>`);
        return;
      }

      // Ably Presence 참가
      channel.presence.enter({ user: userId });
      joined = true;
      $joinBtn.hide();
      $leaveBtn.show();
      displayMessage('<div class="system-message">채팅방에 참가했습니다.</div>');
    } catch (err) {
      console.error("❌ 참가 요청 실패:", err);
      displayMessage('<div class="system-message error">참가 실패</div>');
    }
  });

  // 나가기
  $leaveBtn.off("click").on("click", async () => {
    if (!joined || !channel) return;

    try {
      await $.post(`${CONTEXT}/chat/update`, { 
        postId, 
        action: "leave" 
      });

      channel.presence.leave();
      joined = false;
      $chatMessages.empty();
      $joinBtn.show();
      $leaveBtn.hide();
      displayMessage('<div class="system-message">채팅방에서 나갔습니다.</div>');
    } catch (err) {
      console.error("❌ 나가기 요청 실패:", err);
    }
  });

  // 메시지 전송
  $sendBtn.off("click").on("click", sendMessage);
  $chatInput.off("keypress").on("keypress", (e) => {
    if (e.key === "Enter") sendMessage();
  });
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
   초기화 실행
   ======================================================================== */
$(document).ready(() => {
  init();
});