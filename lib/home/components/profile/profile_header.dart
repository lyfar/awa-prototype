import 'package:flutter/material.dart';

const Color _ink = Colors.white;
const Color _muted = Color(0xFFB1ADC4);

/// Profile panel header component
class ProfileHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;
  final VoidCallback? onBack;
  final String? badgeLabel;
  final Color? badgeColor;
  final VoidCallback? onBadgeTap;

  const ProfileHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onClose,
    this.onBack,
    this.badgeLabel,
    this.badgeColor,
    this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) ...[
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: _ink, size: 18),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (badgeLabel != null) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onBadgeTap,
                      child: _BadgeChip(
                        label: badgeLabel!,
                        color: badgeColor ?? Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: _muted.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            print('ProfileHeader: Closing profile panel');
            onClose();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Icon(
              Icons.close,
              color: _ink,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
