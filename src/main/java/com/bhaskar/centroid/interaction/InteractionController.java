package com.bhaskar.centroid.interaction;

import com.bhaskar.centroid.dto.InteractionRequest;
import com.bhaskar.centroid.dto.InteractionResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/interactions")
@RequiredArgsConstructor
public class InteractionController {

    private final InteractionService interactionService;

    @PostMapping
    public ResponseEntity<InteractionResponse> sendInteraction(
            @Valid @RequestBody InteractionRequest request,
            Authentication authentication) {

        Interaction interaction =
                interactionService.sendInteraction(
                        authentication.getName(),
                        request.getReceiverId()
                );

        InteractionResponse response =
                new InteractionResponse(
                        interaction.getId(),
                        interaction.getSender().getId(),
                        interaction.getReceiver().getId(),
                        interaction.getStatus(),
                        interaction.getCreatedAt()
                );

        return ResponseEntity.ok(response);
    }
    @GetMapping("/pending")
    public ResponseEntity<List<InteractionResponse>> getPendingInteractions(
            Authentication authentication) {

        List<Interaction> interactions =
                interactionService.getPendingInteractions(
                        authentication.getName()
                );

        List<InteractionResponse> responses =
                interactions.stream()
                        .map(interaction ->
                                new InteractionResponse(
                                        interaction.getId(),
                                        interaction.getSender().getId(),
                                        interaction.getReceiver().getId(),
                                        interaction.getStatus(),
                                        interaction.getCreatedAt()
                                )
                        )
                        .toList();

        return ResponseEntity.ok(responses);
    }
    @PutMapping("/{id}/accept")
    public ResponseEntity<InteractionResponse> acceptInteraction(
            @PathVariable Long id,
            Authentication authentication) {

        Interaction interaction =
                interactionService.acceptInteraction(
                        authentication.getName(),
                        id
                );

        return ResponseEntity.ok(
                new InteractionResponse(
                        interaction.getId(),
                        interaction.getSender().getId(),
                        interaction.getReceiver().getId(),
                        interaction.getStatus(),
                        interaction.getCreatedAt()
                )
        );
    }
    @PutMapping("/{id}/decline")
    public ResponseEntity<InteractionResponse> declineInteraction(
            @PathVariable Long id,
            Authentication authentication) {

        Interaction interaction =
                interactionService.declineInteraction(
                        authentication.getName(),
                        id
                );

        return ResponseEntity.ok(
                new InteractionResponse(
                        interaction.getId(),
                        interaction.getSender().getId(),
                        interaction.getReceiver().getId(),
                        interaction.getStatus(),
                        interaction.getCreatedAt()
                )
        );
    }
}