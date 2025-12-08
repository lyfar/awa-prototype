import 'package:flutter/material.dart';

import '../models/announcement_story.dart';
import '../theme/home_colors.dart';
import '../../soul/awa_sphere.dart';

const LinearGradient _sphereOverlay = LinearGradient(
  colors: [Colors.transparent, Color(0xAAFFFFFF)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

class AnnouncementStoryViewer extends StatefulWidget {
  final List<AnnouncementStory> stories;
  final int initialIndex;

  const AnnouncementStoryViewer({super.key, required this.stories, required this.initialIndex});

  @override
  State<AnnouncementStoryViewer> createState() => _AnnouncementStoryViewerState();
}

class _AnnouncementStoryViewerState extends State<AnnouncementStoryViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final stories = widget.stories;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(
                        stories.length,
                        (index) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 4,
                            decoration: BoxDecoration(
                              color: index <= _currentIndex
                                  ? HomeColors.peach
                                  : Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: stories.length,
                itemBuilder: (_, index) {
                  final story = stories[index];
                  return _StorySlide(
                    story: story,
                    onAction: () {
                      Navigator.of(context).pop();
                      story.onCta?.call();
                    },
                    onSecondaryAction: story.secondaryCtaLabel == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            story.onSecondaryCta?.call();
                          },
                    onNext: index == stories.length - 1
                        ? null
                        : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorySlide extends StatelessWidget {
  final AnnouncementStory story;
  final VoidCallback onAction;
  final VoidCallback? onSecondaryAction;
  final VoidCallback? onNext;

  const _StorySlide({
    required this.story,
    required this.onAction,
    this.onSecondaryAction,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heroHeight = (size.height * 0.5).clamp(320.0, 420.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          SizedBox(
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AwaSphereHeader(
                  height: heroHeight,
                  halfScreen: true,
                  interactive: false,
                  energy: 0.08,
                  primaryColor: HomeColors.peach,
                  secondaryColor: HomeColors.lavender,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _sphereOverlay,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Text(
                    story.caption,
                    style: const TextStyle(color: Color(0xFF7B7483), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    story.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF2B2B3C),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    story.body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF7B7483),
                      height: 1.4,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPrimaryCta(),
          if (story.secondaryCtaLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 10),
            _buildSecondaryCta(),
          ],
          if (onNext != null)
            TextButton(
              onPressed: onNext,
              child: const Text('Next story'),
            ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCta() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onAction,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor:
              story.type == AnnouncementType.urgent ? Colors.black : HomeColors.peach,
          foregroundColor:
              story.type == AnnouncementType.urgent ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(
          story.ctaLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSecondaryCta() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onSecondaryAction,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: story.type == AnnouncementType.urgent
                ? Colors.black.withOpacity(0.65)
                : Colors.black.withOpacity(0.25),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Text(
          story.secondaryCtaLabel ?? '',
          style: TextStyle(
            color: story.type == AnnouncementType.urgent ? Colors.black : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
