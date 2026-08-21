package com.bhaskar.centroid.location;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface UserLocationRepository
        extends JpaRepository<UserLocation, Long> {

    Optional<UserLocation> findByUserId(Long userId);

    @Query(value = """
        SELECT
            ul.user_id AS userId,
            u.email AS email,
            p.display_name AS displayName,
            p.profile_picture AS profilePicture,
            ST_Distance(
                ul.location,
                CAST(:point AS geography)
            ) AS distanceMeters
        FROM user_locations ul
        JOIN users u
            ON u.id = ul.user_id
        LEFT JOIN profiles p
            ON p.user_id = ul.user_id
        WHERE ul.discoverable = true
          AND ul.user_id <> :userId
          AND ul.last_updated >= :cutoff
          AND ST_DWithin(
                ul.location,
                CAST(:point AS geography),
                :radius
          )
        ORDER BY distanceMeters
        """, nativeQuery = true)
    List<NearbyUserProjection> findNearbyUsersWithDistance(
            @Param("userId") Long userId,
            @Param("point") String point,
            @Param("radius") double radius,
            @Param("cutoff") LocalDateTime cutoff
    );
}