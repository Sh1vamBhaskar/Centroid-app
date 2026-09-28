package com.bhaskar.centroid.interaction;

import com.bhaskar.centroid.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface InteractionRepository
        extends JpaRepository<Interaction, Long> {

    Optional<Interaction> findBySenderAndReceiverAndStatus(
            User sender,
            User receiver,
            InteractionStatus status
    );

    boolean existsBySenderAndReceiverAndStatus(
            User sender,
            User receiver,
            InteractionStatus status
    );

    List<Interaction> findByReceiverAndStatus(
            User receiver,
            InteractionStatus status
    );

    Optional<Interaction> findByIdAndReceiver(
            Long id,
            User receiver
    );

    @Query("""
            SELECT i
            FROM Interaction i
            WHERE (i.sender = :user1 AND i.receiver = :user2)
               OR (i.sender = :user2 AND i.receiver = :user1)
            ORDER BY i.createdAt DESC
            """)
    List<Interaction> findInteractionsBetweenUsers(
            @Param("user1") User user1,
            @Param("user2") User user2
    );
}