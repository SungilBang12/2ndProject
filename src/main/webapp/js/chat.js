// chat.js (Type: module)

// ✅ 전역 Ably 인스턴스
window.ably = window.ably || null;
let channel = null;
let participantCount = 0;

// Firebase
let firebaseDb = null;
let messagesRef = null; // ✅ Firebase 메시지 참조 추가

const chatModule = document.getElementById("chatModule");
if (!chatModule) throw new Error("❌ chatModule not found.");

const postId = chatModule.dataset.postId || null;
const userId = chatModule.dataset.userId;
window.userId = userId;
const maxPeople = parseInt(chatModule.dataset.maxPeople, 10);

const $joinBtn = $("#joinBtn");
const $leaveBtn = $('<button id="leaveBtn" class="leave-btn">나가기</button>').hide();
$("#chatPanel .chat-header").append($leaveBtn);

const $chatPanel = $("#chatPanel");
const $chatListPanel = $("#chatListPanel");
const $chatList = $("#chatList");
const $chatMessages = $("#chatMessages");
const $chatInput = $("#chatInput");
const $sendBtn = $("#sendBtn");
const $participantCount = $("#participantCount");

$chatPanel.hide();
$chatListPanel.hide();

// postId 없으면 채팅 리스트, 있으면 방 입장
if (!postId) loadChatList();
else initChatRoom();

/* =====================================================
 🟢 채팅 리스트 로드
===================================================== */
function loadChatList() {
  console.log("🗂️ 채팅 리스트 로드 중...");
  $chatListPanel.show();
  $.ajax({
    url: "/chat/join",
    method: "GET",
    dataType: "json",
    success: (rooms) => {
      if (!rooms.items || rooms.items.length === 0) {
        $chatList.html("<li>참여 가능한 채팅방이 없습니다.</li>");
        return;
      }

      const listHtml = rooms.items
        .map(
          (conv) => `
            <li data-id="${conv.id}">
              <strong>${conv.metadata?.displayName || conv.id}</strong><br>
              참여자: ${conv.participants?.length || 0}
            </li>`
        )
        .join("");
      $chatList.html(listHtml);

      $chatList.on("click", "li", function () {
        const convId = $(this).data("id");
        window.location.href = `/chat?postId=${convId}`;
      });
    },
    error: (xhr) => {
      console.error("❌ 채팅방 리스트 로드 실패:", xhr.responseText);
      $chatList.html("<li>리스트를 불러올 수 없습니다.</li>");
    },
  });
}

/* =====================================================
 🟢 Realtime 채팅방 초기화
===================================================== */
async function initChatRoom() {
  console.log("🔹 initChatRoom 시작, postId:", postId);
  $.ajax({
    url: "/chat/join",
    method: "GET",
    data: { postId },
    dataType: "json",
    success: (res) => {
      console.log("✅ /chat/join 응답:", res);

      const { ablyConfig, firebaseConfig, channelName } = res;

      // 1️⃣ Ably 연결
      if (!ablyConfig?.pubKey) {
        console.error("❌ Ably pubKey 누락!", ablyConfig);
        $chatMessages.append('<div class="system-message">Ably 설정 누락</div>');
        return;
      }

      try {
        ably = new Ably.Realtime({ key: ablyConfig.pubKey, clientId: userId });
      } catch (err) {
        console.error("❌ Ably Realtime 연결 실패:", err);
      }

      ably.connection.on("connected", () => {
        console.log("✅ Ably Realtime 연결 성공");
        setupChannel(channelName);
        setupJoinHandler(res); // 참가 버튼
        // 2️⃣ Firebase 초기화
        initFirebase(firebaseConfig);
      });

      ably.connection.on("failed", () => {
        console.error("❌ Ably Realtime 연결 실패 상태 발생");
      });
    },
    error: (err) => {
      console.error("❌ /chat/join AJAX 요청 실패:", err);
    },
  });
}

/* =====================================================
 🟢 Firebase 초기화
===================================================== */
function initFirebase(firebaseConfig) {
  if (!firebaseConfig || !firebaseConfig.apiKey) {
    console.warn("Firebase config 누락");
    return;
  }

  // ✅ Firebase App 초기화
  if (!firebase.apps.length) {
    firebase.initializeApp(firebaseConfig);
  }
  firebaseDb = firebase.database();
  messagesRef = firebaseDb.ref(`chat/${postId}/messages`);

  // ✅ 기존 메시지 불러오기
  messagesRef.once("value", (snapshot) => {
    const messages = snapshot.val();
    if (messages) {
      Object.values(messages).forEach((msg) => {
        const cls = msg.user === userId ? "chat-message-mine" : "chat-message-other";
        displayMessage(`<div class="${cls}"><strong>${msg.user === userId ? "나" : msg.user}</strong>: ${msg.text}</div>`);
      });
    }
  });

  // ✅ 새로운 메시지 실시간 수신
  messagesRef.on("child_added", (snapshot) => {
    const msg = snapshot.val();
    if (!msg) return;
    if (msg.user === userId) return; // 이미 내 메시지는 Ably로 표시됨
    const cls = "chat-message-other";
    displayMessage(`<div class="${cls}"><strong>${msg.user}</strong>: ${msg.text}</div>`);
  });
}

/* =====================================================
 🟢 채널 구독 및 메시지 처리
===================================================== */
function setupChannel(channelName) {
  channel = ably.channels.get(channelName);

  // ✅ Ably → 화면 표시 + Firebase 저장
  channel.subscribe("message", (msg) => {
    const mine = msg.data.user === userId;
    const cls = mine ? "chat-message-mine" : "chat-message-other";
    displayMessage(`<div class="${cls}"><strong>${mine ? "나" : msg.data.user}</strong>: ${msg.data.text}</div>`);

    // Firebase에도 저장 (중복 저장 방지)
    if (!mine && firebaseDb) {
      firebaseDb.ref(`chat/${postId}/messages`).push({
        user: msg.data.user,
        text: msg.data.text,
        timestamp: Date.now(),
      });
    }
  });

  channel.presence.subscribe(["enter", "leave"], (member) => {
    if (member.action === "enter") participantCount++;
    else if (member.action === "leave") participantCount--;
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

/* =====================================================
 🟢 참가 버튼 / 메시지 전송
===================================================== */
function setupJoinHandler(config) {
  const { postId } = config;
  let joined = false;

  $joinBtn.prop("disabled", true);
  ably.connection.on("connected", () => $joinBtn.prop("disabled", false));

  $joinBtn.on("click", () => {
    if (joined) return;
    $.post("/chat/join", { postId, userId }, (res) => {
      if (!res.success) {
        displayMessage(`<div class="system-message" style="color:red;">참가 실패: ${res.message}</div>`);
        return;
      }
      channel.presence.enter({ user: userId });
      joined = true;
      $joinBtn.hide();
      $leaveBtn.show();
    });
  });

  $leaveBtn.on("click", () => {
    if (!joined || !channel) return;
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

  $sendBtn.on("click", () => {
    const text = $chatInput.val().trim();
    if (!text || !channel) return;
    channel.publish("message", { user: userId, text });

    // ✅ Firebase에 메시지 저장
    if (firebaseDb) {
      firebaseDb.ref(`chat/${postId}/messages`).push({
        user: userId,
        text,
        timestamp: Date.now(),
      });
    }

    $chatInput.val("").focus();
  });
}

/* =====================================================
 🟢 화면 업데이트 헬퍼
===================================================== */
function displayMessage(content) {
  $chatMessages.append(content);
  $chatMessages.scrollTop($chatMessages[0].scrollHeight);
}

function updateCountDisplay() {
  $participantCount.text(`${participantCount}/${maxPeople}`);
}
