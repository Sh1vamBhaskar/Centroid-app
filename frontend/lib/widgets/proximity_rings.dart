import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class ProximityRings extends CustomPainter {
  const ProximityRings();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final maxRadius = size.shortestSide / 2;

    final radii = [
      maxRadius * 0.32,
      maxRadius * 0.55,
      maxRadius * 0.78,
      maxRadius,
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.border;

    for (final radius in radii) {
      canvas.drawCircle(
        center,
        radius,
        paint,
      );
    }

    // Soft center area
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primarySoft.withValues(alpha: 0.45);

    canvas.drawCircle(
      center,
      maxRadius * 0.17,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}