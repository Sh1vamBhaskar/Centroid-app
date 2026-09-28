package com.bhaskar.centroid.chat;

import com.bhaskar.centroid.dto.ChatMessageRequest;
import com.bhaskar.centroid.dto.MessageResponse;
import com.bhaskar.centroid.security.WebSocketAuthInterceptor;

import lombok.RequiredArgsConstructor;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;

import org.springframework.stereotype.Controller;

import java.security.Principal;

@Controller
@RequiredArgsConstructor
public class WebSocketChatController {

    private final MessageService messageService;
    private final SimpMessagingTemplate messagingTemplate;
    private final WebSocketAuthInterceptor webSocketAuthInterceptor;

    @MessageMapping("/chat")
    public void sendMessage(
            ChatMessageRequest request,
            StompHeaderAccessor accessor) {

        String sessionId =
                accessor.getSessionId();

        Principal user =
                webSocketAuthInterceptor
                        .getSessionUser(sessionId);

        if (user == null) {

            throw new IllegalArgumentException(
                    "WebSocket authentication required"
            );
        }

        String email = user.getName();

        System.out.println(
                "WS CHAT: sending message as = "
                        + email
        );

        Message message =
                messageService.sendMessage(
                        email,
                        request.getConversationId(),
                        request.getContent()
                );

        MessageResponse response =
                new MessageResponse(
                        message.getId(),
                        message.getConversation().getId(),
                        message.getSender().getId(),
                        message.getContent(),
                        message.getCreatedAt()
                );

        messagingTemplate.convertAndSend(
                "/topic/chat/"
                        + request.getConversationId(),
                response
        );
    }
}