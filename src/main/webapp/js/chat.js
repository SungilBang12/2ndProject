import $ from "jquery";

// Ably 설정
const ably = new Ably.Realtime({ key: 'YOUR_ABLY_FREE_KEY' });

const postId = $("#postId").val();
const userId = $("#userId").val();
let channel;

// 참가 버튼 클릭
$("#joinBtn").on("click", () => {
    $.post("/chat/join", { postId, userId }, function(res) {
        alert(res.message);
        if(!res.success) return;

        // 채널 연결
        channel = ably.channels.get(res.channelName);

        // 메시지 수신
        channel.subscribe(msg => {
            $("#chatMessages").append(`<div>${msg.data.user}: ${msg.data.text}</div>`);
            $("#chatMessages").scrollTop($("#chatMessages")[0].scrollHeight);
        });

        // Presence 참가
        channel.presence.enter({ userId });
        channel.presence.subscribe(presence => {
            const count = presence.length;
            $("#participantCount").text(`${count}/${res.maxParticipants}`);
            if(count >= res.maxParticipants)
                $("#joinBtn").prop("disabled", true);
        });

        // 채팅 모달 표시
        $("#chatModal").show();
    });
});

// 메시지 전송
$("#sendBtn").on("click", () => {
    const text = $("#chatInput").val().trim();
    if(!text) return;
    channel.publish("message", { user: userId, text });
    $("#chatInput").val("");
});

// 모달 닫기
$("#closeModalBtn").on("click", () => {
    $("#chatModal").hide();
});
