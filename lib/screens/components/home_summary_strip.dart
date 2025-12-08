part of 'package:awa_01_spark/screens/home_screen.dart';

class HomeMiniSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color accent;

  const HomeMiniSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF13131D),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: accent.withOpacity(0.9),
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatLightUsers(int count) {
  if (count >= 1000) {
    final double thousands = count / 1000;
    return '${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1)}k';
  }
  return '$count';
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF13131D),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: _lilacMist,
                  fontSize: 11,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showPulseDrawer(BuildContext context, int pulsePercent) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => _SummaryDrawer(
      title: 'AWA Pulse',
      description:
          'Pulse shows the percentage of the community that has left light on the globe today. Keep it above 70% by completing practices and inviting others.',
      metric: '$pulsePercent% active',
      accent: _lilacMist,
    ),
  );
}

void showLightUsersDrawer(BuildContext context, int users) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => _SummaryDrawer(
      title: 'Light carriers',
      description:
          'This is the live count of members who completed a ritual today. When the number dips, AWA Soul gently nudges the circle to add more light.',
      metric: '${formatLightUsers(users)} souls glowing',
      accent: _emberPeach,
    ),
  );
}

class _SummaryDrawer extends StatelessWidget {
  final String title;
  final String description;
  final String metric;
  final Color accent;

  const _SummaryDrawer({
    required this.title,
    required this.description,
    required this.metric,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _spaceBlack,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              metric,
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: Colors.black.withOpacity(0.75), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
