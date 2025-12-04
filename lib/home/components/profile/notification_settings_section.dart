import 'package:flutter/material.dart';

class NotificationSettingsSection extends StatefulWidget {
  const NotificationSettingsSection({super.key});

  @override
  State<NotificationSettingsSection> createState() => _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState extends State<NotificationSettingsSection> {
  final Map<String, bool> _values = {
    'masters': true,
    'practice': true,
    'missions': false,
    'product': true,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToggle(
          title: 'Master reminders',
          description: 'Get a ping 5 minutes before live and lobby sessions open.',
          keyName: 'masters',
        ),
        const SizedBox(height: 12),
        _buildToggle(
          title: 'Daily practice nudges',
          description: 'Soft reminder if you have not practiced by 8pm local time.',
          keyName: 'practice',
        ),
        const SizedBox(height: 12),
        _buildToggle(
          title: 'Mission updates',
          description: 'See when a manuscript hits milestones you helped unlock.',
          keyName: 'missions',
        ),
        const SizedBox(height: 12),
        _buildToggle(
          title: 'Product drops',
          description: 'Announcements for new features, circles, or app releases.',
          keyName: 'product',
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opening system notification settings soon.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          label: const Text(
            'Manage system preferences',
            style: TextStyle(color: Colors.white),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle({
    required String title,
    required String description,
    required String keyName,
  }) {
    final value = _values[keyName] ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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
            onChanged: (next) => setState(() => _values[keyName] = next),
          ),
        ],
      ),
    );
  }
}
