package com.bhaskar.centroid.dto;

import com.bhaskar.centroid.interaction.InteractionStatus;

public record InteractionStatusResponse(
        InteractionStatus status,
        Long interactionId
) {
}