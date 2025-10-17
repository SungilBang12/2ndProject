/* ========================================================================
   전역 변수 및 설정
   ======================================================================== */
window.ably = window.ably || null;

// 방별 상태 관리
const chatStates = {}; // { roomId: { channel, participantCount, maxPeople, joined, messagesRef, isMinimized } }

const CONTEXT = window.APP_CONTEXT || "";

/* ========================================================================
   DOM 요소
   ======================================================================== */
const chatModule = document.getElementById("chatModule");
if (!chatModule) console.warn("⚠️ chatModule not found.");

const postId = chatModule?.dataset.postId || null;
const userId = chatModule?.dataset.userId;
console.log("chat.js postId   " + postId);
console.log("chat.js userId   " + postId);

window.userId = userId;
window.postId = postId;

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
const $chatTitle = $("#chatTitle");

/* ========================================================================
   초기화
   ======================================================================== */
$(document).ready(async () => {
    $chatWidget.hide();
    $chatToggleBtn.on("click", toggleChatWidget);
    $minimizeBtn.on("click", minimizeChatWidget);
    $backToListBtn.on("click", showChatList);
    $sendBtn.on("click", sendMessage);
    $chatInput.on("keypress", e => { if (e.key === "Enter") sendMessage(); });

    try {
        const res = await $.getJSON(`${CONTEXT}/chat/init`, { postId: postId || "" });
        const { ablyConfig, firebaseConfig, userId: serverUserId, rooms, schedules, maxPeople: serverMax } = res;

        initAblyAndFirebase(ablyConfig, firebaseConfig, serverUserId);
        setupJoinLeaveButtons();

        // postId 존재 시 schedule 체크 후 자동 참가
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
   채팅 위젯 토글/최소화
   ======================================================================== */
function toggleChatWidget() {
    if ($chatWidget.is(":visible")) $chatWidget.fadeOut(200);
    else {
        $chatWidget.fadeIn(200);
        const state = chatStates[chatModule.dataset.postId] || {};
        if (state.isMinimized) {
            state.isMinimized = false;
            $chatPanel.show();
            $chatListPanel.show();
        }
    }
}

function minimizeChatWidget() {
    const state = chatStates[chatModule.dataset.postId] || {};
    state.isMinimized = true;
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
    $chatTitle.text("채팅 리스트");

    let rooms = existingRooms.length ? existingRooms : (await $.getJSON(`${CONTEXT}/chat/init`)).rooms || [];
    rooms = rooms.filter(r => !r.scheduleOnly);

    if (!rooms.length) {
        $chatList.html("<li class='no-rooms'>참여 가능한 채팅방이 없습니다.</li>");
        return;
    }

    const listHtml = rooms.map(room => `
        <li class="chat-room-item" data-id="${room.postId}">
            <strong>${room.title || `채팅방 #${room.postId}`}</strong>
        </li>
    `).join("");

    $chatList.html(listHtml);
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

    // 방별 상태 초기화
    if (!chatStates[roomId]) chatStates[roomId] = { channel: null, participantCount: 0, maxPeople: 5, joined: false, messagesRef: null, isMinimized: false };
    const state = chatStates[roomId];

    if (state.joined && state.roomId === roomId) return;

    cleanupCurrentRoom(roomId);
    $chatListPanel.hide();
    $chatPanel.show();
    $backToListBtn.show();
    $chatMessages.empty();

    state.roomId = roomId;
    state.participantCount = 0;
    updateCountDisplay(roomId);

    $chatTitle.text(title || `채팅방 #${roomId}`);

    const channelName = `channel-${roomId}`;
    setupChannel(channelName, roomId);

    try {
        const res = await $.post(`${CONTEXT}/chat/update`, { postId: roomId, action: "join" });
        const alreadyJoined = res.chatResult?.message?.includes("이미 참가");

        if (res.chatResult?.success || alreadyJoined) {
            state.joined = true;
            state.channel.presence.enter({ user: userId });

            $joinBtn.hide();
            $leaveBtn.show();
            $sendBtn.prop("disabled", false);

            displayMessage(`<div class="system-message info">${alreadyJoined ? "이미 참가 중입니다." : "채팅방에 참가했습니다."}</div>`);
        } else {
            state.joined = false;
            $joinBtn.show();
            $leaveBtn.hide();
            $sendBtn.prop("disabled", true);
            displayMessage(`<div class="system-message error">자동 참가 실패: ${res.chatResult?.message}</div>`);
        }

        await updateParticipantCount(roomId);
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
            if (messages) {
                Object.values(messages).forEach(msg => {
                    if (!msg.text) return;
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

    channel.subscribe("message", msg => {
        const mine = msg.data.user === userId;
        const cls = mine ? "chat-message-mine" : "chat-message-other";
        const userName = mine ? "나" : msg.data.user;
        displayMessage(`<div class="${cls}"><strong>${userName}</strong>: ${msg.data.text}</div>`);

        if (mine && state.messagesRef) {
            state.messagesRef.push({ user: msg.data.user, text: msg.data.text, timestamp: Date.now() });
        }
    });

    channel.presence.subscribe(["enter", "leave"], async member => {
        const actionText = member.action === "enter" ? "참가했습니다." : "퇴장했습니다.";
        displayMessage(`<div class="system-message">${member.clientId} 님이 ${actionText}</div>`);
        await updateParticipantCount(roomId);
    });

    channel.presence.get((err, members) => {
        state.participantCount = members?.length || 0;
        updateCountDisplay(roomId);
    });
}

/* ========================================================================
   참가/나가기 버튼
   ======================================================================== */
function setupJoinLeaveButtons() {
    $joinBtn.off("click").on("click", async () => {
        const roomId = chatModule.dataset.postId;
        if (chatStates[roomId]?.joined) return;
        await enterChatRoom(roomId);
    });

    $leaveBtn.off("click").on("click", async () => {
        const roomId = chatModule.dataset.postId;
        const state = chatStates[roomId];
        if (!state?.joined || !state.channel) return;

        try {
            await $.post(`${CONTEXT}/chat/update`, { postId: roomId, action: "leave" });
            state.channel.presence.leave();

            // UI 갱신
            $chatPanel.hide();
            $chatListPanel.show();

            cleanupCurrentRoom(roomId);
            displayMessage('<div class="system-message">채팅방에서 나갔습니다.</div>');

            await updateParticipantCount(roomId);
            await loadChatList();
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
    const roomId = chatModule.dataset.postId;
    const state = chatStates[roomId];
    if (!text || !state?.channel || !state.joined) return;
    state.channel.publish("message", { user: userId, text });
    $chatInput.val("").focus();
}

/* ========================================================================
   화면 업데이트
   ======================================================================== */
function displayMessage(content) {
    $chatMessages.append(content);
    $chatMessages.scrollTop($chatMessages[0].scrollHeight);
}

function updateCountDisplay(roomId) {
    const state = chatStates[roomId];
    if (!state) return;
    $("#participantCount").text(state.participantCount);
    $("#maxPeople").text(state.maxPeople);
}

/* ========================================================================
   참가자 수 갱신 (Servlet 연동)
   ======================================================================== */
async function updateParticipantCount(roomId) {
    if (!roomId) return;
    const state = chatStates[roomId];
    try {
        const res = await $.getJSON(`${CONTEXT}/chat/participants`, { postId: roomId });
        state.participantCount = res.currentPeople || 0;
        state.maxPeople = res.maxPeople || state.maxPeople;
        updateCountDisplay(roomId);
    } catch (err) {
        console.error("❌ 참가자 수 업데이트 실패:", err);
    }
}

/* ========================================================================
   채팅방 정리
   ======================================================================== */
function cleanupCurrentRoom(roomId) {
    const state = chatStates[roomId];
    if (!state) return;

    const { channel, messagesRef } = state;
    if (channel) {
        channel.unsubscribe();
        channel.presence.unsubscribe();
    }
    if (messagesRef) messagesRef.off();

    state.channel = null;
    state.joined = false;
    state.roomId = null;
    state.participantCount = 0;
    state.messagesRef = null;

    $chatMessages.empty();
    $joinBtn.hide();
    $leaveBtn.hide();
    $sendBtn.prop("disabled", true);
}

/* ========================================================================
   리스트로 돌아가기
   ======================================================================== */
function showChatList() {
    const roomId = chatModule.dataset.postId;
    cleanupCurrentRoom(roomId);
    $chatTitle.text("채팅 리스트");
    loadChatList();
}

/* ========================================================================
   전역 함수 노출
   ======================================================================== */
window.chatUpdateParticipantCount = updateParticipantCount;
