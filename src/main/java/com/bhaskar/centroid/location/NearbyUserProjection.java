package com.bhaskar.centroid.location;

public interface NearbyUserProjection {

    Long getUserId();

    String getEmail();

    String getDisplayName();

    String getProfilePicture();

    Double getDistanceMeters();
}