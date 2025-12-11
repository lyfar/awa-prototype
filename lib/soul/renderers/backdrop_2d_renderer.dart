import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../awa_soul_settings.dart';

/// Renders the 2D backdrop spiral with dots
class Backdrop2DRenderer {
  final double sparklePhase;
  final int dotCount;
  final double dotSize;
  final double opacity;
  final Color? gradientStart;
  final Color? gradientMid;
  final Color? gradientEnd;
  final FlickerMode blinkMode;
  final double blinkSpeed;
  final double blinkIntensity;
  final double glowIntensity;
  final double glowSize;
  final double sizeVariation;
  final double centerScale;
  final double edgeFade;
  final double centerOpacity;
  final double innerGlow;
  final double rotationSpeed;
  final double spiralTightness;
  final double spiralExpansion;
  final MotionPattern motionPattern;
  final double driftSpeed;
  final double driftIntensity;

  Backdrop2DRenderer({
    required this.sparklePhase,
    required this.dotCount,
    required this.dotSize,
    required this.opacity,
    this.gradientStart,
    this.gradientMid,
    this.gradientEnd,
    this.blinkMode = FlickerMode.gentle,
    this.blinkSpeed = 0.6,
    this.blinkIntensity = 0.25,
    this.glowIntensity = 0.5,
    this.glowSize = 2.0,
    this.sizeVariation = 0.3,
    this.centerScale = 0.8,
    this.edgeFade = 0.9,
    this.centerOpacity = 0.3,
    this.innerGlow = 0.6,
    this.rotationSpeed = 0.0,
    this.spiralTightness = 1.0,
    this.spiralExpansion = 0.0,
    this.motionPattern = MotionPattern.gentle,
    this.driftSpeed = 0.3,
    this.driftIntensity = 0.5,
  });

  void paint(Canvas canvas, Offset center, double radius) {
    final goldenAngle = 2.39996322972865332 * spiralTightness;
    
    // Apply spiral expansion (breathing)
    final expansionFactor = 1.0 + math.sin(sparklePhase * 0.3) * spiralExpansion;
    final backdropRadius = radius * 1.08 * expansionFactor;
    
    // Apply rotation
    final rotationOffset = sparklePhase * rotationSpeed;

    // Use configurable gradient colors or defaults
    final gradStart = gradientStart ?? const Color(0xFFFFA573);
    final gradMid = gradientMid ?? const Color(0xFFFF8B7A);
    final gradEnd = gradientEnd ?? const Color(0xFFFF7BC5);

    // Draw backdrop spiral dots
    for (int i = 0; i < dotCount; i++) {
      final t = i / dotCount;
      final r = backdropRadius * math.sqrt(t);
      final theta = goldenAngle * i + rotationOffset;

      // Calculate base position
      double x = center.dx + r * math.cos(theta);
      double y = center.dy + r * math.sin(theta);
      
      // Apply motion pattern
      final drift = _calculateDrift(i, r, x, y, center, backdropRadius);
      x += drift.dx;
      y += drift.dy;

      // Distance ratio for gradient
      final distRatio = r / backdropRadius;

      // Interpolate through 3 configurable colors
      Color dotColor;
      if (distRatio < 0.5) {
        dotColor = Color.lerp(gradStart, gradMid, distRatio * 2)!;
      } else {
        dotColor = Color.lerp(gradMid, gradEnd, (distRatio - 0.5) * 2)!;
      }

      // Calculate blink factor
      final blinkFactor = _calculateBlinkFactor(i, distRatio);

      // Size variation
      final sizeVar = math.sin(i * 0.5) * sizeVariation;
      final centerScaleFactor = 1.0 + (1.0 - distRatio) * (centerScale - 1.0);
      final currentDotSize = dotSize * (1 + sizeVar) * centerScaleFactor;

      // Calculate opacity with edge fade and center boost
      double dotOpacity = _calculateOpacity(distRatio);
      dotOpacity *= blinkFactor.clamp(0.0, 1.5);
      dotOpacity = dotOpacity.clamp(0.0, 1.0);

      // Draw the dot layers
      _drawDot(canvas, Offset(x, y), currentDotSize, dotColor, dotOpacity);
    }

    // Soft center glow
    _drawCenterGlow(canvas, center, radius, gradStart, gradMid);
  }

  Offset _calculateDrift(int i, double r, double x, double y, Offset center, double backdropRadius) {
    double driftX = 0, driftY = 0;
    
    switch (motionPattern) {
      case MotionPattern.gentle:
        driftX = math.sin(sparklePhase * 0.2 * driftSpeed + i * 0.1) * driftIntensity;
        driftY = math.cos(sparklePhase * 0.18 * driftSpeed + i * 0.12) * driftIntensity;
        break;
      case MotionPattern.organic:
        driftX = math.sin(sparklePhase * 0.15 * driftSpeed + i * 0.08) * driftIntensity
               + math.sin(sparklePhase * 0.3 * driftSpeed + i * 0.2) * driftIntensity * 0.3;
        driftY = math.cos(sparklePhase * 0.12 * driftSpeed + i * 0.1) * driftIntensity
               + math.cos(sparklePhase * 0.25 * driftSpeed + i * 0.15) * driftIntensity * 0.3;
        break;
      case MotionPattern.pulsing:
        final pulseAmt = math.sin(sparklePhase * 0.4 * driftSpeed) * driftIntensity;
        if (r > 0) {
          driftX = (x - center.dx) / r * pulseAmt * 2;
          driftY = (y - center.dy) / r * pulseAmt * 2;
        }
        break;
      case MotionPattern.swirl:
        final swirlAngle = sparklePhase * 0.1 * driftSpeed;
        final dx = x - center.dx;
        final dy = y - center.dy;
        driftX = (dx * math.cos(swirlAngle * 0.1) - dy * math.sin(swirlAngle * 0.1) - dx) * driftIntensity * 0.5;
        driftY = (dx * math.sin(swirlAngle * 0.1) + dy * math.cos(swirlAngle * 0.1) - dy) * driftIntensity * 0.5;
        break;
      case MotionPattern.jitter:
        driftX = math.sin(sparklePhase * 2 * driftSpeed + i * 1.5) * driftIntensity * 0.3;
        driftY = math.cos(sparklePhase * 1.8 * driftSpeed + i * 1.3) * driftIntensity * 0.3;
        break;
      case MotionPattern.breathe:
        final breathe = math.sin(sparklePhase * 0.1 * driftSpeed);
        driftX = (x - center.dx) / backdropRadius * breathe * driftIntensity * 5;
        driftY = (y - center.dy) / backdropRadius * breathe * driftIntensity * 5;
        break;
      case MotionPattern.float:
        driftX = math.sin(sparklePhase * 0.15 * driftSpeed + i * 0.1) * driftIntensity * 0.5;
        driftY = -((math.sin(sparklePhase * 0.08 * driftSpeed + i * 0.05)).abs()) * driftIntensity
               + math.cos(sparklePhase * 0.12 * driftSpeed + i * 0.08) * driftIntensity * 0.3;
        break;
    }
    
    return Offset(driftX, driftY);
  }

  double _calculateBlinkFactor(int i, double distRatio) {
    switch (blinkMode) {
      case FlickerMode.off:
        return 1.0;
      case FlickerMode.gentle:
        final blinkPhase = math.sin(sparklePhase * blinkSpeed + i * 0.06);
        return 1.0 - blinkIntensity + blinkPhase * blinkIntensity;
      case FlickerMode.candle:
        final noise1 = math.sin(sparklePhase * blinkSpeed * 2.5 + i * 0.2);
        final noise2 = math.cos(sparklePhase * blinkSpeed * 1.7 + i * 0.15);
        return 1.0 - blinkIntensity * 0.5 + (noise1 * noise2) * blinkIntensity;
      case FlickerMode.sparkle:
        final sparkleVal = math.sin(sparklePhase * blinkSpeed * 4 + i * 1.7);
        return sparkleVal > 0.7 ? 1.0 + blinkIntensity : 1.0 - blinkIntensity * 0.3;
      case FlickerMode.sync:
        final syncPhase = math.sin(sparklePhase * blinkSpeed);
        return 1.0 - blinkIntensity + syncPhase * blinkIntensity;
      case FlickerMode.wave:
        final waveOffset = distRatio * 3;
        final wavePhase = math.sin(sparklePhase * blinkSpeed - waveOffset);
        return 1.0 - blinkIntensity + wavePhase * blinkIntensity;
    }
  }

  double _calculateOpacity(double distRatio) {
    double result;
    
    // Edge fade
    final edgeFadeStart = 1.0 - edgeFade * 0.3;
    if (distRatio < 0.15) {
      result = distRatio / 0.15;
    } else if (distRatio > edgeFadeStart) {
      result = 1.0 - (distRatio - edgeFadeStart) / (1.0 - edgeFadeStart);
      result = result.clamp(0.0, 1.0);
    } else {
      result = 1.0;
    }
    
    // Apply base opacity
    result *= opacity;
    
    // Center opacity boost
    if (distRatio < 0.4) {
      result += centerOpacity * (1.0 - distRatio / 0.4);
    }
    
    return result;
  }

  void _drawDot(Canvas canvas, Offset pos, double size, Color color, double dotOpacity) {
    // Outer glow
    final outerGlowSize = size * glowSize;
    final glowPaint = Paint()
      ..color = color.withOpacity(dotOpacity * glowIntensity * 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + glowSize * 2);
    canvas.drawCircle(pos, outerGlowSize, glowPaint);

    // Inner glow layer
    if (innerGlow > 0) {
      final innerGlowPaint = Paint()
        ..color = color.withOpacity(dotOpacity * innerGlow * 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + glowSize * 0.5);
      canvas.drawCircle(pos, size * 1.1, innerGlowPaint);
    }

    // Medium glow layer
    final midGlowPaint = Paint()
      ..color = color.withOpacity(dotOpacity * glowIntensity * 0.6)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + glowSize);
    canvas.drawCircle(pos, size * 1.3, midGlowPaint);

    // Core dot
    final dotPaint = Paint()
      ..color = Color.lerp(color, Colors.white, 0.3)!.withOpacity(dotOpacity * 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, size * 0.7, dotPaint);
  }

  void _drawCenterGlow(Canvas canvas, Offset center, double radius, Color gradStart, Color gradMid) {
    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          gradStart.withOpacity(0.2 + centerOpacity * 0.2),
          gradMid.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.35))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(center, radius * 0.3, centerGlow);
  }
}







