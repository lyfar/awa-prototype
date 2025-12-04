import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../reactions/reaction_palette.dart';

class DashboardStat {
  final String label;
  final String value;

  const DashboardStat({required this.label, required this.value});
}

class DashboardStatChip extends StatelessWidget {
  final DashboardStat stat;
  final bool inverted;

  const DashboardStatChip({super.key, required this.stat, required this.inverted});

  @override
  Widget build(BuildContext context) {
    final Color textColor = inverted ? Colors.white : const Color(0xFF2B2B3C);
    final Color labelColor = inverted ? Colors.white70 : const Color(0xFF7B7483);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: inverted ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          Text(
            stat.label,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class InsiderCard extends StatefulWidget {
  final String title;
  final String description;
  final Widget preview;
  final VoidCallback onTap;
  final bool isActive;
  final List<DashboardStat> stats;
  final List<Color> palette;

  const InsiderCard({
    super.key,
    required this.title,
    required this.description,
    required this.preview,
    required this.onTap,
    required this.isActive,
    this.stats = const [],
    this.palette = const [],
  });

  @override
  State<InsiderCard> createState() => _InsiderCardState();
}

class _InsiderCardState extends State<InsiderCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _colors = _buildPalette(widget.palette);
  }

  List<Color> _buildPalette(List<Color> palette) {
    if (palette.isNotEmpty) {
      return palette.map((c) => c.withOpacity(0.85)).toList();
    }
    return reactionTaxonomy.map((r) => r.color.withOpacity(0.8)).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 12)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MeshGradientPainter(colors: _colors, t: t),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.45),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: Center(child: widget.preview),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (widget.isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Open',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.description,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.4,
                                  fontSize: 13,
                                ),
                              ),
                              if (widget.stats.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: widget.stats
                                      .map((stat) => DashboardStatChip(stat: stat, inverted: true))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.chevron_right, color: Colors.white70),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  final List<Color> colors;
  final double t;

  _MeshGradientPainter({required this.colors, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Dark elegant background base
    final Paint bg = Paint()..color = const Color(0xFF121217);
    canvas.drawRect(rect, bg);

    if (colors.isEmpty) return;

    // Ensure we have a good set of colors to work with
    final List<Color> palette = colors.length >= 2
        ? colors
        : [
            colors.firstOrNull ?? Colors.indigo,
            Colors.purple,
            Colors.blueAccent
          ];

    final double w = size.width;
    final double h = size.height;

    // Helper to draw soft glowing orbs
    void drawOrb(double x, double y, double radius, Color color) {
      final Paint paint = Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius,
          [
            color.withOpacity(0.55),
            color.withOpacity(0.0),
          ],
          [0.0, 1.0],
        );
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // We move 3-4 orbs around in a smooth pattern

    // Orb 1: Top-leftish, moving in a slow circle
    drawOrb(
      w * (0.3 + 0.2 * math.sin(t * 2 * math.pi)),
      h * (0.3 + 0.15 * math.cos(t * 2 * math.pi)),
      w * 0.9,
      palette[0 % palette.length],
    );

    // Orb 2: Bottom-rightish, counter-movement
    drawOrb(
      w * (0.7 - 0.2 * math.sin(t * 2 * math.pi)),
      h * (0.7 - 0.15 * math.cos(t * 2 * math.pi)),
      w * 1.0,
      palette[1 % palette.length],
    );

    // Orb 3: Wandering accent
    if (palette.length > 2) {
      drawOrb(
        w * (0.5 + 0.3 * math.cos(t * 2 * math.pi + 1)),
        h * (0.5 + 0.3 * math.sin(t * 2 * math.pi + 1)),
        w * 0.7,
        palette[2 % palette.length],
      );
    }

    // Orb 4: Pulsing center light to add depth
    drawOrb(
      w * 0.5,
      h * 0.5,
      w * (0.4 + 0.1 * math.sin(t * 4 * math.pi)),
      Colors.white.withOpacity(0.08),
    );
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.colors != colors;
  }
}
