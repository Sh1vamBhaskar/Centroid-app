package com.bhaskar.centroid.location;

import com.bhaskar.centroid.dto.LocationResponse;
import com.bhaskar.centroid.dto.NearbyUserResponse;
import com.bhaskar.centroid.user.User;
import com.bhaskar.centroid.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.bhaskar.centroid.exception.ResourceNotFoundException;


import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LocationService {

    private final UserLocationRepository userLocationRepository;
    private final UserRepository userRepository;

    private final GeometryFactory geometryFactory =
            new GeometryFactory(new PrecisionModel(), 4326);

    @Value("${location.freshness-minutes:5}")
    private long freshnessMinutes;

    public UserLocation updateLocation(
            String email,
            double latitude,
            double longitude) {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                                new ResourceNotFoundException("User not found"));

        UserLocation userLocation =
                userLocationRepository.findByUserId(user.getId())
                        .orElse(
                                UserLocation.builder()
                                        .user(user)
                                        .discoverable(true)
                                        .build()
                        );

        Point point = geometryFactory.createPoint(
                new Coordinate(longitude, latitude)
        );

        userLocation.setLocation(point);
        userLocation.setLastUpdated(LocalDateTime.now());

        return userLocationRepository.save(userLocation);
    }

    public UserLocation updateDiscoverability(
            String email,
            boolean discoverable) {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new ResourceNotFoundException("User not found"));

        UserLocation userLocation =
                userLocationRepository.findByUserId(user.getId())
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Current location not found"
                                ));

        userLocation.setDiscoverable(discoverable);

        return userLocationRepository.save(userLocation);
    }

    public LocationResponse getMyLocation(String email) {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RuntimeException("User not found"));

        UserLocation userLocation =
                userLocationRepository.findByUserId(user.getId())
                        .orElseThrow(() ->
                                new RuntimeException("Current location not found"));

        Point point = userLocation.getLocation();

        double latitude = point.getY();
        double longitude = point.getX();

        return new LocationResponse(
                latitude,
                longitude,
                userLocation.isDiscoverable(),
                userLocation.getLastUpdated()
        );
    }

    public List<NearbyUserResponse> findNearbyUsers(
            String email,
            double radius) {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RuntimeException("User not found"));

        UserLocation currentLocation =
                userLocationRepository.findByUserId(user.getId())
                        .orElseThrow(() ->
                                new RuntimeException("Current location not found"));

        String pointWkt =
                currentLocation.getLocation().toText();

        LocalDateTime cutoff =
                LocalDateTime.now().minusMinutes(freshnessMinutes);

        List<NearbyUserProjection> nearbyUsers =
                userLocationRepository.findNearbyUsersWithDistance(
                        user.getId(),
                        pointWkt,
                        radius,
                        cutoff
                );

        return nearbyUsers.stream()
                .map(nearbyUser ->
                        new NearbyUserResponse(
                                nearbyUser.getUserId(),
                                nearbyUser.getDisplayName() != null
                                        ? nearbyUser.getDisplayName()
                                        : nearbyUser.getEmail(),
                                nearbyUser.getProfilePicture(),
                                nearbyUser.getDistanceMeters()
                        )
                )
                .toList();
    }
}