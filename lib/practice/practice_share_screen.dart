import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/theme/home_colors.dart';
import '../models/meditation_models.dart';
import '../widgets/spiral_backdrop.dart';
import 'components/practice_share_actions.dart';
import 'components/practice_share_preview.dart';

/// Unified sharing surface for practice moments and progress signals.
class PracticeShareScreen extends StatefulWidget {
  final Practice practice;
  final Duration? duration;
  final String? reactionLabel;
  final int? streakDay;
  final int? lumenReward;
  final int? completionCount;
  final String? shareUrl;
  final String? prompt;
  final String? modalityName;

  const PracticeShareScreen({
    super.key,
    required this.practice,
    this.duration,
    this.reactionLabel,
    this.streakDay,
    this.lumenReward,
    this.completionCount,
    this.shareUrl,
    this.prompt,
    this.modalityName,
  });

  @override
  State<PracticeShareScreen> createState() => _PracticeShareScreenState();
}

class _PracticeShareScreenState extends State<PracticeShareScreen> {
  bool _includeMood = true;
  bool _includeStreak = true;
  bool _includeLink = true;

  void _handleAction(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label queued — wiring to native share later.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final practiceName = widget.modalityName ?? widget.practice.getName();
    final practiceType = widget.practice.getTypeName();
    final duration = widget.duration ?? widget.practice.duration;
    final durationLabel = '${duration.inMinutes} min';
    final moodLabel =
        _includeMood ? widget.reactionLabel ?? 'Glowing & grounded' : null;
    final streakDay = _includeStreak ? widget.streakDay : null;
    final completionCount = widget.completionCount ?? 3;
    final lumenReward = widget.lumenReward ?? 15;
    final completionRatio = (duration.inMinutes / 20).clamp(0.35, 0.95).toDouble();
    final shareUrl = _includeLink
        ? widget.shareUrl ?? 'awaterra.com/practice/${widget.practice.id}'
        : null;

    final List<ShareStat> stats = [];
    if (streakDay != null) {
      stats.add(
        ShareStat(
          icon: Icons.local_fire_department_rounded,
          label: 'AwaWay',
          value: 'Day $streakDay',
          accentColor: HomeColors.peach,
        ),
      );
    }
    stats.add(
      ShareStat(
        icon: Icons.bolt,
        label: 'Lumen reward',
        value: '+$lumenReward',
        accentColor: const Color(0xFFF8D570),
      ),
    );
    stats.add(
      ShareStat(
        icon: Icons.timeline_rounded,
        label: 'This week',
        value: '$completionCount runs',
        accentColor: HomeColors.lavender,
      ),
    );
    if (moodLabel != null) {
      stats.add(
        ShareStat(
          icon: Icons.favorite_outline,
          label: 'Signal',
          value: moodLabel,
          accentColor: HomeColors.rose,
        ),
      );
    }

    return Scaffold(
      backgroundColor: HomeColors.space,
      body: Stack(
        children: [
          Positioned.fill(
            child: SpiralBackdrop(
              height: MediaQuery.of(context).size.height,
              overlayGradient: const LinearGradient(
                colors: [Color(0x99090913), Color(0x66090913)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              offsetFactor: 0.2,
              bleedFactor: 1.2,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(practiceName),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                    child: Column(
                      children: [
                        PracticeSharePreview(
                          practiceName: practiceName,
                          practiceType: practiceType,
                          durationLabel: durationLabel,
                          storyLabel:
                              streakDay != null ? 'Day $streakDay • AwaWay' : null,
                          moodLabel: moodLabel,
                          prompt:
                              widget.prompt ??
                                  'Share this moment as a custom shot—perfect for screenshots or social stories.',
                          stats: stats,
                          shareUrl: shareUrl,
                          includeLink: _includeLink,
                          energy: 0.14,
                          completionRatio: completionRatio,
                        ),
                        const SizedBox(height: 18),
                        _buildToggles(),
                        const SizedBox(height: 18),
                        PracticeShareActions(
                          actions: [
                            PracticeShareAction(
                              icon: Icons.camera_alt_outlined,
                              label: 'Save image',
                              isPrimary: true,
                              onTap: () => _handleAction('Image export'),
                            ),
                            PracticeShareAction(
                              icon: Icons.ios_share,
                              label: 'Share to feed',
                              onTap: () => _handleAction('Share sheet'),
                            ),
                            PracticeShareAction(
                              icon: Icons.link,
                              label: 'Copy link',
                              onTap: () => _handleAction('Link copied'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildFooterNote(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String practiceName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share practice',
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Custom overlay for $practiceName',
                  style: GoogleFonts.urbanist(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.screenshot_monitor_outlined, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  'Screenshot ready',
                  style: TextStyle(
                    color: Colors.white70,
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

  Widget _buildToggles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What travels with the card?',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ShareToggleChip(
              label: 'Mood pulse',
              selected: _includeMood,
              onChanged: (value) => setState(() => _includeMood = value),
              icon: Icons.favorite,
            ),
            _ShareToggleChip(
              label: 'AwaWay streak',
              selected: _includeStreak,
              onChanged: (value) => setState(() => _includeStreak = value),
              icon: Icons.local_fire_department,
            ),
            _ShareToggleChip(
              label: 'Link + QR',
              selected: _includeLink,
              onChanged: (value) => setState(() => _includeLink = value),
              icon: Icons.qr_code_2,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
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
                colors: [HomeColors.peach, HomeColors.lavender],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.lightbulb_outline, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Living backstage for now. Trigger this screen whenever we ask users to share a practice, progress snapshot, or AwaSoul dimension card.',
              style: GoogleFonts.urbanist(
                color: Colors.white.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const _ShareToggleChip({
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: selected ? Colors.black : Colors.white70),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.urbanist(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: onChanged,
      backgroundColor: Colors.white.withOpacity(0.06),
      selectedColor: HomeColors.peach,
      checkmarkColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? HomeColors.peach : Colors.white.withOpacity(0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}
