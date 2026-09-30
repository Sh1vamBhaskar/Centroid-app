package com.bhaskar.centroid.chat;

import com.bhaskar.centroid.dto.ConversationListResponse;
import com.bhaskar.centroid.interaction.Interaction;
import com.bhaskar.centroid.interaction.InteractionRepository;
import com.bhaskar.centroid.interaction.InteractionStatus;
import com.bhaskar.centroid.profile.Profile;
import com.bhaskar.centroid.profile.ProfileRepository;
import com.bhaskar.centroid.user.User;
import com.bhaskar.centroid.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ConversationService {

    private final ConversationRepository conversationRepository;
    private final InteractionRepository interactionRepository;
    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;


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


    public List<ConversationListResponse> getMyConversations(
            String userEmail) {

        User currentUser = userRepository.findByEmail(userEmail)
                .orElseThrow(() ->
                        new RuntimeException("User not found"));

        List<Conversation> conversations =
                conversationRepository
                        .findByUserOneOrUserTwoOrderByCreatedAtDesc(
                                currentUser,
                                currentUser
                        );

        List<ConversationListResponse> response =
                new ArrayList<>();

        for (Conversation conversation : conversations) {

            User otherUser;

            if (conversation.getUserOne().getId()
                    .equals(currentUser.getId())) {

                otherUser = conversation.getUserTwo();

            } else {

                otherUser = conversation.getUserOne();
            }

            Profile profile =
                    profileRepository
                            .findByUserId(otherUser.getId())
                            .orElse(null);

            String displayName =
                    profile != null
                            ? profile.getDisplayName()
                            : otherUser.getEmail();

            String profilePicture =
                    profile != null
                            ? profile.getProfilePicture()
                            : null;

            response.add(
                    new ConversationListResponse(
                            conversation.getId(),
                            otherUser.getId(),
                            displayName,
                            profilePicture,
                            conversation.getCreatedAt()
                    )
            );
        }

        return response;
    }
}