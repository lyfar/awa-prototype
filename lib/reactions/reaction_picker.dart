import 'package:flutter/material.dart';

import 'reaction_palette.dart';

class ReactionPicker extends StatelessWidget {
  final List<ReactionStateData> reactions;
  final String? selectedReactionKey;
  final ValueChanged<String> onReactionSelected;
  final bool dense;
  final WrapAlignment alignment;

  const ReactionPicker({
    super.key,
    this.reactions = reactionTaxonomy,
    required this.selectedReactionKey,
    required this.onReactionSelected,
    this.dense = false,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final double spacing = dense ? 8 : 12;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: alignment,
      children: reactions.asMap().entries.map((entry) {
        final index = entry.key;
        final reaction = entry.value;
        final bool selected = reaction.key == selectedReactionKey;
        final gradient = _rainbowGradientFor(index);
        return GestureDetector(
          key: ValueKey('reaction-${reaction.key}'),
          onTap: () => onReactionSelected(reaction.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: dense ? 12 : 16,
              vertical: dense ? 10 : 12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(dense ? 18 : 22),
              border: Border.all(
                color: Colors.white.withOpacity(selected ? 0.9 : 0.6),
                width: selected ? 2.4 : 1.4,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: gradient.last.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reaction.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!dense)
                  Text(
                    reaction.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

List<Color> _rainbowGradientFor(int index) {
  const gradients = [
    [Color(0xFFFFB3C6), Color(0xFFFF6F91)],
    [Color(0xFFFFF5A5), Color(0xFFFFC75F)],
    [Color(0xFFB0FFB4), Color(0xFF5FE18D)],
    [Color(0xFFA8EFFF), Color(0xFF58C8FF)],
    [Color(0xFFBDB3FF), Color(0xFF8465FF)],
    [Color(0xFFFFBCFF), Color(0xFFFF6DCE)],
    [Color(0xFFFFE0B2), Color(0xFFFFA65A)],
  ];
  return gradients[index % gradients.length];
}
