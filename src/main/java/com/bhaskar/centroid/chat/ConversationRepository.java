package com.bhaskar.centroid.chat;

import com.bhaskar.centroid.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ConversationRepository
        extends JpaRepository<Conversation, Long> {

    Optional<Conversation> findByUserOneAndUserTwo(
            User userOne,
            User userTwo
    );

    List<Conversation> findByUserOneOrUserTwoOrderByCreatedAtDesc(
            User userOne,
            User userTwo
    );
}