package com.bhaskar.centroid.chat;

import com.bhaskar.centroid.dto.ChatMessageRequest;
import com.bhaskar.centroid.dto.MessageResponse;
import com.bhaskar.centroid.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class WebSocketChatController {

    private final MessageService messageService;
    private final SimpMessagingTemplate messagingTemplate;
    private final JwtService jwtService;

    @MessageMapping("/chat")
    public void sendMessage(
            ChatMessageRequest request,
            StompHeaderAccessor accessor) {

        // Get JWT from the SEND frame
        String authHeader =
                accessor.getFirstNativeHeader("Authorization");

        if (authHeader == null ||
                !authHeader.startsWith("Bearer ")) {

            throw new IllegalArgumentException(
                    "Authorization token is required"
            );
        }

        String jwt = authHeader.substring(7);

        // Extract email from JWT
        String email;

        try {

            email = jwtService.extractEmail(jwt);

        } catch (Exception e) {

            throw new IllegalArgumentException(
                    "Invalid JWT"
            );
        }

        // Validate JWT
        if (!jwtService.isTokenValid(jwt)) {

            throw new IllegalArgumentException(
                    "Invalid or expired JWT"
            );
        }

        // Save message
        Message message =
                messageService.sendMessage(
                        email,
                        request.getConversationId(),
                        request.getContent()
                );

        // Prepare response
        MessageResponse response =
                new MessageResponse(
                        message.getId(),
                        message.getConversation().getId(),
                        message.getSender().getId(),
                        message.getContent(),
                        message.getCreatedAt()
                );

        // Broadcast to conversation
        messagingTemplate.convertAndSend(
                "/topic/chat/" + request.getConversationId(),
                response
        );
    }
}