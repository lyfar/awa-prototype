import 'package:flutter/material.dart';
import '../home/theme/home_colors.dart';
import 'mission_models.dart';

class MissionShareDialog extends StatelessWidget {
  final Mission mission;

  const MissionShareDialog({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShareableCard(mission: mission),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ShareOption(
                icon: Icons.copy,
                label: 'Copy Link',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 20),
              _ShareOption(
                icon: Icons.share,
                label: 'Share Story',
                isPrimary: true,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 20),
              _ShareOption(
                icon: Icons.download,
                label: 'Save Image',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isPrimary ? Colors.white : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.black : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(isPrimary ? 1.0 : 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareableCard extends StatelessWidget {
  final Mission mission;

  const _ShareableCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Background Image / Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2B2B44), Color(0xFF1C1C30)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Decorative Circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HomeColors.peach.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: HomeColors.peach.withOpacity(0.2),
                      blurRadius: 60,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HomeColors.lavender.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: HomeColors.lavender.withOpacity(0.15),
                      blurRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: HomeColors.peach,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'AWA MISSION',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.qr_code_2,
                        color: Colors.white.withOpacity(0.3),
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    mission.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'I’m helping digitize this ${mission.manuscriptEra} manuscript from ${mission.manuscriptLocation}.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [HomeColors.peach, HomeColors.lavender],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.bolt, color: Colors.black, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Join the preservation',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'awaterra.com/missions',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

