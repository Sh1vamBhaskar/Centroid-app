package com.bhaskar.centroid.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class LocationResponse {

    private double latitude;
    private double longitude;
    private boolean discoverable;
    private LocalDateTime lastUpdated;
}