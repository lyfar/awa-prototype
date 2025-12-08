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
  SupportTab _activeTab = SupportTab.about;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Support & ideas',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2B2B3C),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Navigate to our policies or drop a note. No gating—everyone can reach the crew.',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SupportTabs(
              active: _activeTab,
              onChanged: (tab) => setState(() => _activeTab = tab),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  24 + MediaQuery.of(context).padding.bottom,
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_activeTab) {
      case SupportTab.about:
        return const _StaticPage(
          title: 'About AwaTerra',
          paragraphs: [
            'AwaTerra is a collective of practitioners, engineers, and guides building rituals that protect your attention and celebrate the planet.',
            'We prototype fast, listen to the community, and keep the globe lit with live circles.',
          ],
        );
      case SupportTab.privacy:
        return const _StaticPage(
          title: 'Privacy Policy',
          paragraphs: [
            'We respect your data. Session metadata stays on-device unless you opt into sharing for insights.',
            'Contact details are only used to respond to your requests. We never sell personal data.',
          ],
        );
      case SupportTab.terms:
        return const _StaticPage(
          title: 'Terms & Conditions',
          paragraphs: [
            'This prototype is for exploration only. Practices are not medical advice.',
            'By continuing, you agree to respectful conduct in live circles and to our community standards.',
          ],
        );
      case SupportTab.contact:
        return _SupportCard(
          title: 'Contact us',
          subtitle: 'Bug, billing, or account help.',
          controller: _contactController,
          hint: 'Describe the issue...',
          icon: Icons.support_agent,
          accent: HomeColors.peach,
          onSubmit: _submitContact,
        );
      case SupportTab.feature:
        return _SupportCard(
          title: 'Suggest a feature',
          subtitle: 'Tell us what would make practice better.',
          controller: _featureController,
          hint: 'Request, idea, or workflow...',
          icon: Icons.lightbulb_outline,
          accent: HomeColors.lavender,
          onSubmit: _submitFeature,
        );
    }
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

class _SupportTabs extends StatelessWidget {
  final SupportTab active;
  final ValueChanged<SupportTab> onChanged;

  const _SupportTabs({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _SupportMenuItem(
        tab: SupportTab.about,
        label: 'About us',
        icon: Icons.info_outline,
      ),
      _SupportMenuItem(
        tab: SupportTab.privacy,
        label: 'Privacy policy',
        icon: Icons.privacy_tip_outlined,
      ),
      _SupportMenuItem(
        tab: SupportTab.terms,
        label: 'Terms & conditions',
        icon: Icons.description_outlined,
      ),
      _SupportMenuItem(
        tab: SupportTab.contact,
        label: 'Contact us',
        icon: Icons.support_agent,
      ),
      _SupportMenuItem(
        tab: SupportTab.feature,
        label: 'Suggest a feature',
        icon: Icons.lightbulb_outline,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: tabs.map((item) {
          final selected = item.tab == active;
          return Card(
            color: Colors.white,
            elevation: selected ? 3 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: selected
                    ? HomeColors.peach.withOpacity(0.6)
                    : Colors.black.withOpacity(0.06),
              ),
            ),
            child: ListTile(
              onTap: () => onChanged(item.tab),
              leading: CircleAvatar(
                backgroundColor: HomeColors.cream,
                child: Icon(item.icon, color: const Color(0xFF2B2B3C)),
              ),
              title: Text(
                item.label,
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2B2B3C),
                ),
              ),
              trailing: Icon(
                selected ? Icons.radio_button_checked : Icons.chevron_right,
                color: selected ? HomeColors.peach : Colors.black45,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SupportMenuItem {
  final SupportTab tab;
  final String label;
  final IconData icon;

  _SupportMenuItem({
    required this.tab,
    required this.label,
    required this.icon,
  });
}

class _StaticPage extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const _StaticPage({required this.title, required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2B2B3C),
              ),
            ),
            const SizedBox(height: 10),
            ...paragraphs.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  p,
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum SupportType { contact, feature }

enum SupportTab { about, privacy, terms, contact, feature }

class SupportSubmission {
  final SupportType type;
  final String message;

  SupportSubmission({required this.type, required this.message});
}
