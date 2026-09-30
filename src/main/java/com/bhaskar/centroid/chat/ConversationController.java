package com.bhaskar.centroid.chat;

import com.bhaskar.centroid.dto.ConversationListResponse;
import com.bhaskar.centroid.dto.ConversationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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


    @GetMapping
    public ResponseEntity<List<ConversationListResponse>> getMyConversations(
            Authentication authentication) {

        List<ConversationListResponse> conversations =
                conversationService.getMyConversations(
                        authentication.getName()
                );

        return ResponseEntity.ok(conversations);
    }
}