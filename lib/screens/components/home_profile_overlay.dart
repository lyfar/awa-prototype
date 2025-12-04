part of 'package:awa_01_spark/screens/home_screen.dart';

class HomeProfileOverlay extends StatelessWidget {
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
  final ValueChanged<bool> onPracticeStateChanged;
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

  const HomeProfileOverlay({
    super.key,
    required this.isVisible,
    required this.onClose,
    required this.hasPracticedToday,
    required this.userLatitude,
    required this.userLongitude,
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
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
        ),
        ProfilePanel(
          isVisible: isVisible,
          onClose: onClose,
          activeSection: activeSection,
          onSectionSelected: onSectionSelected,
          hasPracticedToday: hasPracticedToday,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          reactionPalette: reactionPalette,
          totalMindfulnessMinutes: totalMindfulnessMinutes,
          practiceState: practiceState,
          onPracticeStateChanged: onPracticeStateChanged,
          isPaidUser: isPaidUser,
          onPaidStatusChanged: onPaidStatusChanged,
          awawayDay: awawayDay,
          awawayCycleLength: awawayCycleLength,
          onAwawayDayChanged: onAwawayDayChanged,
          streakProgress: streakProgress,
          unitsBalance: unitsBalance,
          unitsEarnedThisWeek: unitsEarnedThisWeek,
          unitsSpentThisWeek: unitsSpentThisWeek,
          historyPracticeCount: historyPracticeCount,
          historyReactionCount: historyReactionCount,
          savedCount: savedCount,
          onUpgradeTapped: onUpgradeTapped,
        ),
      ],
    );
  }
}
