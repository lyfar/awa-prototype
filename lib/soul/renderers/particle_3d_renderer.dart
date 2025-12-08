import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../awa_soul_settings.dart';
import '../awa_sphere_config.dart';

/// Renders the 3D particles with light effects
class Particle3DRenderer {
  final double sparklePhase;
  final double particleSize;
  final double emissiveIntensity;
  final double coreIntensity;
  final double glowRadius;
  final double glowSoftness;
  final bool additiveBlending;
  final double haloOpacity;
  final MotionPattern motionPattern;
  final WiggleStyle wiggleStyle;
  final FlickerMode flickerMode;
  final double driftSpeed;
  final double driftIntensity;
  final double wobbleSpeed;
  final double wiggleIntensity;
  final double flickerSpeed;
  final double flickerIntensity;
  final double pulseSpeed;
  final double sizeVariation;
  final Color coreColor;
  final Color midColor;
  final Color outerColor;

  Particle3DRenderer({
    required this.sparklePhase,
    required this.particleSize,
    this.emissiveIntensity = 3.0,
    this.coreIntensity = 4.0,
    this.glowRadius = 1.0,
    this.glowSoftness = 20.0,
    this.additiveBlending = true,
    this.haloOpacity = 0.4,
    this.motionPattern = MotionPattern.gentle,
    this.wiggleStyle = WiggleStyle.subtle,
    this.flickerMode = FlickerMode.gentle,
    this.driftSpeed = 1.0,
    this.driftIntensity = 1.5,
    this.wobbleSpeed = 1.0,
    this.wiggleIntensity = 0.12,
    this.flickerSpeed = 2.6,
    this.flickerIntensity = 0.15,
    this.pulseSpeed = 2.98,
    this.sizeVariation = 0.5,
    this.coreColor = const Color(0xFFFFFFFB),
    this.midColor = const Color(0xFFFFE8C0),
    this.outerColor = const Color(0xFFFFB880),
  });

  void paintParticle(Canvas canvas, Offset center, Particle particle, double radius) {
    final depthFactor = (particle.z + 1) / 2; // 0 to 1, back to front

    // Calculate drift based on motion pattern
    final drift = _calculateDrift(particle, radius);
    final pos = center + Offset(particle.x + drift.dx, particle.y + drift.dy);

    // Size variation
    final sizeVar = (1.0 - sizeVariation * 0.5) + 
        (math.sin(particle.index * 1.7) + 1) * sizeVariation * 0.5;

    // Flicker factor
    final flickerFactor = _calculateFlickerFactor(particle, depthFactor);
    
    // Pulse
    final pulse = math.sin(sparklePhase * 0.8 * pulseSpeed + particle.index * 0.15);
    final pulseFactor = 0.9 + pulse * 0.1;

    // Colors based on position
    final colors = _calculateColors(particle, radius);
    var baseColor = colors.$1;
    var particleCoreColor = colors.$2;

    // Apply additive blending
    final emissiveMult = emissiveIntensity;
    if (additiveBlending) {
      baseColor = _applyAdditive(baseColor, emissiveMult * 0.3);
      particleCoreColor = _applyAdditive(particleCoreColor, emissiveMult * 0.5);
    }

    // Brightness
    final brightness = (0.5 + depthFactor * 0.5) * flickerFactor * pulseFactor * emissiveMult;
    final opacity = math.min(1.0, brightness);

    // Size with variations
    final sizeMultiplier = sizeVar * (0.6 + depthFactor * 0.4) * flickerFactor;
    final currentSize = particleSize * sizeMultiplier;

    // Wiggle
    final wobbles = _calculateWiggle(particle, currentSize, depthFactor);
    final wobble1 = wobbles.$1;
    final wobble2 = wobbles.$2;
    final wobble3 = wobbles.$3;

    // Draw the particle layers
    _drawParticleLayers(
      canvas, pos, currentSize, depthFactor, opacity,
      baseColor, particleCoreColor,
      wobble1, wobble2, wobble3,
      flickerFactor, pulseFactor, particle.sparkle,
    );
  }

  Offset _calculateDrift(Particle particle, double radius) {
    double driftX = 0, driftY = 0;
    
    switch (motionPattern) {
      case MotionPattern.gentle:
        driftX = math.sin(sparklePhase * 0.3 * driftSpeed + particle.index * 0.5) * driftIntensity;
        driftY = math.cos(sparklePhase * 0.25 * driftSpeed + particle.index * 0.7) * driftIntensity * 0.8;
        break;
      case MotionPattern.organic:
        driftX = math.sin(sparklePhase * 0.2 * driftSpeed + particle.index * 0.3) * driftIntensity
               + math.sin(sparklePhase * 0.5 * driftSpeed + particle.index * 1.1) * driftIntensity * 0.3;
        driftY = math.cos(sparklePhase * 0.18 * driftSpeed + particle.index * 0.5) * driftIntensity
               + math.cos(sparklePhase * 0.45 * driftSpeed + particle.index * 0.9) * driftIntensity * 0.3;
        break;
      case MotionPattern.pulsing:
        final pulseOffset = math.sin(sparklePhase * 0.5 * driftSpeed) * driftIntensity * 0.5;
        driftX = (particle.x / radius) * pulseOffset * 10;
        driftY = (particle.y / radius) * pulseOffset * 10;
        break;
      case MotionPattern.swirl:
        final angle = sparklePhase * 0.1 * driftSpeed;
        final originalDist = math.sqrt(particle.x * particle.x + particle.y * particle.y);
        driftX = (math.cos(angle) * driftIntensity - math.sin(angle) * driftIntensity * 0.2) * originalDist / radius;
        driftY = (math.sin(angle) * driftIntensity + math.cos(angle) * driftIntensity * 0.2) * originalDist / radius;
        break;
      case MotionPattern.jitter:
        driftX = math.sin(sparklePhase * 3 * driftSpeed + particle.index * 2.1) * driftIntensity * 0.5;
        driftY = math.cos(sparklePhase * 2.7 * driftSpeed + particle.index * 1.9) * driftIntensity * 0.5;
        break;
      case MotionPattern.breathe:
        final breathPhase = math.sin(sparklePhase * 0.15 * driftSpeed);
        driftX = (particle.x / radius) * breathPhase * driftIntensity * 5;
        driftY = (particle.y / radius) * breathPhase * driftIntensity * 5;
        break;
      case MotionPattern.float:
        driftX = math.sin(sparklePhase * 0.2 * driftSpeed + particle.index * 0.4) * driftIntensity * 0.5;
        driftY = -(math.sin(sparklePhase * 0.1 * driftSpeed + particle.index * 0.2)).abs() * driftIntensity * 1.5
               + math.cos(sparklePhase * 0.25 * driftSpeed + particle.index * 0.6) * driftIntensity * 0.3;
        break;
    }
    
    return Offset(driftX, driftY);
  }

  double _calculateFlickerFactor(Particle particle, double depthFactor) {
    switch (flickerMode) {
      case FlickerMode.off:
        return 1.0;
      case FlickerMode.gentle:
        final f1 = math.sin(sparklePhase * 1.8 * flickerSpeed + particle.index * 0.4);
        final f2 = math.cos(sparklePhase * 1.4 * flickerSpeed + particle.index * 0.7);
        return 1.0 - flickerIntensity + (f1 * 0.5 + f2 * 0.5 + 1) * flickerIntensity * 0.5;
      case FlickerMode.candle:
        final n1 = math.sin(sparklePhase * 2.5 * flickerSpeed + particle.index * 0.3);
        final n2 = math.cos(sparklePhase * 1.8 * flickerSpeed + particle.index * 0.5);
        final n3 = math.sin(sparklePhase * 4.0 * flickerSpeed + particle.index * 0.8);
        return 1.0 + (n1 * n2 + n3 * 0.3) * flickerIntensity;
      case FlickerMode.sparkle:
        final sparkVal = math.sin(sparklePhase * 5 * flickerSpeed + particle.index * 2.3);
        return sparkVal > 0.6 ? 1.0 + flickerIntensity * 2 : 1.0 - flickerIntensity * 0.2;
      case FlickerMode.sync:
        final syncFlicker = math.sin(sparklePhase * 2 * flickerSpeed);
        return 1.0 - flickerIntensity + syncFlicker * flickerIntensity;
      case FlickerMode.wave:
        final waveOffset = depthFactor * 4;
        final waveFlicker = math.sin(sparklePhase * flickerSpeed - waveOffset);
        return 1.0 - flickerIntensity + waveFlicker * flickerIntensity;
    }
  }

  (Color, Color) _calculateColors(Particle particle, double radius) {
    final normalizedX = (particle.x / radius + 1) / 2;
    final normalizedY = (particle.y / radius + 1) / 2;
    final gradientFactor = (normalizedX * 0.4 + normalizedY * 0.6);

    Color baseColor;
    Color particleCoreColor;
    
    if (gradientFactor < 0.3) {
      baseColor = Color.lerp(outerColor, midColor, gradientFactor / 0.3)!;
      particleCoreColor = Color.lerp(midColor, coreColor, gradientFactor / 0.3)!;
    } else if (gradientFactor < 0.6) {
      baseColor = Color.lerp(midColor, coreColor, (gradientFactor - 0.3) / 0.3)!;
      particleCoreColor = Color.lerp(coreColor, Colors.white, (gradientFactor - 0.3) / 0.3 * 0.3)!;
    } else {
      baseColor = Color.lerp(coreColor, Colors.white, (gradientFactor - 0.6) / 0.4 * 0.2)!;
      particleCoreColor = Color.lerp(coreColor, Colors.white, 0.3)!;
    }
    
    return (baseColor, particleCoreColor);
  }

  (double, double, double) _calculateWiggle(Particle particle, double currentSize, double depthFactor) {
    double w1 = 0, w2 = 0, w3 = 0;
    
    switch (wiggleStyle) {
      case WiggleStyle.none:
        break;
      case WiggleStyle.subtle:
        w1 = math.sin(sparklePhase * 1.2 * wobbleSpeed + particle.index) * currentSize * wiggleIntensity;
        w2 = math.cos(sparklePhase * 1.0 * wobbleSpeed + particle.index * 1.3) * currentSize * wiggleIntensity * 0.8;
        w3 = math.sin(sparklePhase * 1.5 * wobbleSpeed + particle.index * 0.8) * currentSize * wiggleIntensity * 0.6;
        break;
      case WiggleStyle.fluid:
        w1 = math.sin(sparklePhase * 0.8 * wobbleSpeed + particle.index * 0.5) * currentSize * wiggleIntensity * 1.5;
        w2 = math.cos(sparklePhase * 0.6 * wobbleSpeed + particle.index * 0.7) * currentSize * wiggleIntensity * 1.3;
        w3 = math.sin(sparklePhase * 0.9 * wobbleSpeed + particle.index * 0.4) * currentSize * wiggleIntensity;
        break;
      case WiggleStyle.electric:
        w1 = math.sin(sparklePhase * 4 * wobbleSpeed + particle.index * 2) * currentSize * wiggleIntensity;
        w2 = math.cos(sparklePhase * 3.5 * wobbleSpeed + particle.index * 2.3) * currentSize * wiggleIntensity;
        w3 = math.sin(sparklePhase * 5 * wobbleSpeed + particle.index * 1.8) * currentSize * wiggleIntensity * 0.7;
        break;
      case WiggleStyle.wave:
        final waveOffset = depthFactor * 3;
        w1 = math.sin(sparklePhase * 1.5 * wobbleSpeed - waveOffset) * currentSize * wiggleIntensity * 1.2;
        w2 = math.cos(sparklePhase * 1.3 * wobbleSpeed - waveOffset * 0.8) * currentSize * wiggleIntensity;
        w3 = math.sin(sparklePhase * 1.8 * wobbleSpeed - waveOffset * 1.2) * currentSize * wiggleIntensity * 0.8;
        break;
      case WiggleStyle.heartbeat:
        final beat = math.sin(sparklePhase * 2 * wobbleSpeed);
        final beatEnvelope = beat > 0.5 ? (beat - 0.5) * 4 : 0.0;
        w1 = beatEnvelope * currentSize * wiggleIntensity * 2;
        w2 = beatEnvelope * currentSize * wiggleIntensity * 2;
        w3 = 0;
        break;
    }
    
    return (w1, w2, w3);
  }

  void _drawParticleLayers(
    Canvas canvas, Offset pos, double currentSize, double depthFactor, double opacity,
    Color baseColor, Color particleCoreColor,
    double wobble1, double wobble2, double wobble3,
    double flickerFactor, double pulseFactor, double sparkle,
  ) {
    final coreBrightness = math.min(1.0, opacity * coreIntensity);
    
    // Layer 1: Outer halo
    if (depthFactor > 0.15) {
      final outerHaloRadius = currentSize * glowRadius * 1.5;
      final haloPaint = Paint()
        ..color = baseColor.withOpacity(opacity * haloOpacity * 0.5 * pulseFactor)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSoftness * 1.5);
      canvas.drawCircle(pos, outerHaloRadius, haloPaint);
    }

    // Layer 2: Main glow halo
    if (depthFactor > 0.2) {
      final haloRadius = currentSize * glowRadius;
      final haloGlowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            particleCoreColor.withOpacity(opacity * haloOpacity),
            baseColor.withOpacity(opacity * haloOpacity * 0.6),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromCircle(center: pos, radius: haloRadius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSoftness);
      canvas.drawCircle(pos, haloRadius, haloGlowPaint);
    }

    // Layer 3: Inner glow
    final innerGlowRadius = currentSize * glowRadius * 0.5;
    final innerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          particleCoreColor.withOpacity(opacity * 0.7),
          baseColor.withOpacity(opacity * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(pos.dx + wobble1 * 0.2, pos.dy + wobble2 * 0.2),
          radius: innerGlowRadius,
        ),
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSoftness * 0.3);
    canvas.drawCircle(
      Offset(pos.dx + wobble1 * 0.2, pos.dy + wobble2 * 0.2),
      innerGlowRadius,
      innerGlowPaint,
    );

    // Main body
    final bodyWidth = currentSize * (1.0 + wobble1 * 0.08 + wobble3 * 0.02);
    final bodyHeight = currentSize * (1.0 - wobble2 * 0.06 + wobble3 * 0.015);
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(coreBrightness),
          particleCoreColor.withOpacity(coreBrightness * 0.9),
          baseColor.withOpacity(coreBrightness * 0.6),
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(
        Rect.fromCenter(center: pos, width: bodyWidth * 2, height: bodyHeight * 2),
      );
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: bodyWidth * 2, height: bodyHeight * 2),
      bodyPaint,
    );

    // Secondary organic lobe
    if (depthFactor > 0.35) {
      final lobe1Pos = Offset(pos.dx + wobble1 * 0.8, pos.dy + wobble2 * 0.4);
      final lobe1Size = currentSize * 0.55;
      final lobe1Paint = Paint()
        ..color = particleCoreColor.withOpacity(coreBrightness * 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSoftness * 0.1);
      canvas.drawCircle(lobe1Pos, lobe1Size, lobe1Paint);
    }

    // Hot white center
    if (depthFactor > 0.25) {
      final hotSize = currentSize * 0.45 * flickerFactor * coreIntensity * 0.5;
      final hotPaint = Paint()
        ..color = Colors.white.withOpacity(math.min(1.0, coreBrightness * 1.1))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, hotSize, hotPaint);
    }

    // Occasional intense flare
    if (sparkle > 0.85 && flickerFactor > 0.9 && depthFactor > 0.45) {
      final flareSize = currentSize * 0.6 * coreIntensity * 0.6;
      final flarePaint = Paint()
        ..color = Colors.white.withOpacity(0.95)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSoftness * 0.2);
      canvas.drawCircle(pos, flareSize, flarePaint);
    }
  }

  Color _applyAdditive(Color color, double intensity) {
    final r = (color.red + (255 - color.red) * intensity).clamp(0, 255).toInt();
    final g = (color.green + (255 - color.green) * intensity).clamp(0, 255).toInt();
    final b = (color.blue + (255 - color.blue) * intensity).clamp(0, 255).toInt();
    return Color.fromARGB(color.alpha, r, g, b);
  }

  void drawCenterGlow(Canvas canvas, Offset center, double radius) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.06),
          Colors.white.withOpacity(0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.4))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius * 0.3, glow);
  }
}



