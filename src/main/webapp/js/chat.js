const postId = $("#postId").val();
const userId = $("#userId").val();
let channel;

console.log("postId===" + postId);
console.log("userId===" + userId);

// 참가 버튼 클릭
$("#joinBtn").on("click", () => {
	$.post("/chat/join", { postId, userId }, function(res) {
		alert(res.message);
		if (!res.success) return;

		// 채널 가져오기
		channel = ably.channels.get(res.channelName);

		// 메시지 수신
		channel.subscribe(msg => {
			$("#chatMessages").append(`<div>${msg.data.user}: ${msg.data.text}</div>`);
			$("#chatMessages").scrollTop($("#chatMessages")[0].scrollHeight);
		});

		// Presence 참가
		channel.presence.enter(); // clientId 지정됨

		// 참가자 수 표시
		$("#maxParticipants").text(res.maxPeople);

		// 현재 참가자 수 가져오기
		channel.presence.get((err, members) => {
			if (err) return;
			const count = members.length;
			$("#participantCount").text(count);
			$("#joinBtn").prop("disabled", count >= res.maxPeople);
		});

		// Presence 이벤트 발생 시마다 참가자 수 갱신
		channel.presence.subscribe(() => {
			channel.presence.get((err, members) => {
				if (err) return;
				const count = members.length;
				$("#participantCount").text(`${count}/${res.maxPeople}`);
				$("#joinBtn").prop("disabled", count >= res.maxPeople);
			});
		});

		// 채팅 모달 표시
		$("#chatModal").show();
	});
});

// 메시지 전송
$("#sendBtn").on("click", () => {
	const text = $("#chatInput").val().trim();
	if (!text) return;
	channel.publish("message", { user: userId, text });
	$("#chatInput").val("");
});

// 모달 닫기
$("#closeModalBtn").on("click", () => {
	$("#chatModal").hide();
	if (channel) {
		channel.presence.leave(); // 나갈 때 Presence에서 제거
	}
});