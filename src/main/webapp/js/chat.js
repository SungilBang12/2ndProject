/* ========================================================================
   전역 변수 및 설정
   ======================================================================== */
window.ably = window.ably || null;

const chatStates = {}; // roomId => { channel, joined, messagesRef, participantCount, maxPeople, scrollPos, isMinimized }
let activeRoomId = null; // 현재 활성 채팅방

/* ========================================================================
   DOM 요소
   ======================================================================== */
const chatModule = document.getElementById("chatModule");
const postId = chatModule?.dataset.postId || null;
const userId = chatModule?.dataset.userId;

const $chatWidget = $("#chatWidget");
const $chatPanel = $("#chatPanel");
const $chatListPanel = $("#chatListPanel");
const $chatList = $("#chatList");
const $chatMessages = $("#chatMessages");
const $chatInput = $("#chatInput");
const $sendBtn = $("#sendBtn");
const $participantCount = $("#participantCount");
const $maxPeople = $("#maxPeople");
const $chatTitle = $("#chatTitle");
const $minimizeBtn = $("#minimizeBtn");
const $backToListBtn = $("#backToListBtn");
const $leaveBtn = $("#leaveBtn");
const $chatToggleBtn = $("#chatToggleBtn");

/* ========================================================================
   초기화
   ======================================================================== */
$(document).ready(async () => {
    $chatWidget.hide();
    $chatToggleBtn.on("click", toggleChatWidget);
    $minimizeBtn.on("click", minimizeChatWidget);
    $backToListBtn.on("click", showChatList);
    $leaveBtn.on("click", setupLeaveButton);
    $sendBtn.on("click", sendMessage);
    $chatInput.on("input", toggleSendBtn);
    $chatInput.on("keypress", e => { if (e.key === "Enter") sendMessage(); });

    try {
        const res = await $.getJSON(`/chat/init`, { postId: postId || "" });
        const { ablyConfig, firebaseConfig, userId: serverUserId, rooms, schedules } = res;

        initAblyAndFirebase(ablyConfig, firebaseConfig, serverUserId);

        if (postId && schedules?.some(sch => sch.postId === postId)) {
            const schedule = schedules.find(sch => sch.postId === postId);
            await enterChatRoom(postId, schedule.title);
        } else {
            await loadChatList(rooms);
        }
    } catch (err) {
        console.error("❌ /chat/init 요청 실패:", err);
    }
});

/* ========================================================================
   Ably & Firebase 초기화
   ======================================================================== */
function initAblyAndFirebase(ablyConfig, firebaseConfig, serverUserId) {
    if (!ablyConfig?.pubKey) return console.error("❌ Ably 설정 누락");
    window.ably = new Ably.Realtime({ key: ablyConfig.pubKey, clientId: userId || serverUserId });

    window.ably.connection.on("connected", () => {
        console.log("✅ Ably 연결 성공");
        if (firebaseConfig?.apiKey && !firebase.apps.length) firebase.initializeApp(firebaseConfig);
        window.firebaseDb = firebase.database();
    });

    window.ably.connection.on("failed", () => {
        console.error("❌ Ably 연결 실패");
        displayMessage('<div class="system-message error">Ably 연결 실패</div>');
    });
}

/* ========================================================================
   채팅 토글/최소화
   ======================================================================== */
function toggleChatWidget() {
    if ($chatWidget.is(":visible")) $chatWidget.fadeOut(200);
    else {
        $chatWidget.fadeIn(200);
        if (activeRoomId) {
            const state = chatStates[activeRoomId];
            if (state.isMinimized) state.isMinimized = false;
            $chatPanel.show();
            restoreScroll(activeRoomId);
        } else {
            $chatListPanel.show();
        }
    }
}

function minimizeChatWidget() {
    if (activeRoomId) chatStates[activeRoomId].isMinimized = true;
    $chatPanel.hide();
    $chatListPanel.hide();
    $chatWidget.fadeOut(200);
}

/* ========================================================================
   채팅 리스트 로드
   ======================================================================== */
async function loadChatList(existingRooms = []) {
    activeRoomId = null;
    $chatListPanel.show();
    $chatPanel.hide();
    $backToListBtn.hide();
    $leaveBtn.hide();
    $chatTitle.text("채팅 리스트");

    let rooms = existingRooms.length ? existingRooms : (await $.getJSON(`/chat/init`)).rooms || [];
    rooms = rooms.filter(r => !r.scheduleOnly);

    if (!rooms.length) {
        $chatList.html("<li class='no-rooms'>참여 가능한 채팅방이 없습니다.</li>");
        return;
    }

    $chatList.html(
        rooms.map(r => `<li class="chat-room-item" data-id="${r.postId}"><strong>${r.title || `채팅방 #${r.postId}`}</strong></li>`).join("")
    );

    $chatList.off("click").on("click", ".chat-room-item", async function() {
        const roomId = $(this).data("id");
        await enterChatRoom(roomId);
    });
}

/* ========================================================================
   채팅방 참가/채널 설정
   ======================================================================== */
async function enterChatRoom(roomId, title = null) {
    if (!roomId) return;

    if (activeRoomId && activeRoomId !== roomId) cleanupCurrentRoom(activeRoomId);

    activeRoomId = roomId;
    if (!chatStates[roomId]) chatStates[roomId] = { channel: null, joined: false, messagesRef: null, participantCount: 0, maxPeople: 5, scrollPos: 0, isMinimized: false };
    const state = chatStates[roomId];

    $chatListPanel.hide();
    $chatPanel.show();
    $backToListBtn.show();
    $leaveBtn.show();
    $chatMessages.empty();
    state.participantCount = 0;
    updateCountDisplay(roomId);
    $chatTitle.text(title || `채팅방 #${roomId}`);

    setupChannel(`channel-${roomId}`, roomId);

    try {
        const res = await $.post(`/chat/update`, { postId: roomId, action: "join" });
        const alreadyJoined = res.chatResult?.message?.includes("이미 참가");

        if (res.chatResult?.success || alreadyJoined) {
            state.joined = true;
            state.channel.presence.enter({ user: userId });
            toggleSendBtn();
            displayMessage(`<div class="system-message info">${alreadyJoined ? "이미 참가 중입니다." : "채팅방에 참가했습니다."}</div>`);
        } else {
            state.joined = false;
            $leaveBtn.hide();
            $sendBtn.prop("disabled", true);
            displayMessage(`<div class="system-message error">자동 참가 실패: ${res.chatResult?.message}</div>`);
        }

        await updateParticipantCount(roomId);
        restoreScroll(roomId);
    } catch (err) {
        console.error("❌ 자동 참가 실패:", err);
        $sendBtn.prop("disabled", true);
    }
}

/* ========================================================================
   채널 & 메시지 설정
   ======================================================================== */
function setupChannel(channelName, roomId) {
    const state = chatStates[roomId];
    if (!window.ably) return console.error("❌ Ably 미초기화");

    if (state.channel) {
        state.channel.unsubscribe();
        state.channel.presence.unsubscribe();
    }

    const channel = window.ably.channels.get(channelName);
    state.channel = channel;

    if (state.messagesRef) state.messagesRef.off();
    state.messagesRef = null;

    if (window.firebaseDb) {
        const messagesRef = window.firebaseDb.ref(`chat/${roomId}/messages`);
        state.messagesRef = messagesRef;

        messagesRef.once("value", snap => {
            $chatMessages.empty();
            const messages = snap.val();
            if (messages) Object.values(messages).forEach(msg => {
                if (!msg.text) return;
                const cls = msg.user === userId ? "chat-message-mine" : "chat-message-other";
                const userName = msg.user === userId ? "나" : msg.user;
                displayMessage(`<div class="${cls}"><strong>${userName}</strong>: ${msg.text}</div>`);
            });
            restoreScroll(roomId);
        });

        messagesRef.on("child_added", snap => {
            const msg = snap.val();
            if (!msg || msg.user === userId) return;
            displayMessage(`<div class="chat-message-other"><strong>${msg.user}</strong>: ${msg.text}</div>`);
            saveScroll(roomId);
        });
    }

    channel.subscribe("message", msg => {
        const mine = msg.data.user === userId;
        const cls = mine ? "chat-message-mine" : "chat-message-other";
        const userName = mine ? "나" : msg.data.user;
        displayMessage(`<div class="${cls}"><strong>${userName}</strong>: ${msg.data.text}</div>`);

        if (mine && state.messagesRef) {
            state.messagesRef.push({ user: msg.data.user, text: msg.data.text, timestamp: Date.now() });
        }
        saveScroll(roomId);
        toggleSendBtn();
    });

    channel.presence.subscribe(["enter", "leave"], async member => {
        const actionText = member.action === "enter" ? "참가했습니다." : "퇴장했습니다.";
        displayMessage(`<div class="system-message">${member.clientId} 님이 ${actionText}</div>`);
        await updateParticipantCount(roomId);
        saveScroll(roomId);
    });

    channel.presence.get((err, members) => {
        state.participantCount = members?.length || 0;
        updateCountDisplay(roomId);
    });
}

/* ========================================================================
   나가기 버튼
   ======================================================================== */
function setupLeaveButton() {
    $leaveBtn.off("click").on("click", async () => {
        if (!activeRoomId) return;
        const state = chatStates[activeRoomId];
        if (!state?.joined || !state.channel) return;

        try {
            await $.post(`/chat/update`, { postId: activeRoomId, action: "leave" });
            state.channel.presence.leave();

            cleanupCurrentRoom(activeRoomId);
            $chatPanel.hide();
            displayMessage('<div class="system-message">채팅방에서 나갔습니다.</div>');
            $chatTitle.text("채팅 리스트");
            await loadChatList();
            activeRoomId = null;
        } catch (err) {
            console.error("❌ 나가기 요청 실패:", err);
        }
    });
}

/* ========================================================================
   메시지 전송
   ======================================================================== */
function sendMessage() {
    const text = $chatInput.val().trim();
    const state = chatStates[activeRoomId];
    if (!text || !state?.channel || !state.joined) return;

    state.channel.publish("message", { user: userId, text });
    $chatInput.val("").focus();
}

/* ========================================================================
   버튼 활성화/비활성화
   ======================================================================== */
function toggleSendBtn() {
    const state = chatStates[activeRoomId];
    $sendBtn.prop("disabled", !$chatInput.val().trim() || !state?.joined || !state?.channel);
}

/* ========================================================================
   화면 업데이트
   ======================================================================== */
function displayMessage(content) {
    $chatMessages.append(content);
    saveScroll(activeRoomId);
}

function saveScroll(roomId) {
    if (!roomId) return;
    chatStates[roomId].scrollPos = $chatMessages[0].scrollHeight;
    $chatMessages.scrollTop(chatStates[roomId].scrollPos);
}

function restoreScroll(roomId) {
    if (!roomId) return;
    const pos = chatStates[roomId]?.scrollPos || 0;
    $chatMessages.scrollTop(pos);
}

/* ========================================================================
   참가자 수
   ======================================================================== */
async function updateParticipantCount(roomId) {
    if (!roomId) return;
    const state = chatStates[roomId];
    try {
        const res = await $.getJSON(`/chat/participants`, { postId: roomId });
        state.participantCount = res.currentPeople || 0;
        state.maxPeople = res.maxPeople || state.maxPeople;
        updateCountDisplay(roomId);
    } catch (err) {
        console.error("❌ 참가자 수 업데이트 실패:", err);
    }
}

function updateCountDisplay(roomId) {
    const state = chatStates[roomId];
    if (!state) return;
    $participantCount.text(state.participantCount);
    $maxPeople.text(state.maxPeople);
}

/* ========================================================================
   채팅방 정리
   ======================================================================== */
function cleanupCurrentRoom(roomId) {
    if (!roomId) return;
    const state = chatStates[roomId];
    if (!state) return;

    if (state.channel) {
        state.channel.unsubscribe();
        state.channel.presence.unsubscribe();
    }
    if (state.messagesRef) state.messagesRef.off();

    state.channel = null;
    state.joined = false;
    state.messagesRef = null;
    state.scrollPos = 0;
    state.participantCount = 0;
    state.isMinimized = false;

    $chatMessages.empty();
    $sendBtn.prop("disabled", true);
    $leaveBtn.hide();
}

/* ========================================================================
   리스트로 돌아가기
   ======================================================================== */
function showChatList() {
    if (activeRoomId) cleanupCurrentRoom(activeRoomId);
    activeRoomId = null;
    $chatTitle.text("채팅 리스트");
    loadChatList();
}
