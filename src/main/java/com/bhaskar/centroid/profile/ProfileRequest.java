package com.bhaskar.centroid.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProfileRequest {

    @NotBlank
    @Size(max = 50)
    private String displayName;

    @Size(max = 500)
    private String profilePicture;

    @Size(max = 200)
    private String socialLink;

    @Size(max = 100)
    private String bio;
}