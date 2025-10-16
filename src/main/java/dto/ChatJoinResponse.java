//ChatJoinResponse.java
package dto;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public class ChatJoinResponse {
	private boolean success;
	private String message;
	private String channelName; // Ably 채널
	private int currentPeople;
	private int maxPeople;
}