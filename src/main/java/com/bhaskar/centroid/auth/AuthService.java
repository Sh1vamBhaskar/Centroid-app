package com.bhaskar.centroid.auth;

import com.bhaskar.centroid.dto.AuthResponse;
import com.bhaskar.centroid.dto.LoginRequest;
import com.bhaskar.centroid.dto.RegisterRequest;
import com.bhaskar.centroid.security.JwtService;
import com.bhaskar.centroid.user.User;
import com.bhaskar.centroid.user.UserRepository;
import com.bhaskar.centroid.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserService userService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthResponse register(RegisterRequest request) {

        User user = userService.registerUser(
                request.getEmail(),
                request.getPassword()
        );

        return new AuthResponse(
                user.getId(),
                user.getEmail(),
                user.getRole()
        );
    }

    public AuthResponse login(LoginRequest request) {

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() ->
                        new RuntimeException("Invalid email or password"));

        if (!passwordEncoder.matches(
                request.getPassword(),
                user.getPassword())) {

            throw new RuntimeException("Invalid email or password");
        }

        String token = jwtService.generateToken(user.getEmail());

        return new AuthResponse(
                user.getId(),
                user.getEmail(),
                user.getRole(),
                token
        );
    }
}