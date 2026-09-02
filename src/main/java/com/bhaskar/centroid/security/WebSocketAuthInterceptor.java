package com.bhaskar.centroid.security;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtService jwtService;
    private final CustomUserDetailsService userDetailsService;

    @Override
    public Message<?> preSend(
            Message<?> message,
            MessageChannel channel) {

        StompHeaderAccessor accessor =
                StompHeaderAccessor.wrap(message);

        StompCommand command = accessor.getCommand();

        System.out.println(
                "WS AUTH: command = " + command
        );

        String authHeader =
                accessor.getFirstNativeHeader("Authorization");

        /*
         * If the frame contains an Authorization header,
         * authenticate that frame.
         */
        if (authHeader != null &&
                authHeader.startsWith("Bearer ")) {

            String jwt = authHeader.substring(7);

            try {

                String email =
                        jwtService.extractEmail(jwt);

                UserDetails userDetails =
                        userDetailsService
                                .loadUserByUsername(email);

                if (!jwtService.isTokenValid(jwt)) {

                    throw new IllegalArgumentException(
                            "Invalid JWT"
                    );
                }

                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                userDetails,
                                null,
                                userDetails.getAuthorities()
                        );

                accessor.setUser(authentication);

                SecurityContextHolder
                        .getContext()
                        .setAuthentication(authentication);

                System.out.println(
                        "WS AUTH: authenticated = " + email
                );

            } catch (Exception e) {

                System.out.println(
                        "WS AUTH FAILED: "
                                + e.getClass().getSimpleName()
                                + " - "
                                + e.getMessage()
                );

                throw new IllegalArgumentException(
                        "WebSocket authentication failed"
                );
            }
        }

        /*
         * CONNECT must contain a valid Authorization header.
         */
        if (StompCommand.CONNECT.equals(command)) {

            if (accessor.getUser() == null) {

                throw new IllegalArgumentException(
                        "Authorization required for WebSocket connection"
                );
            }
        }

        /*
         * For SEND/SUBSCRIBE frames, if the STOMP session already
         * contains a user, preserve it.
         */
        if (accessor.getUser() != null) {

            SecurityContextHolder
                    .getContext()
                    .setAuthentication(
                            (UsernamePasswordAuthenticationToken)
                                    accessor.getUser()
                    );
        }

        return message;
    }
}