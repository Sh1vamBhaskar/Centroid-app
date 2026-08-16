package com.bhaskar.centroid.profile;

import com.bhaskar.centroid.dto.ProfileRequest;
import com.bhaskar.centroid.dto.ProfileResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @PostMapping
    public ResponseEntity<ProfileResponse> createProfile(
            @Valid @RequestBody ProfileRequest request,
            Authentication authentication) {

        Profile profile = profileService.createProfile(
                authentication.getName(),
                request
        );


        ProfileResponse response = new ProfileResponse(
                profile.getId(),
                profile.getDisplayName(),
                profile.getProfilePicture(),
                profile.getSocialLink(),
                profile.getBio()
        );

        return ResponseEntity.ok(response);
    }
    @GetMapping("/me")
    public ResponseEntity<ProfileResponse> getMyProfile(
            Authentication authentication) {

        Profile profile = profileService.getMyProfile(
                authentication.getName()
        );

        ProfileResponse response = new ProfileResponse(
                profile.getId(),
                profile.getDisplayName(),
                profile.getProfilePicture(),
                profile.getSocialLink(),
                profile.getBio()
        );

        return ResponseEntity.ok(response);
    }
    @PutMapping("/me")
    public ResponseEntity<ProfileResponse> updateProfile(
            @Valid @RequestBody ProfileRequest request,
            Authentication authentication) {

        Profile profile = profileService.updateProfile(
                authentication.getName(),
                request
        );

        ProfileResponse response = new ProfileResponse(
                profile.getId(),
                profile.getDisplayName(),
                profile.getProfilePicture(),
                profile.getSocialLink(),
                profile.getBio()
        );

        return ResponseEntity.ok(response);
    }



}