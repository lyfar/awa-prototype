/// Practice flow states for the home page
enum PracticeFlowState {
  home,           // Normal home page view
  practiceSelect, // Selecting practice type with Awa Soul
  practicing,     // Active practice session with audio controls
  completing,     // Practice completion and transition back
}

/// Types of practices available
enum PracticeType {
  lightPractice,
  guidedMeditation,
  soundMeditation,
  myPractice,
  specialPractice,
}

/// Freshness indicator for rotating practices
enum PracticeFreshness {
  today,      // Day 1 - fresh content
  yesterday,  // Day 2 - last chance before expiring
  monthly,    // Stays for a month (Light Practice)
  always,     // Always available (My Practice)
  timed,      // Time-locked windows (Special Practice)
}

/// Practice session state
enum PracticeSessionState {
  preparing,  // Setting up the practice
  playing,    // Audio is playing
  paused,     // Audio is paused
  completed,  // Practice finished successfully
  failed,     // Practice failed with error
}

/// Modality options for My Practice
enum PracticeModality {
  meditation,
  breathing,
  mantra,
  soundHealing,
  yoga,
  other,
}

extension PracticeModalityExt on PracticeModality {
  String get displayName {
    switch (this) {
      case PracticeModality.meditation: return 'Meditation';
      case PracticeModality.breathing: return 'Breathing';
      case PracticeModality.mantra: return 'Mantra';
      case PracticeModality.soundHealing: return 'Sound Healing';
      case PracticeModality.yoga: return 'Yoga';
      case PracticeModality.other: return 'Other';
    }
  }
}

/// Available mindfulness practices
class Practice {
  final String id;
  final PracticeType type;
  final String nameKey;
  final String descriptionKey;
  final Duration duration;
  final String audioUrl;
  final String icon;
  final PracticeFreshness freshness;
  final String availabilityLabel;
  final String durationLabel;
  final bool downloadable;
  final bool requiresMaster;
  final bool hasCustomDuration;
  final List<String> highlights;
  final String? guideText;
  final Duration? minDuration;
  final Duration? maxDuration;
  final double? graceFactor;
  // For special practices - time windows
  final List<String>? timeWindows;
  
  const Practice({
    required this.id,
    required this.type,
    required this.nameKey,
    required this.descriptionKey,
    required this.duration,
    required this.audioUrl,
    required this.icon,
    required this.freshness,
    required this.availabilityLabel,
    required this.durationLabel,
    this.downloadable = true,
    this.requiresMaster = false,
    this.hasCustomDuration = false,
    this.highlights = const [],
    this.guideText,
    this.minDuration,
    this.maxDuration,
    this.graceFactor,
    this.timeWindows,
  });
  
  /// Get localized name
  String getName() {
    final name = _getLocalizedText(nameKey);
    print('Practice: Getting name for $id -> $name');
    return name;
  }
  
  /// Get localized description
  String getDescription() {
    final description = _getLocalizedText(descriptionKey);
    print('Practice: Getting description for $id -> $description');
    return description;
  }
  
  /// Get practice type display name
  String getTypeName() {
    switch (type) {
      case PracticeType.lightPractice:
        return 'Light Practice';
      case PracticeType.guidedMeditation:
        return 'Guided Meditation';
      case PracticeType.soundMeditation:
        return 'Sound Meditation';
      case PracticeType.myPractice:
        return 'My Practice';
      case PracticeType.specialPractice:
        return 'Special Practice';
    }
  }
  
  /// Get freshness badge text
  String get freshnessBadge {
    switch (freshness) {
      case PracticeFreshness.today:
        return 'NEW TODAY';
      case PracticeFreshness.yesterday:
        return 'LAST CHANCE';
      case PracticeFreshness.monthly:
        return 'THIS MONTH';
      case PracticeFreshness.always:
        return 'ALWAYS';
      case PracticeFreshness.timed:
        return 'TIMED';
    }
  }
  
  /// Check if this practice is currently available
  bool get isAvailable {
    if (freshness == PracticeFreshness.timed && timeWindows != null) {
      return _isInTimeWindow();
    }
    return true;
  }
  
  /// Get countdown to next available window (for timed practices)
  Duration? get countdownToWindow {
    if (freshness != PracticeFreshness.timed || timeWindows == null) return null;
    // Calculate time to next window
    final now = DateTime.now();
    for (final window in timeWindows!) {
      final parts = window.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        var windowTime = DateTime(now.year, now.month, now.day, hour, minute);
        if (windowTime.isBefore(now)) {
          windowTime = windowTime.add(const Duration(days: 1));
        }
        final diff = windowTime.difference(now);
        if (diff.inMinutes <= 30) return diff; // Show countdown within 30 min
      }
    }
    return null;
  }
  
  bool _isInTimeWindow() {
    if (timeWindows == null) return false;
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    for (final window in timeWindows!) {
      final parts = window.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final windowMinutes = hour * 60 + minute;
        // Allow 15 minutes before and after the exact time
        if ((currentMinutes - windowMinutes).abs() <= 15) {
          return true;
        }
      }
    }
    return false;
  }
  
  /// Helper method for localization (mock implementation)
  String _getLocalizedText(String key) {
    final translations = {
      // Light Practice
      'light_practice': 'Light Practice',
      'light_practice_desc': 'Master-led ritual to assemble inner light and community.',
      
      // Guided Meditation
      'guided_meditation': 'Guided Meditation',
      'guided_meditation_today': 'Guided Meditation',
      'guided_meditation_yesterday': 'Guided Meditation',
      'guided_meditation_today_desc': 'Voice-guided meditation on today\'s theme. New narration drops daily.',
      'guided_meditation_yesterday_desc': 'Yesterday\'s guidance – last day before it expires.',
      
      // Sound Meditation
      'sound_meditation': 'Sound Meditation',
      'sound_meditation_today': 'Sound Meditation',
      'sound_meditation_yesterday': 'Sound Meditation',
      'sound_meditation_today_desc': 'Cosmic tones, frequencies, bowls tuned to today\'s energy.',
      'sound_meditation_yesterday_desc': 'Yesterday\'s sound bed – catch it before it rotates out.',
      
      // My Practice
      'my_practice': 'My Practice',
      'my_practice_desc': 'Log your own session. Choose modality and duration.',
      
      // Special Practice
      'special_practice': 'Special Practice',
      'special_practice_desc': 'Master-crafted ritual tied to celestial events.',
    };
    
    return translations[key] ?? 'MISSING_TRANSLATION:$key';
  }
}

/// Practice Type Group - groups today/yesterday variants under one type
class PracticeTypeGroup {
  final PracticeType type;
  final String displayName;
  final String icon;
  final String shortDescription;
  final List<Practice> variants;
  final bool hasMasterInfo;
  final bool hasRotation;  // true for today/yesterday practices
  
  const PracticeTypeGroup({
    required this.type,
    required this.displayName,
    required this.icon,
    required this.shortDescription,
    required this.variants,
    this.hasMasterInfo = false,
    this.hasRotation = false,
  });
  
  /// Get the "freshest" available practice
  Practice get primaryPractice {
    // Prefer today's practice if available
    final today = variants.where((p) => p.freshness == PracticeFreshness.today).firstOrNull;
    if (today != null) return today;
    // Fall back to any available
    return variants.first;
  }
  
  /// Get available count (e.g., "2 available" for rotation practices)
  int get availableCount => variants.length;
  
  /// Summary of what's in this group
  String get availabilitySummary {
    if (!hasRotation) {
      return variants.first.availabilityLabel;
    }
    return '$availableCount available • rotates daily';
  }
}

/// Available practices repository
class Practices {
  static const List<Practice> all = [
    // LIGHT PRACTICE - Monthly, master-led
    Practice(
      id: 'light_practice_monthly',
      type: PracticeType.lightPractice,
      nameKey: 'light_practice',
      descriptionKey: 'light_practice_desc',
      duration: Duration(minutes: 10),
      audioUrl: 'assets/audio/light_practice.mp3',
      icon: '🌞',
      freshness: PracticeFreshness.monthly,
      availabilityLabel: 'Stays live for 1 month',
      durationLabel: 'Fixed • ~10 min',
      downloadable: true,
      requiresMaster: true,
      highlights: [
        'Master info included (bio, photo, description)',
        'Fixed duration ~10 min',
        'Downloadable audio',
      ],
      guideText: 'Invite the shared inner light; breathe with the collective.',
    ),
    
    // GUIDED MEDITATION - Day 1 (Today)
    Practice(
      id: 'guided_meditation_day1',
      type: PracticeType.guidedMeditation,
      nameKey: 'guided_meditation_today',
      descriptionKey: 'guided_meditation_today_desc',
      duration: Duration(minutes: 10),
      audioUrl: 'assets/audio/guided_meditation_breath.mp3',
      icon: '🕊️',
      freshness: PracticeFreshness.today,
      availabilityLabel: 'Today\'s new • Day 1',
      durationLabel: 'Fixed • ~10 min',
      downloadable: true,
      requiresMaster: false,
      highlights: [
        'Title, theme, aim, and outcome shown',
        'Fixed duration ~10 min',
        'Downloadable • Rotates in 2 days',
      ],
      guideText: 'Follow the narration to settle into breath-led awareness.',
    ),
    
    // GUIDED MEDITATION - Day 2 (Yesterday)
    Practice(
      id: 'guided_meditation_day2',
      type: PracticeType.guidedMeditation,
      nameKey: 'guided_meditation_yesterday',
      descriptionKey: 'guided_meditation_yesterday_desc',
      duration: Duration(minutes: 10),
      audioUrl: 'assets/audio/guided_meditation_breath.mp3',
      icon: '🕊️',
      freshness: PracticeFreshness.yesterday,
      availabilityLabel: 'Yesterday\'s • Last day',
      durationLabel: 'Fixed • ~10 min',
      downloadable: true,
      requiresMaster: false,
      highlights: [
        'Expires tonight – not available tomorrow',
        'Fixed duration ~10 min',
        'Downloadable',
      ],
      guideText: 'Return for a final listen before it vanishes.',
    ),
    
    // SOUND MEDITATION - Day 1 (Today)
    Practice(
      id: 'sound_meditation_day1',
      type: PracticeType.soundMeditation,
      nameKey: 'sound_meditation_today',
      descriptionKey: 'sound_meditation_today_desc',
      duration: Duration(minutes: 15),
      audioUrl: 'assets/audio/sound_meditation_basic.mp3',
      icon: '🎵',
      freshness: PracticeFreshness.today,
      availabilityLabel: 'Today\'s new • Day 1',
      durationLabel: 'You choose • up to 30 min',
      downloadable: true,
      requiresMaster: false,
      hasCustomDuration: true,
      maxDuration: Duration(minutes: 30),
      minDuration: Duration(minutes: 5),
      highlights: [
        'Sound meditation info shown',
        'Duration selector (max 30 min)',
        'Downloadable • Rotates in 2 days',
      ],
      guideText: 'Select your duration and let the tones sweep the room.',
    ),
    
    // SOUND MEDITATION - Day 2 (Yesterday)
    Practice(
      id: 'sound_meditation_day2',
      type: PracticeType.soundMeditation,
      nameKey: 'sound_meditation_yesterday',
      descriptionKey: 'sound_meditation_yesterday_desc',
      duration: Duration(minutes: 15),
      audioUrl: 'assets/audio/sound_meditation_basic.mp3',
      icon: '🎵',
      freshness: PracticeFreshness.yesterday,
      availabilityLabel: 'Yesterday\'s • Last day',
      durationLabel: 'You choose • up to 30 min',
      downloadable: true,
      requiresMaster: false,
      hasCustomDuration: true,
      maxDuration: Duration(minutes: 30),
      minDuration: Duration(minutes: 5),
      highlights: [
        'Expires tonight – catch it now',
        'Duration selector (max 30 min)',
        'Downloadable',
      ],
      guideText: 'Pick your minutes before this sound bed rotates out.',
    ),
    
    // MY PRACTICE - Always available, manual logging
    Practice(
      id: 'my_practice_custom',
      type: PracticeType.myPractice,
      nameKey: 'my_practice',
      descriptionKey: 'my_practice_desc',
      duration: Duration(minutes: 20),
      audioUrl: '', // No audio - user's own practice
      icon: '⭐',
      freshness: PracticeFreshness.always,
      availabilityLabel: 'Always available',
      durationLabel: 'You set • +30% grace window',
      downloadable: false,
      requiresMaster: false,
      hasCustomDuration: true,
      minDuration: Duration(minutes: 1),
      maxDuration: Duration(minutes: 180),
      graceFactor: 0.3,
      highlights: [
        'Dropdown: meditation, breathing, mantra, etc.',
        'Manual duration input',
        'Grace logic: +30% buffer to complete',
        'Logged as journal entry (date, type, duration)',
      ],
      guideText: 'Declare your modality, set the timer, stay with it.',
    ),
    
    // SPECIAL PRACTICE - Timed windows, master-crafted
    Practice(
      id: 'special_practice_solstice',
      type: PracticeType.specialPractice,
      nameKey: 'special_practice',
      descriptionKey: 'special_practice_desc',
      duration: Duration(minutes: 10),
      audioUrl: 'assets/audio/special_practice.mp3',
      icon: '✨',
      freshness: PracticeFreshness.timed,
      availabilityLabel: '2× daily at 12:12 & 22:22',
      durationLabel: 'Fixed • ~10 min (master-set)',
      downloadable: false,
      requiresMaster: true,
      timeWindows: ['12:12', '22:22'],
      highlights: [
        'Occasion/meaning description',
        'Master info included',
        'Countdown timer to practice window',
        'Start enabled only at the set time',
        'Lights of participants as they enter',
      ],
      guideText: 'Arrive at the precise window. Let the master hold the circle.',
    ),
  ];
  
  /// Get grouped practices by type
  static List<PracticeTypeGroup> getGrouped() {
    print('Practices: Building grouped practice types');
    
    return [
      PracticeTypeGroup(
        type: PracticeType.lightPractice,
        displayName: 'Light Practice',
        icon: '🌞',
        shortDescription: 'Master-led community ritual',
        variants: all.where((p) => p.type == PracticeType.lightPractice).toList(),
        hasMasterInfo: true,
        hasRotation: false,
      ),
      PracticeTypeGroup(
        type: PracticeType.guidedMeditation,
        displayName: 'Guided Meditation',
        icon: '🕊️',
        shortDescription: 'Voice-guided meditation',
        variants: all.where((p) => p.type == PracticeType.guidedMeditation).toList(),
        hasMasterInfo: false,
        hasRotation: true,
      ),
      PracticeTypeGroup(
        type: PracticeType.soundMeditation,
        displayName: 'Sound Meditation',
        icon: '🎵',
        shortDescription: 'Healing frequencies & tones',
        variants: all.where((p) => p.type == PracticeType.soundMeditation).toList(),
        hasMasterInfo: false,
        hasRotation: true,
      ),
      PracticeTypeGroup(
        type: PracticeType.myPractice,
        displayName: 'My Practice',
        icon: '⭐',
        shortDescription: 'Log your own session',
        variants: all.where((p) => p.type == PracticeType.myPractice).toList(),
        hasMasterInfo: false,
        hasRotation: false,
      ),
      PracticeTypeGroup(
        type: PracticeType.specialPractice,
        displayName: 'Special Practice',
        icon: '✨',
        shortDescription: 'Timed celestial events',
        variants: all.where((p) => p.type == PracticeType.specialPractice).toList(),
        hasMasterInfo: true,
        hasRotation: false,
      ),
    ];
  }
  
  /// Get practices by type
  static List<Practice> getByType(PracticeType type) {
    final practices = all.where((practice) => practice.type == type).toList();
    print('Practices: Found ${practices.length} practices for type ${type.name}');
    return practices;
  }
  
  /// Get practice by ID
  static Practice? getById(String id) {
    try {
      final practice = all.firstWhere((practice) => practice.id == id);
      print('Practices: Found practice $id -> ${practice.getName()}');
      return practice;
    } catch (e) {
      print('Practices: ERROR - Practice not found for ID: $id');
      return null;
    }
  }
  
  /// Get random practice
  static Practice getRandomPractice() {
    final practice = all[DateTime.now().millisecondsSinceEpoch % all.length];
    print('Practices: Selected random practice -> ${practice.getName()}');
    return practice;
  }
}
