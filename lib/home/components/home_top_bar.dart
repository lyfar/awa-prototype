import 'package:flutter/material.dart';

import '../theme/home_colors.dart';
import '../models/announcement_story.dart';
import 'story_carousel.dart';

const Color _ink = Color(0xFF2B2B3C);

class HomeTopBar extends StatelessWidget {
  final bool isMenuOpen;
  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;
  final List<AnnouncementStory> stories;
  final ValueChanged<AnnouncementStory> onStorySelected;

  const HomeTopBar({
    super.key,
    required this.isMenuOpen,
    required this.onMenuTap,
    required this.onProfileTap,
    required this.stories,
    required this.onStorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HamburgerButton(
          isOpen: isMenuOpen,
          onTap: onMenuTap,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: StoryCarousel(
            stories: stories,
            onStorySelected: onStorySelected,
            bubbleSize: 36,
            showLabels: false,
            overlap: true,
          ),
        ),
        const SizedBox(width: 14),
        _ProfileButton(onTap: onProfileTap),
      ],
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onTap;

  const _HamburgerButton({
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isOpen ? HomeColors.cream : Colors.white,
          border: Border.all(
            color: isOpen ? HomeColors.peach : Colors.black12,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isOpen ? Icons.close : Icons.menu,
            key: ValueKey(isOpen),
            color: _ink,
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 2),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.person_outline,
                color: _ink,
                size: 22,
              ),
            ),
            Positioned(
              right: 8,
              bottom: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: HomeColors.peach,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
