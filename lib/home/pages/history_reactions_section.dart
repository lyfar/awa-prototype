import 'package:flutter/material.dart';

import '../../reactions/reaction_palette.dart';
import '../../practice/components/radial_emotion_chart.dart';
import '../theme/home_colors.dart';

const Color _ink = Color(0xFF2B2B3C);
const Color _muted = Color(0xFF6E6677);

class ReactionHistorySection extends StatefulWidget {
  final List<PracticeHistoryEntry> entries;
  final List<ReactionStateData> taxonomy;
  final bool isPaidUser;
  final VoidCallback? onUpgradeRequested;

  const ReactionHistorySection({
    super.key,
    required this.entries,
    required this.taxonomy,
    this.isPaidUser = false,
    this.onUpgradeRequested,
  });

  @override
  State<ReactionHistorySection> createState() => _ReactionHistorySectionState();
}

class _ReactionHistorySectionState extends State<ReactionHistorySection> {
  String? _selectedReactionKey;

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedReactionKey == null
        ? widget.entries
        : widget.entries
            .where((entry) => entry.reactionKey == _selectedReactionKey)
            .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Insider: recaps & reactions',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Insider keeps the last week of sessions so you can leave gratitude, download cards, or share.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _EmotionOverviewCard(
              isLocked: !widget.isPaidUser,
              profile: _buildEmotionProfile(filtered),
              taxonomy: widget.taxonomy,
              onUpgrade: widget.onUpgradeRequested,
            ),
          ),
          const SizedBox(height: 18),
          PracticeHistoryFilters(
            selectedKey: _selectedReactionKey,
            taxonomy: widget.taxonomy,
            onChanged: (key) {
              setState(() {
                _selectedReactionKey = key;
              });
            },
          ),
          const SizedBox(height: 12),
          _PaletteDots(taxonomy: widget.taxonomy),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              itemBuilder: (_, index) {
                final entry = filtered[index];
                return _HistoryCard(
                  entry: entry,
                  taxonomy: widget.taxonomy,
                  onSelectReaction: (reactionKey) {
                    setState(() {
                      entry.reactionKey = reactionKey;
                    });
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemCount: filtered.length,
            ),
          ),
        ],
      ),
    );
  }

  PracticeEmotionProfile _buildEmotionProfile(List<PracticeHistoryEntry> entries) {
    final Map<String, int> counts = {};
    for (final entry in entries) {
      final key = entry.reactionKey;
      if (key == null) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final maxCount = counts.values.isEmpty ? 0 : counts.values.reduce((a, b) => a > b ? a : b);
    double valueForIndex(int index) {
      if (index >= widget.taxonomy.length) return 0.0;
      final key = widget.taxonomy[index].key;
      final count = counts[key] ?? 0;
      if (maxCount == 0) {
        return 0.35; // baseline shape
      }
      return (count / maxCount).clamp(0.25, 1.0);
    }

    return PracticeEmotionProfile(
      grounded: valueForIndex(0),
      joy: valueForIndex(1),
      energy: valueForIndex(2),
      peace: valueForIndex(3),
      release: valueForIndex(4),
      insight: valueForIndex(5),
      unity: valueForIndex(6),
    );
  }
}

class _PaletteDots extends StatelessWidget {
  final List<ReactionStateData> taxonomy;

  const _PaletteDots({required this.taxonomy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reaction palette',
            style: TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: taxonomy
                .map(
                  (reaction) => _PaletteDot(
                    color: reaction.color,
                    label: reaction.label,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PaletteDot extends StatelessWidget {
  final Color color;
  final String label;

  const _PaletteDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class PracticeHistoryFilters extends StatelessWidget {
  final String? selectedKey;
  final List<ReactionStateData> taxonomy;
  final ValueChanged<String?> onChanged;

  const PracticeHistoryFilters({
    super.key,
    required this.selectedKey,
    required this.taxonomy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All reactions'),
            selected: selectedKey == null,
            selectedColor: HomeColors.cream,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selectedKey == null ? _ink : _muted,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 12),
          ...taxonomy.map(
            (state) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(state.label),
                selected: selectedKey == state.key,
                selectedColor: state.color.withValues(alpha: 0.25),
                backgroundColor: Colors.white,
                side: BorderSide(color: state.color.withValues(alpha: 0.4)),
                labelStyle: TextStyle(
                  color: selectedKey == state.key ? _ink : _muted,
                ),
                onSelected: (_) => onChanged(state.key),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionOverviewCard extends StatelessWidget {
  final bool isLocked;
  final PracticeEmotionProfile profile;
  final List<ReactionStateData> taxonomy;
  final VoidCallback? onUpgrade;

  const _EmotionOverviewCard({
    required this.isLocked,
    required this.profile,
    required this.taxonomy,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: HomeColors.cream),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isLocked ? HomeColors.peach.withOpacity(0.2) : HomeColors.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLocked
                        ? HomeColors.peach.withOpacity(0.6)
                        : HomeColors.rose.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLocked ? Icons.lock_outline : Icons.insights_outlined,
                      size: 16,
                      color: _ink,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLocked ? 'AwaJourney' : 'Reaction summary',
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isLocked)
                TextButton(
                  onPressed: onUpgrade,
                  child: const Text(
                    'Unlock',
                    style: TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.8,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RadialEmotionChart(
                  profile: profile,
                  size: 220,
                  showLabels: false,
                  animate: !isLocked,
                  accentColor: HomeColors.peach,
                ),
                if (isLocked)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(0.72),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.lock, color: _ink),
                          SizedBox(height: 6),
                          Text(
                            'Upgrade to see your reaction map',
                            style: TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (!isLocked)
            Text(
              'Live map of your last reactions. Each vertex reflects how often you felt that state.',
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                height: 1.4,
              ),
            )
          else
            const Text(
              'AwaJourney unlocks your personal reaction insights and downloads.',
              style: TextStyle(
                color: _muted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final PracticeHistoryEntry entry;
  final List<ReactionStateData> taxonomy;
  final ValueChanged<String?> onSelectReaction;

  const _HistoryCard({
    required this.entry,
    required this.taxonomy,
    required this.onSelectReaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(color: HomeColors.cream),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  entry.isMasterSession ? Icons.auto_awesome : Icons.self_improvement,
                  color: entry.isMasterSession ? HomeColors.lavender : HomeColors.peach,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${entry.duration.inMinutes} min • ${entry.dateLabel}',
                        style: TextStyle(
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: _ink,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Download card'),
                ),
              ],
            ),
            if (entry.masterName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Master ${entry.masterName}',
                style: TextStyle(
                  color: HomeColors.lavender,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (entry.reactionKey != null)
              _ReactionSummary(
                reaction: taxonomy.firstWhere(
                  (state) => state.key == entry.reactionKey,
                  orElse: () => taxonomy.first,
                ),
              ),
            const SizedBox(height: 12),
            _buildReactionChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: taxonomy.map((reaction) {
        final selected = entry.reactionKey == reaction.key;
        return ChoiceChip(
          label: Text(reaction.label),
          selected: selected,
          selectedColor: reaction.color.withValues(alpha: 0.25),
          labelStyle: TextStyle(
            color: selected ? _ink : _muted,
          ),
          backgroundColor: Colors.white,
          side: BorderSide(color: reaction.color.withValues(alpha: 0.4)),
          onSelected: (_) => onSelectReaction(reaction.key),
        );
      }).toList(),
    );
  }
}

class PracticeHistoryEntry {
  final String title;
  final Duration duration;
  final String dateLabel;
  final bool isMasterSession;
  final String? masterName;
  String? reactionKey;

  PracticeHistoryEntry({
    required this.title,
    required this.duration,
    required this.dateLabel,
    this.isMasterSession = false,
    this.masterName,
    this.reactionKey,
  });
}

class _ReactionSummary extends StatelessWidget {
  final ReactionStateData reaction;

  const _ReactionSummary({required this.reaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: reaction.color.withValues(alpha: 0.1),
        border: Border.all(color: reaction.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: reaction.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reaction.label,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reaction.description,
                  style: TextStyle(color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
