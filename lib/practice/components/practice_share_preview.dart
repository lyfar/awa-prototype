import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/theme/home_colors.dart';
import '../../soul/awa_sphere.dart';

/// Visual preview for the unified practice sharing card.
class PracticeSharePreview extends StatelessWidget {
  final String practiceName;
  final String practiceType;
  final String durationLabel;
  final String? storyLabel;
  final String? moodLabel;
  final String? prompt;
  final List<ShareStat> stats;
  final String? shareUrl;
  final bool includeLink;
  final double energy;
  final double completionRatio;

  const PracticeSharePreview({
    super.key,
    required this.practiceName,
    required this.practiceType,
    required this.durationLabel,
    required this.stats,
    this.storyLabel,
    this.moodLabel,
    this.prompt,
    this.shareUrl,
    this.includeLink = true,
    this.energy = 0.12,
    this.completionRatio = 0.82,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = math.min(constraints.maxWidth, 520.0).toDouble();
        return Center(
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F0F1C), Color(0xFF1B1B2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 24,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned(
                    top: -90,
                    left: -40,
                    right: -40,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Opacity(
                        opacity: 0.75,
                        child: AwaSphereHeader(
                          height: 260,
                          energy: energy,
                          primaryColor: HomeColors.peach,
                          secondaryColor: HomeColors.lavender,
                          accentColor: HomeColors.rose,
                          interactive: false,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.02),
                            Colors.white.withOpacity(0.01),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Badge(
                              label: practiceType.toUpperCase(),
                              icon: Icons.auto_awesome,
                            ),
                            if (storyLabel != null)
                              _Badge(
                                label: storyLabel!,
                                icon: Icons.local_fire_department_outlined,
                                isEmphasized: true,
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          practiceName,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 28,
                            height: 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          prompt ??
                              'Signal this ritual to your circle and let the map glow brighter.',
                          style: GoogleFonts.urbanist(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _ShareStatPill(
                              stat: ShareStat(
                                icon: Icons.timelapse_rounded,
                                label: 'Duration',
                                value: durationLabel,
                              ),
                            ),
                            for (final stat in stats) _ShareStatPill(stat: stat),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (moodLabel != null) ...[
                          _MoodCard(label: moodLabel!),
                          const SizedBox(height: 14),
                        ],
                        _ProgressStrip(
                          completionRatio: completionRatio,
                          descriptor: 'Signal strength to share',
                        ),
                        const SizedBox(height: 14),
                        if (includeLink && shareUrl != null)
                          _LinkRow(shareUrl: shareUrl!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ShareStat {
  final IconData icon;
  final String label;
  final String value;
  final Color? accentColor;

  const ShareStat({
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor,
  });
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isEmphasized;

  const _Badge({
    required this.label,
    required this.icon,
    this.isEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            isEmphasized ? HomeColors.peach.withOpacity(0.18) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEmphasized
              ? HomeColors.peach.withOpacity(0.5)
              : Colors.white.withOpacity(0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isEmphasized ? HomeColors.peach : Colors.white70,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareStatPill extends StatelessWidget {
  final ShareStat stat;

  const _ShareStatPill({required this.stat});

  @override
  Widget build(BuildContext context) {
    final Color accent = stat.accentColor ?? HomeColors.rose.withOpacity(0.9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [accent, accent.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(stat.icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label,
                style: GoogleFonts.urbanist(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                stat.value,
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final String label;

  const _MoodCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [HomeColors.rose, HomeColors.peach],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current state',
                  style: GoogleFonts.urbanist(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  final double completionRatio;
  final String descriptor;

  const _ProgressStrip({
    required this.completionRatio,
    required this.descriptor,
  });

  @override
  Widget build(BuildContext context) {
    final double value = completionRatio.clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              descriptor,
              style: GoogleFonts.urbanist(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                '${(value * 100).round()}%',
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.07),
            valueColor: const AlwaysStoppedAnimation<Color>(HomeColors.peach),
          ),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String shareUrl;

  const _LinkRow({required this.shareUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_2, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              shareUrl,
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [HomeColors.peach, HomeColors.rose],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.ios_share, color: Colors.black, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Share',
                  style: GoogleFonts.urbanist(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
