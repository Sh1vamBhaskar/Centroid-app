package com.bhaskar.centroid.interaction;

import com.bhaskar.centroid.user.User;
import com.bhaskar.centroid.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InteractionService {

    private final InteractionRepository interactionRepository;
    private final UserRepository userRepository;

    public Interaction sendInteraction(
            String senderEmail,
            Long receiverId) {

        User sender = userRepository.findByEmail(senderEmail)
                .orElseThrow(() ->
                        new RuntimeException("Sender not found"));

        User receiver = userRepository.findById(receiverId)
                .orElseThrow(() ->
                        new RuntimeException("Receiver not found"));

        if (sender.getId().equals(receiver.getId())) {
            throw new IllegalArgumentException(
                    "You cannot send an interaction to yourself"
            );
        }

        boolean pendingExists =
                interactionRepository
                        .existsBySenderAndReceiverAndStatus(
                                sender,
                                receiver,
                                InteractionStatus.PENDING
                        );

        if (pendingExists) {
            throw new IllegalArgumentException(
                    "Interaction already exists"
            );
        }

        boolean acceptedExists =
                interactionRepository
                        .existsBySenderAndReceiverAndStatus(
                                sender,
                                receiver,
                                InteractionStatus.ACCEPTED
                        );

        if (acceptedExists) {
            throw new IllegalArgumentException(
                    "Interaction already accepted"
            );
        }

        Interaction reversePending =
                interactionRepository
                        .findBySenderAndReceiverAndStatus(
                                receiver,
                                sender,
                                InteractionStatus.PENDING
                        )
                        .orElse(null);

        if (reversePending != null) {
            throw new IllegalArgumentException(
                    "The other user already has a pending interaction with you"
            );
        }

        Interaction reverseAccepted =
                interactionRepository
                        .findBySenderAndReceiverAndStatus(
                                receiver,
                                sender,
                                InteractionStatus.ACCEPTED
                        )
                        .orElse(null);

        if (reverseAccepted != null) {
            throw new IllegalArgumentException(
                    "An accepted interaction already exists between these users"
            );
        }

        Interaction interaction = Interaction.builder()
                .sender(sender)
                .receiver(receiver)
                .status(InteractionStatus.PENDING)
                .createdAt(LocalDateTime.now())
                .build();

        return interactionRepository.save(interaction);
    }

    public List<Interaction> getPendingInteractions(
            String receiverEmail) {

        User receiver = userRepository.findByEmail(receiverEmail)
                .orElseThrow(() ->
                        new RuntimeException("Receiver not found"));

        return interactionRepository.findByReceiverAndStatus(
                receiver,
                InteractionStatus.PENDING
        );
    }

    public Interaction acceptInteraction(
            String receiverEmail,
            Long interactionId) {

        User receiver = userRepository.findByEmail(receiverEmail)
                .orElseThrow(() ->
                        new RuntimeException("Receiver not found"));

        Interaction interaction =
                interactionRepository.findByIdAndReceiver(
                                interactionId,
                                receiver
                        )
                        .orElseThrow(() ->
                                new RuntimeException("Interaction not found"));

        if (interaction.getStatus() != InteractionStatus.PENDING) {
            throw new IllegalArgumentException(
                    "Interaction is no longer pending"
            );
        }

        interaction.setStatus(InteractionStatus.ACCEPTED);

        return interactionRepository.save(interaction);
    }

    public Interaction declineInteraction(
            String receiverEmail,
            Long interactionId) {

        User receiver = userRepository.findByEmail(receiverEmail)
                .orElseThrow(() ->
                        new RuntimeException("Receiver not found"));

        Interaction interaction =
                interactionRepository.findByIdAndReceiver(
                                interactionId,
                                receiver
                        )
                        .orElseThrow(() ->
                                new RuntimeException("Interaction not found"));

        if (interaction.getStatus() != InteractionStatus.PENDING) {
            throw new IllegalArgumentException(
                    "Interaction is no longer pending"
            );
        }

        interaction.setStatus(InteractionStatus.DECLINED);

        return interactionRepository.save(interaction);
    }
    public Interaction getLatestInteraction(
            String currentUserEmail,
            Long otherUserId) {

        User currentUser = userRepository.findByEmail(currentUserEmail)
                .orElseThrow(() ->
                        new RuntimeException("Current user not found"));

        User otherUser = userRepository.findById(otherUserId)
                .orElseThrow(() ->
                        new RuntimeException("User not found"));

        if (currentUser.getId().equals(otherUser.getId())) {
            throw new IllegalArgumentException(
                    "You cannot check interaction status with yourself"
            );
        }

        return interactionRepository
                .findInteractionsBetweenUsers(
                        currentUser,
                        otherUser
                )
                .stream()
                .findFirst()
                .orElse(null);
    }
}