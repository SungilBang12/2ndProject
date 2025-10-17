/* ========================================================================
   전역 변수 및 설정
   ======================================================================== */
window.ably = window.ably || null;

const chatState = {
    channel: null,
    roomId: null,
    participantCount: 0,
    maxPeople: 5,
    joined: false,
    messagesRef: null,
    isMinimized: false,
};

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

    $sendBtn.on("click", sendMessage);
    $chatInput.on("keypress", e => { if (e.key === "Enter") sendMessage(); });

    try {
        const res = await $.getJSON(`${CONTEXT}/chat/init`, { postId: postId || "" });
        const { ablyConfig, firebaseConfig, userId: serverUserId, rooms, currentPeople, maxPeople: serverMax } = res;

        chatState.maxPeople = serverMax || chatState.maxPeople;
        updateCountDisplay();

        if (ablyConfig?.pubKey) {
            window.ably = new Ably.Realtime({ key: ablyConfig.pubKey, clientId: userId || serverUserId });

            window.ably.connection.on("connected", async () => {
                console.log("✅ Ably 연결 성공");
                initFirebase(firebaseConfig);
                await loadChatList(rooms);

                if (postId) {
                    await enterChatRoom(postId);
                    setupJoinLeaveButtons();
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
});

/* ========================================================================
   채팅 위젯 토글/최소화
   ======================================================================== */
function toggleChatWidget() {
    if ($chatWidget.is(":visible")) $chatWidget.fadeOut(200);
    else {
        $chatWidget.fadeIn(200);
        if (chatState.isMinimized) {
            chatState.isMinimized = false;
            $chatPanel.show();
            $chatListPanel.show();
        }
    }
}

function minimizeChatWidget() {
    chatState.isMinimized = true;
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
   Firebase 초기화
   ======================================================================== */
function initFirebase(firebaseConfig) {
    if (!firebaseConfig?.apiKey) return;
    if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
    window.firebaseDb = firebase.database();
}

/* ========================================================================
   채팅방 참가/채널 설정
   ======================================================================== */
async function enterChatRoom(roomId) {
    if (!roomId) return;
    if (chatState.joined && chatState.roomId === roomId) return; // 이미 참가 중

    cleanupCurrentRoom();

    $chatListPanel.hide();
    $chatPanel.show();
    $backToListBtn.show();
    $chatMessages.empty();

    chatState.roomId = roomId;
    chatState.participantCount = 0;
    updateCountDisplay();

    const channelName = `channel-${roomId}`;
    setupChannel(channelName, roomId);

    try {
        const res = await $.post(`${CONTEXT}/chat/update`, { postId: roomId, action: "join" });
        const alreadyJoined = res.chatResult?.message?.includes("이미 참가");

        if (res.chatResult?.success || alreadyJoined) {
            chatState.joined = true;
            chatState.channel.presence.enter({ user: userId });

            $joinBtn.hide();
            $leaveBtn.show();
            $sendBtn.prop("disabled", false);

            const systemMsg = alreadyJoined ? "이미 참가 중입니다." : "채팅방에 참가했습니다.";
            displayMessage(`<div class="system-message info">${systemMsg}</div>`);
        } else {
            chatState.joined = false;
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

function setupChannel(channelName, roomId) {
    if (!window.ably) return console.error("❌ Ably 미초기화");

    if (chatState.channel) {
        chatState.channel.unsubscribe();
        chatState.channel.presence.unsubscribe();
    }

    const channel = window.ably.channels.get(channelName);
    chatState.channel = channel;

    if (chatState.messagesRef) chatState.messagesRef.off();
    chatState.messagesRef = null;

    if (window.firebaseDb) {
        const messagesRef = window.firebaseDb.ref(`chat/${roomId}/messages`);
        chatState.messagesRef = messagesRef;

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
            if (!msg || msg.user === userId) return; // 중복 표시 방지
            displayMessage(`<div class="chat-message-other"><strong>${msg.user}</strong>: ${msg.text}</div>`);
        });
    }

    channel.subscribe("message", msg => {
        const mine = msg.data.user === userId;
        const cls = mine ? "chat-message-mine" : "chat-message-other";
        const userName = mine ? "나" : msg.data.user;
        displayMessage(`<div class="${cls}"><strong>${userName}</strong>: ${msg.data.text}</div>`);

        if (mine && chatState.messagesRef) {
            chatState.messagesRef.push({ user: msg.data.user, text: msg.data.text, timestamp: Date.now() });
        }
    });

    channel.presence.subscribe(["enter", "leave"], async member => {
        const actionText = member.action === "enter" ? "참가했습니다." : "퇴장했습니다.";
        displayMessage(`<div class="system-message">${member.clientId} 님이 ${actionText}</div>`);
        await updateParticipantCount(roomId);
    });

    channel.presence.get((err, members) => {
        chatState.participantCount = members?.length || 0;
        updateCountDisplay();
    });
}

/* ========================================================================
   참가/나가기 버튼
   ======================================================================== */
function setupJoinLeaveButtons() {
    $joinBtn.off("click").on("click", async () => {
        if (chatState.joined) return;
        await enterChatRoom(chatState.roomId);
    });

    $leaveBtn.off("click").on("click", async () => {
        if (!chatState.joined || !chatState.channel) return;

        try {
            await $.post(`${CONTEXT}/chat/update`, { postId: chatState.roomId, action: "leave" });
            chatState.channel.presence.leave();
            cleanupCurrentRoom();
            displayMessage('<div class="system-message">채팅방에서 나갔습니다.</div>');
            await updateParticipantCount(chatState.roomId);
            loadChatList();
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
    if (!text || !chatState.channel || !chatState.joined) return;

    chatState.channel.publish("message", { user: userId, text });
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
    $participantCount.text(`${chatState.participantCount}/${chatState.maxPeople}`);
}

/* ========================================================================
   참가자 수 갱신
   ======================================================================== */
async function updateParticipantCount(roomId) {
    const targetPostId = roomId || chatState.roomId;
    if (!targetPostId) return;

    try {
        const res = await $.getJSON(`${CONTEXT}/chat/participants`, { postId: targetPostId });
        chatState.participantCount = res.currentPeople || 0;
        chatState.maxPeople = res.maxPeople || chatState.maxPeople;
        updateCountDisplay();

        const $scheduleBlock = $(`.schedule-block[data-post-id="${targetPostId}"]`);
        if ($scheduleBlock.length) {
            $scheduleBlock.find(".currentPeople").text(chatState.participantCount);
        }

        document.dispatchEvent(new CustomEvent("chatParticipantUpdate", {
            detail: { postId: targetPostId, currentPeople: chatState.participantCount, maxPeople: chatState.maxPeople }
        }));
    } catch (err) {
        console.error("❌ 참가자 수 업데이트 실패:", err);
    }
}

/* ========================================================================
   채팅방 정리
   ======================================================================== */
function cleanupCurrentRoom() {
    const { channel, joined, messagesRef } = chatState;

    if (channel) {
        if (joined) channel.presence.leave();
        channel.unsubscribe();
        channel.presence.unsubscribe();
    }

    if (messagesRef) messagesRef.off();

    chatState.channel = null;
    chatState.roomId = null;
    chatState.joined = false;
    chatState.participantCount = 0;
    chatState.messagesRef = null;

    $chatMessages.empty();
    $joinBtn.hide();
    $leaveBtn.hide();
    $sendBtn.prop("disabled", true);
}

/* ========================================================================
   리스트로 돌아가기
   ======================================================================== */
function showChatList() {
    cleanupCurrentRoom();
    loadChatList();
}

/* ========================================================================
   전역 함수 노출
   ======================================================================== */
window.chatUpdateParticipantCount = updateParticipantCount;
