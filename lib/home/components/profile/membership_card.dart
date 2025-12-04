import 'package:flutter/material.dart';

class MembershipCard extends StatelessWidget {
  final bool isPremium;

  const MembershipCard({super.key, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final gradient = isPremium
        ? const LinearGradient(
            colors: [Color(0xFFFFE9D4), Color(0xFFFCB29C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFB89FC1), Color(0xFFD7C4E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final title = isPremium ? 'Premium Companion' : 'Free Explorer';
    final subtitle = isPremium
        ? 'Access to missions, favourite sessions, and support tools.'
        : 'Upgrade to unlock missions, favourite sessions, and support.';

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPremium ? Icons.auto_awesome : Icons.lock_open,
              color: Colors.white,
            ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
