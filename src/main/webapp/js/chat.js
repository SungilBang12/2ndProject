// chat.js (Type: module)

// Ably 전역 변수 초기화
let ably = null;
let channel = null;

// DOM에서 설정값 읽기
const chatModule = document.getElementById('chatModule');
if (!chatModule) {
    console.error("❌ Chat module element not found.");
    // 모듈이 없으면 로직 실행 중단
    throw new Error('Chat module initialization failed: Missing DOM element.');
}

const postId = chatModule.getAttribute('data-post-id');
const userId = chatModule.getAttribute('data-user-id');
const maxPeople = parseInt(chatModule.getAttribute('data-max-people'), 10);
const ablyConfigJson = chatModule.getAttribute('data-ably-config');

// DOM 요소 캐시
const $joinBtn = $("#joinBtn");
const $chatPanel = $("#chatPanel");
const $chatMessages = $("#chatMessages");
const $chatInput = $("#chatInput");
const $sendBtn = $("#sendBtn");
const $participantCount = $("#participantCount");

// 초기 UI 설정
$chatPanel.hide();
$participantCount.text(`0/${maxPeople}`);

// 1. Ably 초기화
try {
    const ablyConfig = JSON.parse(ablyConfigJson);
    
    // 🚨 디버깅 로그 (개인 정보 노출 주의)
    console.log('[DEBUG] Loaded Ably Config:', ablyConfig);
    
    if (!ablyConfig || !ablyConfig.pubKey) {
        throw new Error('Ably 설정(pubKey)이 누락되었습니다.');
    }

    if (!userId || userId === 'null' || userId === 'undefined') {
        throw new Error('인증된 사용자 ID가 필요합니다.');
    }

    ably = new Ably.Realtime({
        key: ablyConfig.pubKey,
        clientId: userId // Ably의 클라이언트 ID로 사용
    });

    ably.connection.on('connected', () => {
        console.log('✅ Ably 연결 성공');
        $joinBtn.prop('disabled', false); // 연결 성공 시 참가 버튼 활성화
    });

    ably.connection.on('failed', (err) => {
        console.error('❌ Ably 연결 실패:', err);
        $joinBtn.prop('disabled', true);
        $chatMessages.append('<div class="system-message">Ably 연결 실패. 잠시 후 다시 시도해 주세요.</div>');
    });

} catch (e) {
    console.error("❌ Ably 초기화 실패:", e.message);
    $joinBtn.prop('disabled', true);
    $chatMessages.append('<div class="system-message">채팅 기능 초기화 실패. (설정 오류)</div>');
}

/**
 * 메시지를 채팅창에 추가하고 스크롤을 맨 아래로 이동
 * @param {string} content - 표시할 메시지 HTML 문자열
 */
const displayMessage = (content) => {
    $chatMessages.append(content);
    $chatMessages.scrollTop($chatMessages[0].scrollHeight);
};

/**
 * 참가자 수를 갱신하고 참가 버튼을 제어합니다.
 * @param {Ably.PresenceMessage[]} members - 현재 참가 멤버 목록
 */
const updateParticipantCount = (members) => {
    const count = members.length;
    $participantCount.text(`${count}/${maxPeople}`);
    
    // 최대 인원 초과 시 참가 버튼 비활성화 (새로운 참가 방지)
    $joinBtn.prop("disabled", count >= maxPeople); 
    
    // 현재 챗방에 들어온 상태라면 (채팅 패널이 보임), 최대 인원 초과 시에도 전송은 허용.
};


// 2. 참가 로직
$joinBtn.on("click", () => {
	// Post 요청: 서버에 채널 이름 및 토큰 발급 요청
	// 주의: 실제 서비스에서는 pubKey 대신 Token Auth를 사용하는 것이 보안상 훨씬 안전합니다.
	$.post("/chat/join", { postId, userId }, function(res) {
		
		// 🚨 alert() 대신 UI 피드백 사용 (KISA 가이드라인 준수)
		if (!res.success) {
            displayMessage(`<div class="system-message" style="color:red;">[시스템] 참가 실패: ${res.message}</div>`);
            return;
        }

		// 챗 채널 가져오기
		const channelName = res.channelName;
		channel = ably.channels.get(channelName);
        
        // UI 변경: 참가 버튼 비활성화, 채팅 패널 표시
        $joinBtn.hide(); 
        $chatPanel.show();
        $sendBtn.prop('disabled', false);

		// 2-1. 메시지 수신 (Publish/Subscribe)
		channel.subscribe('message', msg => {
			const isMine = msg.data.user === userId;
			const userName = isMine ? '나' : msg.data.user;
            const messageClass = isMine ? 'chat-message-mine' : 'chat-message-other';
			displayMessage(`<div class="${messageClass}"><strong>${userName}</strong>: ${msg.data.text}</div>`);
		});

        // 2-2. Presence 참가
		// Presence.enter()를 호출하여 채널에 접속했음을 알림
		channel.presence.enter(); 
        displayMessage(`<div class="system-message">${userId} 님이 채팅방에 참가했습니다.</div>`);

		// 2-3. 초기 참가자 수 가져오기
		channel.presence.get((err, members) => {
			if (err) {
                console.error("❌ 초기 참가자 수 조회 실패:", err);
                return;
            }
			updateParticipantCount(members);
		});

		// 2-4. Presence 이벤트 구독 (참가/퇴장 시 실시간 갱신)
		channel.presence.subscribe(['enter', 'leave'], (msg) => {
            const isEnter = msg.action === 'enter';
            const actionText = isEnter ? '참가' : '퇴장';
            const user = msg.clientId;
            
            displayMessage(`<div class="system-message">${user} 님이 채팅방을 ${actionText}했습니다.</div>`);

			// 이벤트 발생 시마다 전체 멤버 목록 다시 조회
			channel.presence.get((err, members) => {
				if (err) return;
				updateParticipantCount(members);
			});
		});

	}).fail(function(jqXHR, textStatus, errorThrown) {
        // 서버 요청 실패 처리
        displayMessage('<div class="system-message" style="color:red;">[시스템] 서버 연결 또는 참가 요청 실패.</div>');
        console.error("❌ Join request failed:", textStatus, errorThrown);
    });
});

// 3. 메시지 전송 로직
$sendBtn.on("click", () => {
	const text = $chatInput.val().trim();
	if (!text) return;
    
    // Ably Publish
    // 데이터는 { user: userId, text: 메시지 내용 } 형식으로 보냄
	channel.publish("message", { user: userId, text });
	$chatInput.val("");
    
    // Enter 키로도 전송 가능하도록 이벤트 추가
    $chatInput.focus();
});

// 엔터 키 이벤트 처리
$chatInput.on('keypress', (e) => {
    if (e.key === 'Enter') {
        e.preventDefault(); // 기본 개행 방지
        $sendBtn.trigger('click');
    }
});


// 4. 퇴장 로직 (모듈이 닫힐 때)
// chat-module.jsp 에는 닫기 버튼이 없으므로, 퇴장은 페이지를 떠나거나 모듈이 DOM에서 제거될 때를 가정합니다.
// 여기서는 임시로 '퇴장하기' 버튼을 추가하고 로직을 구현합니다.
$(`#chatModule`).on("click", "#leaveBtn", () => {
    if (channel) {
        // Presence.leave()를 호출하여 Presence에서 나감을 알림
        channel.presence.leave(() => {
            console.log("✅ Ably Presence leave successful.");
            // 채널 구독 해제 및 채널 객체 정리
            channel.unsubscribe();
            channel = null;
            
            // UI 초기화
            $chatPanel.hide();
            $joinBtn.show().prop('disabled', false);
            $participantCount.text(`0/${maxPeople}`);
            $chatMessages.empty();
        });
    }
});

// 초기화 시 참가 버튼 활성화 여부는 Ably 연결 상태에 따라 결정됩니다 (1. Ably 초기화 섹션 참고).
