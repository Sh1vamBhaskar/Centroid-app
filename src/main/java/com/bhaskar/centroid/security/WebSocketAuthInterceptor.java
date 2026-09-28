package com.bhaskar.centroid.security;

import org.springframework.messaging.support.MessageBuilder;

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

import java.security.Principal;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtService jwtService;
    private final CustomUserDetailsService userDetailsService;

    /*
     * Stores authenticated users against their STOMP session ID.
     *
     * CONNECT -> save user
     * SEND/SUBSCRIBE -> retrieve user
     * DISCONNECT -> remove user
     */
    private final Map<String, Principal> sessionUsers =
            new ConcurrentHashMap<>();

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

        /*
         * ---------------------------------------------------------
         * 1. CONNECT
         * ---------------------------------------------------------
         *
         * Authenticate the initial WebSocket/STOMP connection
         * using the JWT sent by Flutter.
         */
        if (StompCommand.CONNECT.equals(command)) {

            String authHeader =
                    accessor.getFirstNativeHeader("Authorization");

            if (authHeader == null ||
                    !authHeader.startsWith("Bearer ")) {

                throw new IllegalArgumentException(
                        "Authorization required for WebSocket connection"
                );
            }

            String jwt = authHeader.substring(7);

            try {

                String email =
                        jwtService.extractEmail(jwt);

                if (!jwtService.isTokenValid(jwt)) {

                    throw new IllegalArgumentException(
                            "Invalid JWT"
                    );
                }

                UserDetails userDetails =
                        userDetailsService
                                .loadUserByUsername(email);

                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                userDetails,
                                null,
                                userDetails.getAuthorities()
                        );

                /*
                 * Attach user to this STOMP message.
                 */
                accessor.setUser(authentication);

                /*
                 * Store user against STOMP session.
                 */
                String sessionId =
                        accessor.getSessionId();

                if (sessionId != null) {

                    sessionUsers.put(
                            sessionId,
                            authentication
                    );
                }

                /*
                 * Also set SecurityContext for this thread.
                 */
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

            return message;
        }

        /*
         * ---------------------------------------------------------
         * 2. SEND / SUBSCRIBE
         * ---------------------------------------------------------
         *
         * Recover the authenticated user from the STOMP session.
         */
        String sessionId =
                accessor.getSessionId();

        if (sessionId != null) {

            Principal sessionUser =
                    sessionUsers.get(sessionId);

            if (sessionUser != null) {

                /*
                 * If Spring has not attached the Principal to this
                 * frame, attach our stored Principal now.
                 */
                if (accessor.getUser() == null) {

                    accessor.setUser(sessionUser);
                }

                /*
                 * Restore SecurityContext for this thread.
                 */
                if (sessionUser instanceof UsernamePasswordAuthenticationToken) {

                    SecurityContextHolder
                            .getContext()
                            .setAuthentication(
                                    (UsernamePasswordAuthenticationToken)
                                            sessionUser
                            );
                }

                System.out.println(
                        "WS AUTH: session user = "
                                + sessionUser.getName()
                );
            }
        }

        /*
         * ---------------------------------------------------------
         * 3. DISCONNECT
         * ---------------------------------------------------------
         *
         * Remove the user from memory after the WebSocket closes.
         */
        if (StompCommand.DISCONNECT.equals(command)) {

            if (sessionId != null) {

                sessionUsers.remove(sessionId);

                System.out.println(
                        "WS AUTH: session removed = "
                                + sessionId
                );
            }

            SecurityContextHolder.clearContext();
        }

        return MessageBuilder.createMessage(
                message.getPayload(),
                accessor.getMessageHeaders()
        );
    }

    /*
     * Returns the authenticated Principal associated
     * with a STOMP session.
     */
    public Principal getSessionUser(String sessionId) {
        return sessionUsers.get(sessionId);
    }

}
