import 'package:flutter/material.dart';

import '../models/home_section.dart';
import '../theme/home_colors.dart';
import 'left_menu_insider_card.dart';

class LeftMenu extends StatelessWidget {
  final HomeSection activeSection;
  final ValueChanged<HomeSection> onSectionSelected;
  final bool isPaidUser;
  final int newMissionCount;
  final double awaPulseLevel;
  final int lightCarriers;
  final int unitsSpentThisWeek;
  final int missionsTotal;
  final int missionPagesRestored;
  final int faqCount;
  final VoidCallback onClose;

  const LeftMenu({
    super.key,
    required this.activeSection,
    required this.onSectionSelected,
    required this.isPaidUser,
    this.newMissionCount = 0,
    required this.awaPulseLevel,
    required this.lightCarriers,
    required this.unitsSpentThisWeek,
    required this.missionsTotal,
    required this.missionPagesRestored,
    required this.faqCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [HomeColors.space, HomeColors.eclipse],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildBranding()),
                  const SizedBox(width: 12),
                  _buildCloseButton(),
                ],
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const _SectionLabel('Journey'),
                    const SizedBox(height: 8),
                    _buildHomeCard(),
                    const SizedBox(height: 12),
                    _buildMissionsCard(),
                    const SizedBox(height: 24),
                    const _SectionLabel('Support'),
                    const SizedBox(height: 8),
                    _buildSupportCard(),
                    const SizedBox(height: 12),
                    _buildFaqCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'SYSTEM MENU',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Keep AWAWAY glowing',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Navigate missions, support, and updates without leaving the flow.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            height: 1.4,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Need help or want to suggest a practice? We’re listening.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap anywhere outside to return to the experience canvas.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildHomeCard() {
    return _DashboardCard(
      title: 'Home',
      description: 'Globe vitals and practice entry.',
      preview: const _GlobePreview(),
      stats: [
        DashboardStat(
          label: 'AWA pulse',
          value: '${(awaPulseLevel * 100).round()}%',
        ),
        DashboardStat(
          label: 'Light carriers',
          value: _formatLightUsers(lightCarriers),
        ),
      ],
      onTap: () => onSectionSelected(HomeSection.home),
      isActive: activeSection == HomeSection.home,
    );
  }

  Widget _buildMissionsCard() {
    final badge = newMissionCount > 0 ? '$newMissionCount new' : null;
    return _DashboardCard(
      title: 'Missions',
      description: 'Digitize manuscripts and unlock favourite pages.',
      preview: const Icon(
        Icons.auto_awesome,
        color: HomeColors.peach,
        size: 26,
      ),
      badgeText: badge,
      stats: [
        DashboardStat(label: 'Active missions', value: '$missionsTotal'),
        DashboardStat(label: 'Pages restored', value: '$missionPagesRestored'),
      ],
      onTap: () => onSectionSelected(HomeSection.missions),
      isActive: activeSection == HomeSection.missions,
    );
  }

  Widget _buildSupportCard() {
    return _DashboardCard(
      title: 'Support',
      description: 'Contact us, suggest features, or offer help.',
      preview: const Icon(
        Icons.favorite_outline,
        color: HomeColors.peach,
        size: 26,
      ),
      stats: [
        DashboardStat(label: 'New missions', value: '$newMissionCount'),
        DashboardStat(
          label: 'Spent this week',
          value: '-$unitsSpentThisWeek Lumens',
        ),
      ],
      onTap: () => onSectionSelected(HomeSection.donations),
      locked: false,
      isActive: activeSection == HomeSection.donations,
    );
  }

  Widget _buildFaqCard() {
    return _DashboardCard(
      title: 'FAQ',
      description: 'Answers about masters, AWAWAY, and more.',
      preview: const Icon(Icons.help_outline, color: Colors.white70, size: 24),
      stats: [DashboardStat(label: 'Questions available', value: '$faqCount')],
      onTap: () => onSectionSelected(HomeSection.faq),
      locked: false,
      isActive: activeSection == HomeSection.faq,
    );
  }

  Widget _buildCloseButton() {
    return InkWell(
      onTap: onClose,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 20),
      ),
    );
  }

  String _formatLightUsers(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget preview;
  final VoidCallback onTap;
  final bool locked;
  final bool isActive;
  final String? badgeText;
  final List<DashboardStat> stats;

  const _DashboardCard({
    required this.title,
    required this.description,
    required this.preview,
    required this.onTap,
    this.locked = false,
    this.isActive = false,
    this.badgeText,
    this.stats = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient:
              isActive
                  ? LinearGradient(
                    colors: [
                      HomeColors.peach.withOpacity(0.9),
                      HomeColors.lavender.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          border: Border.all(
            color:
                isActive ? Colors.transparent : Colors.white.withOpacity(0.08),
          ),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: HomeColors.peach.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    isActive
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.2),
                border: Border.all(
                  color: Colors.white.withOpacity(isActive ? 0.3 : 0.05),
                ),
              ),
              child: Center(child: preview),
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
                          title,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (badgeText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            badgeText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (locked)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(isActive ? 0.9 : 0.6),
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  if (stats.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          stats
                              .map(
                                (stat) => DashboardStatChip(
                                  stat: stat,
                                  inverted: true, // Always dark/glass theme now
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _GlobePreview extends StatelessWidget {
  const _GlobePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF1C1C30), Color(0xFF2B2B44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.public, color: Colors.white70),
    );
  }
}
