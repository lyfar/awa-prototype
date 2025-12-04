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
    
    // Warm fire gradient colors
    const gradientColors = [
      Color(0xFFE8C8B8), // 10% - soft warm beige (center)
      Color(0xFFF5D0B0), // 30% - warm cream
      Color(0xFFFFD4A8), // 50% - golden peach
      Color(0xFFFFBF90), // 65% - warm orange
      Color(0xFFE8A090), // 80% - coral rose
      Color(0xFFD8A0A8), // 95% - dusty rose (edge)
    ];
    const gradientStops = [0.10, 0.30, 0.50, 0.65, 0.80, 0.95];
    
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
      
      // Gentle blink - slower and subtler
      final blinkPhase = math.sin(sparklePhase * 0.6 + i * 0.06);
      final blinkFactor = 0.75 + blinkPhase * 0.25; // 0.5 to 1.0
      
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
    
    // === GENTLE DRIFT - very slight position movement ===
    final driftX = math.sin(sparklePhase * 0.3 + particle.index * 0.5) * 1.5;
    final driftY = math.cos(sparklePhase * 0.25 + particle.index * 0.7) * 1.2;
    final pos = center + Offset(particle.x + driftX, particle.y + driftY);
    
    // === ORGANIC SIZE VARIATION ===
    // Each particle has unique base size (0.5x to 2x)
    final sizeVariation = 0.5 + (math.sin(particle.index * 1.7) + 1) * 0.75;
    
    // Gentle flicker - slower, more subtle
    final flicker1 = math.sin(sparklePhase * 1.8 + particle.index * 0.4);
    final flicker2 = math.cos(sparklePhase * 1.4 + particle.index * 0.7);
    final flickerFactor = 0.85 + flicker1 * 0.08 + flicker2 * 0.07;
    
    // Slow pulse (breathing)
    final pulse = math.sin(sparklePhase * 0.8 + particle.index * 0.15);
    final pulseFactor = 0.9 + pulse * 0.1;
    
    // === WARM FIRE COLORS ===
    // Gradient from white-hot center → orange → deep amber
    final normalizedX = (particle.x / radius + 1) / 2;
    final normalizedY = (particle.y / radius + 1) / 2;
    final gradientFactor = (normalizedX * 0.4 + normalizedY * 0.6);
    
    // Fire color palette - warm and organic
    const hotWhite = Color(0xFFFFF8F0);     // White hot
    const brightYellow = Color(0xFFFFE4B5); // Moccasin/warm yellow
    const warmOrange = Color(0xFFFFB07C);   // Warm orange
    const deepAmber = Color(0xFFE8967C);    // Deep amber/coral
    const softRose = Color(0xFFDDA0A0);     // Soft rose for cooler parts
    
    Color baseColor;
    Color coreColor;
    if (gradientFactor < 0.3) {
      baseColor = Color.lerp(softRose, deepAmber, gradientFactor / 0.3)!;
      coreColor = Color.lerp(warmOrange, brightYellow, gradientFactor / 0.3)!;
    } else if (gradientFactor < 0.6) {
      baseColor = Color.lerp(deepAmber, warmOrange, (gradientFactor - 0.3) / 0.3)!;
      coreColor = Color.lerp(brightYellow, hotWhite, (gradientFactor - 0.3) / 0.3)!;
    } else {
      baseColor = Color.lerp(warmOrange, brightYellow, (gradientFactor - 0.6) / 0.4)!;
      coreColor = hotWhite;
    }
    
    // Brightness combines depth, flicker, and pulse
    final brightness = (0.5 + depthFactor * 0.5) * flickerFactor * pulseFactor;
    final opacity = math.min(1.0, brightness);
    
    // Size with all variations
    final sizeMultiplier = sizeVariation * (0.6 + depthFactor * 0.4) * flickerFactor;
    final currentSize = particleSize * sizeMultiplier;
    
    // === ORGANIC SHAPE - Gentle wobbly edges ===
    // Create irregular shape using multiple offset circles - slower movement
    final wobble1 = math.sin(sparklePhase * 1.2 + particle.index) * currentSize * 0.12;
    final wobble2 = math.cos(sparklePhase * 1.0 + particle.index * 1.3) * currentSize * 0.1;
    final wobble3 = math.sin(sparklePhase * 1.5 + particle.index * 0.8) * currentSize * 0.08;
    
    // === BLOOM / GLOW LAYERS ===
    
    // Layer 1: Large warm ambient glow
    if (depthFactor > 0.2) {
      final bloomRadius = currentSize * 5.0;
      final bloomPaint = Paint()
        ..color = baseColor.withOpacity(opacity * 0.2 * pulseFactor)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(pos, bloomRadius, bloomPaint);
    }
    
    // Layer 2: Medium orange glow
    if (depthFactor > 0.25) {
      final midGlowRadius = currentSize * 3.0;
      final midGlowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            coreColor.withOpacity(opacity * 0.35),
            baseColor.withOpacity(opacity * 0.25),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: pos, radius: midGlowRadius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(pos, midGlowRadius, midGlowPaint);
    }
    
    // Layer 3: Inner warm glow - slightly offset for organic feel
    final innerGlowRadius = currentSize * 1.8;
    final innerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          coreColor.withOpacity(opacity * 0.6),
          baseColor.withOpacity(opacity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(pos.dx + wobble1 * 0.3, pos.dy + wobble2 * 0.3),
        radius: innerGlowRadius,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(
      Offset(pos.dx + wobble1 * 0.3, pos.dy + wobble2 * 0.3),
      innerGlowRadius,
      innerGlowPaint,
    );
    
    // === ORGANIC FIRE CORE - Multiple wobbly circles ===
    
    // Main body - slightly squished/stretched
    final bodyWidth = currentSize * (1.0 + wobble1 * 0.1);
    final bodyHeight = currentSize * (1.0 - wobble2 * 0.08);
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          hotWhite.withOpacity(opacity * 0.9),
          coreColor.withOpacity(opacity * 0.8),
          baseColor.withOpacity(opacity * 0.6),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCenter(center: pos, width: bodyWidth * 2, height: bodyHeight * 2));
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: bodyWidth * 2, height: bodyHeight * 2),
      bodyPaint,
    );
    
    // Secondary lobe - offset for organic shape
    if (depthFactor > 0.35) {
      final lobe1Pos = Offset(pos.dx + wobble1, pos.dy + wobble2 * 0.5);
      final lobe1Size = currentSize * 0.65;
      final lobe1Paint = Paint()
        ..color = coreColor.withOpacity(opacity * 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      canvas.drawCircle(lobe1Pos, lobe1Size, lobe1Paint);
    }
    
    // Third lobe - different offset
    if (depthFactor > 0.45) {
      final lobe2Pos = Offset(pos.dx - wobble2 * 0.7, pos.dy + wobble3);
      final lobe2Size = currentSize * 0.5;
      final lobe2Paint = Paint()
        ..color = coreColor.withOpacity(opacity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      canvas.drawCircle(lobe2Pos, lobe2Size, lobe2Paint);
    }
    
    // Hot white center - the brightest point
    if (depthFactor > 0.3) {
      final hotSize = currentSize * 0.4 * flickerFactor;
      final hotPaint = Paint()
        ..color = hotWhite.withOpacity(opacity * 0.95)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, hotSize, hotPaint);
    }
    
    // Occasional bright flare
    if (particle.sparkle > 0.88 && flickerFactor > 0.9 && depthFactor > 0.5) {
      final flarePaint = Paint()
        ..color = hotWhite.withOpacity(0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(pos, currentSize * 0.7, flarePaint);
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
