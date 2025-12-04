import 'package:flutter/material.dart';

class UnitsActionSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<UnitActionItem> actions;
  final ScrollController? controller;

  const UnitsActionSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.actions,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom + 12;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        controller: controller,
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: actions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = actions[index];
                return _ActionTile(
                  item: item,
                  accentColor: accentColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UnitActionItem {
  final IconData icon;
  final String title;
  final String description;
  final String? valueLabel;
  final String? badgeLabel;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const UnitActionItem({
    required this.icon,
    required this.title,
    required this.description,
    this.valueLabel,
    this.badgeLabel,
    this.badgeColor,
    this.onTap,
  });
}

class _ActionTile extends StatelessWidget {
  final UnitActionItem item;
  final Color accentColor;

  const _ActionTile({
    required this.item,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.2),
              ),
              child: Icon(item.icon, color: accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (item.badgeLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: item.badgeColor ?? Colors.white24,
                          ),
                          child: Text(
                            item.badgeLabel!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  if (item.valueLabel != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.valueLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
