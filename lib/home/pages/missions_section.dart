import 'package:flutter/material.dart';

import '../../missions/mission_models.dart';
import '../../missions/mission_share_dialog.dart';
import '../theme/home_colors.dart';

class MissionsSection extends StatelessWidget {
  final List<Mission> missions;
  final ValueChanged<Mission> onMissionSelected;
  final ValueChanged<Mission> onContribute;

  const MissionsSection({
    super.key,
    required this.missions,
    required this.onMissionSelected,
    required this.onContribute,
  });

  @override
  Widget build(BuildContext context) {
    final Mission? mission = missions.isNotEmpty ? missions.first : null;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HomeColors.space, Color(0xFF0D111F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 28,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: mission == null
          ? const _MissionEmptyState()
          : _SingleMissionView(
              mission: mission,
              onMissionSelected: () => onMissionSelected(mission),
              onContribute: () => onContribute(mission),
            ),
    );
  }
}

class _SingleMissionView extends StatelessWidget {
  final Mission mission;
  final VoidCallback onMissionSelected;
  final VoidCallback onContribute;

  const _SingleMissionView({
    required this.mission,
    required this.onMissionSelected,
    required this.onContribute,
  });

  @override
  Widget build(BuildContext context) {
    final pagesDigitized = (mission.progress * mission.totalPages).round();
    final progressPercent = (mission.progress * 100).clamp(0, 100).round();
    final double safeBottom = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 22, 20, 210 + safeBottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _MissionPill(
                      label: 'Single mission live',
                      icon: Icons.bolt_outlined,
                      background: Colors.white.withOpacity(0.08),
                    ),
                    const SizedBox(width: 8),
                    _MissionPill(
                      label: 'Lumens ready',
                      icon: Icons.light_mode_outlined,
                      background: Colors.white.withOpacity(0.08),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Preservation mission',
                  style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Spend Lumens to digitize this story.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                _MissionHero(
                  mission: mission,
                  pagesDigitized: pagesDigitized,
                  progressPercent: progressPercent,
                ),
                const SizedBox(height: 18),
                _SpendFlowRow(
                  unitCost: mission.unitCost,
                  pagesPerContribution: mission.pagesPerContribution,
                ),
                const SizedBox(height: 18),
                _MissionDetails(
                  mission: mission,
                  pagesDigitized: pagesDigitized,
                ),
              ],
            ),
          ),
        ),
        _MissionActionBar(
          unitCost: mission.unitCost,
          onContribute: onContribute,
          mission: mission,
        ),
      ],
    );
  }
}

class _MissionHero extends StatelessWidget {
  final Mission mission;
  final int pagesDigitized;
  final int progressPercent;

  const _MissionHero({
    required this.mission,
    required this.pagesDigitized,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HomeColors.peach.withOpacity(0.22),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _MissionPill(
                          label: mission.manuscriptLocation,
                          icon: Icons.place_outlined,
                          background: Colors.white10,
                        ),
                        _MissionPill(
                          label: mission.manuscriptEra,
                          icon: Icons.schedule,
                          background: Colors.white10,
                        ),
                        if (mission.isNew)
                          _MissionPill(
                            label: 'New drop',
                            icon: Icons.auto_awesome,
                            background: Colors.white10,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ProgressBadge(percent: progressPercent),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            mission.description,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Each contribution covers ${mission.pagesPerContribution} page(s) for ${mission.unitCost} Lumens.',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: mission.progress.clamp(0, 1),
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(HomeColors.peach),
            minHeight: 10,
          ),
          const SizedBox(height: 6),
          Text(
            '$pagesDigitized / ${mission.totalPages} pages already digitized',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _SpendFlowRow extends StatelessWidget {
  final int unitCost;
  final int pagesPerContribution;

  const _SpendFlowRow({
    required this.unitCost,
    required this.pagesPerContribution,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lumens spend flow',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _FlowStep(
              icon: Icons.tune,
              title: 'Pick your boost',
              body: 'Choose a contribution bundle sized for this mission.',
            ),
            _FlowStep(
              icon: Icons.document_scanner_outlined,
              title: 'Scan fragile pages',
              body: 'Lumens cover lab time to capture each folio safely.',
            ),
            _FlowStep(
              icon: Icons.collections_bookmark_outlined,
              title: 'Unlock for the library',
              body: 'Get favourite pages and help the public archive stay accessible.',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Base bundle: $pagesPerContribution page(s) for $unitCost Lumens.',
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _FlowStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FlowStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(color: Colors.white70, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionDetails extends StatelessWidget {
  final Mission mission;
  final int pagesDigitized;

  const _MissionDetails({
    required this.mission,
    required this.pagesDigitized,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mission.importance,
          style: const TextStyle(color: Colors.white, height: 1.4),
        ),
        const SizedBox(height: 10),
        Text(
          'Process: ${mission.preservationProcess}',
          style: const TextStyle(color: Colors.white70, height: 1.3),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Pages digitized',
                value: '$pagesDigitized / ${mission.totalPages}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Your pages',
                value: mission.userPages.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Per contribution',
                value: '${mission.pagesPerContribution} page(s)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'One focused mission keeps scanners, restorers, and archivists aligned.',
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }
}

class _MissionActionBar extends StatelessWidget {
  final int unitCost;
  final VoidCallback onContribute;
  final Mission mission; // Added mission

  const _MissionActionBar({
    required this.unitCost,
    required this.onContribute,
    required this.mission,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111116).withOpacity(0.95), // Slightly more opaque
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), // Top rounded only
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 32,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.ios_share),
                  color: Colors.white,
                  iconSize: 22,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => MissionShareDialog(mission: mission),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: onContribute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomeColors.peach,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.local_fire_department_outlined),
                    label: Text(
                      'Spend $unitCost Lumens',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;

  const _MissionPill({
    required this.label,
    required this.icon,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int percent;

  const _ProgressBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        '$percent%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _MissionEmptyState extends StatelessWidget {
  const _MissionEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.menu_book_outlined, color: Colors.white54),
          SizedBox(height: 8),
          Text(
            'New mission arriving soon.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'We will announce when the next preservation is ready.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
