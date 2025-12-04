part of 'package:awa_01_spark/screens/home_screen.dart';

Future<void> showMissionFeedbackDialog({
  required BuildContext context,
  required Mission mission,
  required int pages,
  required int cost,
  required int remainingBalance,
  required VoidCallback onViewSaved,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF101428),
        title: const Text('Thank you for supporting!'),
        content: Text(
          'You favourited $pages page(s) of ${mission.title} with $cost Lumens. Your new balance is $remainingBalance Lumens.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onViewSaved();
            },
            child: const Text('View favourite pages'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}

void showMissionSavedPagesSheet({
  required BuildContext context,
  required Mission mission,
  required List<String> pageAssets,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0D111F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
    ),
    builder:
        (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: MissionSavedPagesSheet(
          missionTitle: mission.title,
          pageAssets: pageAssets,
        ),
      ),
  );
}
