import 'package:flutter/material.dart';

import '../models/master_guide.dart';
import '../reactions/reaction_palette.dart';
import '../reactions/reaction_picker.dart';

class MasterSessionFeedbackScreen extends StatelessWidget {
  final MasterGuide master;

  const MasterSessionFeedbackScreen({super.key, required this.master});

  ReactionStateData _reactionFor(String key) {
    return reactionTaxonomy.firstWhere(
      (reaction) => reaction.key == key,
      orElse: () => reactionTaxonomy.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${master.title} complete',
                  style: const TextStyle(
                    color: Color(0xFF2B2B3C),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'How did ${master.name} leave you feeling?',
                  style: const TextStyle(
                    color: Color(0xFF2B2B3C),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masters tune the collective through these pulses. Tap a feeling and we will log it instantly.',
                  style: TextStyle(color: Colors.black.withOpacity(0.65)),
                ),
                const SizedBox(height: 24),
                ReactionPicker(
                  selectedReactionKey: null,
                  alignment: WrapAlignment.center,
                  onReactionSelected: (key) {
                    Navigator.of(context).pop(_reactionFor(key));
                  },
                ),
                const Spacer(),
                const Text(
                  'Tap any feeling to finish.',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
