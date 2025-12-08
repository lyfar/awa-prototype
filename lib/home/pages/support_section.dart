import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/home_colors.dart';

class SupportSection extends StatefulWidget {
  final ValueChanged<SupportSubmission> onSubmit;

  const SupportSection({super.key, required this.onSubmit});

  @override
  State<SupportSection> createState() => _SupportSectionState();
}

class _SupportSectionState extends State<SupportSection> {
  final _contactController = TextEditingController();
  final _featureController = TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support & ideas',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2B2B3C),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Send an issue or suggest the next feature. No gating—everyone can reach the crew.',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _SupportCard(
                title: 'Contact us',
                subtitle: 'Bug, billing, or account help.',
                controller: _contactController,
                hint: 'Describe the issue...',
                icon: Icons.support_agent,
                accent: HomeColors.peach,
                onSubmit: _submitContact,
              ),
              const SizedBox(height: 16),
              _SupportCard(
                title: 'Suggest a feature',
                subtitle: 'Tell us what would make practice better.',
                controller: _featureController,
                hint: 'Request, idea, or workflow...',
                icon: Icons.lightbulb_outline,
                accent: HomeColors.lavender,
                onSubmit: _submitFeature,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitContact() {
    final text = _contactController.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(
      SupportSubmission(type: SupportType.contact, message: text),
    );
    _contactController.clear();
    _showSnack('Thanks — we’ll respond soon.');
  }

  void _submitFeature() {
    final text = _featureController.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(
      SupportSubmission(type: SupportType.feature, message: text),
    );
    _featureController.clear();
    _showSnack('Idea saved. +10 Lumens coming your way.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color accent;
  final VoidCallback onSubmit;

  const _SupportCard({
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.accent,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeColors.cream),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.15),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF2B2B3C),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.black.withOpacity(0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: accent, width: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum SupportType { contact, feature }

class SupportSubmission {
  final SupportType type;
  final String message;

  SupportSubmission({required this.type, required this.message});
}
