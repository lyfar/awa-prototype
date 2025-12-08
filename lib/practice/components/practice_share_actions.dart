import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/theme/home_colors.dart';

class PracticeShareAction {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const PracticeShareAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });
}

class PracticeShareActions extends StatelessWidget {
  final List<PracticeShareAction> actions;

  const PracticeShareActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: actions
          .map((action) => _ShareActionButton(action: action))
          .toList(growable: false),
    );
  }
}

class _ShareActionButton extends StatelessWidget {
  final PracticeShareAction action;

  const _ShareActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        action.isPrimary ? Colors.black : Colors.white.withOpacity(0.9);
    final BoxDecoration decoration = action.isPrimary
        ? const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [HomeColors.peach, HomeColors.rose],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33FCB29C),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          )
        : BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          );

    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: decoration,
            child: Icon(
              action.icon,
              color: foreground,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: GoogleFonts.urbanist(
              color: Colors.white.withOpacity(action.isPrimary ? 1.0 : 0.8),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
