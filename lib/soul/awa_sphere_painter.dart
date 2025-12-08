import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'awa_soul_settings.dart';
import 'awa_sphere_config.dart';
import 'renderers/particle_3d_renderer.dart';
import 'renderers/backdrop_2d_renderer.dart';

/// Main painter for AwaSphere that orchestrates 2D backdrop and 3D particles
class AwaSpherePainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final double scale;
  final double wavePhase;
  final double sparklePhase;
  final double energy;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double particleSize;
  final int particleCount;
  final bool showParticles;
  
  // 2D Backdrop settings
  final int backdropDotCount;
  final double backdropDotSize;
  final double backdropOpacity;
  final bool showBackdrop;
  final Color? backdropGradientStart;
  final Color? backdropGradientMid;
  final Color? backdropGradientEnd;
  
  // Animation speeds
  final double flickerSpeed;
  final double pulseSpeed;
  final double driftSpeed;
  final double wobbleSpeed;
  
  // Light rendering
  final double emissiveIntensity;
  final double coreIntensity;
  final double glowRadius;
  final double glowSoftness;
  final bool additiveBlending;
  final double haloOpacity;
  
  // 3D Motion/Style
  final MotionPattern motionPattern;
  final WiggleStyle wiggleStyle;
  final FlickerMode flickerMode;
  final double driftIntensity;
  final double wiggleIntensity;
  final double flickerIntensity;
  final double sizeVariation;
  
  // 3D Colors
  final Color particle3DCoreColor;
  final Color particle3DMidColor;
  final Color particle3DOuterColor;
  
  // 2D specific
  final FlickerMode blinkMode;
  final double blinkSpeed;
  final double blinkIntensity;
  final double glowIntensityBackdrop;
  final double glowSizeBackdrop;
  final double backdrop2DSizeVariation;
  final double backdrop2DCenterScale;
  final double backdrop2DEdgeFade;
  final double backdrop2DCenterOpacity;
  final double backdrop2DInnerGlow;
  final double backdrop2DRotationSpeed;
  final double backdrop2DSpiralTightness;
  final double backdrop2DSpiralExpansion;
  final MotionPattern backdrop2DMotionPattern;
  final double backdrop2DDriftSpeed;
  final double backdrop2DDriftIntensity;

  AwaSpherePainter({
    required this.rotationX,
    required this.rotationY,
    required this.scale,
    required this.wavePhase,
    required this.sparklePhase,
    required this.energy,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.particleSize,
    required this.particleCount,
    required this.showParticles,
    required this.backdropDotCount,
    required this.backdropDotSize,
    required this.backdropOpacity,
    required this.showBackdrop,
    this.backdropGradientStart,
    this.backdropGradientMid,
    this.backdropGradientEnd,
    required this.flickerSpeed,
    required this.pulseSpeed,
    required this.driftSpeed,
    required this.wobbleSpeed,
    required this.emissiveIntensity,
    required this.coreIntensity,
    required this.glowRadius,
    required this.glowSoftness,
    required this.additiveBlending,
    required this.haloOpacity,
    this.motionPattern = MotionPattern.gentle,
    this.wiggleStyle = WiggleStyle.subtle,
    this.flickerMode = FlickerMode.gentle,
    this.driftIntensity = 1.5,
    this.wiggleIntensity = 0.12,
    this.flickerIntensity = 0.15,
    this.sizeVariation = 0.5,
    this.particle3DCoreColor = const Color(0xFFFFFFFB),
    this.particle3DMidColor = const Color(0xFFFFE8C0),
    this.particle3DOuterColor = const Color(0xFFFFB880),
    this.blinkMode = FlickerMode.gentle,
    this.blinkSpeed = 0.6,
    this.blinkIntensity = 0.25,
    this.glowIntensityBackdrop = 0.5,
    this.glowSizeBackdrop = 2.0,
    this.backdrop2DSizeVariation = 0.3,
    this.backdrop2DCenterScale = 0.8,
    this.backdrop2DEdgeFade = 0.9,
    this.backdrop2DCenterOpacity = 0.3,
    this.backdrop2DInnerGlow = 0.6,
    this.backdrop2DRotationSpeed = 0.0,
    this.backdrop2DSpiralTightness = 1.0,
    this.backdrop2DSpiralExpansion = 0.0,
    this.backdrop2DMotionPattern = MotionPattern.gentle,
    this.backdrop2DDriftSpeed = 0.3,
    this.backdrop2DDriftIntensity = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (math.min(size.width, size.height) / 2) * 0.6 * scale;

    // Golden angle for phyllotaxis
    const goldenAngle = 2.39996322972865332;

    final floatIntensity = 1.5 + (energy * 1.0);
    final waveIntensity = 0.06 + (energy * 0.03);

    // Draw 2D backdrop
    if (showBackdrop && backdropDotCount > 0 && backdropOpacity > 0) {
      final backdropRenderer = Backdrop2DRenderer(
        sparklePhase: sparklePhase,
        dotCount: backdropDotCount,
        dotSize: backdropDotSize,
        opacity: backdropOpacity,
        gradientStart: backdropGradientStart,
        gradientMid: backdropGradientMid,
        gradientEnd: backdropGradientEnd,
        blinkMode: blinkMode,
        blinkSpeed: blinkSpeed,
        blinkIntensity: blinkIntensity,
        glowIntensity: glowIntensityBackdrop,
        glowSize: glowSizeBackdrop,
        sizeVariation: backdrop2DSizeVariation,
        centerScale: backdrop2DCenterScale,
        edgeFade: backdrop2DEdgeFade,
        centerOpacity: backdrop2DCenterOpacity,
        innerGlow: backdrop2DInnerGlow,
        rotationSpeed: backdrop2DRotationSpeed,
        spiralTightness: backdrop2DSpiralTightness,
        spiralExpansion: backdrop2DSpiralExpansion,
        motionPattern: backdrop2DMotionPattern,
        driftSpeed: backdrop2DDriftSpeed,
        driftIntensity: backdrop2DDriftIntensity,
      );
      backdropRenderer.paint(canvas, center, baseRadius);
    }

    // Draw 3D particles
    if (showParticles && particleCount > 0) {
      final particleRenderer = Particle3DRenderer(
        sparklePhase: sparklePhase,
        particleSize: particleSize,
        emissiveIntensity: emissiveIntensity,
        coreIntensity: coreIntensity,
        glowRadius: glowRadius,
        glowSoftness: glowSoftness,
        additiveBlending: additiveBlending,
        haloOpacity: haloOpacity,
        motionPattern: motionPattern,
        wiggleStyle: wiggleStyle,
        flickerMode: flickerMode,
        driftSpeed: driftSpeed,
        driftIntensity: driftIntensity,
        wobbleSpeed: wobbleSpeed,
        wiggleIntensity: wiggleIntensity,
        flickerSpeed: flickerSpeed,
        flickerIntensity: flickerIntensity,
        pulseSpeed: pulseSpeed,
        sizeVariation: sizeVariation,
        coreColor: particle3DCoreColor,
        midColor: particle3DMidColor,
        outerColor: particle3DOuterColor,
      );

      // Generate and sort particles by z-depth
      final particles = <Particle>[];

      for (int i = 0; i < particleCount; i++) {
        final t = i / particleCount;
        final inclination = math.acos(1 - 2 * t);
        final azimuth = goldenAngle * i;

        final particleWaveOffset = math.sin(wavePhase + i * 0.1) * waveIntensity;
        final particleRadius = baseRadius * (1 + particleWaveOffset);

        // Base position on sphere
        var x = particleRadius * math.sin(inclination) * math.cos(azimuth);
        var y = particleRadius * math.sin(inclination) * math.sin(azimuth);
        var z = particleRadius * math.cos(inclination);

        // Floating drift
        final driftT = sparklePhase * floatIntensity + i * 0.1;
        final driftX = math.sin(driftT * 0.2) * baseRadius * 0.03;
        final driftY = math.cos(driftT * 0.15) * baseRadius * 0.025;
        final driftZ = math.sin(driftT * 0.18) * baseRadius * 0.02;

        // Apply rotation
        final cosX = math.cos(rotationX);
        final sinX = math.sin(rotationX);
        final y1 = y * cosX - z * sinX;
        final z1 = y * sinX + z * cosX;

        final cosY = math.cos(rotationY);
        final sinY = math.sin(rotationY);
        final x2 = x * cosY + z1 * sinY;
        final z2 = -x * sinY + z1 * cosY;

        final sparkle = (math.sin(sparklePhase * 1.5 + i * 0.3) + 1) / 2;

        particles.add(Particle(
          x: x2 + driftX,
          y: y1 + driftY,
          z: z2 / baseRadius + driftZ / baseRadius,
          index: i,
          sparkle: sparkle,
          waveOffset: particleWaveOffset,
        ));
      }

      // Sort by z (back to front)
      particles.sort((a, b) => a.z.compareTo(b.z));

      // Draw each particle
      for (final particle in particles) {
        particleRenderer.paintParticle(canvas, center, particle, baseRadius);
      }

      // Draw center glow
      particleRenderer.drawCenterGlow(canvas, center, baseRadius);
    }
  }

  @override
  bool shouldRepaint(covariant AwaSpherePainter oldDelegate) {
    return oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.scale != scale ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.sparklePhase != sparklePhase ||
        oldDelegate.energy != energy ||
        oldDelegate.particleSize != particleSize ||
        oldDelegate.particleCount != particleCount ||
        oldDelegate.showParticles != showParticles ||
        oldDelegate.backdropDotCount != backdropDotCount ||
        oldDelegate.backdropDotSize != backdropDotSize ||
        oldDelegate.backdropOpacity != backdropOpacity ||
        oldDelegate.showBackdrop != showBackdrop;
  }
}



