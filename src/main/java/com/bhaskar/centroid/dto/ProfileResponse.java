package com.bhaskar.centroid.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ProfileResponse {

    private Long id;
    private String displayName;
    private String profilePicture;
    private String socialLink;
    private String bio;
}