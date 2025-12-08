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
  SupportTab _activeView = SupportTab.about;
  bool _showingDetail = false;

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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Navigate to our policies or drop a note. No gating—everyone can reach the crew.',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _showingDetail
                    ? _buildDetailView()
                    : _buildMenuView(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuView(BuildContext context) {
    return ListView(
      key: const ValueKey('support_menu'),
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        _SupportMenuTile(
          icon: Icons.info_outline,
          label: 'About us',
          selected: false,
          onTap: () => _openDetail(SupportTab.about),
        ),
        _SupportMenuTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy policy',
          selected: false,
          onTap: () => _openDetail(SupportTab.privacy),
        ),
        _SupportMenuTile(
          icon: Icons.description_outlined,
          label: 'Terms & conditions',
          selected: false,
          onTap: () => _openDetail(SupportTab.terms),
        ),
        _SupportMenuTile(
          icon: Icons.support_agent,
          label: 'Contact us',
          selected: false,
          onTap: () => _openDetail(SupportTab.contact),
        ),
        _SupportMenuTile(
          icon: Icons.lightbulb_outline,
          label: 'Suggest a feature',
          selected: false,
          onTap: () => _openDetail(SupportTab.feature),
        ),
      ],
    );
  }

  Widget _buildDetailView() {
    return Column(
      key: const ValueKey('support_detail'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showingDetail = false),
              ),
              const SizedBox(width: 4),
              Text(
                _titleForTab(_activeView),
                style: GoogleFonts.urbanist(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2B2B3C),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            child: _SupportContentPane(
              tab: _activeView,
              contactController: _contactController,
              featureController: _featureController,
              onSubmit: widget.onSubmit,
              showSnack: _showSnack,
            ),
          ),
        ),
      ],
    );
  }

  String _titleForTab(SupportTab tab) {
    switch (tab) {
      case SupportTab.about:
        return 'About us';
      case SupportTab.privacy:
        return 'Privacy policy';
      case SupportTab.terms:
        return 'Terms & conditions';
      case SupportTab.contact:
        return 'Contact us';
      case SupportTab.feature:
        return 'Suggest a feature';
    }
  }

  void _openDetail(SupportTab tab) {
    setState(() {
      _activeView = tab;
      _showingDetail = true;
    });
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

class _SupportMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const _SupportMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? HomeColors.peach.withOpacity(0.5)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: HomeColors.cream,
              child: Icon(icon, color: const Color(0xFF2B2B3C)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: const Color(0xFF2B2B3C),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: selected ? HomeColors.peach : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportContentPane extends StatelessWidget {
  final SupportTab tab;
  final TextEditingController contactController;
  final TextEditingController featureController;
  final ValueChanged<SupportSubmission> onSubmit;
  final void Function(String message) showSnack;

  const _SupportContentPane({
    required this.tab,
    required this.contactController,
    required this.featureController,
    required this.onSubmit,
    required this.showSnack,
  });

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case SupportTab.about:
        return const _SupportStaticCard(
          title: 'About AwaTerra',
          paragraphs: [
            'AwaTerra is a collective of practitioners, engineers, and guides building rituals that protect your attention and celebrate the planet.',
            'We prototype fast, listen to the community, and keep the globe lit with live circles.',
          ],
        );
      case SupportTab.privacy:
        return const _SupportStaticCard(
          title: 'Privacy Policy',
          paragraphs: [
            'We respect your data. Session metadata stays on-device unless you opt into sharing for insights.',
            'Contact details are only used to respond to your requests. We never sell personal data.',
          ],
        );
      case SupportTab.terms:
        return const _SupportStaticCard(
          title: 'Terms & Conditions',
          paragraphs: [
            'This prototype is for exploration only. Practices are not medical advice.',
            'By continuing, you agree to respectful conduct in live circles and to our community standards.',
          ],
        );
      case SupportTab.contact:
        return _SupportFormCard(
          title: 'Contact us',
          subtitle: 'Bug, billing, or account help.',
          controller: contactController,
          hint: 'Describe the issue...',
          accent: HomeColors.peach,
          icon: Icons.support_agent,
          onSubmit: () {
            final text = contactController.text.trim();
            if (text.isEmpty) return;
            onSubmit(SupportSubmission(type: SupportType.contact, message: text));
            contactController.clear();
            showSnack('Thanks — we’ll respond soon.');
          },
        );
      case SupportTab.feature:
        return _SupportFormCard(
          title: 'Suggest a feature',
          subtitle: 'Tell us what would make practice better.',
          controller: featureController,
          hint: 'Request, idea, or workflow...',
          accent: HomeColors.lavender,
          icon: Icons.lightbulb_outline,
          onSubmit: () {
            final text = featureController.text.trim();
            if (text.isEmpty) return;
            onSubmit(SupportSubmission(type: SupportType.feature, message: text));
            featureController.clear();
            showSnack('Idea saved. +10 Lumens coming your way.');
          },
        );
    }
  }
}

class _SupportStaticCard extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const _SupportStaticCard({required this.title, required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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

class _SupportFormCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final String hint;
  final Color accent;
  final IconData icon;
  final VoidCallback onSubmit;

  const _SupportFormCard({
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.hint,
    required this.accent,
    required this.icon,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accent.withOpacity(0.15),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2B2B3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.urbanist(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 4,
              maxLines: 6,
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
