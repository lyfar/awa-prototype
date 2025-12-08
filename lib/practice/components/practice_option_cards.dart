import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/meditation_models.dart';
import '../../models/saved_practice.dart';

/// Returns the icon for a practice type
IconData getPracticeIcon(PracticeType type) {
  switch (type) {
    case PracticeType.lightPractice:
      return Icons.wb_sunny_outlined;
    case PracticeType.guidedMeditation:
      return Icons.headphones_outlined;
    case PracticeType.soundMeditation:
      return Icons.graphic_eq;
    case PracticeType.myPractice:
      return Icons.self_improvement;
    case PracticeType.specialPractice:
      return Icons.auto_awesome;
  }
}

/// Returns the duration label for a practice type
String getPracticeDurationLabel(PracticeType type) {
  switch (type) {
    case PracticeType.lightPractice:
      return '~10 Min';
    case PracticeType.guidedMeditation:
      return '~10 Min';
    case PracticeType.soundMeditation:
      return '5-30 Min';
    case PracticeType.myPractice:
      return '1-180 Min';
    case PracticeType.specialPractice:
      return '~10 Min';
  }
}

/// Single practice type option card
class PracticeTypeOptionCard extends StatelessWidget {
  final PracticeTypeGroup group;
  final bool isSelected;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback onInfoTap;

  const PracticeTypeOptionCard({
    super.key,
    required this.group,
    required this.isSelected,
    required this.iconColor,
    required this.onTap,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final practiceIcon = getPracticeIcon(group.type);
    final durationLabel = getPracticeDurationLabel(group.type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? iconColor : Colors.black.withValues(alpha: 0.06),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Practice-specific icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(practiceIcon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    group.displayName,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    group.shortDescription,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Duration badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                durationLabel,
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Info button
            GestureDetector(
              onTap: onInfoTap,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.04),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Saved practice option card
class SavedPracticeOptionCard extends StatelessWidget {
  final SavedPractice saved;
  final bool isSelected;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback onInfoTap;

  const SavedPracticeOptionCard({
    super.key,
    required this.saved,
    required this.isSelected,
    required this.iconColor,
    required this.onTap,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final practiceIcon = getPracticeIcon(saved.practice.type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? iconColor : Colors.black.withValues(alpha: 0.06),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Practice-specific icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(practiceIcon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    saved.practice.getName(),
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (saved.note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      saved.note!,
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Duration badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${saved.duration.inMinutes} Min',
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Info button
            GestureDetector(
              onTap: onInfoTap,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.04),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


