package com.bhaskar.centroid.dto;

import com.bhaskar.centroid.enums.Role;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class AuthResponse {

    private Long id;
    private String email;
    private Role role;
    private String token;

    public AuthResponse(Long id, String email, Role role) {
        this(id, email, role, null);
    }
}