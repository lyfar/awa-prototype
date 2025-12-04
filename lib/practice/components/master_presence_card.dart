import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../reactions/reaction_palette.dart';

class MasterPresenceCard extends StatelessWidget {
  final int participantCount;
  final String startTime;
  final double sessionProgress;
  final List<ReactionStateData> reactions;
  final Map<String, int> feelingCounts;
  final List<PresenceFeelingMarker> feelingMarkers;
  final ReactionStateData? selectedFeeling;
  final ValueChanged<ReactionStateData>? onFeelingSelected;
  final bool allowFeelingSelection;

  const MasterPresenceCard({
    super.key,
    required this.participantCount,
    required this.startTime,
    required this.sessionProgress,
    required this.reactions,
    required this.feelingCounts,
    required this.feelingMarkers,
    this.selectedFeeling,
    this.onFeelingSelected,
    this.allowFeelingSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = reactions.isEmpty ? reactionTaxonomy : reactions;
    final lights = _lightColorsForCounts(palette, feelingCounts);
    final markers = feelingMarkers.isEmpty ? feelingMarkers : feelingMarkers.take(16).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2343), Color(0xFF120C23)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collective presence',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Lights are recolored live as participants drop feelings into the timeline.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomPaint(
                  painter: _PresenceMapPainter(lights: lights),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _FeelingLegend(palette: palette, counts: feelingCounts),
          const SizedBox(height: 18),
          _FeelingTimelineView(
            markers: markers,
            sessionProgress: sessionProgress,
          ),
          const SizedBox(height: 18),
          Text(
            'Leave a feeling mid-session',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _FeelingPalette(
            palette: palette,
            selected: selectedFeeling,
            enabled: allowFeelingSelection && onFeelingSelected != null,
            onSelected: onFeelingSelected,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Participants',
                      style: TextStyle(color: Colors.white54),
                    ),
                    Text(
                      '$participantCount lights',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live timing',
                    style: TextStyle(color: Colors.white54),
                  ),
                  Text(
                    'Master started at $startTime',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PresenceFeelingMarker {
  final double progress; // 0-1 through the session
  final ReactionStateData reaction;
  final String label;

  const PresenceFeelingMarker({
    required this.progress,
    required this.reaction,
    required this.label,
  });
}

List<Color> _lightColorsForCounts(
  List<ReactionStateData> palette,
  Map<String, int> counts,
) {
  const int totalLights = 24;
  final totalCount = counts.values.fold<int>(0, (sum, value) => sum + value);
  if (totalCount == 0) {
    return List<Color>.filled(totalLights, Colors.white.withOpacity(0.35));
  }
  final List<Color> lights = [];
  for (final reaction in palette) {
    final count = counts[reaction.key] ?? 0;
    if (count == 0) continue;
    int share = ((count / totalCount) * totalLights).round();
    share = share.clamp(1, totalLights - lights.length);
    lights.addAll(List<Color>.filled(share, reaction.color.withOpacity(0.9)));
    if (lights.length >= totalLights) break;
  }
  while (lights.length < totalLights) {
    lights.add(Colors.white.withOpacity(0.25));
  }
  return lights.take(totalLights).toList();
}

class _PresenceMapPainter extends CustomPainter {
  final List<Color> lights;

  const _PresenceMapPainter({required this.lights});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2.2;
    final globePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0E1A36), Color(0xFF1F3563)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, globePaint);

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(0.12);
    canvas.drawCircle(center, radius * 1.1, orbitPaint);
    canvas.drawCircle(center, radius * 0.8, orbitPaint);

    final dotPaint = Paint()..style = PaintingStyle.fill;
    final totalDots = lights.isEmpty ? 16 : lights.length;
    for (int i = 0; i < totalDots; i++) {
      final angle = (i / totalDots) * math.pi * 2;
      final ripple = math.sin(angle * 3) * 6;
      final dotRadius = 4 + (i % 3) * 1.2;
      final dx = center.dx + math.cos(angle) * (radius - 6 + ripple);
      final dy = center.dy + math.sin(angle) * (radius - 6 + ripple);
      final color =
          i < lights.length ? lights[i] : Colors.white.withOpacity(0.4 + (i % 4) * 0.1);
      dotPaint.color = color;
      canvas.drawCircle(Offset(dx, dy), dotRadius, dotPaint);
    }

    final pulsePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.25), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center.translate(radius * 0.2, -radius * 0.2), radius * 0.7, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _PresenceMapPainter oldDelegate) {
    return oldDelegate.lights != lights;
  }
}

class _FeelingPalette extends StatelessWidget {
  final List<ReactionStateData> palette;
  final ReactionStateData? selected;
  final bool enabled;
  final ValueChanged<ReactionStateData>? onSelected;

  const _FeelingPalette({
    required this.palette,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final reaction in palette)
          ChoiceChip(
            label: Text(reaction.label),
            avatar: Icon(Icons.circle, size: 12, color: reaction.color),
            selected: selected?.key == reaction.key,
            onSelected: enabled ? (_) => onSelected?.call(reaction) : null,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white.withOpacity(0.08),
            selectedColor: reaction.color.withOpacity(0.25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
      ],
    );
  }
}

class _FeelingLegend extends StatelessWidget {
  final List<ReactionStateData> palette;
  final Map<String, int> counts;

  const _FeelingLegend({
    required this.palette,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final entries =
        palette.where((reaction) => (counts[reaction.key] ?? 0) > 0).toList(growable: false);
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (final reaction in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: reaction.color, size: 10),
              const SizedBox(width: 4),
              Text(
                '${reaction.label} ${(counts[reaction.key] ?? 0)}',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }
}

class _FeelingTimelineView extends StatelessWidget {
  final List<PresenceFeelingMarker> markers;
  final double sessionProgress;

  const _FeelingTimelineView({
    required this.markers,
    required this.sessionProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.03),
        ),
        child: const Text(
          'Live feeling pings will show up here with their timecodes once the practice begins.',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    final latest = markers.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Feeling timeline',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${latest.reaction.label} @ ${latest.label}',
              style: TextStyle(color: latest.reaction.color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final usableWidth = constraints.maxWidth - 16;
              return Stack(
                children: [
                  Positioned(
                    top: 24,
                    left: 8,
                    right: 8,
                    child: Container(height: 2, color: Colors.white.withOpacity(0.12)),
                  ),
                  Positioned(
                    top: 18,
                    left: 8 + usableWidth * sessionProgress.clamp(0, 1),
                    child: Container(
                      width: 2,
                      height: 20,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                  for (final marker in markers)
                    Positioned(
                      top: 8,
                      left: 8 + usableWidth * marker.progress.clamp(0, 1),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: marker.reaction.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              marker.reaction.label,
                              style: TextStyle(
                                color: marker.reaction.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(Icons.circle, color: marker.reaction.color, size: 12),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
