package com.bhaskar.centroid.chat;

import com.bhaskar.centroid.dto.MessageRequest;
import com.bhaskar.centroid.dto.MessageResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/messages")
@RequiredArgsConstructor
public class MessageController {

    private final MessageService messageService;

    @PostMapping("/{conversationId}")
    public ResponseEntity<MessageResponse> sendMessage(
            @PathVariable Long conversationId,
            @Valid @RequestBody MessageRequest request,
            Authentication authentication) {

        Message message = messageService.sendMessage(
                authentication.getName(),
                conversationId,
                request.getContent()
        );

        MessageResponse response = new MessageResponse(
                message.getId(),
                message.getConversation().getId(),
                message.getSender().getId(),
                message.getContent(),
                message.getCreatedAt()
        );

        return ResponseEntity.ok(response);
    }

    @GetMapping("/{conversationId}")
    public ResponseEntity<List<MessageResponse>> getMessages(
            @PathVariable Long conversationId,
            Authentication authentication) {

        List<Message> messages =
                messageService.getMessages(
                        authentication.getName(),
                        conversationId
                );

        List<MessageResponse> responses =
                messages.stream()
                        .map(message ->
                                new MessageResponse(
                                        message.getId(),
                                        message.getConversation().getId(),
                                        message.getSender().getId(),
                                        message.getContent(),
                                        message.getCreatedAt()
                                )
                        )
                        .toList();

        return ResponseEntity.ok(responses);
    }
}