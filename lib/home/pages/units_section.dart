import 'package:flutter/material.dart';

import '../theme/home_colors.dart';

const Color _ink = Color(0xFF2B2B3C);
const Color _muted = Color(0xFF6E6677);

class UnitsSection extends StatelessWidget {
  final int balance;
  final int earnedThisWeek;
  final int spentThisWeek;
  final List<UnitTransaction> history;
  final VoidCallback onEarnUnits;
  final VoidCallback onSpendUnits;

  const UnitsSection({
    super.key,
    required this.balance,
    required this.earnedThisWeek,
    required this.spentThisWeek,
    required this.history,
    required this.onEarnUnits,
    required this.onSpendUnits,
  });

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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lumens',
              style: TextStyle(
                color: _ink,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Balance • $balance Lumens',
              style: TextStyle(
                color: _muted,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            _buildBalanceCard(),
            const SizedBox(height: 24),
            _buildActionRow(),
            const SizedBox(height: 24),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: HomeColors.cream,
        border: Border.all(color: HomeColors.rose.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          _buildDeltaColumn('Earned this week', earnedThisWeek, Colors.greenAccent),
          const SizedBox(width: 24),
          Container(
            width: 1,
            height: 60,
            color: Colors.black12,
          ),
          const SizedBox(width: 24),
          _buildDeltaColumn('Spent this week', -spentThisWeek, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildDeltaColumn(String title, int amount, Color color) {
    final sign = amount >= 0 ? '+' : '-';
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$sign${amount.abs()} Lumens',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: _UnitsActionCard(
            title: 'Earn Lumens',
            description: 'Complete special practices, share with friends, or join missions.',
            accentColor: HomeColors.peach,
            icon: Icons.arrow_circle_up,
            onTap: onEarnUnits,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _UnitsActionCard(
            title: 'Spend Lumens',
            description: 'Support masters, keep AWAWAY streaks, unlock downloads.',
            accentColor: HomeColors.lavender,
            icon: Icons.loyalty,
            onTap: onSpendUnits,
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(color: HomeColors.cream),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            final entry = history[index];
            final positive = entry.amount >= 0;
            return Row(
              children: [
                Icon(
                  entry.icon,
                  color: positive ? Colors.greenAccent : Colors.orangeAccent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.description,
                        style: TextStyle(color: _muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${positive ? '+' : '-'}${entry.amount.abs()} Lumens',
                  style: TextStyle(
                    color: positive ? Colors.greenAccent : Colors.orangeAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (_, __) => const Divider(color: Color(0xFFE3E1EA)),
          itemCount: history.length,
        ),
      ),
    );
  }
}

class _UnitsActionCard extends StatelessWidget {
  final String title;
  final String description;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;

  const _UnitsActionCard({
    required this.title,
    required this.description,
    required this.accentColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(color: accentColor.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 30),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                color: _muted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tap to explore',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.arrow_outward, color: accentColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UnitTransaction {
  final String title;
  final String description;
  final int amount;
  final IconData icon;

  UnitTransaction({
    required this.title,
    required this.description,
    required this.amount,
    required this.icon,
  });
}
