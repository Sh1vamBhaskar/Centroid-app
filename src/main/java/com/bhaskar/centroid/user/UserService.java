package com.bhaskar.centroid.user;

import com.bhaskar.centroid.enums.Role;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public boolean existsByEmail(String email) {
        return userRepository.findByEmail(email).isPresent();
    }

    public User registerUser(String email, String password) {

        if (existsByEmail(email)) {
            throw new RuntimeException("Email already registered");
        }

        User user = User.builder()
                .email(email)
                .password(passwordEncoder.encode(password))
                .role(Role.USER)
                .enabled(true)
                .build();

        return userRepository.save(user);
    }
}