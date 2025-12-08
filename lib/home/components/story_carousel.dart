import 'package:flutter/material.dart';

import '../models/announcement_story.dart';

class StoryCarousel extends StatelessWidget {
  final List<AnnouncementStory> stories;
  final ValueChanged<AnnouncementStory> onStorySelected;
  final double bubbleSize;
  final bool showLabels;
  final bool overlap;

  const StoryCarousel({
    super.key,
    required this.stories,
    required this.onStorySelected,
    this.bubbleSize = 68,
    this.showLabels = true,
    this.overlap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }
    if (overlap) {
      final double spacing = bubbleSize * 0.6;
      final double totalWidth = bubbleSize + (stories.length - 1) * spacing;
      return SizedBox(
        height: bubbleSize,
        child: Center(
          child: SizedBox(
            width: totalWidth,
            height: bubbleSize,
            child: Stack(
              children: [
                for (int i = 0; i < stories.length; i++)
                  Positioned(
                    left: i * spacing,
                    child: _StoryBubble(
                      story: stories[i],
                      onTap: () => onStorySelected(stories[i]),
                      size: bubbleSize,
                      showLabel: false,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: bubbleSize + (showLabels ? 24 : 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          final story = stories[index];
          return _StoryBubble(
            story: story,
            onTap: () => onStorySelected(story),
            size: bubbleSize,
            showLabel: showLabels,
          );
        },
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final AnnouncementStory story;
  final VoidCallback onTap;
  final double size;
  final bool showLabel;

  const _StoryBubble({
    required this.story,
    required this.onTap,
    required this.size,
    required this.showLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: story.isNew
                      ? story.gradient
                      : const LinearGradient(
                          colors: [Colors.black12, Colors.black26],
                        ),
                  border: Border.all(
                    color: story.isNew ? Colors.white : Colors.black12,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _iconForType(story.type),
                    color: story.isNew ? Colors.white : Colors.white70,
                    size: size * 0.35,
                  ),
                ),
              ),
            ],
          ),
          if (showLabel) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: size + 2,
              child: Text(
                story.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForType(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.mission:
        return Icons.menu_book_rounded;
      case AnnouncementType.master:
        return Icons.auto_awesome;
      case AnnouncementType.practice:
        return Icons.self_improvement;
      case AnnouncementType.update:
        return Icons.system_update_alt_rounded;
      case AnnouncementType.feedback:
        return Icons.chat_outlined;
      case AnnouncementType.urgent:
        return Icons.warning_amber_rounded;
    }
  }
}
