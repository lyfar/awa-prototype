import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/meditation_models.dart';
import '../reactions/reaction_palette.dart';
import '../soul/awa_sphere.dart';

/// Feedback screen shown after completing a practice
/// User selects their emotional state/reaction
class PracticeFeedbackScreen extends StatefulWidget {
  final Practice practice;
  final Duration? duration;
  final String? modalityName;

  const PracticeFeedbackScreen({
    super.key,
    required this.practice,
    this.duration,
    this.modalityName,
  });

  @override
  State<PracticeFeedbackScreen> createState() => _PracticeFeedbackScreenState();
}

class _PracticeFeedbackScreenState extends State<PracticeFeedbackScreen> {
  String? _selectedReactionKey;

  ReactionStateData _reactionFor(String key) {
    return reactionTaxonomy.firstWhere(
      (reaction) => reaction.key == key,
      orElse: () => reactionTaxonomy.first,
    );
  }

  void _selectReaction(String key) {
    setState(() {
      _selectedReactionKey = key;
    });
    print('PracticeFeedbackScreen: Selected reaction - $key');
  }

  void _submitFeedback() {
    if (_selectedReactionKey == null) return;
    
    final reaction = _reactionFor(_selectedReactionKey!);
    print('PracticeFeedbackScreen: Submitting feedback - ${reaction.label}');
    Navigator.of(context).pop(reaction);
  }

  void _skipFeedback() {
    print('PracticeFeedbackScreen: Skipped feedback');
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final practiceName = widget.modalityName ?? widget.practice.getName();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // AwaSphere at top - half screen size
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AwaSphereHeader(
              halfScreen: true,
              interactive: false,
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Completion badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$practiceName complete',
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'How are you\nfeeling now?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Share a pulse so AwaSoul can tune your next journey.',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      color: Colors.black45,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Reaction grid
                  Expanded(
                    child: _buildReactionGrid(),
                  ),

                  // Buttons
                  if (_selectedReactionKey != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B2B3C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Save & Continue',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Skip option
                  Center(
                    child: TextButton(
                      onPressed: _skipFeedback,
                      child: Text(
                        'Skip for now',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: reactionTaxonomy.length,
      itemBuilder: (context, index) {
        final reaction = reactionTaxonomy[index];
        final isSelected = _selectedReactionKey == reaction.key;

        return GestureDetector(
          onTap: () => _selectReaction(reaction.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected 
                  ? reaction.color.withValues(alpha: 0.15) 
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? reaction.color 
                    : Colors.black.withValues(alpha: 0.08),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: reaction.color.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Colored circle indicator
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: reaction.color.withValues(alpha: isSelected ? 0.8 : 0.2),
                    border: Border.all(
                      color: reaction.color,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  reaction.label,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? reaction.color : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
