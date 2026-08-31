package com.bhaskar.centroid.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final CustomUserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        System.out.println(
                "========================================"
        );

        System.out.println(
                "JWT CHECK: Request = "
                        + request.getMethod()
                        + " "
                        + request.getRequestURI()
        );

        // 1. Check Authorization header
        if (authHeader == null) {

            System.out.println(
                    "JWT CHECK: No Authorization header"
            );

            filterChain.doFilter(request, response);
            return;
        }

        System.out.println(
                "JWT CHECK: Authorization header received"
        );

        // 2. Check Bearer format
        if (!authHeader.startsWith("Bearer ")) {

            System.out.println(
                    "JWT CHECK: Authorization header is NOT Bearer"
            );

            filterChain.doFilter(request, response);
            return;
        }

        // 3. Extract token
        String jwt = authHeader.substring(7);

        System.out.println(
                "JWT CHECK: Token extracted"
        );

        // 4. Extract email
        String email;

        try {

            email = jwtService.extractEmail(jwt);

            System.out.println(
                    "JWT CHECK: Extracted email = " + email
            );

        } catch (Exception e) {

            System.out.println(
                    "JWT CHECK: FAILED TO EXTRACT TOKEN"
            );

            System.out.println(
                    "JWT CHECK ERROR: "
                            + e.getClass().getSimpleName()
                            + " - "
                            + e.getMessage()
            );

            filterChain.doFilter(request, response);
            return;
        }

        // 5. Check whether authentication already exists
        if (SecurityContextHolder
                .getContext()
                .getAuthentication() != null) {

            System.out.println(
                    "JWT CHECK: Authentication already exists"
            );

            filterChain.doFilter(request, response);
            return;
        }

        // 6. Load user
        UserDetails userDetails;

        try {

            userDetails =
                    userDetailsService.loadUserByUsername(email);

            System.out.println(
                    "JWT CHECK: User loaded = "
                            + userDetails.getUsername()
            );

        } catch (Exception e) {

            System.out.println(
                    "JWT CHECK: FAILED TO LOAD USER"
            );

            System.out.println(
                    "JWT CHECK ERROR: "
                            + e.getClass().getSimpleName()
                            + " - "
                            + e.getMessage()
            );

            filterChain.doFilter(request, response);
            return;
        }

        // 7. Validate token
        boolean valid;

        try {

            valid = jwtService.isTokenValid(jwt);

            System.out.println(
                    "JWT CHECK: Token valid = " + valid
            );

        } catch (Exception e) {

            System.out.println(
                    "JWT CHECK: TOKEN VALIDATION EXCEPTION"
            );

            System.out.println(
                    "JWT CHECK ERROR: "
                            + e.getClass().getSimpleName()
                            + " - "
                            + e.getMessage()
            );

            filterChain.doFilter(request, response);
            return;
        }

        // 8. Set authentication
        if (valid) {

            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(
                            userDetails,
                            null,
                            userDetails.getAuthorities()
                    );

            authentication.setDetails(
                    new WebAuthenticationDetailsSource()
                            .buildDetails(request)
            );

            SecurityContextHolder
                    .getContext()
                    .setAuthentication(authentication);

            System.out.println(
                    "JWT CHECK: Authentication set successfully"
            );

        } else {

            System.out.println(
                    "JWT CHECK: Authentication NOT set"
            );
        }

        System.out.println(
                "========================================"
        );

        // 9. Continue request
        filterChain.doFilter(request, response);
    }
}