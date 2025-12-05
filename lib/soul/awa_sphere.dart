import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'awa_soul_settings.dart';

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

/// AwaSphere - Interactive light sphere with glowing particles
/// Implements proper light rendering: emissive colors, additive blending, bloom
/// Supports drag to rotate, pinch to zoom
class AwaSphere extends StatefulWidget {
  final double? width;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final Color? accentColor;
  final bool interactive;
  final bool animate;
  final double particleSize;
  final int particleCount;
  final double energy;
  final bool showParticles;

  // Use global settings from AwaSoulSettings singleton
  final bool useGlobalSettings;

  // 2D Backdrop settings
  final int backdropDotCount;
  final double backdropDotSize;
  final double backdropOpacity;
  final bool showBackdrop;
  final Color? backdropGradientStart;
  final Color? backdropGradientMid;
  final Color? backdropGradientEnd;

  // Animation speed multipliers
  final double flickerSpeed;
  final double pulseSpeed;
  final double driftSpeed;
  final double wobbleSpeed;

  // Light/Emissive settings
  final double emissiveIntensity;
  final double coreIntensity;
  final double glowRadius;
  final double glowSoftness;
  final bool additiveBlending;
  final double haloOpacity;

  const AwaSphere({
    super.key,
    this.width,
    this.height = AwaSphereConfig.lobbyHeight,
    this.primaryColor = AwaSphereConfig.primaryColor,
    this.secondaryColor = AwaSphereConfig.secondaryColor,
    this.accentColor,
    this.interactive = true,
    this.animate = true,
    this.particleSize = AwaSphereConfig.particleSize,
    this.particleCount = AwaSphereConfig.particleCount,
    this.showParticles = true,
    this.energy = 0.0,
    this.useGlobalSettings = true,
    // 2D Backdrop defaults
    this.backdropDotCount = 380,
    this.backdropDotSize = 5.0,
    this.backdropOpacity = 0.75,
    this.showBackdrop = true,
    this.backdropGradientStart,
    this.backdropGradientMid,
    this.backdropGradientEnd,
    // Animation speed defaults
    this.flickerSpeed = 1.0,
    this.pulseSpeed = 1.0,
    this.driftSpeed = 1.0,
    this.wobbleSpeed = 1.0,
    // Light rendering defaults
    this.emissiveIntensity = 1.5,
    this.coreIntensity = 2.0,
    this.glowRadius = 3.0,
    this.glowSoftness = 8.0,
    this.additiveBlending = true,
    this.haloOpacity = 0.4,
  });

  @override
  State<AwaSphere> createState() => _AwaSphereState();
}

class _AwaSphereState extends State<AwaSphere>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0;
  double _rotationX = 0;
  double _rotationY = 0;
  double _scale = 1.0;
  double _targetScale = 1.0;
  double _smoothEnergy = 0.0;
  double _targetEnergy = 0.0;
  Offset? _lastPanPosition;
  double _lastScaleValue = 1.0;

  static const double _rotationSpeed = 0.06;
  static const double _breathSpeed = 0.35;
  static const double _waveSpeed = 0.45;
  static const double _sparkleSpeed = 0.65;

  @override
  void initState() {
    super.initState();
    _smoothEnergy = widget.energy;
    _targetEnergy = widget.energy;

    _ticker = createTicker(_onTick);
    if (widget.animate) {
      _ticker.start();
    }

    // Listen to global settings changes
    if (widget.useGlobalSettings) {
      AwaSoulSettings().addListener(_onSettingsChanged);
    }
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTick(Duration elapsed) {
    setState(() {
      _time += 0.016;

      // Smooth energy transition
      if (_smoothEnergy != _targetEnergy) {
        final diff = _targetEnergy - _smoothEnergy;
        _smoothEnergy += diff * 0.08;
        if ((diff).abs() < 0.001) {
          _smoothEnergy = _targetEnergy;
        }
      }

      // Smooth scale transition
      if (_scale != _targetScale) {
        final diff = _targetScale - _scale;
        _scale += diff * 0.15;
        if ((diff).abs() < 0.001) {
          _scale = _targetScale;
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant AwaSphere oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.energy != oldWidget.energy) {
      _targetEnergy = widget.energy;
    }

    if (widget.animate && !_ticker.isActive) {
      _ticker.start();
    } else if (!widget.animate && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    if (widget.useGlobalSettings) {
      AwaSoulSettings().removeListener(_onSettingsChanged);
    }
    _ticker.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.interactive) return;
    _lastPanPosition = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.interactive || _lastPanPosition == null) return;

    final delta = details.localPosition - _lastPanPosition!;
    setState(() {
      _rotationY += delta.dx * 0.01;
      _rotationX += delta.dy * 0.01;
      _rotationX = _rotationX.clamp(-math.pi / 2.5, math.pi / 2.5);
    });
    _lastPanPosition = details.localPosition;
  }

  void _handlePanEnd(DragEndDetails details) {
    _lastPanPosition = null;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (!widget.interactive) return;
    _lastScaleValue = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!widget.interactive) return;

    if (details.pointerCount == 2) {
      // Pinch to zoom
      setState(() {
        _targetScale = (_lastScaleValue * details.scale).clamp(0.5, 2.0);
      });
    } else if (details.pointerCount == 1) {
      // Single finger drag
      final delta = details.focalPointDelta;
      setState(() {
        _rotationY += delta.dx * 0.01;
        _rotationX += delta.dy * 0.01;
        _rotationX = _rotationX.clamp(-math.pi / 2.5, math.pi / 2.5);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use global settings or widget props
    final settings = widget.useGlobalSettings ? AwaSoulSettings() : null;

    // Get animation multipliers from settings
    final pulseSpeedMult = settings?.pulseSpeed ?? widget.pulseSpeed;
    final driftSpeedMult = settings?.driftSpeed ?? widget.driftSpeed;
    final flickerSpeedMult = settings?.flickerSpeed ?? widget.flickerSpeed;
    final breathIntensity = settings?.breathingIntensity ?? 1.0;
    final showParticles = settings?.showParticles ?? widget.showParticles;
    final showBackdrop = settings?.showBackdrop ?? widget.showBackdrop;

    // Apply speed multipliers to animation phases
    final autoRotation = _time * _rotationSpeed * 2 * math.pi;
    final breathPhase = math.sin(
      _time * _breathSpeed * pulseSpeedMult * 2 * math.pi,
    );
    final breathScale = 1.0 + breathPhase * 0.05 * breathIntensity;
    final wavePhase = _time * _waveSpeed * driftSpeedMult * 2 * math.pi;
    final sparklePhase = _time * _sparkleSpeed * flickerSpeedMult * 2 * math.pi;

    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = widget.width ?? constraints.maxWidth;

          final painter = _AwaSphereParticles(
            rotationX: _rotationX,
            rotationY: _rotationY + autoRotation,
            scale: _scale * breathScale,
            wavePhase: wavePhase,
            sparklePhase: sparklePhase,
            energy: _smoothEnergy,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            accentColor:
                widget.accentColor ?? widget.primaryColor.withOpacity(0.8),
            // Use global settings if enabled
            particleSize: settings?.particleSize ?? widget.particleSize,
            particleCount: settings?.particleCount ?? widget.particleCount,
            showParticles: showParticles,
            backdropDotCount:
                settings?.backdropDotCount ?? widget.backdropDotCount,
            backdropDotSize:
                settings?.backdropDotSize ?? widget.backdropDotSize,
            backdropOpacity:
                settings?.backdropOpacity ?? widget.backdropOpacity,
            showBackdrop: showBackdrop,
            backdropGradientStart:
                settings?.gradientStart ?? widget.backdropGradientStart,
            backdropGradientMid:
                settings?.gradientMid ?? widget.backdropGradientMid,
            backdropGradientEnd:
                settings?.gradientEnd ?? widget.backdropGradientEnd,
            flickerSpeed: settings?.flickerSpeed ?? widget.flickerSpeed,
            pulseSpeed: settings?.pulseSpeed ?? widget.pulseSpeed,
            driftSpeed: settings?.driftSpeed ?? widget.driftSpeed,
            wobbleSpeed: settings?.wobbleSpeed ?? widget.wobbleSpeed,
            // Light rendering
            emissiveIntensity:
                settings?.emissiveIntensity ?? widget.emissiveIntensity,
            coreIntensity: settings?.coreIntensity ?? widget.coreIntensity,
            glowRadius: settings?.glowRadius ?? widget.glowRadius,
            glowSoftness: settings?.glowSoftness ?? widget.glowSoftness,
            additiveBlending:
                settings?.additiveBlending ?? widget.additiveBlending,
            haloOpacity: settings?.haloOpacity ?? widget.haloOpacity,
            // New motion settings from layer3D
            motionPattern:
                settings?.layer3D.motionPattern ?? MotionPattern.gentle,
            wiggleStyle: settings?.layer3D.wiggleStyle ?? WiggleStyle.subtle,
            flickerMode: settings?.layer3D.flickerMode ?? FlickerMode.gentle,
            driftIntensity: settings?.layer3D.driftIntensity ?? 1.5,
            wiggleIntensity: settings?.layer3D.wiggleIntensity ?? 0.12,
            flickerIntensity: settings?.layer3D.flickerIntensity ?? 0.15,
            sizeVariation: settings?.layer3D.sizeVariation ?? 0.5,
            // 2D layer settings
            blinkMode: settings?.layer2D.blinkMode ?? FlickerMode.gentle,
            blinkSpeed: settings?.layer2D.blinkSpeed ?? 0.6,
            blinkIntensity: settings?.layer2D.blinkIntensity ?? 0.25,
            glowIntensityBackdrop: settings?.layer2D.glowIntensity ?? 0.5,
            glowSizeBackdrop: settings?.layer2D.glowSize ?? 2.0,
            // New 2D settings
            backdrop2DSizeVariation: settings?.layer2D.sizeVariation ?? 0.3,
            backdrop2DCenterScale: settings?.layer2D.centerScale ?? 0.8,
            backdrop2DEdgeFade: settings?.layer2D.edgeFade ?? 0.9,
            backdrop2DCenterOpacity: settings?.layer2D.centerOpacity ?? 0.3,
            backdrop2DInnerGlow: settings?.layer2D.innerGlow ?? 0.6,
            backdrop2DRotationSpeed: settings?.layer2D.rotationSpeed ?? 0.0,
            backdrop2DSpiralTightness: settings?.layer2D.spiralTightness ?? 1.0,
            backdrop2DSpiralExpansion: settings?.layer2D.spiralExpansion ?? 0.0,
            backdrop2DMotionPattern:
                settings?.layer2D.motionPattern ?? MotionPattern.gentle,
            backdrop2DDriftSpeed: settings?.layer2D.driftSpeed ?? 0.3,
            backdrop2DDriftIntensity: settings?.layer2D.driftIntensity ?? 0.5,
          );

          // Apply bloom effect if enabled
          final enableBloom = settings?.enableBloom ?? false;
          final bloomIntensity = settings?.bloomIntensity ?? 0.6;
          final bloomRadius = settings?.bloomRadius ?? 12.0;

          if (enableBloom && bloomIntensity > 0) {
            return Stack(
              children: [
                // Base layer
                CustomPaint(size: Size(width, widget.height), painter: painter),
                // Bloom layer
                Positioned.fill(
                  child: IgnorePointer(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: bloomRadius * bloomIntensity,
                        sigmaY: bloomRadius * bloomIntensity,
                      ),
                      child: Opacity(
                        opacity: 0.4 * bloomIntensity,
                        child: CustomPaint(
                          size: Size(width, widget.height),
                          painter: painter,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return CustomPaint(
            size: Size(width, widget.height),
            painter: painter,
          );
        },
      ),
    );
  }
}

class _AwaSphereParticles extends CustomPainter {
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
  // 2D Backdrop
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
  // New motion settings
  final MotionPattern motionPattern;
  final WiggleStyle wiggleStyle;
  final FlickerMode flickerMode;
  final double driftIntensity;
  final double wiggleIntensity;
  final double flickerIntensity;
  final double sizeVariation;
  // 2D specific
  final FlickerMode blinkMode;
  final double blinkSpeed;
  final double blinkIntensity;
  final double glowIntensityBackdrop;
  final double glowSizeBackdrop;
  // New 2D settings
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

  _AwaSphereParticles({
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
    this.blinkMode = FlickerMode.gentle,
    this.blinkSpeed = 0.6,
    this.blinkIntensity = 0.25,
    this.glowIntensityBackdrop = 0.5,
    this.glowSizeBackdrop = 2.0,
    // New 2D settings
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

    // Draw subtle dark sphere backdrop
    if (showBackdrop && backdropDotCount > 0 && backdropOpacity > 0) {
      _drawDarkSphere(canvas, center, baseRadius);
    }

    if (showParticles && particleCount > 0) {
      // Generate and sort particles by z-depth
      final particles = <_Particle>[];

      for (int i = 0; i < particleCount; i++) {
        final t = i / particleCount;
        final inclination = math.acos(1 - 2 * t);
        final azimuth = goldenAngle * i;

        final particleWaveOffset =
            math.sin(wavePhase + i * 0.1) * waveIntensity;
        final particleRadius = baseRadius * (1 + particleWaveOffset);

        double x = math.sin(inclination) * math.cos(azimuth);
        double y = math.sin(inclination) * math.sin(azimuth);
        double z = math.cos(inclination);

        // Apply rotation around Y axis
        final cosY = math.cos(rotationY);
        final sinY = math.sin(rotationY);
        final newX = x * cosY - z * sinY;
        final newZ = x * sinY + z * cosY;
        x = newX;
        z = newZ;

        // Apply rotation around X axis
        final cosX = math.cos(rotationX);
        final sinX = math.sin(rotationX);
        final newY = y * cosX - z * sinX;
        final newZ2 = y * sinX + z * cosX;
        y = newY;
        z = newZ2;

        // Subtle floating movement
        final floatX = math.sin(wavePhase * 1.1 + i * 0.15) * floatIntensity;
        final floatY = math.cos(wavePhase * 0.9 + i * 0.19) * floatIntensity;

        // Sparkle/twinkle factor
        final sparkle = (math.sin(sparklePhase * 2 + i * 0.35) + 1) / 2;

        particles.add(
          _Particle(
            x: x * particleRadius + floatX,
            y: y * particleRadius + floatY,
            z: z,
            index: i,
            sparkle: sparkle,
            waveOffset: particleWaveOffset,
          ),
        );
      }

      // Sort by z for proper depth rendering
      particles.sort((a, b) => a.z.compareTo(b.z));

      // Draw particles as light points
      for (final particle in particles) {
        _drawLightParticle(canvas, center, particle, baseRadius);
      }
    }

    // Draw center glow
    _drawCenterGlow(canvas, center, baseRadius);
  }

  void _drawDarkSphere(Canvas canvas, Offset center, double radius) {
    // 2D Phyllotaxis spiral backdrop with blurred gradient dots
    final goldenAngle = 2.39996322972865332 * backdrop2DSpiralTightness;

    // Apply spiral expansion (breathing)
    final expansionFactor =
        1.0 + math.sin(sparklePhase * 0.3) * backdrop2DSpiralExpansion;
    final backdropRadius = radius * 1.08 * expansionFactor;

    // Apply rotation
    final rotationOffset = sparklePhase * backdrop2DRotationSpeed;

    // Use configurable gradient colors or defaults
    final gradStart = backdropGradientStart ?? const Color(0xFFFFA573);
    final gradMid = backdropGradientMid ?? const Color(0xFFFF8B7A);
    final gradEnd = backdropGradientEnd ?? const Color(0xFFFF7BC5);

    // Draw backdrop spiral dots with gradient and blink
    for (int i = 0; i < backdropDotCount; i++) {
      final t = i / backdropDotCount;
      final r = backdropRadius * math.sqrt(t);
      final theta = goldenAngle * i + rotationOffset;

      // Calculate base position
      double x = center.dx + r * math.cos(theta);
      double y = center.dy + r * math.sin(theta);

      // Apply 2D motion pattern
      double driftX = 0, driftY = 0;
      switch (backdrop2DMotionPattern) {
        case MotionPattern.gentle:
          driftX =
              math.sin(sparklePhase * 0.2 * backdrop2DDriftSpeed + i * 0.1) *
              backdrop2DDriftIntensity;
          driftY =
              math.cos(sparklePhase * 0.18 * backdrop2DDriftSpeed + i * 0.12) *
              backdrop2DDriftIntensity;
          break;
        case MotionPattern.organic:
          driftX =
              math.sin(sparklePhase * 0.15 * backdrop2DDriftSpeed + i * 0.08) *
                  backdrop2DDriftIntensity +
              math.sin(sparklePhase * 0.3 * backdrop2DDriftSpeed + i * 0.2) *
                  backdrop2DDriftIntensity *
                  0.3;
          driftY =
              math.cos(sparklePhase * 0.12 * backdrop2DDriftSpeed + i * 0.1) *
                  backdrop2DDriftIntensity +
              math.cos(sparklePhase * 0.25 * backdrop2DDriftSpeed + i * 0.15) *
                  backdrop2DDriftIntensity *
                  0.3;
          break;
        case MotionPattern.pulsing:
          final pulseAmt =
              math.sin(sparklePhase * 0.4 * backdrop2DDriftSpeed) *
              backdrop2DDriftIntensity;
          driftX = (x - center.dx) / r * pulseAmt * 2;
          driftY = (y - center.dy) / r * pulseAmt * 2;
          break;
        case MotionPattern.swirl:
          final swirlAngle = sparklePhase * 0.1 * backdrop2DDriftSpeed;
          final dx = x - center.dx;
          final dy = y - center.dy;
          driftX =
              dx * math.cos(swirlAngle * 0.1) -
              dy * math.sin(swirlAngle * 0.1) -
              dx;
          driftY =
              dx * math.sin(swirlAngle * 0.1) +
              dy * math.cos(swirlAngle * 0.1) -
              dy;
          driftX *= backdrop2DDriftIntensity * 0.5;
          driftY *= backdrop2DDriftIntensity * 0.5;
          break;
        case MotionPattern.jitter:
          driftX =
              math.sin(sparklePhase * 2 * backdrop2DDriftSpeed + i * 1.5) *
              backdrop2DDriftIntensity *
              0.3;
          driftY =
              math.cos(sparklePhase * 1.8 * backdrop2DDriftSpeed + i * 1.3) *
              backdrop2DDriftIntensity *
              0.3;
          break;
        case MotionPattern.breathe:
          final breathe = math.sin(sparklePhase * 0.1 * backdrop2DDriftSpeed);
          driftX =
              (x - center.dx) /
              backdropRadius *
              breathe *
              backdrop2DDriftIntensity *
              5;
          driftY =
              (y - center.dy) /
              backdropRadius *
              breathe *
              backdrop2DDriftIntensity *
              5;
          break;
        case MotionPattern.float:
          driftX =
              math.sin(sparklePhase * 0.15 * backdrop2DDriftSpeed + i * 0.1) *
              backdrop2DDriftIntensity *
              0.5;
          driftY =
              -((math.sin(
                    sparklePhase * 0.08 * backdrop2DDriftSpeed + i * 0.05,
                  )).abs()) *
                  backdrop2DDriftIntensity +
              math.cos(sparklePhase * 0.12 * backdrop2DDriftSpeed + i * 0.08) *
                  backdrop2DDriftIntensity *
                  0.3;
          break;
      }
      x += driftX;
      y += driftY;

      // Distance ratio for gradient
      final distRatio = r / backdropRadius;

      // Interpolate through 3 configurable colors
      Color dotColor;
      if (distRatio < 0.5) {
        dotColor = Color.lerp(gradStart, gradMid, distRatio * 2)!;
      } else {
        dotColor = Color.lerp(gradMid, gradEnd, (distRatio - 0.5) * 2)!;
      }

      // Blink/flicker based on blinkMode
      double blinkFactor = 1.0;
      switch (blinkMode) {
        case FlickerMode.off:
          blinkFactor = 1.0;
          break;
        case FlickerMode.gentle:
          final blinkPhase = math.sin(sparklePhase * blinkSpeed + i * 0.06);
          blinkFactor = 1.0 - blinkIntensity + blinkPhase * blinkIntensity;
          break;
        case FlickerMode.candle:
          final noise1 = math.sin(sparklePhase * blinkSpeed * 2.5 + i * 0.2);
          final noise2 = math.cos(sparklePhase * blinkSpeed * 1.7 + i * 0.15);
          blinkFactor =
              1.0 - blinkIntensity * 0.5 + (noise1 * noise2) * blinkIntensity;
          break;
        case FlickerMode.sparkle:
          final sparkleVal = math.sin(sparklePhase * blinkSpeed * 4 + i * 1.7);
          blinkFactor =
              sparkleVal > 0.7
                  ? 1.0 + blinkIntensity
                  : 1.0 - blinkIntensity * 0.3;
          break;
        case FlickerMode.sync:
          final syncPhase = math.sin(sparklePhase * blinkSpeed);
          blinkFactor = 1.0 - blinkIntensity + syncPhase * blinkIntensity;
          break;
        case FlickerMode.wave:
          final waveOffset = distRatio * 3;
          final wavePhase = math.sin(sparklePhase * blinkSpeed - waveOffset);
          blinkFactor = 1.0 - blinkIntensity + wavePhase * blinkIntensity;
          break;
      }

      // Size variation based on settings
      final sizeVar = math.sin(i * 0.5) * backdrop2DSizeVariation;

      // Center scale - dots bigger in center
      final centerScaleFactor =
          1.0 + (1.0 - distRatio) * (backdrop2DCenterScale - 1.0);

      final dotSize = backdropDotSize * (1 + sizeVar) * centerScaleFactor;

      // Opacity with edge fade and center boost
      double opacity;

      // Edge fade - fade out at edges based on edgeFade setting
      final edgeFadeStart =
          1.0 -
          backdrop2DEdgeFade * 0.3; // Start fading later with higher values
      if (distRatio < 0.15) {
        opacity = distRatio / 0.15; // Fade in from center
      } else if (distRatio > edgeFadeStart) {
        opacity = 1.0 - (distRatio - edgeFadeStart) / (1.0 - edgeFadeStart);
        opacity = opacity.clamp(0.0, 1.0);
      } else {
        opacity = 1.0;
      }

      // Apply base opacity
      opacity *= backdropOpacity;

      // Center opacity boost
      if (distRatio < 0.4) {
        opacity += backdrop2DCenterOpacity * (1.0 - distRatio / 0.4);
      }

      // Apply blink
      opacity *= blinkFactor.clamp(0.0, 1.5);
      opacity = opacity.clamp(0.0, 1.0);

      // Outer glow
      final outerGlowSize = dotSize * glowSizeBackdrop;
      final glowPaint =
          Paint()
            ..color = dotColor.withOpacity(
              opacity * glowIntensityBackdrop * 0.5,
            )
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              4 + glowSizeBackdrop * 2,
            );
      canvas.drawCircle(Offset(x, y), outerGlowSize, glowPaint);

      // Inner glow layer (new!)
      if (backdrop2DInnerGlow > 0) {
        final innerGlowPaint =
            Paint()
              ..color = dotColor.withOpacity(
                opacity * backdrop2DInnerGlow * 0.4,
              )
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                2 + glowSizeBackdrop * 0.5,
              );
        canvas.drawCircle(Offset(x, y), dotSize * 1.1, innerGlowPaint);
      }

      // Medium glow layer
      final midGlowPaint =
          Paint()
            ..color = dotColor.withOpacity(
              opacity * glowIntensityBackdrop * 0.6,
            )
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              2 + glowSizeBackdrop,
            );
      canvas.drawCircle(Offset(x, y), dotSize * 1.3, midGlowPaint);

      // Core dot
      final dotPaint =
          Paint()
            ..color = Color.lerp(
              dotColor,
              Colors.white,
              0.3,
            )!.withOpacity(opacity * 0.8)
            ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), dotSize * 0.7, dotPaint);
    }

    // Soft center glow
    final centerGlow =
        Paint()
          ..shader = RadialGradient(
            colors: [
              gradStart.withOpacity(0.2 + backdrop2DCenterOpacity * 0.2),
              gradMid.withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 0.35))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(center, radius * 0.3, centerGlow);
  }

  void _drawLightParticle(
    Canvas canvas,
    Offset center,
    _Particle particle,
    double radius,
  ) {
    final depthFactor = (particle.z + 1) / 2; // 0 to 1, back to front

    // === MOTION PATTERN DRIFT ===
    double driftX = 0;
    double driftY = 0;
    switch (motionPattern) {
      case MotionPattern.gentle:
        driftX =
            math.sin(sparklePhase * 0.3 * driftSpeed + particle.index * 0.5) *
            driftIntensity;
        driftY =
            math.cos(sparklePhase * 0.25 * driftSpeed + particle.index * 0.7) *
            driftIntensity *
            0.8;
        break;
      case MotionPattern.organic:
        // Perlin-like layered noise
        driftX =
            math.sin(sparklePhase * 0.2 * driftSpeed + particle.index * 0.3) *
                driftIntensity +
            math.sin(sparklePhase * 0.5 * driftSpeed + particle.index * 1.1) *
                driftIntensity *
                0.3;
        driftY =
            math.cos(sparklePhase * 0.18 * driftSpeed + particle.index * 0.5) *
                driftIntensity +
            math.cos(sparklePhase * 0.45 * driftSpeed + particle.index * 0.9) *
                driftIntensity *
                0.3;
        break;
      case MotionPattern.pulsing:
        // Radial pulsing
        final pulseOffset =
            math.sin(sparklePhase * 0.5 * driftSpeed) * driftIntensity * 0.5;
        driftX = (particle.x / radius) * pulseOffset * 10;
        driftY = (particle.y / radius) * pulseOffset * 10;
        break;
      case MotionPattern.swirl:
        // Circular/spiral motion
        final angle = sparklePhase * 0.1 * driftSpeed;
        final originalDist = math.sqrt(
          particle.x * particle.x + particle.y * particle.y,
        );
        driftX =
            math.cos(angle) * driftIntensity -
            math.sin(angle) * driftIntensity * 0.2;
        driftY =
            math.sin(angle) * driftIntensity +
            math.cos(angle) * driftIntensity * 0.2;
        driftX *= originalDist / radius;
        driftY *= originalDist / radius;
        break;
      case MotionPattern.jitter:
        // Quick random micro-movements
        driftX =
            math.sin(sparklePhase * 3 * driftSpeed + particle.index * 2.1) *
            driftIntensity *
            0.5;
        driftY =
            math.cos(sparklePhase * 2.7 * driftSpeed + particle.index * 1.9) *
            driftIntensity *
            0.5;
        break;
      case MotionPattern.breathe:
        // Slow inhale/exhale
        final breathPhase = math.sin(sparklePhase * 0.15 * driftSpeed);
        driftX = (particle.x / radius) * breathPhase * driftIntensity * 5;
        driftY = (particle.y / radius) * breathPhase * driftIntensity * 5;
        break;
      case MotionPattern.float:
        // Lazy upward tendency
        driftX =
            math.sin(sparklePhase * 0.2 * driftSpeed + particle.index * 0.4) *
            driftIntensity *
            0.5;
        driftY =
            -(math.sin(
                  sparklePhase * 0.1 * driftSpeed + particle.index * 0.2,
                )).abs() *
                driftIntensity *
                1.5 +
            math.cos(sparklePhase * 0.25 * driftSpeed + particle.index * 0.6) *
                driftIntensity *
                0.3;
        break;
    }
    final pos = center + Offset(particle.x + driftX, particle.y + driftY);

    // === SIZE VARIATION ===
    final sizeVar =
        (1.0 - sizeVariation * 0.5) +
        (math.sin(particle.index * 1.7) + 1) * sizeVariation * 0.5;

    // === FLICKER BASED ON MODE ===
    double flickerFactor = 1.0;
    switch (flickerMode) {
      case FlickerMode.off:
        flickerFactor = 1.0;
        break;
      case FlickerMode.gentle:
        final flicker1 = math.sin(
          sparklePhase * 1.8 * flickerSpeed + particle.index * 0.4,
        );
        final flicker2 = math.cos(
          sparklePhase * 1.4 * flickerSpeed + particle.index * 0.7,
        );
        flickerFactor =
            1.0 -
            flickerIntensity +
            (flicker1 * 0.5 + flicker2 * 0.5 + 1) * flickerIntensity * 0.5;
        break;
      case FlickerMode.candle:
        // Fire-like irregular brightness
        final n1 = math.sin(
          sparklePhase * 2.5 * flickerSpeed + particle.index * 0.3,
        );
        final n2 = math.cos(
          sparklePhase * 1.8 * flickerSpeed + particle.index * 0.5,
        );
        final n3 = math.sin(
          sparklePhase * 4.0 * flickerSpeed + particle.index * 0.8,
        );
        flickerFactor = 1.0 + (n1 * n2 + n3 * 0.3) * flickerIntensity;
        break;
      case FlickerMode.sparkle:
        // Sharp random flashes
        final sparkVal = math.sin(
          sparklePhase * 5 * flickerSpeed + particle.index * 2.3,
        );
        flickerFactor =
            sparkVal > 0.6
                ? 1.0 + flickerIntensity * 2
                : 1.0 - flickerIntensity * 0.2;
        break;
      case FlickerMode.sync:
        // All flicker together
        final syncFlicker = math.sin(sparklePhase * 2 * flickerSpeed);
        flickerFactor = 1.0 - flickerIntensity + syncFlicker * flickerIntensity;
        break;
      case FlickerMode.wave:
        // Brightness wave
        final waveOffset = depthFactor * 4;
        final waveFlicker = math.sin(sparklePhase * flickerSpeed - waveOffset);
        flickerFactor = 1.0 - flickerIntensity + waveFlicker * flickerIntensity;
        break;
    }

    // Pulse
    final pulse = math.sin(
      sparklePhase * 0.8 * pulseSpeed + particle.index * 0.15,
    );
    final pulseFactor = 0.9 + pulse * 0.1;

    // === EMISSIVE COLORS (HDR-like) ===
    final normalizedX = (particle.x / radius + 1) / 2;
    final normalizedY = (particle.y / radius + 1) / 2;
    final gradientFactor = (normalizedX * 0.4 + normalizedY * 0.6);

    // Fire color palette
    const hotWhite = Color(0xFFFFFAF5);
    const brightYellow = Color(0xFFFFE8C0);
    const warmOrange = Color(0xFFFFB880);
    const deepAmber = Color(0xFFE89878);
    const softRose = Color(0xFFDDA0A0);

    Color baseColor;
    Color coreColor;
    if (gradientFactor < 0.3) {
      baseColor = Color.lerp(softRose, deepAmber, gradientFactor / 0.3)!;
      coreColor = Color.lerp(warmOrange, brightYellow, gradientFactor / 0.3)!;
    } else if (gradientFactor < 0.6) {
      baseColor =
          Color.lerp(deepAmber, warmOrange, (gradientFactor - 0.3) / 0.3)!;
      coreColor =
          Color.lerp(brightYellow, hotWhite, (gradientFactor - 0.3) / 0.3)!;
    } else {
      baseColor =
          Color.lerp(warmOrange, brightYellow, (gradientFactor - 0.6) / 0.4)!;
      coreColor = hotWhite;
    }

    // Apply emissive intensity (HDR simulation)
    final emissiveMult = emissiveIntensity;

    // Apply additive blending simulation (lighten colors)
    if (additiveBlending) {
      baseColor = _applyAdditive(baseColor, emissiveMult * 0.3);
      coreColor = _applyAdditive(coreColor, emissiveMult * 0.5);
    }

    // Brightness combines depth, flicker, pulse, and emissive
    final brightness =
        (0.5 + depthFactor * 0.5) * flickerFactor * pulseFactor * emissiveMult;
    final opacity = math.min(1.0, brightness);

    // Size with variations
    final sizeMultiplier = sizeVar * (0.6 + depthFactor * 0.4) * flickerFactor;
    final currentSize = particleSize * sizeMultiplier;

    // === WIGGLE BASED ON STYLE ===
    double wobble1 = 0, wobble2 = 0, wobble3 = 0;
    switch (wiggleStyle) {
      case WiggleStyle.none:
        // No wobble
        break;
      case WiggleStyle.subtle:
        wobble1 =
            math.sin(sparklePhase * 1.2 * wobbleSpeed + particle.index) *
            currentSize *
            wiggleIntensity;
        wobble2 =
            math.cos(sparklePhase * 1.0 * wobbleSpeed + particle.index * 1.3) *
            currentSize *
            wiggleIntensity *
            0.8;
        wobble3 =
            math.sin(sparklePhase * 1.5 * wobbleSpeed + particle.index * 0.8) *
            currentSize *
            wiggleIntensity *
            0.6;
        break;
      case WiggleStyle.fluid:
        // Smooth liquid-like deformation
        wobble1 =
            math.sin(sparklePhase * 0.8 * wobbleSpeed + particle.index * 0.5) *
            currentSize *
            wiggleIntensity *
            1.5;
        wobble2 =
            math.cos(sparklePhase * 0.6 * wobbleSpeed + particle.index * 0.7) *
            currentSize *
            wiggleIntensity *
            1.3;
        wobble3 =
            math.sin(sparklePhase * 0.9 * wobbleSpeed + particle.index * 0.4) *
            currentSize *
            wiggleIntensity;
        break;
      case WiggleStyle.electric:
        // Quick nervous energy
        wobble1 =
            math.sin(sparklePhase * 4 * wobbleSpeed + particle.index * 2) *
            currentSize *
            wiggleIntensity;
        wobble2 =
            math.cos(sparklePhase * 3.5 * wobbleSpeed + particle.index * 2.3) *
            currentSize *
            wiggleIntensity;
        wobble3 =
            math.sin(sparklePhase * 5 * wobbleSpeed + particle.index * 1.8) *
            currentSize *
            wiggleIntensity *
            0.7;
        break;
      case WiggleStyle.wave:
        // Wave propagation
        final waveOffset = depthFactor * 3;
        wobble1 =
            math.sin(sparklePhase * 1.5 * wobbleSpeed - waveOffset) *
            currentSize *
            wiggleIntensity *
            1.2;
        wobble2 =
            math.cos(sparklePhase * 1.3 * wobbleSpeed - waveOffset * 0.8) *
            currentSize *
            wiggleIntensity;
        wobble3 =
            math.sin(sparklePhase * 1.8 * wobbleSpeed - waveOffset * 1.2) *
            currentSize *
            wiggleIntensity *
            0.8;
        break;
      case WiggleStyle.heartbeat:
        // Pulse-like expansion
        final beat = math.sin(sparklePhase * 2 * wobbleSpeed);
        final beatEnvelope = beat > 0.5 ? (beat - 0.5) * 4 : 0;
        wobble1 = beatEnvelope * currentSize * wiggleIntensity * 2;
        wobble2 = beatEnvelope * currentSize * wiggleIntensity * 2;
        wobble3 = 0;
        break;
    }

    // === SOFT GRADIENT SPRITE (Light Recipe #5) ===
    // Use soft circular gradient texture - white center, alpha fade to edges

    // Layer 1: Outer halo (soft aura)
    if (depthFactor > 0.15) {
      final outerHaloRadius = currentSize * glowRadius * 1.5;
      final haloPaint =
          Paint()
            ..color = baseColor.withOpacity(
              opacity * haloOpacity * 0.5 * pulseFactor,
            )
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              glowSoftness * 1.5,
            );
      canvas.drawCircle(pos, outerHaloRadius, haloPaint);
    }

    // Layer 2: Main glow halo
    if (depthFactor > 0.2) {
      final haloRadius = currentSize * glowRadius;
      final haloGlowPaint =
          Paint()
            ..shader = RadialGradient(
              colors: [
                coreColor.withOpacity(opacity * haloOpacity),
                baseColor.withOpacity(opacity * haloOpacity * 0.6),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ).createShader(Rect.fromCircle(center: pos, radius: haloRadius))
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSoftness);
      canvas.drawCircle(pos, haloRadius, haloGlowPaint);
    }

    // Layer 3: Inner glow (tighter)
    final innerGlowRadius = currentSize * glowRadius * 0.5;
    final innerGlowPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              coreColor.withOpacity(opacity * 0.7),
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

    // === EMISSIVE CORE (Light Recipe #1 & #2) ===
    // Bright core with emissive intensity

    // Main body with emissive boost - use wobble3 for rotation effect
    final bodyWidth = currentSize * (1.0 + wobble1 * 0.08 + wobble3 * 0.02);
    final bodyHeight = currentSize * (1.0 - wobble2 * 0.06 + wobble3 * 0.015);
    final coreBrightness = math.min(1.0, opacity * coreIntensity);

    final bodyPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withOpacity(coreBrightness),
              coreColor.withOpacity(coreBrightness * 0.9),
              baseColor.withOpacity(coreBrightness * 0.6),
            ],
            stops: const [0.0, 0.3, 1.0],
          ).createShader(
            Rect.fromCenter(
              center: pos,
              width: bodyWidth * 2,
              height: bodyHeight * 2,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: pos,
        width: bodyWidth * 2,
        height: bodyHeight * 2,
      ),
      bodyPaint,
    );

    // Secondary organic lobe
    if (depthFactor > 0.35) {
      final lobe1Pos = Offset(pos.dx + wobble1 * 0.8, pos.dy + wobble2 * 0.4);
      final lobe1Size = currentSize * 0.55;
      final lobe1Paint =
          Paint()
            ..color = coreColor.withOpacity(coreBrightness * 0.7)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              glowSoftness * 0.1,
            );
      canvas.drawCircle(lobe1Pos, lobe1Size, lobe1Paint);
    }

    // === HOT WHITE CENTER (emissive peak) ===
    if (depthFactor > 0.25) {
      final hotSize = currentSize * 0.45 * flickerFactor * coreIntensity * 0.5;
      final hotPaint =
          Paint()
            ..color = Colors.white.withOpacity(
              math.min(1.0, coreBrightness * 1.1),
            )
            ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, hotSize, hotPaint);
    }

    // Occasional intense flare (simulates HDR peak)
    if (particle.sparkle > 0.85 && flickerFactor > 0.9 && depthFactor > 0.45) {
      final flareSize = currentSize * 0.6 * coreIntensity * 0.6;
      final flarePaint =
          Paint()
            ..color = Colors.white.withOpacity(0.95)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              glowSoftness * 0.2,
            );
      canvas.drawCircle(pos, flareSize, flarePaint);
    }
  }

  /// Simulate additive blending by lightening the color
  Color _applyAdditive(Color color, double intensity) {
    final r = (color.red + (255 - color.red) * intensity).clamp(0, 255).toInt();
    final g =
        (color.green + (255 - color.green) * intensity).clamp(0, 255).toInt();
    final b =
        (color.blue + (255 - color.blue) * intensity).clamp(0, 255).toInt();
    return Color.fromARGB(color.alpha, r, g, b);
  }

  void _drawCenterGlow(Canvas canvas, Offset center, double radius) {
    // Subtle ambient glow in center - doesn't interfere with particles
    final glow =
        Paint()
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

  @override
  bool shouldRepaint(covariant _AwaSphereParticles oldDelegate) => true;
}

class _Particle {
  final double x;
  final double y;
  final double z;
  final int index;
  final double sparkle;
  final double waveOffset;

  _Particle({
    required this.x,
    required this.y,
    required this.z,
    required this.index,
    required this.sparkle,
    required this.waveOffset,
  });
}

/// A positioned AwaSphere header with consistent sizing
class AwaSphereHeader extends StatelessWidget {
  final double? height;
  final bool halfScreen;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? accentColor;
  final bool interactive;
  final double energy;
  final Widget? child;

  const AwaSphereHeader({
    super.key,
    this.height,
    this.halfScreen = false,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.interactive = true,
    this.energy = 0.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final h =
        height ??
        (halfScreen
            ? AwaSphereConfig.getHalfScreenHeight(context)
            : AwaSphereConfig.lobbyHeight);
    final primary = primaryColor ?? AwaSphereConfig.primaryColor;
    final secondary = secondaryColor ?? AwaSphereConfig.secondaryColor;
    final accent = accentColor ?? AwaSphereConfig.accentColor;

    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Subtle background gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0),
                  radius: 1.2,
                  colors: [
                    primary.withOpacity(0.04 + energy * 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // The sphere - full width, interactive
          Positioned.fill(
            child: AwaSphere(
              height: h,
              primaryColor: primary,
              secondaryColor: secondary,
              accentColor: accent,
              interactive: interactive,
              animate: true,
              particleCount: AwaSphereConfig.particleCount,
              particleSize: AwaSphereConfig.particleSize,
              energy: energy,
            ),
          ),

          // Optional child content overlay
          if (child != null) Positioned.fill(child: child!),
        ],
      ),
    );
  }
}

/// Compact sphere for inline use
class AwaSphereCompact extends StatelessWidget {
  final double size;
  final Color? color;

  const AwaSphereCompact({super.key, this.size = 60, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AwaSphere(
        height: size,
        width: size,
        primaryColor: color ?? AwaSphereConfig.primaryColor,
        secondaryColor:
            color?.withOpacity(0.6) ?? AwaSphereConfig.secondaryColor,
        interactive: false,
        animate: true,
        particleCount: 60,
        particleSize: 2.0,
      ),
    );
  }
}
