package com.bhaskar.centroid.interaction;

import com.bhaskar.centroid.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

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
}