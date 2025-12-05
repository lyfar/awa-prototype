import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'awa_soul_settings.dart';
import 'awa_sphere_config.dart';
import 'awa_sphere_painter.dart';

// Re-export config for backwards compatibility
export 'awa_sphere_config.dart';

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

          final painter = AwaSpherePainter(
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
            // 3D color settings
            particle3DCoreColor:
                settings?.layer3D.coreColor ?? const Color(0xFFFFFFFB),
            particle3DMidColor:
                settings?.layer3D.midColor ?? const Color(0xFFFFE8C0),
            particle3DOuterColor:
                settings?.layer3D.outerColor ?? const Color(0xFFFFB880),
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

/// Compact sphere for header/inline use
class AwaSphereCompact extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  const AwaSphereCompact({
    super.key,
    this.size = 48,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AwaSphere(
        width: size,
        height: size,
        primaryColor: primaryColor ?? AwaSphereConfig.primaryColor,
        secondaryColor: secondaryColor ?? AwaSphereConfig.secondaryColor,
        interactive: false,
        particleCount: 80,
        particleSize: 1.5,
        backdropDotCount: 60,
        backdropDotSize: 2.0,
        useGlobalSettings: false,
      ),
    );
  }
}

/// Header variant of AwaSphere with proper sizing
class AwaSphereHeader extends StatelessWidget {
  final double height;
  final double energy;

  const AwaSphereHeader({super.key, this.height = 200, this.energy = 0.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AwaSphere(
        height: height,
        energy: energy,
        interactive: false,
        particleCount: 200,
        particleSize: 2.5,
        backdropDotCount: 150,
      ),
    );
  }
}
