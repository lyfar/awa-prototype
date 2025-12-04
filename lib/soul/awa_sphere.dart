import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
    final autoRotation = _time * _rotationSpeed * 2 * math.pi;
    final breathPhase = math.sin(_time * _breathSpeed * 2 * math.pi);
    final breathScale = 1.0 + breathPhase * 0.05;
    final wavePhase = _time * _waveSpeed * 2 * math.pi;
    final sparklePhase = _time * _sparkleSpeed * 2 * math.pi;

    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = widget.width ?? constraints.maxWidth;
          return CustomPaint(
            size: Size(width, widget.height),
            painter: _AwaSphereParticles(
              rotationX: _rotationX,
              rotationY: _rotationY + autoRotation,
              scale: _scale * breathScale,
              wavePhase: wavePhase,
              sparklePhase: sparklePhase,
              energy: _smoothEnergy,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
              accentColor: widget.accentColor ?? widget.primaryColor.withOpacity(0.8),
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
  final double scale;
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
    required this.scale,
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
    final baseRadius = (math.min(size.width, size.height) / 2) * 0.6 * scale;
    
    // Golden angle for phyllotaxis
    const goldenAngle = 2.39996322972865332;
    
    final floatIntensity = 1.5 + (energy * 1.0);
    final waveIntensity = 0.06 + (energy * 0.03);
    
    // Draw subtle dark sphere backdrop
    _drawDarkSphere(canvas, center, baseRadius);
    
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
    
    // Draw particles as light points
    for (final particle in particles) {
      _drawLightParticle(canvas, center, particle, baseRadius);
    }
    
    // Draw center glow
    _drawCenterGlow(canvas, center, baseRadius);
  }

  void _drawDarkSphere(Canvas canvas, Offset center, double radius) {
    // 2D Phyllotaxis spiral backdrop with blurred gradient dots
    const goldenAngle = 2.39996322972865332;
    final backdropRadius = radius * 1.08;
    final dotCount = 380;
    
    // Gradient colors from the design
    const gradientColors = [
      Color(0xFFB89FC1), // 14% - lavender
      Color(0xFFEFABBF), // 46% - pink
      Color(0xFFFDB196), // 61% - peach coral
      Color(0xFFFBAD99), // 75% - salmon
      Color(0xFFFEC0A2), // 80% - light peach
      Color(0xFFFABF9E), // 94% - warm peach
    ];
    const gradientStops = [0.14, 0.46, 0.61, 0.75, 0.80, 0.94];
    
    // Draw backdrop spiral dots with gradient and blink
    for (int i = 0; i < dotCount; i++) {
      final t = i / dotCount;
      final r = backdropRadius * math.sqrt(t);
      final theta = goldenAngle * i;
      
      final x = center.dx + r * math.cos(theta);
      final y = center.dy + r * math.sin(theta);
      
      // Distance ratio for gradient
      final distRatio = r / backdropRadius;
      
      // Get color from gradient based on distance
      Color dotColor = gradientColors.last;
      for (int j = 0; j < gradientStops.length - 1; j++) {
        if (distRatio >= gradientStops[j] && distRatio <= gradientStops[j + 1]) {
          final localT = (distRatio - gradientStops[j]) / (gradientStops[j + 1] - gradientStops[j]);
          dotColor = Color.lerp(gradientColors[j], gradientColors[j + 1], localT)!;
          break;
        } else if (distRatio < gradientStops[0]) {
          dotColor = gradientColors[0];
          break;
        }
      }
      
      // Blink factor based on sparkle phase and dot index
      final blinkPhase = math.sin(sparklePhase * 1.5 + i * 0.08);
      final blinkFactor = 0.6 + blinkPhase * 0.4; // 0.2 to 1.0
      
      // Dot size with slight variation
      final sizeVariation = math.sin(i * 0.5) * 0.3;
      final dotSize = (5.0 + (1 - distRatio) * 4.0) * (1 + sizeVariation * 0.2);
      
      // Opacity with fade at edges and blink
      double opacity;
      if (distRatio < 0.2) {
        opacity = distRatio * 4; // Fade in from center
      } else if (distRatio > 0.9) {
        opacity = (1 - distRatio) * 8; // Fade out at edge
      } else {
        opacity = 0.8;
      }
      opacity *= blinkFactor;
      
      // Large soft blur glow
      final glowPaint = Paint()
        ..color = dotColor.withOpacity(opacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), dotSize * 2.0, glowPaint);
      
      // Medium glow layer
      final midGlowPaint = Paint()
        ..color = dotColor.withOpacity(opacity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), dotSize * 1.3, midGlowPaint);
      
      // Core dot
      final dotPaint = Paint()
        ..color = Color.lerp(dotColor, Colors.white, 0.3)!.withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), dotSize * 0.7, dotPaint);
    }
    
    // Soft center glow
    final centerGlow = Paint()
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

  void _drawLightParticle(Canvas canvas, Offset center, _Particle particle, double radius) {
    final depthFactor = (particle.z + 1) / 2; // 0 to 1, back to front
    final pos = center + Offset(particle.x, particle.y);
    
    // Blink/twinkle effect - each star pulses
    final blinkPhase = math.sin(sparklePhase * 2.5 + particle.index * 0.12);
    final blinkFactor = 0.4 + blinkPhase * 0.6; // 0.0 to 1.0
    
    // Secondary shimmer (faster)
    final shimmer = math.sin(sparklePhase * 5.0 + particle.index * 0.3);
    final shimmerFactor = 0.85 + shimmer * 0.15;
    
    // Color gradient across sphere
    final normalizedX = (particle.x / radius + 1) / 2;
    final normalizedY = (particle.y / radius + 1) / 2;
    final gradientFactor = (normalizedX * 0.5 + normalizedY * 0.5);
    
    // Gradient colors - slightly brighter
    const warmColor = Color(0xFFFFD4B8);  // Bright warm peach
    const midColor = Color(0xFFF8C0D8);   // Bright pink
    const coolColor = Color(0xFFD0B8E0);  // Bright lavender
    
    Color baseColor;
    if (gradientFactor < 0.5) {
      baseColor = Color.lerp(coolColor, midColor, gradientFactor * 2)!;
    } else {
      baseColor = Color.lerp(midColor, warmColor, (gradientFactor - 0.5) * 2)!;
    }
    
    // Brightness with blink and shimmer
    final brightness = (0.5 + depthFactor * 0.5) * blinkFactor * shimmerFactor;
    final opacity = math.min(1.0, brightness);
    final sizeMultiplier = (0.6 + depthFactor * 0.4) * (1 + particle.waveOffset * 0.05);
    final currentSize = particleSize * sizeMultiplier * (0.85 + blinkFactor * 0.15);
    
    // === STAR RAYS - Draw cross pattern for star effect ===
    if (depthFactor > 0.4 && blinkFactor > 0.5) {
      final rayLength = currentSize * (4.0 + blinkFactor * 3.0);
      final rayWidth = currentSize * 0.3;
      final rayOpacity = opacity * 0.5 * (blinkFactor - 0.3);
      
      // Horizontal ray
      final hRayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(rayOpacity * 0.3),
            Colors.white.withOpacity(rayOpacity),
            Colors.white.withOpacity(rayOpacity * 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ).createShader(Rect.fromCenter(center: pos, width: rayLength * 2, height: rayWidth))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      canvas.drawRect(
        Rect.fromCenter(center: pos, width: rayLength * 2, height: rayWidth),
        hRayPaint,
      );
      
      // Vertical ray
      final vRayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(rayOpacity * 0.3),
            Colors.white.withOpacity(rayOpacity),
            Colors.white.withOpacity(rayOpacity * 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ).createShader(Rect.fromCenter(center: pos, width: rayWidth, height: rayLength * 2))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      canvas.drawRect(
        Rect.fromCenter(center: pos, width: rayWidth, height: rayLength * 2),
        vRayPaint,
      );
      
      // Diagonal rays for brighter stars
      if (blinkFactor > 0.7 && depthFactor > 0.55) {
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(math.pi / 4);
        
        final diagRayLength = rayLength * 0.7;
        final diagOpacity = rayOpacity * 0.6;
        
        // Diagonal ray 1
        final d1Paint = Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(diagOpacity),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCenter(center: Offset.zero, width: diagRayLength * 2, height: rayWidth * 0.7))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: diagRayLength * 2, height: rayWidth * 0.7),
          d1Paint,
        );
        
        // Diagonal ray 2
        final d2Paint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(diagOpacity),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCenter(center: Offset.zero, width: rayWidth * 0.7, height: diagRayLength * 2))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: rayWidth * 0.7, height: diagRayLength * 2),
          d2Paint,
        );
        
        canvas.restore();
      }
    }
    
    // === BLOOM EFFECT - Multiple blur layers ===
    
    // Layer 1: Very large soft bloom
    if (depthFactor > 0.25) {
      final bloomRadius = currentSize * 6.0;
      final bloomOpacity = opacity * 0.25 * blinkFactor;
      final bloomPaint = Paint()
        ..color = baseColor.withOpacity(bloomOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(pos, bloomRadius, bloomPaint);
    }
    
    // Layer 2: Medium bloom with color
    if (depthFactor > 0.3) {
      final midBloomRadius = currentSize * 3.5;
      final midBloomPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(opacity * 0.4 * blinkFactor),
            baseColor.withOpacity(opacity * 0.3 * blinkFactor),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromCircle(center: pos, radius: midBloomRadius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(pos, midBloomRadius, midBloomPaint);
    }
    
    // Layer 3: Inner glow
    final innerGlowRadius = currentSize * 2.0;
    final innerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(opacity * 0.7 * blinkFactor),
          baseColor.withOpacity(opacity * 0.5 * blinkFactor),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: innerGlowRadius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(pos, innerGlowRadius, innerGlowPaint);
    
    // Layer 4: Bright core
    final coreColor = Color.lerp(baseColor, Colors.white, 0.8)!;
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(opacity * blinkFactor),
          coreColor.withOpacity(opacity * 0.9 * blinkFactor),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: currentSize));
    canvas.drawCircle(pos, currentSize, corePaint);
    
    // Layer 5: Hot white center - the "star point"
    if (depthFactor > 0.3) {
      final hotCenterPaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.98 * blinkFactor)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, currentSize * 0.55, hotCenterPaint);
    }
    
    // Extra intense flash on some stars
    if (particle.sparkle > 0.85 && blinkFactor > 0.8 && depthFactor > 0.5) {
      // Bright starburst flash
      final flashPaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(pos, currentSize * 0.8, flashPaint);
    }
  }

  void _drawCenterGlow(Canvas canvas, Offset center, double radius) {
    // Subtle ambient glow in center - doesn't interfere with particles
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
    final h = height ?? 
        (halfScreen ? AwaSphereConfig.getHalfScreenHeight(context) : AwaSphereConfig.lobbyHeight);
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
        secondaryColor: color?.withOpacity(0.6) ?? AwaSphereConfig.secondaryColor,
        interactive: false,
        animate: true,
        particleCount: 60,
        particleSize: 2.0,
      ),
    );
  }
}
