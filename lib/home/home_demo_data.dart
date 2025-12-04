import 'package:flutter/material.dart';

import '../home/theme/home_colors.dart';
import '../home/pages/awaway_section.dart';
import '../home/pages/history_reactions_section.dart';
import '../home/pages/units_section.dart';
import '../missions/mission_models.dart';
import '../models/master_guide.dart';
import '../models/meditation_models.dart';
import '../models/saved_practice.dart';
import '../home/models/faq_item.dart';

class HomeDemoData {
  static const Map<PracticeType, List<String>> practiceScripts = {
    PracticeType.lightPractice: [
      'Invite the master’s lantern to mirror your breath.',
      'Sense how the shared light expands outward.',
      'Seal the ritual by offering thanks to the circle.',
    ],
    PracticeType.guidedMeditation: [
      'Follow the narrator’s cadence with soft inhales.',
      'Let today’s theme settle like dew across your chest.',
      'Return gently when the closing bell arrives.',
    ],
    PracticeType.soundMeditation: [
      'Listen for the lowest tone anchoring your spine.',
      'Ride the waves of sound out into the field.',
      'Exhale with a long hum to harmonize the final chord.',
    ],
    PracticeType.myPractice: [
      'Name your modality silently to begin.',
      'Keep attention with the timer and stay honest.',
      'Log any insights so your history remembers.',
    ],
    PracticeType.specialPractice: [
      'Arrive early; notice the countdown soften.',
      'When the master speaks, let the event wash over you.',
      'Close with gratitude for being present in this window.',
    ],
  };

  static const Map<PracticeType, List<Duration>> durationOptions = {
    PracticeType.lightPractice: [Duration(minutes: 10)],
    PracticeType.guidedMeditation: [Duration(minutes: 10)],
    PracticeType.soundMeditation: [
      Duration(minutes: 10),
      Duration(minutes: 20),
      Duration(minutes: 30),
    ],
    PracticeType.myPractice: [Duration(minutes: 20)],
    PracticeType.specialPractice: [Duration(minutes: 10)],
  };

  static final List<SavedPractice> savedPractices = [
    SavedPractice(
      id: 'saved_guided_evening',
      practice: _practiceById('guided_meditation_day1'),
      duration: const Duration(minutes: 10),
      note: 'Evening downshift with oceanic narrations.',
      savedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    SavedPractice(
      id: 'saved_sound_ground',
      practice: _practiceById('sound_meditation_day2'),
      duration: const Duration(minutes: 20),
      note: 'Grounding frequency sweep when energy spikes.',
      savedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    SavedPractice(
      id: 'saved_light_sunrise',
      practice: _practiceById('light_practice_monthly'),
      duration: const Duration(minutes: 10),
      note: 'Sunrise ignition bookmarked by Aurora.',
      savedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  static const Map<String, Map<String, int>> practiceReactionSnapshots = {
    'light_practice_monthly': {
      'joy': 42,
      'energy': 36,
      'peace': 24,
      'insight': 18,
      'unity': 27,
    },
    'guided_meditation_day1': {
      'peace': 44,
      'insight': 32,
      'grounded': 28,
      'joy': 21,
      'release': 19,
    },
    'guided_meditation_day2': {
      'peace': 33,
      'insight': 24,
      'grounded': 20,
      'joy': 16,
      'release': 14,
    },
    'sound_meditation_day1': {
      'energy': 48,
      'peace': 26,
      'release': 22,
      'unity': 20,
      'joy': 18,
    },
    'sound_meditation_day2': {
      'energy': 34,
      'peace': 24,
      'release': 20,
      'unity': 18,
      'joy': 14,
    },
    'my_practice_custom': {
      'insight': 31,
      'grounded': 29,
      'peace': 25,
      'release': 24,
      'unity': 17,
    },
    'special_practice_window': {
      'energy': 34,
      'joy': 33,
      'unity': 29,
      'insight': 22,
      'peace': 18,
    },
  };

  static List<UnitTransaction> initialUnitHistory() => [
        UnitTransaction(
          title: 'Completed Light Practice',
          description: 'Daily glow + reactions bonus',
          amount: 15,
          icon: Icons.brightness_5,
        ),
        UnitTransaction(
          title: 'Thanked Master Amrita',
          description: 'Support offering',
          amount: -10,
          icon: Icons.favorite_border,
        ),
        UnitTransaction(
          title: 'Favourited AWAWAY streak',
          description: 'Repair fee',
          amount: -8,
          icon: Icons.bolt,
        ),
      ];

  static const List<AwawayMilestone> awawayMilestones = [
    AwawayMilestone(
      day: 4,
      label: 'Vesica invitation',
      description: 'Overlap widens, so invite a friend into the shared glow.',
    ),
    AwawayMilestone(
      day: 10,
      label: 'Seed circle stable',
      description: 'Sevenfold rhythm lets you anchor weekly mission plans.',
    ),
    AwawayMilestone(
      day: 19,
      label: 'Fruit lattice call',
      description: 'Thirteen nodes unlock a guidance broadcast from mentors.',
    ),
    AwawayMilestone(
      day: 28,
      label: 'Air temple unlocked',
      description: 'Octahedron breath work opens breeze meditations.',
    ),
    AwawayMilestone(
      day: 37,
      label: 'Metatron signal',
      description: 'Whole grid online — reframing ceremony scheduled.',
    ),
  ];

  static List<PracticeHistoryEntry> initialPracticeHistory() => [
        PracticeHistoryEntry(
          title: 'Sound Meditation • Aurora',
          duration: const Duration(minutes: 18),
          dateLabel: 'Yesterday, 07:20',
          isMasterSession: true,
          masterName: 'Aurora Lumen',
          reactionKey: 'unity',
        ),
        PracticeHistoryEntry(
          title: 'Light Practice',
          duration: const Duration(minutes: 12),
          dateLabel: '2 days ago, 21:04',
          reactionKey: 'peace',
        ),
      ];

  static const List<MasterGuide> masterGuides = [
    MasterGuide(
      id: 'master_aurora',
      name: 'Aurora Lumen',
      title: 'Dawn Collective',
      description: 'Pre-sunrise ignition with mantra, sound, and shared breath.',
      startTime: 'Tomorrow • 05:30',
      duration: Duration(minutes: 25),
      participantCount: 248,
      gradient: LinearGradient(
        colors: [HomeColors.peach, HomeColors.rose],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      sessionState: MasterSessionState.upcoming,
      timeUntilStart: Duration(hours: 18, minutes: 20),
    ),
    MasterGuide(
      id: 'master_sol',
      name: 'Sol Rivera',
      title: 'Noon Resonance',
      description: 'Sound bowls tuned to solar harmonics for midday reset.',
      startTime: 'Today • 12:00',
      duration: Duration(minutes: 30),
      participantCount: 132,
      gradient: LinearGradient(
        colors: [HomeColors.lavender, HomeColors.blush],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      sessionState: MasterSessionState.lobby,
      timeUntilStart: Duration(minutes: 4),
    ),
    MasterGuide(
      id: 'master_lyra',
      name: 'Lyra Okoye',
      title: 'Night Chorus',
      description: 'Drift into collective humming layered with soft percussion.',
      startTime: 'Live • 21:00',
      duration: Duration(minutes: 32),
      participantCount: 402,
      gradient: LinearGradient(
        colors: [HomeColors.eclipse, HomeColors.lavender],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      sessionState: MasterSessionState.live,
      timeRemaining: Duration(minutes: 19),
    ),
    MasterGuide(
      id: 'master_mira',
      name: 'Mira Solace',
      title: 'Midnight Gather',
      description: 'Collective hum already in progress; next call opens soon.',
      startTime: 'Live • 00:00',
      duration: Duration(minutes: 28),
      participantCount: 520,
      gradient: LinearGradient(
        colors: [HomeColors.eclipse, HomeColors.rose],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      sessionState: MasterSessionState.sealed,
      timeRemaining: Duration.zero,
    ),
  ];

  static List<Mission> initialMissions() => const [
        Mission(
          id: 'mission_alexandria',
          title: 'Alexandria Golden Pages',
          description:
              'Help digitize fire-worn folios from the lost Library of Alexandria archives.',
          unitCost: 15,
          pagesPerContribution: 2,
          progress: 0.32,
          totalPages: 180,
          userPages: 4,
          manuscriptLocation: 'Alexandria, Egypt',
          manuscriptEra: '3rd century BCE',
          importance:
              'These fragments contain early astronomical notes that deteriorate when exposed to light. Digitizing them preserves the gold-leaf ink for researchers.',
          preservationProcess:
              'We scan each fragment inside a nitrogen chamber, then stitch pages digitally to rebuild the codex sequence.',
          isNew: true,
        ),
      ].toList();

  static final List<FaqItem> faqItems = [
    const FaqItem(
      question: 'Why did the master session seal after a minute?',
      answer:
          'AWA masters guide everyone into the ritual at the same tempo. After sixty seconds we close the circle so the group travels together. Subscribe to master reminders to get nudged before the next window opens.',
      category: 'Masters',
      icon: Icons.auto_awesome,
    ),
    const FaqItem(
      question: 'How do I favourite a practice for later?',
      answer:
          'Paid members can pin any practice from the Lobby by tapping the bookmark icon on a card. Favourite picks, including preferred durations, live in the “My” tab whenever you enter practice selection.',
      category: 'Practice',
      icon: Icons.bookmark_border,
    ),
    const FaqItem(
      question: 'Do AWAWAY streak repairs cost Lumens?',
      answer:
          'Yes. Repairing the sacred geometry streak uses 12 Lumens and keeps your portal progress intact. Earn more Lumens from missions, daily practices, and sending reactions.',
      category: 'AWAWAY',
      icon: Icons.bolt,
    ),
    const FaqItem(
      question: 'Where can I read more about missions?',
      answer:
          'Open the Missions surface to explore current preservation projects, backstory, and rewards. Each mission includes a “Favourite pages” sheet that stores the folios you funded.',
      category: 'Missions',
      icon: Icons.menu_book,
    ),
  ];

  static Practice _practiceById(String id) {
    return Practices.getById(id) ?? Practices.all.first;
  }
}
