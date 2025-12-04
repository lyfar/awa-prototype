import 'package:flutter/material.dart';
import '../../models/meditation_models.dart';
import '../models/home_section.dart';
import '../theme/home_colors.dart';
import 'left_menu_insider_card.dart';
import 'profile/profile_header.dart';
import 'profile/user_info_section.dart';
import 'profile/language_section.dart';
import 'profile/debug_section.dart';
import 'profile/notification_settings_section.dart';
import 'profile/profile_shortcuts.dart';

const LinearGradient _profileBackdrop = LinearGradient(
  colors: [HomeColors.space, HomeColors.eclipse],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Sliding profile panel that opens from the right
/// Contains user info and debug controls
class ProfilePanel extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;
  final bool hasPracticedToday;
  final double? userLatitude;
  final double? userLongitude;
  final List<Color> reactionPalette;
  final int totalMindfulnessMinutes;
  final HomeSection activeSection;
  final ValueChanged<HomeSection> onSectionSelected;
  final PracticeFlowState practiceState;
  final Function(bool) onPracticeStateChanged;
  final bool isPaidUser;
  final ValueChanged<bool> onPaidStatusChanged;
  final int awawayDay;
  final int awawayCycleLength;
  final ValueChanged<int> onAwawayDayChanged;
  final double streakProgress;
  final int unitsBalance;
  final int unitsEarnedThisWeek;
  final int unitsSpentThisWeek;
  final int historyPracticeCount;
  final int historyReactionCount;
  final int savedCount;
  final VoidCallback onUpgradeTapped;

  const ProfilePanel({
    super.key,
    required this.isVisible,
    required this.onClose,
    required this.hasPracticedToday,
    this.userLatitude,
    this.userLongitude,
    required this.reactionPalette,
    required this.totalMindfulnessMinutes,
    required this.activeSection,
    required this.onSectionSelected,
    required this.practiceState,
    required this.onPracticeStateChanged,
    required this.isPaidUser,
    required this.onPaidStatusChanged,
    required this.awawayDay,
    required this.awawayCycleLength,
    required this.onAwawayDayChanged,
    required this.streakProgress,
    required this.unitsBalance,
    required this.unitsEarnedThisWeek,
    required this.unitsSpentThisWeek,
    required this.historyPracticeCount,
    required this.historyReactionCount,
    required this.savedCount,
    required this.onUpgradeTapped,
  });

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

enum _ProfilePage { overview, settings, debug }

class _ProfilePanelState extends State<ProfilePanel> {
  _ProfilePage _page = _ProfilePage.overview;
  bool _allowNotifications = true;
  bool _allowLocation = true;

  @override
  void didUpdateWidget(covariant ProfilePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible && widget.isVisible) {
      _page = _ProfilePage.overview;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      top: 0,
      right: widget.isVisible ? 0 : -panelWidth,
      width: panelWidth,
      height: MediaQuery.of(context).size.height,
      child: Material(
        elevation: 24,
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(gradient: _profileBackdrop),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: ProfileHeader(
                    title: _pageTitle,
                    subtitle: _pageSubtitle,
                    onClose: widget.onClose,
                    onBack:
                        _page == _ProfilePage.overview ? null : _backToOverview,
                    badgeLabel: widget.isPaidUser ? 'Premium' : 'Free',
                    badgeColor:
                        widget.isPaidUser ? HomeColors.peach : Colors.white,
                    onBadgeTap: widget.onUpgradeTapped,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    physics: const BouncingScrollPhysics(),
                    children: _buildPageChildren(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _pageTitle {
    switch (_page) {
      case _ProfilePage.settings:
        return 'Settings';
      case _ProfilePage.debug:
        return 'Debug tools';
      case _ProfilePage.overview:
      default:
        return 'Profile';
    }
  }

  String get _pageSubtitle {
    switch (_page) {
      case _ProfilePage.settings:
        return 'User info, permissions, language, and notifications.';
      case _ProfilePage.debug:
        return 'Internal controls for practice states and membership.';
      case _ProfilePage.overview:
      default:
        return 'Quick links, membership badge, and journeys.';
    }
  }

  List<Widget> _buildPageChildren() {
    switch (_page) {
      case _ProfilePage.settings:
        return _buildSettingsContent();
      case _ProfilePage.debug:
        return _buildDebugContent();
      case _ProfilePage.overview:
      default:
        return _buildOverviewContent();
    }
  }

  List<Widget> _buildOverviewContent() {
    return [
      InsiderCard(
        title: 'Insider',
        description: 'Recaps, reactions, and exports.',
        preview: const Icon(Icons.history, color: Colors.white, size: 26),
        stats: [
          DashboardStat(
            label: 'Practices',
            value: '${widget.historyPracticeCount}',
          ),
          DashboardStat(
            label: 'Reactions',
            value: '${widget.historyReactionCount}',
          ),
          DashboardStat(
            label: 'Mindful time',
            value: _formatMindfulnessTime(widget.totalMindfulnessMinutes),
          ),
        ],
        onTap: () => widget.onSectionSelected(HomeSection.history),
        isActive: widget.activeSection == HomeSection.history,
        palette: widget.reactionPalette,
      ),
      const SizedBox(height: 16),
      const _SectionLabel('Journey surfaces'),
      const SizedBox(height: 8),
      ProfileShortcutsSection(
        activeSection: widget.activeSection,
        onSectionSelected: widget.onSectionSelected,
        awawayDay: widget.awawayDay,
        awawayCycleLength: widget.awawayCycleLength,
        streakProgress: widget.streakProgress,
        unitsBalance: widget.unitsBalance,
        unitsEarnedThisWeek: widget.unitsEarnedThisWeek,
        unitsSpentThisWeek: widget.unitsSpentThisWeek,
        savedCount: widget.savedCount,
        isPaidUser: widget.isPaidUser,
      ),
      const SizedBox(height: 20),
      _buildQuickActionsColumn(),
      const SizedBox(height: 24),
      _buildFooterNote(),
    ];
  }

  List<Widget> _buildSettingsContent() {
    return [
      const _SectionLabel('User'),
      const SizedBox(height: 8),
      _SettingsContainer(
        child: UserInfoSection(
          hasPracticedToday: widget.hasPracticedToday,
          userLatitude: widget.userLatitude,
          userLongitude: widget.userLongitude,
          practiceState: widget.practiceState,
        ),
      ),
      const SizedBox(height: 24),
      const _SectionLabel('Profile settings'),
      const SizedBox(height: 8),
      _SettingsToggle(
        title: 'Allow location',
        description: 'Share approximate location to light the map.',
        value: _allowLocation,
        onChanged: (value) {
          setState(() => _allowLocation = value);
        },
      ),
      const SizedBox(height: 24),
      const _SectionLabel('Language'),
      const SizedBox(height: 8),
      const LanguageSection(),
      const SizedBox(height: 24),
      const _SectionLabel('Push & notifications'),
      const SizedBox(height: 8),
      _SettingsToggle(
        title: 'Allow notifications',
        description: 'Receive reminders about rituals and masters.',
        value: _allowNotifications,
        onChanged: (value) {
          setState(() => _allowNotifications = value);
        },
      ),
      const SizedBox(height: 24),
      const NotificationSettingsSection(),
      const SizedBox(height: 24),
      const _SectionLabel('Danger zone'),
      const SizedBox(height: 8),
      _DeleteProfileButton(onPressed: _confirmDeleteProfileFlow),
      const SizedBox(height: 20),
      _buildFooterNote(),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildDebugContent() {
    return [
      const _SectionLabel('Debug tools'),
      const SizedBox(height: 8),
      _SettingsContainer(
        child: DebugSection(
          onPracticeStateChanged: widget.onPracticeStateChanged,
          isPaidUser: widget.isPaidUser,
          onPaidStatusChanged: widget.onPaidStatusChanged,
          awawayDay: widget.awawayDay,
          awawayCycleLength: widget.awawayCycleLength,
          onAwawayDayChanged: widget.onAwawayDayChanged,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Internal only. These controls adjust the prototype state for testing.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          height: 1.4,
        ),
      ),
      const SizedBox(height: 20),
      _buildFooterNote(),
      const SizedBox(height: 20),
    ];
  }

  void _openSettingsPage() {
    setState(() => _page = _ProfilePage.settings);
  }

  void _openDebugPage() {
    setState(() => _page = _ProfilePage.debug);
  }

  void _backToOverview() {
    setState(() => _page = _ProfilePage.overview);
  }

  Widget _buildQuickActionsColumn() {
    return Column(
      children: [
        _QuickActionCard(
          title: 'Settings',
          description: 'Profile, language, notifications, and delete.',
          icon: Icons.settings_outlined,
          onTap: _openSettingsPage,
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          title: 'Debug',
          description: 'Prototype controls and QA helpers.',
          icon: Icons.bug_report_outlined,
          onTap: _openDebugPage,
        ),
      ],
    );
  }

  Widget _buildMembershipBadge() {
    final bool premium = widget.isPaidUser;
    final Color accent =
        premium ? HomeColors.peach : Colors.white.withValues(alpha: 0.6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            premium ? Icons.auto_awesome : Icons.lock_open,
            color: accent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            premium ? 'Premium badge' : 'Free badge',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Text(
      'Need anything else? Message us from the missions console or email hello@awaterra.com',
      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), height: 1.4),
    );
  }

  String _formatMindfulnessTime(int minutes) {
    if (minutes <= 0) return '0m';
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    return mins == 0 ? '${hours}h' : '${hours}h ${mins}m';
  }

  Future<void> _confirmDeleteProfileFlow() async {
    bool agreed = false;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.07)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete account?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Are you sure you want to delete your account? All data will be erased. This action can’t be undone.',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: agreed,
                          onChanged: (value) {
                            setModalState(() => agreed = value ?? false);
                          },
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                        ),
                        Expanded(
                          child: Text(
                            'I agree and confirm that I want to delete my account',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                agreed
                                    ? () => Navigator.of(context).pop(true)
                                    : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Delete now'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile deletion flow will be wired soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SettingsContainer extends StatelessWidget {
  final Widget child;

  const _SettingsContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            activeColor: Colors.black,
            activeTrackColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DeleteProfileButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteProfileButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B1B24), Color(0xFF2A0A0F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Center(
          child: Text(
            'Delete profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      height: 1.3,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white54,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
