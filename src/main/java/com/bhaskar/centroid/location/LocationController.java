package com.bhaskar.centroid.location;

import com.bhaskar.centroid.dto.DiscoverabilityRequest;
import com.bhaskar.centroid.dto.LocationResponse;
import com.bhaskar.centroid.dto.LocationUpdateRequest;
import com.bhaskar.centroid.dto.NearbyUserResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/location")
@RequiredArgsConstructor
public class LocationController {

    private final LocationService locationService;

    @PutMapping
    public ResponseEntity<String> updateLocation(
            @Valid @RequestBody LocationUpdateRequest request,
            Authentication authentication) {

        locationService.updateLocation(
                authentication.getName(),
                request.getLatitude(),
                request.getLongitude()
        );

        return ResponseEntity.ok("Location updated successfully");
    }

    @GetMapping("/me")
    public ResponseEntity<LocationResponse> getMyLocation(
            Authentication authentication) {

        LocationResponse location =
                locationService.getMyLocation(
                        authentication.getName()
                );

        return ResponseEntity.ok(location);
    }

    @GetMapping("/nearby")
    public ResponseEntity<List<NearbyUserResponse>> findNearbyUsers(
            @RequestParam(defaultValue = "1000") double radius,
            Authentication authentication) {

        if (radius < 50 || radius > 5000) {
            throw new IllegalArgumentException(
                    "Radius must be between 50 and 5000 meters"
            );
        }

        List<NearbyUserResponse> nearbyUsers =
                locationService.findNearbyUsers(
                        authentication.getName(),
                        radius
                );

        return ResponseEntity.ok(nearbyUsers);
    }
    @PutMapping("/discoverable")
    public ResponseEntity<String> updateDiscoverability(
            @Valid @RequestBody DiscoverabilityRequest request,
            Authentication authentication) {

        locationService.updateDiscoverability(
                authentication.getName(),
                request.getDiscoverable()
        );

        return ResponseEntity.ok(
                request.getDiscoverable()
                        ? "You are now visible to nearby users"
                        : "You are now invisible to nearby users"
        );
    }
}