import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../soul/soul_states.dart';
import '../soul/soul_widget.dart';

class SpiralBackdrop extends StatelessWidget {
  final double height;
  final double bleedFactor;
  final double offsetFactor;
  final bool disableInteraction;
  final bool showParticles;
  final LinearGradient overlayGradient;

  const SpiralBackdrop({
    super.key,
    required this.height,
    required this.overlayGradient,
    this.bleedFactor = 1.4,
    this.offsetFactor = 0.5,
    this.disableInteraction = true,
    this.showParticles = true,
  });

  @override
  Widget build(BuildContext context) {
    final double overlayHeight = height * bleedFactor;
    final double topOffset = -(overlayHeight - height) * offsetFactor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: topOffset,
          left: 0,
          right: 0,
          height: overlayHeight,
          child: IgnorePointer(
            ignoring: disableInteraction,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SoulWidget(
                  config: SoulConfig.human(
                    height: double.infinity,
                    disableInteraction: true,
                  ).copyWith(backgroundColor: Colors.transparent),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(gradient: overlayGradient),
                ),
              ],
            ),
          ),
        ),
        if (showParticles) const Positioned.fill(child: SpiralParticleField()),
      ],
    );
  }
}

class SpiralParticleField extends StatelessWidget {
  const SpiralParticleField({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpiralParticlePainter(),
    );
  }
}

class _SpiralParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x33FFFFFF), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, paint);

    final noisePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final int particleCount = (size.width * 0.35).round();
    final double width = size.width;
    final double height = size.height;

    for (int i = 0; i < particleCount; i++) {
      final double x = (i * 37.0) % width;
      final double y = (math.sin(i * 0.18) * 0.5 + 0.5) * height;
      final double radius = 1.5 + math.sin(i * 0.45) * 0.8;
      canvas.drawCircle(Offset(x, y), radius.abs(), noisePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
