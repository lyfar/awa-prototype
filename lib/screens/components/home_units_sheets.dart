part of 'package:awa_01_spark/screens/home_screen.dart';

void showEarnUnitsSheet({
  required BuildContext context,
  required bool hasPracticedToday,
  required int awawayDay,
  required int awawayCycleLength,
  required VoidCallback onPractice,
  required VoidCallback onAwaway,
  required VoidCallback onOfferings,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0D111F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
    ),
    builder: (sheetContext) {
      return UnitsActionSheet(
        title: 'Earn Lumens',
        subtitle: 'Stay consistent with AWA Soul to earn energy for missions and masters.',
        accentColor: _emberPeach,
        actions: [
          UnitActionItem(
            icon: Icons.self_improvement_outlined,
            title: 'Complete guided practice',
            description: 'Each completed practice adds 15 Lumens and brightens Light Ignition.',
            valueLabel: '+15 Lumens per session',
            badgeLabel: hasPracticedToday ? 'Done today' : 'Pending',
            badgeColor: hasPracticedToday ? const Color(0xFF8BFFC7) : Colors.white24,
            onTap: () {
              Navigator.of(sheetContext).pop();
              onPractice();
            },
          ),
          UnitActionItem(
            icon: Icons.auto_fix_high,
            title: 'Keep AWAWAY glowing',
            description: 'Day $awawayDay of $awawayCycleLength • repair lapses early to keep bonuses.',
            valueLabel: 'Cycle bonus +10 Lumens',
            badgeLabel: 'AWAWAY',
            badgeColor: const Color(0xFFD8C3FF),
            onTap: () {
              Navigator.of(sheetContext).pop();
              onAwaway();
            },
          ),
          UnitActionItem(
            icon: Icons.volunteer_activism_outlined,
            title: 'Direct offerings',
            description: 'One-time donation to purchase Lumens and accelerate digitization (coming soon).',
            badgeLabel: 'Soon',
            badgeColor: Colors.white24,
            onTap: () {
              Navigator.of(sheetContext).pop();
              onOfferings();
            },
          ),
        ],
      );
    },
  );
}

void showSpendUnitsSheet({
  required BuildContext context,
  required int minMissionCost,
  required bool hasNewMissionNotification,
  required bool isPaidUser,
  required VoidCallback onSupportMissions,
  required VoidCallback onMasters,
  required VoidCallback onRepairAwaway,
  required VoidCallback onDownloads,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0D111F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
    ),
    builder: (sheetContext) {
      return UnitsActionSheet(
        title: 'Spend Lumens',
        subtitle: 'Invest your balance into digitization missions, masters, or protective rituals.',
        accentColor: const Color(0xFFB89FC1),
        actions: [
          UnitActionItem(
            icon: Icons.menu_book_outlined,
            title: 'Support missions',
            description: 'Digitize manuscripts and unlock favourite pages for the library.',
            valueLabel: 'From $minMissionCost Lumens',
            badgeLabel: hasNewMissionNotification ? 'New' : null,
            badgeColor: hasNewMissionNotification ? const Color(0xFFFFE9D4) : null,
            onTap: () {
              Navigator.of(sheetContext).pop();
              onSupportMissions();
            },
          ),
          UnitActionItem(
            icon: Icons.groups_outlined,
            title: 'Masters & collectives',
            description: 'Reserve seats or offer gratitude to masters (coming soon).',
            badgeLabel: 'Soon',
            badgeColor: Colors.white24,
            onTap: () {
              Navigator.of(sheetContext).pop();
              onMasters();
            },
          ),
          UnitActionItem(
            icon: Icons.auto_graph,
            title: 'Repair AWAWAY',
            description: 'Use Lumens to fix missed days and keep geometry intact.',
            valueLabel: 'Repair fee 8 Lumens',
            badgeLabel: 'AWAWAY',
            badgeColor: const Color(0xFFD8C3FF),
            onTap: () {
              Navigator.of(sheetContext).pop();
              onRepairAwaway();
            },
          ),
          UnitActionItem(
            icon: Icons.download_for_offline_outlined,
            title: 'Download history',
            description: 'Paid members can save weekly dashboards and audio for offline focus.',
            valueLabel: 'Premium unlock',
            badgeLabel: isPaidUser ? 'Included' : 'Premium',
            badgeColor: isPaidUser ? const Color(0xFF8BFFC7) : const Color(0xFFFFD5C1),
            onTap: () {
              Navigator.of(sheetContext).pop();
              onDownloads();
            },
          ),
        ],
      );
    },
  );
}
