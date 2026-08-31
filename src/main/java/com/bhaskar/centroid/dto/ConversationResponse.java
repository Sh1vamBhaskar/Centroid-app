package com.bhaskar.centroid.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class ConversationResponse {

    private Long id;
    private Long userOneId;
    private Long userTwoId;
    private LocalDateTime createdAt;
}