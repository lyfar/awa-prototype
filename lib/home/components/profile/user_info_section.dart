import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/practice_service.dart';
import '../../../models/meditation_models.dart';

/// User info section component for profile panel
class UserInfoSection extends StatefulWidget {
  final bool hasPracticedToday;
  final double? userLatitude;
  final double? userLongitude;
  final PracticeFlowState practiceState;

  const UserInfoSection({
    super.key,
    required this.hasPracticedToday,
    this.userLatitude,
    this.userLongitude,
    required this.practiceState,
  });

  @override
  State<UserInfoSection> createState() => _UserInfoSectionState();
}

class _UserInfoSectionState extends State<UserInfoSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Information',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        _buildInfoRow('Name', 'Mindful Explorer'),
        _buildInfoRow('Location', widget.userLatitude != null && widget.userLongitude != null
            ? '${widget.userLatitude!.toStringAsFixed(2)}, ${widget.userLongitude!.toStringAsFixed(2)}'
            : 'Not set'),
        _buildInfoRow('Practiced Today', widget.hasPracticedToday ? 'Yes ✓' : 'No'),
        _buildInfoRow('Practice State', widget.practiceState.name),

        const SizedBox(height: 16),

        // Location permission button (only show if location not set)
        if (widget.userLatitude == null || widget.userLongitude == null)
          _buildLocationPermissionButton(),
      ],
    );
  }

  /// Build location permission button
  Widget _buildLocationPermissionButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () async {
            print('ProfilePanel: Requesting location permission');
            try {
              final permission = await Geolocator.requestPermission();
              print('ProfilePanel: Location permission result: $permission');

              if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
                // Permission granted, save location
                await PracticeService.saveCurrentLocation();
                // Note: We can't directly update the parent state here
                // The parent component should handle refreshing data
                print('ProfilePanel: Location permission granted and saved');

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Location permission granted! You are now connected to the global community.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green.withOpacity(0.8),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } else {
                // Permission denied
                print('ProfilePanel: Location permission denied');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Location permission is needed to connect with nearby practitioners.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.orange.withOpacity(0.8),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            } catch (e) {
              print('ProfilePanel: ERROR requesting location permission: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Failed to request location permission. Please try again.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red.withOpacity(0.8),
                    duration: const Duration(seconds: 3),
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
              border: Border.all(color: Colors.blue.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Enable Location',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build info row helper
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
