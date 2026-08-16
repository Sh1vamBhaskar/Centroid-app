package com.bhaskar.centroid.profile;

import com.bhaskar.centroid.dto.ProfileRequest;
import com.bhaskar.centroid.user.User;
import com.bhaskar.centroid.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;

    public Profile createProfile(
            String email,
            ProfileRequest request) {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RuntimeException("User not found"));

        if (profileRepository.findByUserId(user.getId()).isPresent()) {
            throw new RuntimeException("Profile already exists");
        }

        Profile profile = Profile.builder()
                .user(user)
                .displayName(request.getDisplayName())
                .profilePicture(request.getProfilePicture())
                .socialLink(request.getSocialLink())
                .bio(request.getBio())
                .build();

        return profileRepository.save(profile);
    }
    public Profile getMyProfile(String email) {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RuntimeException("User not found"));

        return profileRepository.findByUserId(user.getId())
                .orElseThrow(() ->
                        new RuntimeException("Profile not found"));
    }
    public Profile updateProfile(
            String email,
            ProfileRequest request) {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RuntimeException("User not found"));

        Profile profile = profileRepository.findByUserId(user.getId())
                .orElseThrow(() ->
                        new RuntimeException("Profile not found"));

        profile.setDisplayName(request.getDisplayName());
        profile.setProfilePicture(request.getProfilePicture());
        profile.setSocialLink(request.getSocialLink());
        profile.setBio(request.getBio());

        return profileRepository.save(profile);
    }
}