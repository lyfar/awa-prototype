import 'package:flutter/material.dart';

import '../home/models/announcement_story.dart';
import '../home/models/home_section.dart';
import '../home/theme/home_colors.dart';

typedef StoryAction = void Function();

List<AnnouncementStory> buildHomeStories({
  required StoryAction onMissionCta,
  required StoryAction onPracticeCta,
  required StoryAction onMasterCta,
  required StoryAction onUpdateCta,
  required StoryAction onFeedbackCta,
}) {
  return [
    AnnouncementStory(
      id: 'story_mission_01',
      title: 'Golden Manuscript',
      caption: 'AWA Soul whispers',
      body:
          'Alexandria folios just surfaced. Help digitize the scorched pages and keep their astronomy alive.',
      ctaLabel: 'Support mission',
      type: AnnouncementType.mission,
      gradient: const LinearGradient(
        colors: [HomeColors.cream, HomeColors.peach],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onCta: onMissionCta,
    ),
    AnnouncementStory(
      id: 'story_masters_01',
      title: 'Dawn Collective Awaits',
      caption: 'Live master call',
      body:
          'T-15 minutes until the Dawn collective lights up. Reserve your flame if you feel called.',
      ctaLabel: 'View masters',
      type: AnnouncementType.master,
      gradient: const LinearGradient(
        colors: [HomeColors.rose, HomeColors.lavender],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onCta: onMasterCta,
    ),
    AnnouncementStory(
      id: 'story_practice_01',
      title: 'Saffron Dawn',
      caption: 'New practice drops',
      body:
          'A 15-min sunrise ritual blending breath, sound, and sun geometry. Try it when ready.',
      ctaLabel: 'Begin practice',
      type: AnnouncementType.practice,
      gradient: const LinearGradient(
        colors: [HomeColors.coral, HomeColors.clay],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onCta: onPracticeCta,
    ),
    AnnouncementStory(
      id: 'story_update_01',
      title: 'App update 1.2',
      caption: 'New build live',
      body:
          'Fresh masters tab, favourite picks, and push toggles just landed. Update to explore the full Lobby.',
      ctaLabel: 'See what’s new',
      type: AnnouncementType.update,
      gradient: const LinearGradient(
        colors: [HomeColors.eclipse, HomeColors.lavender],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onCta: onUpdateCta,
    ),
    AnnouncementStory(
      id: 'story_feedback_earn',
      title: 'Feedback = Lumens',
      caption: 'Help us grow',
      body:
          'Share your favorite ritual ideas or UI tweaks and we’ll gift +10 Lumens for each meaningful suggestion.',
      ctaLabel: 'Send feedback',
      type: AnnouncementType.feedback,
      gradient: const LinearGradient(
        colors: [HomeColors.rose, HomeColors.peach],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onCta: onFeedbackCta,
    ),
  ];
}
