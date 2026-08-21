package com.bhaskar.centroid.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class NearbyUserResponse {

    private Long userId;
    private String displayName;
    private String profilePicture;
    private double distanceMeters;
}