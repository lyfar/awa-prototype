import 'package:flutter/material.dart';

/// Standard sphere configuration for consistent sizing across the app
class AwaSphereConfig {
  /// Standard height for lobby screens (larger now)
  static const double lobbyHeight = 340;

  /// Half-screen height ratio for other screens (60% now)
  static const double halfScreenRatio = 0.6;

  /// Primary coral/peach color
  static const Color primaryColor = Color(0xFFFCB29C);

  /// Secondary soft pink color
  static const Color secondaryColor = Color(0xFFE8D5D0);

  /// Accent highlight color
  static const Color accentColor = Color(0xFFFFD4C4);

  /// Standard particle count (dense coverage)
  static const int particleCount = 450;

  /// Standard particle size (smaller for denser packing)
  static const double particleSize = 3.0;

  /// Get height for half-screen mode
  static double getHalfScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * halfScreenRatio;
  }
}

/// Particle data for 3D rendering
class Particle {
  final double x;
  final double y;
  final double z;
  final int index;
  final double sparkle;
  final double waveOffset;

  Particle({
    required this.x,
    required this.y,
    required this.z,
    required this.index,
    required this.sparkle,
    required this.waveOffset,
  });
}


