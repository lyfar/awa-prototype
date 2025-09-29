import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/practice_service.dart';

/// Debug section component for profile panel
class DebugSection extends StatelessWidget {
  final Function(bool) onPracticeStateChanged;

  const DebugSection({
    super.key,
    required this.onPracticeStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Debug Controls',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        // Reset practice state button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () async {
                print('DebugSection: RESET BUTTON TAPPED!');
                try {
                  await PracticeService.resetPracticeData();
                  onPracticeStateChanged(false);
                  print('DebugSection: Reset completed successfully');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Practice state reset successfully!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green.withOpacity(0.8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  print('DebugSection: ERROR resetting practice state: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Failed to reset practice state',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.withOpacity(0.8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
                ),
                child: const Text(
                  'RESET PRACTICE STATE',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Mark practice complete button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () async {
                print('DebugSection: MARK COMPLETE BUTTON TAPPED!');
                try {
                  await PracticeService.markPracticeCompleted();
                  onPracticeStateChanged(true);
                  print('DebugSection: Mark complete finished successfully');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Practice marked as completed!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green.withOpacity(0.8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  print('DebugSection: ERROR marking practice complete: $e');
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.5), width: 1),
                ),
                child: const Text(
                  'MARK PRACTICE COMPLETE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Reset location button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () async {
                print('DebugSection: RESET LOCATION BUTTON TAPPED!');
                try {
                  // Clear stored location data
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('last_location');
                  await prefs.remove('user_location_saved');

                  print('DebugSection: Location data reset successfully');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Location reset! You can now test the location permission feature.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.orange.withOpacity(0.8),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  print('DebugSection: ERROR resetting location: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Failed to reset location data',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.withOpacity(0.8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1),
                ),
                child: const Text(
                  'RESET LOCATION DATA',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
