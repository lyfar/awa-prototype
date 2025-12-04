import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Emotion dimension for the radial chart
class EmotionDimension {
  final String label;
  final IconData icon;
  final double value; // 0.0 to 1.0

  const EmotionDimension({
    required this.label,
    required this.icon,
    required this.value,
  });
}

/// Practice emotion profile - what emotional states a practice cultivates
class PracticeEmotionProfile {
  final double calm;       // Inner peace, stillness
  final double energy;     // Vitality, alertness
  final double clarity;    // Mental focus, insight
  final double joy;        // Happiness, lightness
  final double presence;   // Grounding, awareness
  final double release;    // Letting go, relief
  final double connection; // Unity, belonging

  const PracticeEmotionProfile({
    this.calm = 0.0,
    this.energy = 0.0,
    this.clarity = 0.0,
    this.joy = 0.0,
    this.presence = 0.0,
    this.release = 0.0,
    this.connection = 0.0,
  });

  List<EmotionDimension> get dimensions => [
        EmotionDimension(label: 'Calm', icon: Icons.water_drop_outlined, value: calm),
        EmotionDimension(label: 'Energy', icon: Icons.bolt_outlined, value: energy),
        EmotionDimension(label: 'Clarity', icon: Icons.lightbulb_outline, value: clarity),
        EmotionDimension(label: 'Joy', icon: Icons.wb_sunny_outlined, value: joy),
        EmotionDimension(label: 'Presence', icon: Icons.center_focus_strong, value: presence),
        EmotionDimension(label: 'Release', icon: Icons.air, value: release),
        EmotionDimension(label: 'Connection', icon: Icons.favorite_outline, value: connection),
      ];

  /// Default profiles for each practice type
  static const PracticeEmotionProfile lightPractice = PracticeEmotionProfile(
    calm: 0.75,
    energy: 0.65,
    clarity: 0.90,
    joy: 0.60,
    presence: 0.95,
    release: 0.50,
    connection: 0.55,
  );

  static const PracticeEmotionProfile guidedMeditation = PracticeEmotionProfile(
    calm: 0.90,
    energy: 0.35,
    clarity: 0.70,
    joy: 0.55,
    presence: 0.85,
    release: 0.80,
    connection: 0.75,
  );

  static const PracticeEmotionProfile soundMeditation = PracticeEmotionProfile(
    calm: 0.95,
    energy: 0.25,
    clarity: 0.50,
    joy: 0.70,
    presence: 0.80,
    release: 0.90,
    connection: 0.85,
  );

  static const PracticeEmotionProfile myPractice = PracticeEmotionProfile(
    calm: 0.60,
    energy: 0.70,
    clarity: 0.65,
    joy: 0.65,
    presence: 0.75,
    release: 0.55,
    connection: 0.50,
  );

  static const PracticeEmotionProfile specialPractice = PracticeEmotionProfile(
    calm: 0.45,
    energy: 0.80,
    clarity: 0.75,
    joy: 0.85,
    presence: 0.70,
    release: 0.65,
    connection: 0.90,
  );
}

/// Beautiful radial/spider chart showing emotional dimensions
class RadialEmotionChart extends StatefulWidget {
  final PracticeEmotionProfile profile;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final bool animate;

  const RadialEmotionChart({
    super.key,
    required this.profile,
    this.size = 220,
    this.primaryColor = const Color(0xFFE88A6E),
    this.secondaryColor = const Color(0xFFFCB29C),
    this.animate = true,
  });

  @override
  State<RadialEmotionChart> createState() => _RadialEmotionChartState();
}

class _RadialEmotionChartState extends State<RadialEmotionChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = widget.profile.dimensions;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _RadialChartPainter(
              dimensions: dimensions,
              progress: _animation.value,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
            ),
            child: child,
          );
        },
        child: _buildLabels(dimensions),
      ),
    );
  }

  Widget _buildLabels(List<EmotionDimension> dimensions) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        final radius = constraints.maxWidth * 0.46;
        final labelRadius = radius + 28;

        return Stack(
          children: List.generate(dimensions.length, (index) {
            final angle = -math.pi / 2 + (2 * math.pi / dimensions.length) * index;
            final x = center.dx + labelRadius * math.cos(angle);
            final y = center.dy + labelRadius * math.sin(angle);
            final dimension = dimensions[index];

            return Positioned(
              left: x - 30,
              top: y - 20,
              child: SizedBox(
                width: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      dimension.icon,
                      size: 18,
                      color: widget.primaryColor,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dimension.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _RadialChartPainter extends CustomPainter {
  final List<EmotionDimension> dimensions;
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  _RadialChartPainter({
    required this.dimensions,
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;
    final sides = dimensions.length;

    // Draw grid circles
    _drawGridCircles(canvas, center, radius);

    // Draw axis lines
    _drawAxisLines(canvas, center, radius, sides);

    // Draw data polygon with gradient fill
    _drawDataPolygon(canvas, center, radius, sides);

    // Draw data points
    _drawDataPoints(canvas, center, radius, sides);
  }

  void _drawGridCircles(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw 4 concentric circles
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), gridPaint);
    }

    // Draw outer border circle (dashed effect via dotted)
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawAxisLines(Canvas canvas, Offset center, double radius, int sides) {
    final axisPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + (2 * math.pi / sides) * i;
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(endX, endY), axisPaint);
    }
  }

  void _drawDataPolygon(Canvas canvas, Offset center, double radius, int sides) {
    if (progress == 0) return;

    final path = Path();
    final glowPath = Path();

    for (int i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + (2 * math.pi / sides) * i;
      final value = dimensions[i].value * progress;
      final pointRadius = radius * value;
      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
        glowPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        glowPath.lineTo(x, y);
      }
    }
    path.close();
    glowPath.close();

    // Draw outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.3),
          primaryColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(glowPath, glowPaint);

    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.3),
        radius: 1.2,
        colors: [
          secondaryColor.withOpacity(0.7),
          primaryColor.withOpacity(0.5),
          primaryColor.withOpacity(0.3),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw stroke
    final strokePaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);
  }

  void _drawDataPoints(Canvas canvas, Offset center, double radius, int sides) {
    if (progress == 0) return;

    for (int i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + (2 * math.pi / sides) * i;
      final value = dimensions[i].value * progress;
      final pointRadius = radius * value;
      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);

      // Outer glow
      final glowPaint = Paint()
        ..color = primaryColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), 8, glowPaint);

      // Outer ring
      final outerPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(x, y), 6, outerPaint);

      // Inner fill
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 4, innerPaint);

      // Center dot
      final centerPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 2, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialChartPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        primaryColor != oldDelegate.primaryColor ||
        dimensions != oldDelegate.dimensions;
  }
}

/// Compact version for smaller displays
class RadialEmotionChartCompact extends StatelessWidget {
  final PracticeEmotionProfile profile;
  final Color primaryColor;

  const RadialEmotionChartCompact({
    super.key,
    required this.profile,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return RadialEmotionChart(
      profile: profile,
      size: 180,
      primaryColor: primaryColor,
      secondaryColor: primaryColor.withOpacity(0.6),
      animate: true,
    );
  }
}

