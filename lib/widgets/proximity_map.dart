import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/nearby_user.dart';
import 'nearby_user_bubble.dart';

class ProximityMap extends StatelessWidget {
  final List<NearbyUser> users;
  final double maxDistance;
  final ValueChanged<NearbyUser> onUserTap;

  const ProximityMap({
    super.key,
    required this.users,
    required this.maxDistance,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        final center = Offset(
          size / 2,
          size / 2,
        );

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ==================================================
              // PROXIMITY RINGS
              // ==================================================
              Positioned.fill(
                child: CustomPaint(
                  painter: _ProximityMapPainter(
                    maxRadius: size / 2,
                  ),
                ),
              ),

              // ==================================================
              // NEARBY USERS
              // ==================================================
              ...List.generate(
                users.length,
                    (index) {
                  final user = users[index];

                  // Temporary deterministic angle.
                  //
                  // The backend currently gives us distance,
                  // but not geographic bearing. Therefore we
                  // distribute users around the map for now.
                  final angle =
                      (-math.pi / 2) + (index * 1.45);

                  // Convert actual distance to a visual radius.
                  final distanceRatio =
                  (user.distanceMeters / maxDistance)
                      .clamp(0.18, 0.88);

                  final mapRadius =
                      (size / 2) * distanceRatio;

                  final x =
                      center.dx +
                          math.cos(angle) * mapRadius;

                  final y =
                      center.dy +
                          math.sin(angle) * mapRadius;

                  const bubbleSize = 62.0;

                  return Positioned(
                    left: x - bubbleSize / 2,
                    top: y - bubbleSize / 2,
                    child: NearbyUserBubble(
                      name: user.displayName,
                      imageUrl:
                      user.profilePicture ?? '',
                      distance:
                      user.distanceMeters.round(),
                      isOnline: false,
                      size: bubbleSize,
                      onTap: () => onUserTap(user),
                    ),
                  );
                },
              ),

              // ==================================================
              // CURRENT USER
              // ==================================================
              Positioned(
                left: center.dx - 34,
                top: center.dy - 34,
                child: const _CurrentUserMarker(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// CURRENT USER MARKER
// ============================================================

class _CurrentUserMarker extends StatelessWidget {
  const _CurrentUserMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: 0.20,
                ),
                blurRadius: 18,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),

        const SizedBox(height: 7),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: const Text(
            'You',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PROXIMITY RINGS PAINTER
// ============================================================

class _ProximityMapPainter extends CustomPainter {
  final double maxRadius;

  const _ProximityMapPainter({
    required this.maxRadius,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final rings = [
      maxRadius * 0.26,
      maxRadius * 0.47,
      maxRadius * 0.69,
      maxRadius * 0.91,
    ];

    for (int i = 0; i < rings.length; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth =
        i == rings.length - 1 ? 1.0 : 1.15
        ..color = AppColors.border.withValues(
          alpha: 0.65 - (i * 0.08),
        );

      canvas.drawCircle(
        center,
        rings[i],
        paint,
      );
    }

    // Subtle center glow.
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primarySoft.withValues(
        alpha: 0.28,
      );

    canvas.drawCircle(
      center,
      maxRadius * 0.18,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _ProximityMapPainter oldDelegate,
      ) {
    return oldDelegate.maxRadius != maxRadius;
  }
}