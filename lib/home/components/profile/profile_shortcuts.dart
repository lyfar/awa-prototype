import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../models/home_section.dart';
import '../../theme/home_colors.dart';
import '../left_menu_insider_card.dart';

class ProfileShortcutsSection extends StatelessWidget {
  final HomeSection activeSection;
  final ValueChanged<HomeSection> onSectionSelected;
  final int awawayDay;
  final int awawayCycleLength;
  final double streakProgress;
  final int unitsBalance;
  final int unitsEarnedThisWeek;
  final int unitsSpentThisWeek;
  final int savedCount;
  final bool isPaidUser;

  const ProfileShortcutsSection({
    super.key,
    required this.activeSection,
    required this.onSectionSelected,
    required this.awawayDay,
    required this.awawayCycleLength,
    required this.streakProgress,
    required this.unitsBalance,
    required this.unitsEarnedThisWeek,
    required this.unitsSpentThisWeek,
    required this.savedCount,
    required this.isPaidUser,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;
        if (constraints.maxWidth >= 980) {
          columns = 3;
        } else if (constraints.maxWidth >= 640) {
          columns = 2;
        }
        final double gap = 12;
        final double cardWidth =
            columns > 1 ? (constraints.maxWidth - gap * (columns - 1)) / columns : constraints.maxWidth;

        final int progressPercent = (streakProgress.clamp(0, 1) * 100).round();
        final int daysLeft =
            (awawayCycleLength - awawayDay).clamp(0, awawayCycleLength);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: ProfileShortcutCard(
                title: 'AWAWAY',
                description: 'Sacred geometry streak and portal repairs.',
                icon: const Icon(Icons.blur_circular, color: Colors.white, size: 26),
                stats: [
                  DashboardStat(label: 'Day', value: '$awawayDay/$awawayCycleLength'),
                  DashboardStat(label: 'Cycle', value: '$progressPercent%'),
                  DashboardStat(
                    label: 'Next',
                    value: daysLeft == 0 ? 'Unlocking' : 'In ${daysLeft}d',
                  ),
                ],
                isActive: activeSection == HomeSection.streaks,
                onTap: () => onSectionSelected(HomeSection.streaks),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: ProfileShortcutCard(
                title: 'Lumens',
                description: 'Balance, earn cadence, and spend flows.',
                icon: const Icon(Icons.loyalty, color: Colors.white, size: 26),
                stats: [
                  DashboardStat(label: 'Balance', value: '$unitsBalance Lumens'),
                  DashboardStat(label: 'Earned', value: '+$unitsEarnedThisWeek Lumens'),
                  DashboardStat(label: 'Spent', value: '-$unitsSpentThisWeek Lumens'),
                ],
                isActive: activeSection == HomeSection.units,
                onTap: () => onSectionSelected(HomeSection.units),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: ProfileShortcutCard(
                title: 'Favourites',
                description: 'Bookmarks and downloads.',
                icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 24),
                stats: [DashboardStat(label: 'Saved', value: '$savedCount')],
                isActive: activeSection == HomeSection.saved,
                locked: !isPaidUser,
                onTap: () => onSectionSelected(HomeSection.saved),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProfileShortcutCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget icon;
  final List<DashboardStat> stats;
  final bool isActive;
  final bool locked;
  final VoidCallback onTap;

  const ProfileShortcutCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.stats = const [],
    this.isActive = false,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine accent color based on title (simple heuristic)
    Color accent;
    if (title.contains('AWAWAY')) {
      accent = const Color(0xFF00F0FF); // Cyan
    } else if (title.contains('Lumens')) {
      accent = const Color(0xFFFFD700); // Gold
    } else {
      accent = const Color(0xFFFF00FF); // Magenta
    }

    return GestureDetector(
      onTap: onTap,
      child: _HolographicCard(
        accent: accent,
        locked: locked,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: accent.withOpacity(0.1),
                    border: Border.all(color: accent.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Theme(
                      data: ThemeData(iconTheme: IconThemeData(color: accent)),
                      child: icon,
                    ),
                  ),
                ),
                const Spacer(),
                if (locked)
                  Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.4), size: 16)
                else if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                height: 1.3,
                fontSize: 11,
                fontFamily: 'Courier', // Monospaced tech feel
              ),
            ),
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: stats
                    .map(
                      (stat) => _TechStatChip(stat: stat, accent: accent),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TechStatChip extends StatelessWidget {
  final DashboardStat stat;
  final Color accent;

  const _TechStatChip({required this.stat, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${stat.label}: ',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
          ),
          Text(
            stat.value,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}

class _HolographicCard extends StatelessWidget {
  final Widget child;
  final Color accent;
  final bool locked;

  const _HolographicCard({
    required this.child,
    required this.accent,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // Fixed height for uniformity
      decoration: BoxDecoration(
        color: const Color(0xFF09090B), // Deep tech black
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: locked ? Colors.white.withOpacity(0.05) : accent.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: locked
            ? []
            : [
                BoxShadow(
                  color: accent.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle grid background
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPatternPainter(
                  color: accent.withOpacity(locked ? 0.02 : 0.04),
                ),
              ),
            ),
            // Top gradient glow
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withOpacity(locked ? 0.0 : 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
            // Locked overlay
            if (locked)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white.withOpacity(0.2),
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  final Color color;

  _GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const double spacing = 20;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class MeshGradientCard extends StatefulWidget {
  final Widget child;
  final List<Color>? palette;
  final double borderRadius;
  final EdgeInsets padding;
  final bool dimmed;

  const MeshGradientCard({
    super.key,
    required this.child,
    this.palette,
    this.borderRadius = 22,
    this.padding = const EdgeInsets.all(16),
    this.dimmed = false,
  });

  @override
  State<MeshGradientCard> createState() => _MeshGradientCardState();
}

class _MeshGradientCardState extends State<MeshGradientCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _colors = widget.palette ??
        [
          HomeColors.lavender.withOpacity(0.9),
          HomeColors.peach.withOpacity(0.9),
          HomeColors.rose.withOpacity(0.85),
        ];
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: MeshGradientPainter(colors: _colors, t: t),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.22),
                        Colors.black.withOpacity(0.16),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                ),
              ),
              if (widget.dimmed)
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.15)),
                ),
              Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }
}

class MeshGradientPainter extends CustomPainter {
  final List<Color> colors;
  final double t;

  MeshGradientPainter({required this.colors, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;
    final Rect rect = Offset.zero & size;
    final double spread = size.shortestSide * 0.7;

    final Paint base = Paint()..color = colors.first.withOpacity(0.12);
    canvas.drawRect(rect, base);

    final int layerCount = math.max(4, math.min(colors.length * 2, 6));
    for (int i = 0; i < layerCount; i++) {
      final Color c1 = colors[i % colors.length];
      final Color c2 = colors[(i + 1) % colors.length];
      final double angle = t * math.pi * 2 + (i * math.pi / 3);
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      final Offset begin = rect.center - dir * spread;
      final Offset end = rect.center + dir * spread;

      final Paint paint = Paint()
        ..shader = ui.Gradient.linear(
          begin,
          end,
          [
            c1.withOpacity(0.7),
            c2.withOpacity(0.6),
            c1.withOpacity(0.4),
          ],
          const [0.0, 0.5, 1.0],
        );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MeshGradientPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.colors != colors;
  }
}
