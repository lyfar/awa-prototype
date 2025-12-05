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

        final particleWaveOffset = math.sin(wavePhase + i * 0.1) * waveIntensity;
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
    const goldenAngle = 2.39996322972865332;
    final backdropRadius = radius * 1.08;

    // Use configurable gradient colors or defaults
    final gradStart = backdropGradientStart ?? const Color(0xFFE8C8B8);
    final gradMid = backdropGradientMid ?? const Color(0xFFFFD4A8);
    final gradEnd = backdropGradientEnd ?? const Color(0xFFD8A0A8);

    // Draw backdrop spiral dots with gradient and blink
    for (int i = 0; i < backdropDotCount; i++) {
      final t = i / backdropDotCount;
      final r = backdropRadius * math.sqrt(t);
      final theta = goldenAngle * i;

      final x = center.dx + r * math.cos(theta);
      final y = center.dy + r * math.sin(theta);

      // Distance ratio for gradient
      final distRatio = r / backdropRadius;

      // Interpolate through 3 configurable colors
      Color dotColor;
      if (distRatio < 0.5) {
        dotColor = Color.lerp(gradStart, gradMid, distRatio * 2)!;
      } else {
        dotColor = Color.lerp(gradMid, gradEnd, (distRatio - 0.5) * 2)!;
      }

      // Gentle blink - speed controlled by pulseSpeed
      final blinkPhase = math.sin(sparklePhase * 0.6 * pulseSpeed + i * 0.06);
      final blinkFactor = 0.75 + blinkPhase * 0.25;

      // Dot size with slight variation - use configurable backdropDotSize
      final sizeVariation = math.sin(i * 0.5) * 0.3;
      final dotSize =
          (backdropDotSize + (1 - distRatio) * backdropDotSize * 0.8) *
          (1 + sizeVariation * 0.2);

      // Opacity with fade at edges and blink - use configurable backdropOpacity
      double opacity;
      if (distRatio < 0.2) {
        opacity = distRatio * 4;
      } else if (distRatio > 0.9) {
        opacity = (1 - distRatio) * 8;
      } else {
        opacity = backdropOpacity;
      }
      opacity *= blinkFactor;

      // Large soft blur glow
      final glowPaint =
          Paint()
            ..color = dotColor.withOpacity(opacity * 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), dotSize * 2.0, glowPaint);

      // Medium glow layer
      final midGlowPaint =
          Paint()
            ..color = dotColor.withOpacity(opacity * 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
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
              const Color(0xFFFFF5F0).withOpacity(0.3),
              const Color(0xFFFAE8E0).withOpacity(0.15),
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

    // === GENTLE DRIFT ===
    final driftX =
        math.sin(sparklePhase * 0.3 * driftSpeed + particle.index * 0.5) * 1.5;
    final driftY =
        math.cos(sparklePhase * 0.25 * driftSpeed + particle.index * 0.7) * 1.2;
    final pos = center + Offset(particle.x + driftX, particle.y + driftY);

    // === ORGANIC SIZE VARIATION ===
    final sizeVariation = 0.5 + (math.sin(particle.index * 1.7) + 1) * 0.75;

    // Flicker and pulse
    final flicker1 = math.sin(
      sparklePhase * 1.8 * flickerSpeed + particle.index * 0.4,
    );
    final flicker2 = math.cos(
      sparklePhase * 1.4 * flickerSpeed + particle.index * 0.7,
    );
    final flickerFactor = 0.85 + flicker1 * 0.08 + flicker2 * 0.07;
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
    final sizeMultiplier =
        sizeVariation * (0.6 + depthFactor * 0.4) * flickerFactor;
    final currentSize = particleSize * sizeMultiplier;

    // Wobble for organic shape
    final wobble1 =
        math.sin(sparklePhase * 1.2 * wobbleSpeed + particle.index) *
        currentSize *
        0.12;
    final wobble2 =
        math.cos(sparklePhase * 1.0 * wobbleSpeed + particle.index * 1.3) *
        currentSize *
        0.1;
    final wobble3 =
        math.sin(sparklePhase * 1.5 * wobbleSpeed + particle.index * 0.8) *
        currentSize *
        0.08;

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

    // Main body with emissive boost
    final bodyWidth = currentSize * (1.0 + wobble1 * 0.08);
    final bodyHeight = currentSize * (1.0 - wobble2 * 0.06);
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
