import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/home_colors.dart';

const Color _ink = Color(0xFF2B2B3C);

/// Explains the friend invite reward and provides share/copy actions.
class InviteFriendScreen extends StatelessWidget {
  final String shareLink;
  final String? inviteCode;
  final int rewardYou;
  final int rewardFriend;

  const InviteFriendScreen({
    super.key,
    required this.shareLink,
    required this.rewardYou,
    required this.rewardFriend,
    this.inviteCode,
  });

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: shareLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied. Share with a friend to earn Lumens.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: shareLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share sheet coming soon. Link copied for now.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.space,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              _RewardCard(
                rewardYou: rewardYou,
                rewardFriend: rewardFriend,
              ),
              const SizedBox(height: 18),
              _buildDetails(),
              const SizedBox(height: 18),
              _buildLinkCard(context),
              const SizedBox(height: 14),
              _buildActions(context),
              if (inviteCode != null) ...[
                const SizedBox(height: 16),
                _buildCodeRow(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white70),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite a friend',
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            Text(
              'Both of you collect Lumens on their first practice.',
              style: GoogleFonts.urbanist(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetails() {
    final List<_DetailItem> items = [
      _DetailItem(
        icon: Icons.bolt,
        title: 'Immediate boost',
        description:
            'We drop +$rewardYou Lumens to your balance when your friend completes their first session.',
      ),
      _DetailItem(
        icon: Icons.favorite_outline,
        title: 'Your friend gains',
        description: 'They start with +$rewardFriend Lumens and unlock their first download.',
      ),
      const _DetailItem(
        icon: Icons.shield_moon_outlined,
        title: 'Safe invite link',
        description: 'No phone contacts needed. Share via DM, chat, or QR when available.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DetailRow(item: item),
              )),
        ],
      ),
    );
  }

  Widget _buildLinkCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.link, color: _ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              shareLink,
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _copyLink(context),
            icon: const Icon(Icons.copy, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => _shareLink(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [HomeColors.peach, HomeColors.rose],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33FCB29C),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.ios_share, color: _ink),
                const SizedBox(width: 10),
                Text(
                  'Share invite link',
                  style: GoogleFonts.urbanist(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _copyLink(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            'Copy link',
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_2, color: Colors.white70),
          const SizedBox(width: 10),
          Text(
            'Code',
            style: GoogleFonts.urbanist(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              inviteCode!,
              style: GoogleFonts.urbanist(
                color: _ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Drop in the app when QR is live',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final int rewardYou;
  final int rewardFriend;

  const _RewardCard({
    required this.rewardYou,
    required this.rewardFriend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF131320), Color(0xFF1E1E30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [HomeColors.peach, HomeColors.rose],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.group_work_outlined, color: _ink, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+$rewardYou for you',
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+$rewardFriend for your friend',
                  style: GoogleFonts.urbanist(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rewards drop after their first completed practice.',
                  style: GoogleFonts.urbanist(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String title;
  final String description;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _DetailRow extends StatelessWidget {
  final _DetailItem item;

  const _DetailRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(item.icon, color: Colors.white70),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: GoogleFonts.urbanist(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
