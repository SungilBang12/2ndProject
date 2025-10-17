// chat.js (Type: module)

let ably = null;
let channel = null;

const chatModule = document.getElementById("chatModule");
if (!chatModule) throw new Error("❌ chatModule not found.");

const postId = chatModule.dataset.postId || null;
const userId = chatModule.dataset.userId;
const maxPeople = parseInt(chatModule.dataset.maxPeople, 10);

const $joinBtn = $("#joinBtn");
const $chatPanel = $("#chatPanel");
const $chatListPanel = $("#chatListPanel");
const $chatList = $("#chatList");
const $chatMessages = $("#chatMessages");
const $chatInput = $("#chatInput");
const $sendBtn = $("#sendBtn");
const $participantCount = $("#participantCount");

$chatPanel.hide();
$chatListPanel.hide();

if (!postId) loadChatList();
else initChatRoom();

// ✅ Ably Chat API 기반 채팅 리스트 로드
function loadChatList() {
    console.log("🗂️ 채팅 리스트 로드 중...");
    $chatListPanel.show();
    $.ajax({
        url: "/chat/join", // postId 없으므로 Servlet에서 Ably Chat API 호출
        method: "GET",
        dataType: "json",
        success: (rooms) => {
            if (!rooms.items || rooms.items.length === 0) {
                $chatList.html("<li>참여 가능한 채팅방이 없습니다.</li>");
                return;
            }

            const listHtml = rooms.items.map(conv => `
                <li data-id="${conv.id}">
                    <strong>${conv.metadata?.displayName || conv.id}</strong><br>
                    참여자: ${conv.participants?.length || 0}
                </li>
            `).join("");
            $chatList.html(listHtml);

            $chatList.on("click", "li", function () {
                const convId = $(this).data("id");
                window.location.href = `/chat?postId=${convId}`;
            });
        },
        error: (xhr) => {
            console.error("❌ 채팅방 리스트 로드 실패:", xhr.responseText);
            $chatList.html("<li>리스트를 불러올 수 없습니다.</li>");
        }
    });
}

// ✅ 기존 Realtime 기반 채팅방 초기화
async function initChatRoom() {
    $.ajax({
        url: "/chat/join",
        method: "GET",
        data: { postId },
        dataType: "json",
        success: (res) => {
            console.log("✅ Ably 설정 로드:", res);
            const { ablyConfig } = res;
            if (!ablyConfig?.pubKey) {
                $chatMessages.append('<div class="system-message">Ably 설정 누락</div>');
                return;
            }

            ably = new Ably.Realtime({ key: ablyConfig.pubKey, clientId: userId });
            setupJoinHandler(res);
        },
        error: (err) => {
            console.error("❌ 설정 로드 실패:", err);
        }
    });
}

function setupJoinHandler(config) {
    const { postId, userId } = config;

    ably.connection.on("connected", () => {
        $joinBtn.prop("disabled", false);
    });

    $joinBtn.on("click", () => {
        $.post("/chat/join", { postId, userId }, function (res) {
            if (!res.success) {
                displayMessage(`<div class="system-message" style="color:red;">참가 실패: ${res.message}</div>`);
                return;
            }

            const channelName = res.channelName;
            channel = ably.channels.get(channelName);
            $joinBtn.hide(); $chatPanel.show(); $sendBtn.prop("disabled", false);

            channel.subscribe("message", msg => {
                const mine = msg.data.user === userId;
                const cls = mine ? "chat-message-mine" : "chat-message-other";
                displayMessage(`<div class="${cls}"><strong>${mine ? "나" : msg.data.user}</strong>: ${msg.data.text}</div>`);
            });

            channel.presence.enter();
            displayMessage(`<div class="system-message">${userId} 님이 참가했습니다.</div>`);

            channel.presence.get((err, members) => {
                if (!err) updateCount(members);
            });
        });
    });

    $sendBtn.on("click", () => {
        const text = $chatInput.val().trim();
        if (!text || !channel) return;
        channel.publish("message", { user: userId, text });
        $chatInput.val("").focus();
    });
}

function displayMessage(content) {
    $chatMessages.append(content);
    $chatMessages.scrollTop($chatMessages[0].scrollHeight);
}

function updateCount(members) {
    const count = members.length;
    $participantCount.text(`${count}/${maxPeople}`);
}
