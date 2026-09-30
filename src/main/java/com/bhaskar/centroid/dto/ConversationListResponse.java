package com.bhaskar.centroid.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class ConversationListResponse {

    private Long id;
    private Long otherUserId;
    private String otherUserName;
    private String otherUserPicture;
    private LocalDateTime createdAt;
}