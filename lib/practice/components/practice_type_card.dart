import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/meditation_models.dart';
import '../../home/theme/home_colors.dart';

/// Compact card showing a practice type with freshness badge and key info
/// Expandable to show variants and details
class PracticeTypeCard extends StatelessWidget {
  final PracticeTypeGroup group;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<Practice>? onPracticeSelected;

  const PracticeTypeCard({
    super.key,
    required this.group,
    this.isExpanded = false,
    this.isSelected = false,
    required this.onTap,
    this.onPracticeSelected,
  });

  Color get _cardColor {
    switch (group.type) {
      case PracticeType.lightPractice:
        return HomeColors.cream;
      case PracticeType.guidedMeditation:
        return HomeColors.lavender;
      case PracticeType.soundMeditation:
        return const Color(0xFFE8F0E8); // Soft sage
      case PracticeType.myPractice:
        return HomeColors.peach;
      case PracticeType.specialPractice:
        return const Color(0xFFF5E6FF); // Soft violet
    }
  }

  Color get _badgeColor {
    final primary = group.primaryPractice;
    switch (primary.freshness) {
      case PracticeFreshness.today:
        return const Color(0xFF4CAF50); // Green
      case PracticeFreshness.yesterday:
        return const Color(0xFFFF9800); // Orange
      case PracticeFreshness.monthly:
        return const Color(0xFF2196F3); // Blue
      case PracticeFreshness.always:
        return const Color(0xFF9C27B0); // Purple
      case PracticeFreshness.timed:
        return const Color(0xFFE91E63); // Pink
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = group.primaryPractice;
    print('PracticeTypeCard: Building ${group.displayName} - expanded: $isExpanded');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black26 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.12 : 0.06),
              blurRadius: isSelected ? 16 : 8,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - always visible
            _buildHeader(primary),
            
            // Expanded content
            if (isExpanded) ...[
              const Divider(height: 1, color: Colors.black12),
              _buildExpandedContent(primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Practice primary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                group.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        group.displayName,
                        style: GoogleFonts.urbanist(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2B2B3C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Freshness badge
                    _buildFreshnessBadge(primary),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  group.shortDescription,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Expand indicator
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.black38,
          ),
        ],
      ),
    );
  }

  Widget _buildFreshnessBadge(Practice primary) {
    // For timed practices, show countdown if available
    String badgeText = primary.freshnessBadge;
    final countdown = primary.countdownToWindow;
    if (countdown != null) {
      final mins = countdown.inMinutes;
      badgeText = mins > 0 ? 'IN ${mins}m' : 'NOW';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        badgeText,
        style: GoogleFonts.urbanist(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildExpandedContent(Practice primary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick info row
          _buildInfoRow(primary),
          
          const SizedBox(height: 16),
          
          // Highlights
          ...primary.highlights.map((h) => _buildHighlightItem(h)),
          
          // Variants selector (for rotation practices)
          if (group.hasRotation && group.variants.length > 1) ...[
            const SizedBox(height: 16),
            _buildVariantsSelector(),
          ],
          
          const SizedBox(height: 16),
          
          // Start button
          _buildStartButton(primary),
        ],
      ),
    );
  }

  Widget _buildInfoRow(Practice primary) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildInfoChip(Icons.timer_outlined, primary.durationLabel),
        if (primary.downloadable)
          _buildInfoChip(Icons.download_outlined, 'Downloadable'),
        if (primary.requiresMaster)
          _buildInfoChip(Icons.person_outlined, 'Master Info'),
        if (!primary.isAvailable)
          _buildInfoChip(Icons.lock_outlined, 'Locked'),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: _badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.urbanist(
                fontSize: 13,
                color: const Color(0xFF2B2B3C),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose version:',
          style: GoogleFonts.urbanist(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: group.variants.map((variant) {
            final isToday = variant.freshness == PracticeFreshness.today;
            return GestureDetector(
              onTap: () => onPracticeSelected?.call(variant),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isToday ? _badgeColor.withOpacity(0.15) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday ? _badgeColor : Colors.black12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isToday ? Icons.new_releases : Icons.history,
                      size: 16,
                      color: isToday ? _badgeColor : Colors.black45,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isToday ? "Today's New" : "Yesterday's",
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isToday ? _badgeColor : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton(Practice primary) {
    final isLocked = !primary.isAvailable;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLocked ? null : () => onPracticeSelected?.call(primary),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLocked ? Colors.grey[300] : const Color(0xFF2B2B3C),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLocked) ...[
              const Icon(Icons.lock, size: 18),
              const SizedBox(width: 8),
              Text(
                'Opens at ${primary.timeWindows?.first ?? "scheduled time"}',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                'Start ${group.displayName}',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mini card for practice variant selection in expanded view
class PracticeVariantMiniCard extends StatelessWidget {
  final Practice practice;
  final bool isSelected;
  final VoidCallback onTap;

  const PracticeVariantMiniCard({
    super.key,
    required this.practice,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black26 : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  practice.freshnessBadge,
                  style: GoogleFonts.urbanist(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: practice.freshness == PracticeFreshness.today 
                      ? const Color(0xFF4CAF50) 
                      : const Color(0xFFFF9800),
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(Icons.check_circle, size: 16, color: Colors.black54),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              practice.availabilityLabel,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

