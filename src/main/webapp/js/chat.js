//chat.js
/* ========================================================================
   전역 변수 및 설정
   ======================================================================== */
window.ably = window.ably || null;
let channel = null;
let participantCount = 0;
let firebaseDb = null;
let messagesRef = null;
let isMinimized = false;
let joined = false;

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
$(document).ready(async () => {
	$chatWidget.hide();
	$chatToggleBtn.on("click", toggleChatWidget);
	$minimizeBtn.on("click", minimizeChatWidget);
	$backToListBtn.on("click", showChatList);

	try {
		const res = await $.getJSON(`${CONTEXT}/chat/init`, { postId: postId || "" });
		const { ablyConfig, firebaseConfig, userId: serverUserId, rooms } = res;

		// Ably 초기화
		if (ablyConfig?.pubKey) {
			window.ably = new Ably.Realtime({
				key: ablyConfig.pubKey,
				clientId: userId || serverUserId
			});

			window.ably.connection.on("connected", async () => {
				console.log("✅ Ably 연결 성공");
				initFirebase(firebaseConfig);
				await loadChatList(rooms);

				// postId가 있으면 자동 참가
				if (postId) await enterChatRoom(postId);
			});

			window.ably.connection.on("failed", () => {
				console.error("❌ Ably 연결 실패");
				displayMessage('<div class="system-message error">Ably 연결 실패</div>');
			});
		} else console.error("❌ Ably 설정 누락");
	} catch (err) {
		console.error("❌ /chat/init 요청 실패:", err);
	}
});

/* ========================================================================
   채팅 위젯 토글/최소화
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
async function loadChatList(existingRooms = []) {
	$chatListPanel.show();
	$chatPanel.hide();
	$backToListBtn.hide();

	try {
		let rooms = existingRooms;
		if (!rooms.length) {
			const res = await $.getJSON(`${CONTEXT}/chat/init`);
			rooms = res.rooms || [];
		}

		if (!rooms.length) {
			$chatList.html("<li class='no-rooms'>참여 가능한 채팅방이 없습니다.</li>");
			return;
		}

		const listHtml = rooms
			.map(room => `<li class="chat-room-item" data-id="${room.postId}">
        <strong>${room.title || `채팅방 #${room.postId}`}</strong><br>
        <span class="room-info">참여자: ${room.currentPeople || 0}/${room.maxPeople || 0}</span>
      </li>`).join("");

		$chatList.html(listHtml);

		$chatList.off("click").on("click", ".chat-room-item", async function() {
			const roomId = $(this).data("id");
			await enterChatRoom(roomId);
		});
	} catch (err) {
		console.error("❌ 채팅방 리스트 로드 실패:", err);
		$chatList.html("<li class='error-message'>리스트를 불러올 수 없습니다.</li>");
	}
}

/* ========================================================================
   채팅방 참가 (자동 참가)
   ======================================================================== */
async function enterChatRoom(roomId) {
	$chatListPanel.hide();
	$chatPanel.show();
	$backToListBtn.show();
	$chatMessages.empty();

	const channelName = `channel-${roomId}`;
	window.chatChannelName = channelName;

	if (!channel || channel.name !== channelName) {
		setupChannel(channelName);
	}

	try {
		const res = await $.post(`${CONTEXT}/chat/update`, { postId: roomId, action: "join" });

		if (res.chatResult?.success) {
			joined = true;
			$joinBtn.hide();
			$leaveBtn.show();
			displayMessage('<div class="system-message">채팅방에 참가했습니다.</div>');
		} else if (res.chatResult?.message?.includes("이미 참가")) {
			joined = true;  // 이미 참가 상태라면 joined=true
			$joinBtn.hide();
			$leaveBtn.show();
			displayMessage('<div class="system-message info">이미 참가 중입니다.</div>');
		} else {
			joined = false;
			$joinBtn.show();
			$leaveBtn.hide();
			displayMessage(`<div class="system-message error">자동 참가 실패: ${res.chatResult?.message}</div>`);
		}

		await updateParticipantCount();
		$sendBtn.prop("disabled", false);
	} catch (err) {
		console.error("❌ 자동 참가 실패:", err);
	}
}

/* ========================================================================
   Firebase 초기화
   ======================================================================== */
function initFirebase(firebaseConfig) {
	if (!firebaseConfig?.apiKey) return;
	if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);

	firebaseDb = firebase.database();
	messagesRef = firebaseDb.ref(`chat/${postId}/messages`);

	messagesRef.once("value", snap => {
		const messages = snap.val();
		if (messages) {
			Object.values(messages).forEach(msg => {
				const cls = msg.user === userId ? "chat-message-mine" : "chat-message-other";
				const userName = msg.user === userId ? "나" : msg.user;
				displayMessage(`<div class="${cls}"><strong>${userName}</strong>: ${msg.text}</div>`);
			});
		}
	});

	messagesRef.on("child_added", snap => {
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

	// 메시지 수신
	channel.subscribe("message", msg => {
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

	// 참가/퇴장 실시간 감지
	channel.presence.subscribe(["enter", "leave"], async member => {
		const actionText = member.action === "enter" ? "참가했습니다." : "퇴장했습니다.";
		displayMessage(`<div class="system-message">${member.clientId} 님이 ${actionText}</div>`);
		await updateParticipantCount();
	});
}

/* ========================================================================
   참가/나가기 버튼 상태
   ======================================================================== */
function setupJoinLeaveButtons() {
  $joinBtn.off("click").on("click", async () => {
    if (joined) return;  // 이미 참가한 경우 무시
    await enterChatRoom(postId);
  });

  $leaveBtn.off("click").on("click", async () => {
    if (!joined || !channel) return;

    try {
      await $.post(`${CONTEXT}/chat/update`, { postId, action: "leave" });
      channel.presence.leave();
      joined = false;
      $chatMessages.empty();
      $joinBtn.hide();   // 참가 버튼 숨김
      $leaveBtn.hide();  // 나가기 버튼 숨김
      displayMessage('<div class="system-message">채팅방에서 나갔습니다.</div>');
      await updateParticipantCount();
      loadChatList();
    } catch (err) {
      console.error("❌ 나가기 요청 실패:", err);
    }
  });

  $sendBtn.off("click").on("click", sendMessage);
  $chatInput.off("keypress").on("keypress", e => { if (e.key === "Enter") sendMessage(); });
}

/* ========================================================================
   메시지 전송
   ======================================================================== */
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
   DB 기반 참가자 수 갱신
   ======================================================================== */
async function updateParticipantCount() {
	if (!postId) return;
	try {
		const res = await $.getJSON(`${CONTEXT}/chat/participants`, { postId });
		participantCount = res.currentPeople || 0;
		updateCountDisplay();

		const $scheduleBlock = $(`.schedule-current-people[data-post-id="${postId}"]`);
		if ($scheduleBlock.length) {
			const max = $scheduleBlock.data("max-people") || maxPeople;
			$scheduleBlock.text(`${participantCount}/${max}`);
		}
	} catch (err) {
		console.error("❌ 참가자 수 업데이트 실패:", err);
	}
}

/* ========================================================================
   리스트로 돌아가기
   ======================================================================== */
function showChatList() {
	if (channel) {
		if (joined) channel.presence.leave();
		channel.unsubscribe();
		channel.presence.unsubscribe();
		channel = null;
	}
	$chatMessages.empty();
	joined = false;
	$joinBtn.show();
	$leaveBtn.hide();
	loadChatList();
}
