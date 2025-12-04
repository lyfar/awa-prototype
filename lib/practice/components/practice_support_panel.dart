import 'package:flutter/material.dart';

import '../../models/meditation_models.dart';

class PracticeSupportPanel extends StatelessWidget {
  final Practice practice;
  final String? title;
  final String? caption;

  const PracticeSupportPanel({
    super.key,
    required this.practice,
    this.title,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final supports = _buildSupports(practice);
    if (supports.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? 'Practice supports',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B3C),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption!,
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ],
          const SizedBox(height: 14),
          ...supports.map((support) => _SupportTile(item: support)),
        ],
      ),
    );
  }

  List<_SupportItem> _buildSupports(Practice practice) {
    final entries = <_SupportItem>[];

    entries.add(
      _SupportItem(
        icon: practice.requiresMaster ? Icons.auto_awesome : Icons.self_improvement,
        title: practice.requiresMaster ? 'Master guidance' : 'Self-guided with AWAsoul',
        description:
            practice.requiresMaster
                ? 'The ${practice.getName()} wiki calls for master presence to anchor the ritual.'
                : 'Follow AWAsoul prompts exactly as the ${practice.getName()} doc describes.',
      ),
    );

    if (practice.downloadable) {
      entries.add(
        const _SupportItem(
          icon: Icons.download,
          title: 'Downloadable audio',
          description: 'The catalogue marks this practice as downloadable for offline runs.',
        ),
      );
    }

    if (practice.hasCustomDuration) {
      entries.add(
        const _SupportItem(
          icon: Icons.timer_outlined,
          title: 'Manual duration',
          description: 'My Practice follows the wiki grace window—set exact minutes you need.',
        ),
      );
    }

    switch (practice.type) {
      case PracticeType.lightPractice:
        entries.addAll([
          const _SupportItem(
            icon: Icons.wb_sunny_outlined,
            title: 'Light activation',
            description: 'Community ignition ritual stays active for 30 days per the wiki.',
          ),
          const _SupportItem(
            icon: Icons.groups_outlined,
            title: 'Featured master',
            description: 'Bio + follow prompts surface automatically after completion.',
          ),
        ]);
        break;
      case PracticeType.guidedMeditation:
        entries.addAll([
          const _SupportItem(
            icon: Icons.voice_over_off,
            title: 'Narrated journey',
            description: 'Daily copy and outcomes mirror the Guided Meditation wiki entry.',
          ),
          const _SupportItem(
            icon: Icons.schedule,
            title: 'Fixed ten minutes',
            description: 'Duration cannot change, reinforcing the breathing cadence.',
          ),
        ]);
        break;
      case PracticeType.soundMeditation:
        entries.addAll([
          const _SupportItem(
            icon: Icons.graphic_eq,
            title: 'Soundscape layers',
            description: 'Immersive tones respond to the duration preset you choose.',
          ),
          const _SupportItem(
            icon: Icons.timelapse,
            title: '10 / 15 / 20 min presets',
            description: 'Matches the Sound Meditation wiki so AWAsoul can sync loops.',
          ),
        ]);
        break;
      case PracticeType.myPractice:
        entries.addAll([
          const _SupportItem(
            icon: Icons.edit_note,
            title: 'Self-logged modality',
            description: 'Document modality + intention just like the My Practice spec says.',
          ),
          const _SupportItem(
            icon: Icons.security_update_good,
            title: 'Grace window',
            description: 'Streak protection mirrors the wiki thresholds—stay with the timer.',
          ),
        ]);
        break;
      case PracticeType.specialPractice:
        entries.addAll([
          const _SupportItem(
            icon: Icons.event_available,
            title: 'Timed unlock',
            description: 'Special Practice opens for 24 hours—arrive with the countdown.',
          ),
          const _SupportItem(
            icon: Icons.auto_awesome_motion,
            title: 'Distinct presentation',
            description: 'Unique AWAsoul visuals follow the Special Practice requirements.',
          ),
        ]);
        break;
    }

    if (practice.highlights.isNotEmpty) {
      entries.addAll(
        practice.highlights.map(
          (highlight) => _SupportItem(
            icon: Icons.check_circle_outline,
            title: highlight,
            description: 'Documented in the ${practice.getName()} wiki card.',
          ),
        ),
      );
    }

    return entries;
  }
}

class _SupportItem {
  final IconData icon;
  final String title;
  final String description;

  const _SupportItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _SupportTile extends StatelessWidget {
  final _SupportItem item;

  const _SupportTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Icon(item.icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF2B2B3C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.65),
                    height: 1.3,
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
