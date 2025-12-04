import 'package:flutter/material.dart';

import '../models/faq_item.dart';
import '../theme/home_colors.dart';

const Color _ink = Color(0xFF1F1F2B);
const Color _muted = Color(0xFF6E6677);

class FaqSection extends StatelessWidget {
  final List<FaqItem> items;
  final VoidCallback onContact;

  const FaqSection({
    super.key,
    required this.items,
    required this.onContact,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FAQ & rituals support',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Answers to the most common questions about practices, masters, and missions.',
                  style: TextStyle(color: _muted),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final entry = items[index];
                return _FaqTile(item: entry);
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: items.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: ElevatedButton.icon(
              onPressed: onContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeColors.lavender,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text(
                'Contact support',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final FaqItem item;

  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white,
        border: Border.all(
          color: _isExpanded ? HomeColors.peach : Colors.black12,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: HomeColors.cream,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.item.icon, color: HomeColors.eclipse),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.category.toUpperCase(),
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.question,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(
                  _isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                  color: HomeColors.peach,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                widget.item.answer,
                style: const TextStyle(
                  color: _ink,
                  height: 1.4,
                ),
              ),
            ),
            crossFadeState:
                _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}
