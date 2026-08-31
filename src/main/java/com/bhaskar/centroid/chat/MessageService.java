package com.bhaskar.centroid.chat;

import com.bhaskar.centroid.user.User;
import com.bhaskar.centroid.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MessageService {

    private final MessageRepository messageRepository;
    private final ConversationRepository conversationRepository;
    private final UserRepository userRepository;

    public Message sendMessage(
            String senderEmail,
            Long conversationId,
            String content) {

        User sender = userRepository.findByEmail(senderEmail)
                .orElseThrow(() ->
                        new RuntimeException("Sender not found"));

        Conversation conversation =
                conversationRepository.findById(conversationId)
                        .orElseThrow(() ->
                                new RuntimeException("Conversation not found"));

        boolean isParticipant =
                conversation.getUserOne().getId().equals(sender.getId())
                        || conversation.getUserTwo().getId().equals(sender.getId());

        if (!isParticipant) {
            throw new IllegalArgumentException(
                    "You are not a participant in this conversation"
            );
        }

        Message message = Message.builder()
                .conversation(conversation)
                .sender(sender)
                .content(content)
                .createdAt(LocalDateTime.now())
                .build();

        return messageRepository.save(message);
    }

    public List<Message> getMessages(
            String userEmail,
            Long conversationId) {

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() ->
                        new RuntimeException("User not found"));

        Conversation conversation =
                conversationRepository.findById(conversationId)
                        .orElseThrow(() ->
                                new RuntimeException("Conversation not found"));

        boolean isParticipant =
                conversation.getUserOne().getId().equals(user.getId())
                        || conversation.getUserTwo().getId().equals(user.getId());

        if (!isParticipant) {
            throw new IllegalArgumentException(
                    "You are not a participant in this conversation"
            );
        }

        return messageRepository
                .findByConversationIdOrderByCreatedAtAsc(
                        conversationId
                );
    }
}