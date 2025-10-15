//ChatJoinResponse.java
package dto;

public class ChatJoinResponse {
	public ChatJoinResponse(boolean b, String string, Object object, int i, int j) {
		// TODO Auto-generated constructor stub
	}
	public ChatJoinResponse(boolean b, String string, String object, int currentPeople, int maxPeople) {
		// TODO Auto-generated constructor stub
	}
	private boolean success;
	private String message;
	private String channelName; // Ably 채널
	private int currentParticipants;
	private int maxParticipants;
}