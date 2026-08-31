package com.bhaskar.centroid.dto;

import com.bhaskar.centroid.interaction.InteractionStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class InteractionResponse {

    private Long id;
    private Long senderId;
    private Long receiverId;
    private InteractionStatus status;
    private LocalDateTime createdAt;
}