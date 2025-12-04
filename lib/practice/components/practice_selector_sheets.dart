import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/meditation_models.dart';
import '../../models/saved_practice.dart';
import '../../subscription/awa_journey_screen.dart';
import 'radial_emotion_chart.dart';

/// Premium upgrade sheet
class PremiumUpgradeSheet extends StatelessWidget {
  final VoidCallback onUpgrade;
  final VoidCallback onClose;

  const PremiumUpgradeSheet({
    super.key,
    required this.onUpgrade,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Lock icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFCB29C), Color(0xFFE88A6E)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.favorite, size: 40, color: Colors.white),
            ),

            const SizedBox(height: 24),

            Text(
              'Favorite Practices',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Mark your favorite practices for quick access.\nAvailable with AwaJourney subscription.',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Features list
            _buildFeatureRow(Icons.favorite_border, 'Unlimited favorites'),
            const SizedBox(height: 12),
            _buildFeatureRow(Icons.flash_on, 'Quick-start your favorites'),
            const SizedBox(height: 12),
            _buildFeatureRow(Icons.note_alt_outlined, 'Add personal notes'),

            const SizedBox(height: 32),

            // Upgrade button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AwaJourneyScreen(onSubscribed: onUpgrade),
                    ),
                  );
                },
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
                  'Explore AwaJourney',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: onClose,
              child: Text(
                'Maybe Later',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFCB29C).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFE88A6E)),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.urbanist(fontSize: 15, color: Colors.black87),
        ),
      ],
    );
  }
}

/// Helper class for practice content
class PracticeContent {
  final String title;
  final String subtitle;
  final String description;
  final String duration;
  final bool hasCustomDuration;
  final String? theme;
  final String? aim;
  final String? outcome;
  final String? masterName;
  final String? masterBio;
  final String? eventTime;
  final List<String>? modalities;
  final List<Color> imageGradient;
  final List<String> highlights;

  const PracticeContent({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.duration,
    this.hasCustomDuration = false,
    this.theme,
    this.aim,
    this.outcome,
    this.masterName,
    this.masterBio,
    this.eventTime,
    this.modalities,
    required this.imageGradient,
    required this.highlights,
  });

  /// Get content for a practice type
  static PracticeContent forType(PracticeType type) {
    switch (type) {
      case PracticeType.lightPractice:
        return const PracticeContent(
          title: 'Light Practice',
          subtitle: 'Community Connection',
          description:
              'A master-led short practice focusing on community connection and awakening your inner light. Connect with practitioners worldwide as we share this moment of collective presence.',
          duration: '~10 min',
          masterName: 'Aurora Chen',
          masterBio:
              'Energy healer and meditation guide with 15+ years of experience in light work and community healing.',
          imageGradient: [Color(0xFFFFE4D6), Color(0xFFFCB29C)],
          highlights: ['Master-guided', 'Community sync', 'Downloadable'],
        );
      case PracticeType.guidedMeditation:
        return const PracticeContent(
          title: 'Guided Meditation',
          subtitle: 'Today\'s Theme',
          description:
              'Voice-guided meditation exploring inner landscapes. Each day brings a new theme—releasing tension, cultivating gratitude, or finding clarity.',
          theme: 'Releasing & Letting Go',
          aim: 'Release accumulated tension and mental clutter',
          outcome: 'Feel lighter, clearer, more present',
          duration: '~10 min',
          imageGradient: [Color(0xFFE8E0F0), Color(0xFFD4B8E8)],
          highlights: ['New daily', '2-day access', 'Downloadable'],
        );
      case PracticeType.soundMeditation:
        return const PracticeContent(
          title: 'Sound Meditation',
          subtitle: 'Cosmic Frequencies',
          description:
              'Immerse yourself in healing sound frequencies—cosmic tones, singing bowls, and binaural beats designed to shift your brainwave state and open deeper awareness.',
          theme: 'Earth Grounding Frequencies',
          duration: '5-30 min',
          hasCustomDuration: true,
          imageGradient: [Color(0xFFD6EAF0), Color(0xFF9ED4E8)],
          highlights: ['Choose duration', '2-day access', 'Downloadable'],
        );
      case PracticeType.myPractice:
        return const PracticeContent(
          title: 'My Practice',
          subtitle: 'Personal Journey',
          description:
              'Log your own practice—meditation, breathing, mantra, yoga, or any mindfulness activity. Track your journey and build your personal practice history.',
          duration: 'You set the time',
          hasCustomDuration: true,
          modalities: [
            'Meditation',
            'Breathing',
            'Mantra',
            'Sound Healing',
            'Yoga',
            'Other',
          ],
          imageGradient: [Color(0xFFD6F0E0), Color(0xFF8EDEC4)],
          highlights: ['Any modality', 'Journal entry', 'Track progress'],
        );
      case PracticeType.specialPractice:
        return const PracticeContent(
          title: 'Winter Solstice Ceremony',
          subtitle: 'Special Event',
          description:
              'Join a unique master-crafted practice tied to the cosmic rhythm of the solstice. Experience collective meditation as participants\' lights appear around you.',
          duration: '~10 min',
          masterName: 'Council of Light',
          masterBio:
              'A gathering of masters facilitating this sacred moment of planetary alignment.',
          eventTime: '12:12 & 22:22',
          imageGradient: [Color(0xFFF0E8D0), Color(0xFFE8D08C)],
          highlights: [
            'Timed event',
            'See other participants',
            'Master\'s Planet',
          ],
        );
    }
  }
}

/// Practice info sheet - user-facing content for each practice type
class PracticeInfoSheet extends StatelessWidget {
  final PracticeTypeGroup group;

  const PracticeInfoSheet({super.key, required this.group});

  PracticeContent get _content => PracticeContent.forType(group.type);

  Color _getTypeColor() {
    switch (group.type) {
      case PracticeType.lightPractice:
        return const Color(0xFFE88A6E);
      case PracticeType.guidedMeditation:
        return const Color(0xFFB08AD4);
      case PracticeType.soundMeditation:
        return const Color(0xFF5CBAD4);
      case PracticeType.myPractice:
        return const Color(0xFF4EBE96);
      case PracticeType.specialPractice:
        return const Color(0xFFD4A84E);
    }
  }

  PracticeEmotionProfile _getEmotionProfile() {
    switch (group.type) {
      case PracticeType.lightPractice:
        return PracticeEmotionProfile.lightPractice;
      case PracticeType.guidedMeditation:
        return PracticeEmotionProfile.guidedMeditation;
      case PracticeType.soundMeditation:
        return PracticeEmotionProfile.soundMeditation;
      case PracticeType.myPractice:
        return PracticeEmotionProfile.myPractice;
      case PracticeType.specialPractice:
        return PracticeEmotionProfile.specialPractice;
    }
  }

  Widget _buildInfoParagraph(String label, String value) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.urbanist(
          fontSize: 14,
          color: Colors.black54,
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image mock
                  Container(
                    height: 180,
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: content.imageGradient,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: AbstractPatternPainter(
                              color: Colors.white.withValues(alpha: 0.3),
                              type: group.type,
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                group.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Image',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Duration badge at top - important info
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor().withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 16,
                                    color: _getTypeColor(),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    content.duration,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _getTypeColor(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (content.hasCustomDuration) ...[
                              const SizedBox(width: 8),
                              Text(
                                'You choose',
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          content.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Full description text
                        Text(
                          content.description,
                          style: GoogleFonts.urbanist(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.7,
                          ),
                        ),

                        // Theme/Aim/Outcome as flowing text if available
                        if (content.theme != null || content.aim != null || content.outcome != null) ...[
                          const SizedBox(height: 20),
                          if (content.theme != null) ...[
                            _buildInfoParagraph('Theme', content.theme!),
                            const SizedBox(height: 12),
                          ],
                          if (content.aim != null) ...[
                            _buildInfoParagraph('Aim', content.aim!),
                            const SizedBox(height: 12),
                          ],
                          if (content.outcome != null)
                            _buildInfoParagraph('Outcome', content.outcome!),
                        ],

                        if (content.eventTime != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8F0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getTypeColor().withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 18,
                                  color: _getTypeColor(),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Available at ${content.eventTime}',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getTypeColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Emotional Profile - what feelings this practice evokes
                        Text(
                          'What You May Feel',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Common emotional responses from this practice',
                          style: GoogleFonts.urbanist(
                            fontSize: 13,
                            color: Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: RadialEmotionChart(
                            profile: _getEmotionProfile(),
                            size: 260,
                            accentColor: _getTypeColor(),
                          ),
                        ),

                        if (content.modalities != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Modalities',
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: content.modalities!
                                .map(
                                  (m) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      m,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],

                        if (content.masterName != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: content.imageGradient,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        content.masterName!,
                                        style: GoogleFonts.urbanist(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        content.masterBio ?? '',
                                        style: GoogleFonts.urbanist(
                                          fontSize: 12,
                                          color: Colors.black45,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B2B3C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              'Got it',
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Saved practice info sheet
class SavedInfoSheet extends StatelessWidget {
  final SavedPractice saved;

  const SavedInfoSheet({super.key, required this.saved});

  Color get _typeColor {
    switch (saved.practice.type) {
      case PracticeType.lightPractice:
        return const Color(0xFFE88A6E);
      case PracticeType.guidedMeditation:
        return const Color(0xFFB08AD4);
      case PracticeType.soundMeditation:
        return const Color(0xFF5CBAD4);
      case PracticeType.myPractice:
        return const Color(0xFF4EBE96);
      case PracticeType.specialPractice:
        return const Color(0xFFD4A84E);
    }
  }

  PracticeEmotionProfile get _emotionProfile {
    switch (saved.practice.type) {
      case PracticeType.lightPractice:
        return PracticeEmotionProfile.lightPractice;
      case PracticeType.guidedMeditation:
        return PracticeEmotionProfile.guidedMeditation;
      case PracticeType.soundMeditation:
        return PracticeEmotionProfile.soundMeditation;
      case PracticeType.myPractice:
        return PracticeEmotionProfile.myPractice;
      case PracticeType.specialPractice:
        return PracticeEmotionProfile.specialPractice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                saved.practice.getName(),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              if (saved.note != null) ...[
                Text(
                  saved.note!,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: _typeColor),
                  const SizedBox(width: 8),
                  Text(
                    '${saved.duration.inMinutes} minutes',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Emotion radial chart
              const SizedBox(height: 8),
              Text(
                'What You May Feel',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: RadialEmotionChart(
                  profile: _emotionProfile,
                  size: 200,
                  accentColor: _typeColor,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2B3C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Got it',
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Info row widget
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? trailing;
  final bool highlight;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: highlight ? const Color(0xFFE88A6E) : Colors.black38,
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black45),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: highlight ? const Color(0xFFE88A6E) : Colors.black87,
            ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              trailing!,
              style: GoogleFonts.urbanist(fontSize: 11, color: Colors.black54),
            ),
          ),
      ],
    );
  }
}

/// Small chip widget
class InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const InfoChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.urbanist(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Abstract pattern painter for image backgrounds
class AbstractPatternPainter extends CustomPainter {
  final Color color;
  final PracticeType type;

  AbstractPatternPainter({required this.color, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    switch (type) {
      case PracticeType.lightPractice:
        for (int i = 1; i <= 4; i++) {
          canvas.drawCircle(
            Offset(size.width * 0.5, size.height * 0.5),
            30.0 * i,
            paint,
          );
        }
        break;
      case PracticeType.guidedMeditation:
        final path = Path();
        for (int i = 0; i < 4; i++) {
          path.moveTo(0, size.height * (0.3 + i * 0.15));
          for (double x = 0; x <= size.width; x += 20) {
            path.lineTo(
              x,
              size.height * (0.3 + i * 0.15) + 15 * math.sin(x * 0.05 + i),
            );
          }
        }
        canvas.drawPath(path, paint);
        break;
      case PracticeType.soundMeditation:
        for (int i = 0; i < 8; i++) {
          final x = size.width * (0.15 + i * 0.1);
          final h = 20.0 + (i % 3) * 20;
          canvas.drawLine(
            Offset(x, size.height * 0.5 - h),
            Offset(x, size.height * 0.5 + h),
            paint,
          );
        }
        break;
      case PracticeType.myPractice:
        for (int i = 0; i < 12; i++) {
          canvas.drawCircle(
            Offset(
              size.width * (0.2 + (i % 4) * 0.2),
              size.height * (0.25 + (i ~/ 4) * 0.25),
            ),
            6,
            paint..style = PaintingStyle.fill,
          );
        }
        break;
      case PracticeType.specialPractice:
        final center = Offset(size.width * 0.5, size.height * 0.5);
        for (int i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          canvas.drawLine(
            center,
            Offset(
              center.dx + 60 * math.cos(angle),
              center.dy + 60 * math.sin(angle),
            ),
            paint,
          );
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

