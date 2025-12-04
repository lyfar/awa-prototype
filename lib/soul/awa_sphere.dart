import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Standard sphere configuration for consistent sizing across the app
class AwaSphereConfig {
  /// Standard height for the sphere header (1/3 of typical screen)
  static const double standardHeight = 280;
  
  /// Primary coral/peach color
  static const Color primaryColor = Color(0xFFFCB29C);
  
  /// Secondary soft pink color  
  static const Color secondaryColor = Color(0xFFE8D5D0);
  
  /// Accent highlight color
  static const Color accentColor = Color(0xFFFFD4C4);
  
  /// Standard particle count
  static const int particleCount = 200;
  
  /// Standard particle size
  static const double particleSize = 4.0;
}

/// AwaSphere - A beautiful interactive phyllotaxis spiral sphere
/// Displays particles arranged in a golden spiral pattern on a sphere
/// Used as the AwaSoul visual representation across all screens
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
  /// Energy level from 0.0 (calm) to 1.0 (excited) - affects particle movement
  final double energy;

  const AwaSphere({
    super.key,
    this.width,
    this.height = AwaSphereConfig.standardHeight,
    this.primaryColor = AwaSphereConfig.primaryColor,
    this.secondaryColor = AwaSphereConfig.secondaryColor,
    this.accentColor,
    this.interactive = true,
    this.animate = true,
    this.particleSize = AwaSphereConfig.particleSize,
    this.particleCount = AwaSphereConfig.particleCount,
    this.energy = 0.0,
  });

  @override
  State<AwaSphere> createState() => _AwaSphereState();
}

class _AwaSphereState extends State<AwaSphere> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0;
  double _rotationX = 0;
  double _rotationY = 0;
  double _smoothEnergy = 0.0;
  double _targetEnergy = 0.0;
  Offset? _lastPanPosition;

  // Use different "frequencies" that don't have common factors to avoid sync
  static const double _rotationSpeed = 0.08;      // Slow rotation
  static const double _breathSpeed = 0.4;          // Breathing pulse
  static const double _waveSpeed = 0.55;           // Wave through particles
  static const double _sparkleSpeed = 0.73;        // Sparkle effect

  @override
  void initState() {
    super.initState();
    _smoothEnergy = widget.energy;
    _targetEnergy = widget.energy;
    
    // Use a single Ticker for smooth, continuous animation
    _ticker = createTicker(_onTick);
    if (widget.animate) {
      _ticker.start();
    }
  }
  
  void _onTick(Duration elapsed) {
    setState(() {
      // Continuous time increment - never resets, just keeps going
      _time += 0.016; // ~60fps increment
      
      // Smoothly interpolate energy for seamless transitions
      if (_smoothEnergy != _targetEnergy) {
        final diff = _targetEnergy - _smoothEnergy;
        _smoothEnergy += diff * 0.08; // Smooth easing
        if ((diff).abs() < 0.001) {
          _smoothEnergy = _targetEnergy;
        }
      }
    });
  }
  
  @override
  void didUpdateWidget(covariant AwaSphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Smoothly transition to new energy level
    if (widget.energy != oldWidget.energy) {
      _targetEnergy = widget.energy;
    }
    
    // Handle animate changes
    if (widget.animate && !_ticker.isActive) {
      _ticker.start();
    } else if (!widget.animate && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
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
      _rotationY += delta.dx * 0.008;
      _rotationX += delta.dy * 0.008;
      _rotationX = _rotationX.clamp(-math.pi / 3, math.pi / 3);
    });
    _lastPanPosition = details.localPosition;
  }

  void _handlePanEnd(DragEndDetails details) {
    _lastPanPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate animation phases using continuous time (no resets)
    final autoRotation = _time * _rotationSpeed * 2 * math.pi;
    final breathPhase = math.sin(_time * _breathSpeed * 2 * math.pi);
    final breathScale = 1.0 + breathPhase * 0.06;
    final wavePhase = _time * _waveSpeed * 2 * math.pi;
    final sparklePhase = _time * _sparkleSpeed * 2 * math.pi;

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = widget.width ?? constraints.maxWidth;
          return CustomPaint(
            size: Size(width, widget.height),
            painter: _AwaSphereParticles(
              rotationX: _rotationX,
              rotationY: _rotationY + autoRotation,
              breathScale: breathScale,
              wavePhase: wavePhase,
              sparklePhase: sparklePhase,
              energy: _smoothEnergy,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
              accentColor: widget.accentColor ?? widget.primaryColor.withValues(alpha: 0.8),
              particleSize: widget.particleSize,
              particleCount: widget.particleCount,
            ),
          );
        },
      ),
    );
  }
}

class _AwaSphereParticles extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final double breathScale;
  final double wavePhase;
  final double sparklePhase;
  final double energy;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double particleSize;
  final int particleCount;

  _AwaSphereParticles({
    required this.rotationX,
    required this.rotationY,
    required this.breathScale,
    required this.wavePhase,
    required this.sparklePhase,
    required this.energy,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.particleSize,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (math.min(size.width, size.height) / 2) * 0.7;
    
    // Golden angle for phyllotaxis
    const goldenAngle = 2.39996322972865332;
    
    // Energy affects movement intensity - keep subtle
    final floatIntensity = 2.0 + (energy * 1.5);
    final waveIntensity = 0.08 + (energy * 0.04);
    
    // Generate and sort particles by z-depth
    final particles = <_Particle>[];
    
    for (int i = 0; i < particleCount; i++) {
      final t = i / particleCount;
      final inclination = math.acos(1 - 2 * t);
      final azimuth = goldenAngle * i;
      
      // Individual wave offset - smooth continuous
      final particleWaveOffset = math.sin(wavePhase + i * 0.12) * waveIntensity;
      final particleRadius = baseRadius * breathScale * (1 + particleWaveOffset);
      
      // Spherical to Cartesian
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
      final floatX = math.sin(wavePhase * 1.1 + i * 0.17) * floatIntensity;
      final floatY = math.cos(wavePhase * 0.9 + i * 0.21) * floatIntensity;
      
      // Sparkle factor - continuous, no jumps
      final sparkle = (math.sin(sparklePhase * 2 + i * 0.4) + 1) / 2;
      
      particles.add(_Particle(
        x: x * particleRadius + floatX,
        y: y * particleRadius + floatY,
        z: z,
        index: i,
        sparkle: sparkle,
        waveOffset: particleWaveOffset,
      ));
    }
    
    // Sort by z for proper depth rendering
    particles.sort((a, b) => a.z.compareTo(b.z));
    
    // Draw ambient glow
    final ambientGlow = RadialGradient(
      colors: [
        primaryColor.withValues(alpha: 0.12),
        primaryColor.withValues(alpha: 0.04),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final ambientPaint = Paint()
      ..shader = ambientGlow.createShader(
        Rect.fromCircle(center: center, radius: baseRadius * 1.15),
      );
    canvas.drawCircle(center, baseRadius * 1.15, ambientPaint);
    
    // Draw particles
    for (final particle in particles) {
      final depthFactor = (particle.z + 1) / 2;
      final baseOpacity = 0.2 + depthFactor * 0.8;
      final sparkleBoost = particle.sparkle * 0.2 * depthFactor;
      final opacity = math.min(1.0, baseOpacity + sparkleBoost);
      final sizeMultiplier = (0.5 + depthFactor * 0.5) * (1 + particle.waveOffset * 0.2);
      
      final colorT = (particle.index / particleCount);
      Color baseColor;
      if (particle.sparkle > 0.75 && depthFactor > 0.6) {
        baseColor = Color.lerp(primaryColor, accentColor, particle.sparkle)!;
      } else {
        baseColor = Color.lerp(primaryColor, secondaryColor, colorT)!;
      }
      final color = baseColor.withValues(alpha: opacity);
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      final pos = center + Offset(particle.x, particle.y);
      final currentSize = particleSize * sizeMultiplier;
      
      // Glow for front particles
      if (depthFactor > 0.65) {
        final glowIntensity = depthFactor * 0.35;
        final glowPaint = Paint()
          ..color = color.withValues(alpha: opacity * glowIntensity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + particle.sparkle * 2);
        canvas.drawCircle(pos, currentSize * 1.8, glowPaint);
      }
      
      canvas.drawCircle(pos, currentSize, paint);
      
      // Bright center for front particles
      if (depthFactor > 0.75) {
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, currentSize * 0.25, highlightPaint);
      }
    }
    
    // Center glow
    final centerGlow = RadialGradient(
      colors: [
        primaryColor.withValues(alpha: 0.08),
        primaryColor.withValues(alpha: 0.0),
      ],
    );
    
    final centerPaint = Paint()
      ..shader = centerGlow.createShader(
        Rect.fromCircle(center: center, radius: baseRadius * 0.45),
      );
    canvas.drawCircle(center, baseRadius * 0.45, centerPaint);
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
/// Use this across all screens for uniform appearance
class AwaSphereHeader extends StatelessWidget {
  final double? height;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? accentColor;
  final bool interactive;
  final double energy;
  final Widget? child;

  const AwaSphereHeader({
    super.key,
    this.height,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.interactive = true,
    this.energy = 0.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? AwaSphereConfig.standardHeight;
    final primary = primaryColor ?? AwaSphereConfig.primaryColor;
    final secondary = secondaryColor ?? AwaSphereConfig.secondaryColor;
    final accent = accentColor ?? AwaSphereConfig.accentColor;

    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Subtle radial gradient background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.5,
                  colors: [
                    primary.withValues(alpha: 0.08 + energy * 0.04),
                    primary.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          
          // The sphere - full width
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
          if (child != null)
            Positioned.fill(child: child!),
        ],
      ),
    );
  }
}

/// Compact sphere for inline use
class AwaSphereCompact extends StatelessWidget {
  final double size;
  final Color? color;

  const AwaSphereCompact({
    super.key,
    this.size = 60,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AwaSphere(
        height: size,
        width: size,
        primaryColor: color ?? AwaSphereConfig.primaryColor,
        secondaryColor: color?.withValues(alpha: 0.6) ?? AwaSphereConfig.secondaryColor,
        interactive: false,
        animate: true,
        particleCount: 80,
        particleSize: 2.0,
      ),
    );
  }
}
