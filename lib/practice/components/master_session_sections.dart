import 'package:flutter/material.dart';

import '../../models/master_guide.dart';

class MasterSessionStatsRow extends StatelessWidget {
  final MasterGuide master;

  const MasterSessionStatsRow({super.key, required this.master});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SessionStatCard(
            icon: Icons.timelapse,
            label: 'Duration',
            value: '${master.duration.inMinutes} min',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SessionStatCard(
            icon: Icons.people_alt_outlined,
            label: 'Circle',
            value: '${master.participantCount} souls',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SessionStatCard(
            icon: Icons.auto_awesome,
            label: 'Lobby',
            value: 'Begins ${master.startTime}',
          ),
        ),
      ],
    );
  }
}

class MasterLobbyCard extends StatelessWidget {
  final MasterGuide master;

  const MasterLobbyCard({super.key, required this.master});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        'Arrive softly',
        'Doors open 5 min before ${master.startTime}. Match breath with the host hum.',
      ),
      (
        'Offer your emotion',
        'Choose a feeling once the audio finishes so the guide can tune the next wave.',
      ),
      (
        'Close in gratitude',
        'Stay through closing chime to send a collective thanks.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FF),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lobby ritual',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2B3C),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF2B2B3C),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.$1,
                          style: const TextStyle(
                            color: Color(0xFF2B2B3C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.$2,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SessionStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SessionStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black.withOpacity(0.7)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B6B7A),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2B2B3C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
