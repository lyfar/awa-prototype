import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/meditation_models.dart';

/// Helper class for floating icon positions
class IconPosition {
  final double left;
  final double top;
  final double size;
  final bool isCenter;

  const IconPosition({
    required this.left,
    required this.top,
    required this.size,
    this.isCenter = false,
  });
}

/// Floating icons overlay that animates with the sphere
/// Each icon represents a user/light - they glow with inner light
class FloatingIconsOverlay extends StatefulWidget {
  final List<PracticeTypeGroup> groups;
  final int selectedIndex;
  final Function(int) onSelect;
  final List<Color> iconColors;
  final IconData Function(PracticeType) getIcon;

  const FloatingIconsOverlay({
    super.key,
    required this.groups,
    required this.selectedIndex,
    required this.onSelect,
    required this.iconColors,
    required this.getIcon,
  });

  @override
  State<FloatingIconsOverlay> createState() => _FloatingIconsOverlayState();
}

class _FloatingIconsOverlayState extends State<FloatingIconsOverlay>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _driftController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Slow floating animation - prime duration to avoid sync
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4700),
    );

    // Horizontal drift - different prime duration
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6100),
    );

    // Glow pulse - breathing light effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    // Start at random points
    _floatController.value = 0.33;
    _driftController.value = 0.71;
    _glowController.value = 0.5;

    _floatController.repeat(reverse: true);
    _driftController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _driftController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Positions scattered across the sphere area
    final positions = [
      const IconPosition(left: 0.18, top: 0.15, size: 48),
      const IconPosition(left: 0.72, top: 0.12, size: 44),
      const IconPosition(left: 0.08, top: 0.42, size: 52),
      const IconPosition(left: 0.50, top: 0.35, size: 68, isCenter: true),
      const IconPosition(left: 0.85, top: 0.48, size: 46),
      const IconPosition(left: 0.25, top: 0.72, size: 50),
      const IconPosition(left: 0.68, top: 0.78, size: 42),
    ];

    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatController,
        _driftController,
        _glowController,
      ]),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              clipBehavior: Clip.none,
              children: List.generate(
                widget.groups.length.clamp(0, positions.length),
                (index) {
                  final pos = positions[index];
                  final group = widget.groups[index];
                  final isSelected = index == widget.selectedIndex;
                  final color = widget.iconColors[index % widget.iconColors.length];

                  // Each icon has unique float offset based on index
                  final floatPhase = _floatController.value * 2 * math.pi;
                  final driftPhase = _driftController.value * 2 * math.pi;
                  final glowPhase = _glowController.value;

                  // Unique offset per icon
                  final floatY = math.sin(floatPhase + index * 1.3) * 8;
                  final floatX = math.cos(driftPhase + index * 0.9) * 5;

                  // Unique glow pulse per icon
                  final glowIntensity =
                      0.6 + math.sin(glowPhase * math.pi * 2 + index * 0.7) * 0.4;

                  // Scale pulse for selected
                  final scalePulse = isSelected
                      ? 1.0 + math.sin(floatPhase * 2) * 0.04
                      : 1.0 + math.sin(floatPhase * 1.5 + index) * 0.015;

                  final baseSize = isSelected ? pos.size * 1.25 : pos.size;
                  final size = baseSize * scalePulse;

                  return Positioned(
                    left: pos.left * width - size / 2 + floatX,
                    top: pos.top * height - size / 2 + floatY,
                    child: GestureDetector(
                      onTap: () => widget.onSelect(index),
                      child: GlowingOrb(
                        size: size,
                        color: color,
                        isSelected: isSelected,
                        glowIntensity: glowIntensity,
                        icon: widget.getIcon(group.type),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// A single glowing orb that represents a light/user
class GlowingOrb extends StatelessWidget {
  final double size;
  final Color color;
  final bool isSelected;
  final double glowIntensity;
  final IconData icon;

  const GlowingOrb({
    super.key,
    required this.size,
    required this.color,
    required this.isSelected,
    required this.glowIntensity,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final brightColor = Color.lerp(color, Colors.white, 0.5)!;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: OrbGlowPainter(
          color: color,
          glowIntensity: glowIntensity,
          isSelected: isSelected,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 0.9,
              colors: [
                Colors.white,
                Colors.white.withValues(alpha: 0.95),
                brightColor.withValues(alpha: 0.3),
                color.withValues(alpha: isSelected ? 0.4 : 0.2),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.8)
                  : color.withValues(alpha: 0.25 + glowIntensity * 0.2),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2 * glowIntensity),
                blurRadius: size * 0.4,
                spreadRadius: size * 0.05,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: size * 0.2,
                offset: Offset(0, size * 0.05),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Highlight spot
              Positioned(
                left: size * 0.15,
                top: size * 0.12,
                child: Container(
                  width: size * 0.22,
                  height: size * 0.18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.5 * glowIntensity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Icon
              Center(
                child: Icon(
                  icon,
                  size: size * 0.38,
                  color: color.withValues(alpha: 0.8 + glowIntensity * 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for outer glow effect
class OrbGlowPainter extends CustomPainter {
  final Color color;
  final double glowIntensity;
  final bool isSelected;

  OrbGlowPainter({
    required this.color,
    required this.glowIntensity,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow
    if (glowIntensity > 0.3) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.2 * glowIntensity),
            color.withValues(alpha: 0.08 * glowIntensity),
            Colors.transparent,
          ],
          stops: const [0.4, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3));
      canvas.drawCircle(center, radius * 1.3, glowPaint);
    }

    // Selection ring
    if (isSelected) {
      final ringPaint = Paint()
        ..color = color.withValues(alpha: 0.15 * glowIntensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius * 1.12, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OrbGlowPainter oldDelegate) {
    return color != oldDelegate.color ||
        glowIntensity != oldDelegate.glowIntensity ||
        isSelected != oldDelegate.isSelected;
  }
}











