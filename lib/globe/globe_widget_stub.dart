import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'globe_states.dart';

const _holographicPalette = <Color>[
  Color(0xFF90F5FF),
  Color(0xFF9D7BFF),
  Color(0xFFFF8FFB),
  Color(0xFF7CFFB2),
  Color(0xFFFFE27A),
];

const Map<String, List<List<double>>> _continentLatLngs = {
  'northAmerica': [
    [72, -168],
    [72, -120],
    [70, -90],
    [61, -70],
    [50, -55],
    [40, -70],
    [30, -85],
    [15, -95],
    [5, -105],
    [10, -125],
    [30, -140],
    [50, -150],
  ],
  'southAmerica': [
    [12, -81],
    [5, -75],
    [-10, -77],
    [-30, -70],
    [-50, -64],
    [-55, -50],
    [-35, -45],
    [-5, -50],
    [8, -60],
  ],
  'europe': [
    [71, -10],
    [70, 15],
    [64, 30],
    [54, 40],
    [45, 20],
    [36, 0],
    [50, -5],
  ],
  'africa': [
    [35, -17],
    [33, 15],
    [23, 30],
    [5, 38],
    [-15, 35],
    [-30, 20],
    [-34, 10],
    [-30, -10],
    [-5, -17],
  ],
  'asia': [
    [78, 45],
    [70, 90],
    [60, 135],
    [45, 150],
    [25, 140],
    [10, 115],
    [20, 95],
    [30, 70],
    [40, 55],
    [55, 60],
  ],
  'australia': [
    [-10, 110],
    [-12, 145],
    [-32, 150],
    [-44, 130],
    [-28, 112],
  ],
};

/// Stub implementation for non-web platforms
class GlobeRenderer extends StatelessWidget {
  final GlobeConfig config;
  final Color backgroundColor;

  const GlobeRenderer({
    super.key,
    required this.config,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    String stateTitle;
    String stateSubtitle;

    // Handle transition states
    if (config.isTransitioning && config.transitionState != null) {
      switch (config.transitionState!) {
        case GlobeTransitionState.lightToAwaSoul:
          stateTitle = 'Expanding Consciousness';
          stateSubtitle = 'Zooming out to reveal the orbital particle field...';
          break;
        case GlobeTransitionState.awaSoulToGlobe:
          stateTitle = 'Earth Emergence';
          stateSubtitle =
              'The globe texture fades in as community particles appear...';
          break;
        case GlobeTransitionState.globeToAwaSoul:
          stateTitle = 'Returning to Orbit';
          stateSubtitle =
              'Earth texture fades as we return to particle view...';
          break;
        case GlobeTransitionState.awaSoulToLight:
          stateTitle = 'Focusing Inward';
          stateSubtitle = 'Zooming in to the core light source...';
          break;
      }
    } else {
      // Handle static states
      switch (config.state) {
        case GlobeState.light:
          stateTitle = 'Inner Light Resonance';
          stateSubtitle = 'Extreme close-up on a single luminous origin.';
          break;
        case GlobeState.awaSoul:
          stateTitle = 'Orbital Constellation';
          stateSubtitle =
              'Satellite points sweep across the globe before the map fades in.';
          break;
        case GlobeState.globe:
          stateTitle = 'Global Holographic Field';
          stateSubtitle =
              'Continents fade in to anchor the holographic network.';
          break;
      }
    }

    final palette = _holographicPalette;
    final backgroundGradient = const LinearGradient(
      colors: [Color(0xFF05010D), Color(0xFF0D1630)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final decoration =
        backgroundColor == Colors.black
            ? BoxDecoration(gradient: backgroundGradient)
            : BoxDecoration(color: backgroundColor);

    return Container(
      decoration: decoration,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableHeight =
              constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : (config.height.isFinite ? config.height : 320.0);
          final double globeDiameter = math.min(availableHeight, 280.0);

          final column = Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: globeDiameter,
                height: globeDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: palette.first.withValues(alpha: 0.35),
                      blurRadius: 45,
                      spreadRadius: 6,
                    ),
                    BoxShadow(
                      color: palette[2].withValues(alpha: 0.18),
                      blurRadius: 90,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomPaint(
                    painter: _HolographicGlobePainter(palette),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                stateTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                stateSubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (config.showUserLight) ...[
                const SizedBox(height: 12),
                Text(
                  'Your light is shimmering across the globe ✨',
                  style: TextStyle(
                    color: palette[0].withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );

          if (constraints.maxHeight.isFinite &&
              constraints.maxHeight < globeDiameter + 140) {
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: column),
              ),
            );
          }

          return Center(child: column);
        },
      ),
    );
  }

  /// Static methods for welcome screen transitions (stub implementation)
  static void transitionToAwaSoul() {
    print('GlobeRenderer: (Stub) Transition Light → Awa Soul');
  }

  static void transitionToGlobe() {
    print('GlobeRenderer: (Stub) Transition Awa Soul → Globe');
  }

  static void transitionToLight() {
    print('GlobeRenderer: (Stub) Transition Awa Soul → Light');
  }

  static void transitionGlobeToAwaSoul() {
    print('GlobeRenderer: (Stub) Transition Globe → Awa Soul');
  }
}

class _HolographicGlobePainter extends CustomPainter {
  const _HolographicGlobePainter(this.palette);

  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = rect.shortestSide / 2;

    final outerGlow =
        Paint()
          ..shader = RadialGradient(
            colors: [palette[1].withValues(alpha: 0.32), Colors.transparent],
          ).createShader(
            Rect.fromCircle(center: center, radius: radius * 1.25),
          );
    canvas.drawCircle(center, radius * 1.15, outerGlow);

    final mainGradient = RadialGradient(
      colors: [
        palette[0].withValues(alpha: 0.92),
        palette[1].withValues(alpha: 0.85),
        palette[2].withValues(alpha: 0.78),
        palette[3].withValues(alpha: 0.72),
      ],
      stops: const [0.0, 0.45, 0.72, 1.0],
    );

    final globePaint =
        Paint()
          ..shader = mainGradient.createShader(
            Rect.fromCircle(center: center, radius: radius),
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center, radius, globePaint);

    final highlightPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.45), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: center.translate(-radius * 0.28, -radius * 0.32),
              radius: radius * 0.55,
            ),
          );
    canvas.drawCircle(
      center.translate(-radius * 0.28, -radius * 0.32),
      radius * 0.55,
      highlightPaint,
    );

    final clipPath =
        Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(clipPath);
    _drawContinents(canvas, size);
    canvas.restore();
  }

  void _drawContinents(Canvas canvas, Size size) {
    final entries = _continentLatLngs.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final coords = entries[i].value;
      if (coords.length < 3) continue;

      final projected = coords
          .map((pair) => _project(pair[0], pair[1], size))
          .toList(growable: false);

      final path = Path()..moveTo(projected.first.dx, projected.first.dy);
      for (var j = 1; j < projected.length; j++) {
        path.lineTo(projected[j].dx, projected[j].dy);
      }
      path.close();

      final bounds = path.getBounds();
      final gradient = LinearGradient(
        colors: [
          palette[i % palette.length].withValues(alpha: 0.85),
          palette[(i + 2) % palette.length].withValues(alpha: 0.7),
          palette[(i + 3) % palette.length].withValues(alpha: 0.82),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds);

      final fillPaint =
          Paint()
            ..shader = gradient
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
            ..blendMode = BlendMode.plus;
      canvas.drawPath(path, fillPaint);

      final glowPaint =
          Paint()
            ..color = palette[(i + 1) % palette.length].withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32)
            ..blendMode = BlendMode.plus;
      canvas.drawPath(path, glowPaint);
    }
  }

  Offset _project(double lat, double lng, Size size) {
    final x = (lng + 180) / 360 * size.width;
    final y = (90 - lat) / 180 * size.height;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant _HolographicGlobePainter oldDelegate) {
    return !identical(oldDelegate.palette, palette);
  }
}
