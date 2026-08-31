package com.bhaskar.centroid.chat;

import com.bhaskar.centroid.dto.ConversationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/conversations")
@RequiredArgsConstructor
public class ConversationController {

    private final ConversationService conversationService;

    @PostMapping("/from-interaction/{interactionId}")
    public ResponseEntity<ConversationResponse> createFromInteraction(
            @PathVariable Long interactionId,
            Authentication authentication) {

        Conversation conversation =
                conversationService.createConversationFromInteraction(
                        authentication.getName(),
                        interactionId
                );

        ConversationResponse response =
                new ConversationResponse(
                        conversation.getId(),
                        conversation.getUserOne().getId(),
                        conversation.getUserTwo().getId(),
                        conversation.getCreatedAt()
                );

        return ResponseEntity.ok(response);
    }
}