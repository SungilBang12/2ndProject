// chat.js (Type: module)

// ✅ 전역 Ably 인스턴스 (공용)
window.ably = window.ably || null;
let channel = null;

const chatModule = document.getElementById("chatModule");
if (!chatModule) throw new Error("❌ chatModule not found.");

const postId = chatModule.dataset.postId || null;
const userId = chatModule.dataset.userId;
// ✅ 수정: 전역 window 객체에 'userId' 그대로 노출하여 schedule-block.js가 사용할 수 있게 함
window.userId = userId; 
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

// ✅ postId 없으면 채팅 리스트, 있으면 방 입장
if (!postId) loadChatList();
else initChatRoom();

/* =====================================================
 🟢 Ably Chat API 기반 채팅방 리스트 로드
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
 🟢 Realtime 기반 채팅방 초기화
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

            const { ablyConfig } = res;

            if (!ablyConfig?.pubKey) {
                console.error("❌ Ably pubKey 누락!", ablyConfig);
                $chatMessages.append('<div class="system-message">Ably 설정 누락</div>');
                return;
            }

            try {
                console.log("🔹 Ably 연결 시도, key:", ablyConfig.pubKey);
                ably = new Ably.Realtime({ key: ablyConfig.pubKey, clientId: userId });
            } catch (err) {
                console.error("❌ Ably Realtime 연결 실패:", err);
            }

            ably.connection.on("connected", () => {
                console.log("✅ Ably Realtime 연결 성공");
                // ✅ 수정: setupChannel 바로 호출
                setupChannel(res.channelName); 
                setupJoinHandler(res); // 버튼 핸들러는 그대로 유지
            });

            ably.connection.on("failed", () => {
                console.error("❌ Ably Realtime 연결 실패 상태 발생");
            });
        },
        error: (err) => {
            console.error("❌ /chat/join AJAX 요청 실패:", err);
        }
    });
}


/* =====================================================
 🟢 채널 구독 및 메시지 처리
===================================================== */
function setupChannel(channelName) {
    const ably = window.ably;
    channel = ably.channels.get(channelName);
    
    // ✅ 메시지 구독을 join 전에 미리 설정
    channel.subscribe("message", (msg) => {
        const mine = msg.data.user === userId;
        const cls = mine ? "chat-message-mine" : "chat-message-other";
        displayMessage(`<div class="${cls}"><strong>${mine ? "나" : msg.data.user}</strong>: ${msg.data.text}</div>`);
    });
    
    // ✅ Presence 구독으로 실시간 인원 카운트 업데이트
    channel.presence.subscribe(["enter", "leave", "update"], (member) => {
        channel.presence.get((err, members) => {
            if (!err) updateCount(members);
        });
        
        // 참가/퇴장 시스템 메시지
        if (member.action === 'enter') {
            displayMessage(`<div class="system-message">${member.clientId} 님이 참가했습니다.</div>`);
        } else if (member.action === 'leave') {
            displayMessage(`<div class="system-message">${member.clientId} 님이 퇴장했습니다.</div>`);
        }
    });
    
    // 초기 인원 로드
    channel.presence.get((err, members) => {
        if (!err) updateCount(members);
    });
    
    // ✅ 전송 버튼 활성화 (Join은 별개)
    $sendBtn.prop("disabled", false);
    $chatPanel.show();
}


/* =====================================================
 🟢 채팅방 참가 처리 (버튼 클릭 이벤트만 담당)
===================================================== */
function setupJoinHandler(config) {
  const { postId } = config; // userId는 전역 상수 userId를 사용
  const ably = window.ably;
  let joined = false;

  ably.connection.on("connected", () => {
    $joinBtn.prop("disabled", false);
  });

  $joinBtn.on("click", () => {
    if (joined) return;
    
    // ✅ POST 요청으로 서버에 참가 요청
    $.post("/chat/join", { postId, userId }, function (res) {
      if (!res.success) {
        displayMessage(`<div class="system-message" style="color:red;">참가 실패: ${res.message}</div>`);
        return;
      }

      // ✅ Ably Presence에 참가
      channel.presence.enter({ user: userId });
      joined = true;
      $joinBtn.hide(); // 참가 후 버튼 숨기기
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