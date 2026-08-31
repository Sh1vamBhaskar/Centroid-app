package com.bhaskar.centroid.chat;

import com.bhaskar.centroid.interaction.Interaction;
import com.bhaskar.centroid.interaction.InteractionRepository;
import com.bhaskar.centroid.interaction.InteractionStatus;
import com.bhaskar.centroid.user.User;
import com.bhaskar.centroid.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ConversationService {

    private final ConversationRepository conversationRepository;
    private final InteractionRepository interactionRepository;
    private final UserRepository userRepository;

    public Conversation createConversationFromInteraction(
            String userEmail,
            Long interactionId) {

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() ->
                        new RuntimeException("User not found"));

        Interaction interaction =
                interactionRepository.findById(interactionId)
                        .orElseThrow(() ->
                                new RuntimeException("Interaction not found"));

        if (interaction.getStatus() != InteractionStatus.ACCEPTED) {
            throw new IllegalArgumentException(
                    "Conversation can only be created for an accepted interaction"
            );
        }

        boolean isParticipant =
                interaction.getSender().getId().equals(user.getId())
                        || interaction.getReceiver().getId().equals(user.getId());

        if (!isParticipant) {
            throw new IllegalArgumentException(
                    "You are not a participant in this interaction"
            );
        }

        User sender = interaction.getSender();
        User receiver = interaction.getReceiver();

        User userOne;
        User userTwo;

        if (sender.getId() < receiver.getId()) {
            userOne = sender;
            userTwo = receiver;
        } else {
            userOne = receiver;
            userTwo = sender;
        }

        return conversationRepository
                .findByUserOneAndUserTwo(userOne, userTwo)
                .orElseGet(() -> {

                    Conversation conversation =
                            Conversation.builder()
                                    .userOne(userOne)
                                    .userTwo(userTwo)
                                    .createdAt(LocalDateTime.now())
                                    .build();

                    return conversationRepository.save(conversation);
                });
    }
}