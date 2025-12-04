import 'package:flutter/material.dart';

import 'mission_models.dart';

class MissionDashboardSheet extends StatelessWidget {
  final List<Mission> missions;

  const MissionDashboardSheet({super.key, required this.missions});

  int get totalPages => missions.fold(0, (sum, m) => sum + m.totalPages);
  int get userPages => missions.fold(0, (sum, m) => sum + m.userPages);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Missions Dashboard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metricCard('Total pages digitized', totalPages.toString())),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('Your pages', userPages.toString())),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: missions.length,
              itemBuilder: (_, index) {
                final mission = missions[index];
                return Container(
                  width: 220,
                  margin: EdgeInsets.only(right: index == missions.length - 1 ? 0 : 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(mission.progress * 100).round()}% complete',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: mission.progress,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFFFCB29C)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${mission.userPages} of your pages',
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
