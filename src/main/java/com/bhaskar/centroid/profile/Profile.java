package com.bhaskar.centroid.profile;

import com.bhaskar.centroid.user.User;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "profiles")
public class Profile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            unique = true
    )
    private User user;

    @Column(nullable = false, length = 50)
    private String displayName;

    @Column(length = 500)
    private String profilePicture;

    @Column(length = 200)
    private String socialLink;

    @Column(length = 100)
    private String bio;
}
