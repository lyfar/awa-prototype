import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../reactions/reaction_palette.dart';

/// Practice emotion profile - what emotional states a practice cultivates
/// Uses the actual reaction taxonomy from the app
class PracticeEmotionProfile {
  final double grounded;  // Rooted, steady, supported
  final double joy;       // Light, expansive, delighted
  final double energy;    // Activated, buzzing, ready
  final double peace;     // Calm, soft, rested
  final double release;   // Let go of weight or tension
  final double insight;   // Gained clarity or perspective
  final double unity;     // Deeply connected to others

  const PracticeEmotionProfile({
    this.grounded = 0.0,
    this.joy = 0.0,
    this.energy = 0.0,
    this.peace = 0.0,
    this.release = 0.0,
    this.insight = 0.0,
    this.unity = 0.0,
  });

  List<EmotionValue> get values => [
    EmotionValue(data: reactionTaxonomy[0], value: grounded),  // Grounded
    EmotionValue(data: reactionTaxonomy[1], value: joy),       // Joy
    EmotionValue(data: reactionTaxonomy[2], value: energy),    // Energy
    EmotionValue(data: reactionTaxonomy[3], value: peace),     // Peace
    EmotionValue(data: reactionTaxonomy[4], value: release),   // Release
    EmotionValue(data: reactionTaxonomy[5], value: insight),   // Insight
    EmotionValue(data: reactionTaxonomy[6], value: unity),     // Unity
  ];

  /// Default profiles for each practice type
  static const PracticeEmotionProfile lightPractice = PracticeEmotionProfile(
    grounded: 0.85,
    joy: 0.60,
    energy: 0.70,
    peace: 0.75,
    release: 0.50,
    insight: 0.90,
    unity: 0.55,
  );

  static const PracticeEmotionProfile guidedMeditation = PracticeEmotionProfile(
    grounded: 0.80,
    joy: 0.55,
    energy: 0.35,
    peace: 0.90,
    release: 0.80,
    insight: 0.70,
    unity: 0.75,
  );

  static const PracticeEmotionProfile soundMeditation = PracticeEmotionProfile(
    grounded: 0.70,
    joy: 0.70,
    energy: 0.25,
    peace: 0.95,
    release: 0.90,
    insight: 0.50,
    unity: 0.85,
  );

  static const PracticeEmotionProfile myPractice = PracticeEmotionProfile(
    grounded: 0.65,
    joy: 0.65,
    energy: 0.70,
    peace: 0.60,
    release: 0.55,
    insight: 0.65,
    unity: 0.50,
  );

  static const PracticeEmotionProfile specialPractice = PracticeEmotionProfile(
    grounded: 0.70,
    joy: 0.85,
    energy: 0.80,
    peace: 0.45,
    release: 0.65,
    insight: 0.75,
    unity: 0.90,
  );
}

class EmotionValue {
  final ReactionStateData data;
  final double value;

  const EmotionValue({required this.data, required this.value});
}

/// Beautiful radial/spider chart showing emotional dimensions
class RadialEmotionChart extends StatefulWidget {
  final PracticeEmotionProfile profile;
  final double size;
  final Color? accentColor;
  final bool animate;
  final bool showLabels;

  const RadialEmotionChart({
    super.key,
    required this.profile,
    this.size = 260,
    this.accentColor,
    this.animate = true,
    this.showLabels = true,
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
    final values = widget.profile.values;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The chart
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _RadialChartPainter(
                  values: values,
                  progress: _animation.value,
                  accentColor: widget.accentColor,
                ),
                child: widget.showLabels ? _buildLabels(values) : null,
              );
            },
          ),
        ),
        
        // Legend below
        const SizedBox(height: 20),
        _buildLegend(values),
      ],
    );
  }

  Widget _buildLabels(List<EmotionValue> values) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        final radius = constraints.maxWidth * 0.36;
        final labelRadius = radius + 32;

        return Stack(
          children: List.generate(values.length, (index) {
            final angle = -math.pi / 2 + (2 * math.pi / values.length) * index;
            final x = center.dx + labelRadius * math.cos(angle);
            final y = center.dy + labelRadius * math.sin(angle);
            final emotion = values[index];

            return Positioned(
              left: x - 28,
              top: y - 16,
              child: SizedBox(
                width: 56,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: emotion.data.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: emotion.data.color.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emotion.data.label,
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

  Widget _buildLegend(List<EmotionValue> values) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: values.map((emotion) {
        final percentage = (emotion.value * 100).round();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: emotion.data.color,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: emotion.data.color.withOpacity(0.3),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${emotion.data.label} $percentage%',
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _RadialChartPainter extends CustomPainter {
  final List<EmotionValue> values;
  final double progress;
  final Color? accentColor;

  _RadialChartPainter({
    required this.values,
    required this.progress,
    this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.36;
    final sides = values.length;

    // Draw grid circles
    _drawGridCircles(canvas, center, radius);

    // Draw axis lines
    _drawAxisLines(canvas, center, radius, sides);

    // Draw data polygon with multi-color gradient fill
    _drawDataPolygon(canvas, center, radius, sides);

    // Draw data points
    _drawDataPoints(canvas, center, radius, sides);
  }

  void _drawGridCircles(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), gridPaint);
    }

    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawAxisLines(Canvas canvas, Offset center, double radius, int sides) {
    final axisPaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
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

    for (int i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + (2 * math.pi / sides) * i;
      final value = values[i].value * progress;
      final pointRadius = radius * value;
      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Create gradient from mixed colors
    final colors = values.map((v) => v.data.color.withOpacity(0.3)).toList();
    final avgColor = Color.lerp(colors[0], colors[colors.length ~/ 2], 0.5)!;

    // Draw outer glow
    final glowPaint = Paint()
      ..color = avgColor.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawPath(path, glowPaint);

    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 1.2,
        colors: [
          avgColor.withOpacity(0.5),
          avgColor.withOpacity(0.3),
          avgColor.withOpacity(0.15),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw stroke with color segments
    for (int i = 0; i < sides; i++) {
      final nextI = (i + 1) % sides;
      final angle1 = -math.pi / 2 + (2 * math.pi / sides) * i;
      final angle2 = -math.pi / 2 + (2 * math.pi / sides) * nextI;
      
      final v1 = values[i].value * progress;
      final v2 = values[nextI].value * progress;
      
      final x1 = center.dx + radius * v1 * math.cos(angle1);
      final y1 = center.dy + radius * v1 * math.sin(angle1);
      final x2 = center.dx + radius * v2 * math.cos(angle2);
      final y2 = center.dy + radius * v2 * math.sin(angle2);

      final segmentPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            values[i].data.color.withOpacity(0.8),
            values[nextI].data.color.withOpacity(0.8),
          ],
        ).createShader(Rect.fromPoints(Offset(x1, y1), Offset(x2, y2)))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), segmentPaint);
    }
  }

  void _drawDataPoints(Canvas canvas, Offset center, double radius, int sides) {
    if (progress == 0) return;

    for (int i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + (2 * math.pi / sides) * i;
      final value = values[i].value * progress;
      final pointRadius = radius * value;
      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);
      final color = values[i].data.color;

      // Outer glow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(x, y), 10, glowPaint);

      // White background
      final bgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 7, bgPaint);

      // Colored fill
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 5, fillPaint);

      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x - 1.5, y - 1.5), 2, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialChartPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        values != oldDelegate.values;
  }
}
