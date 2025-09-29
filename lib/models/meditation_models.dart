/// Practice flow states for the home page
enum PracticeFlowState {
  home,           // Normal home page view
  practiceSelect, // Selecting practice type with Awa Soul
  practicing,     // Active practice session with audio controls
  completing,     // Practice completion and transition back
}

/// Types of practices available
enum PracticeType {
  soundMeditation,
  soundHealing,
  guidedMeditation,
  cosmicMusic,
  myPractice,
}

/// Practice session state
enum PracticeSessionState {
  preparing,  // Setting up the practice
  playing,    // Audio is playing
  paused,     // Audio is paused
  completed,  // Practice finished successfully
  failed,     // Practice failed with error
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
  final List<String> benefits;
  final String? guideText; // Optional guide text for the practice
  
  const Practice({
    required this.id,
    required this.type,
    required this.nameKey,
    required this.descriptionKey,
    required this.duration,
    required this.audioUrl,
    required this.icon,
    this.benefits = const [],
    this.guideText,
  });
  
  /// Get localized name
  String getName() {
    // This would use LanguageService.getText(nameKey) in production
    // For now, return English defaults with proper logging
    final name = _getLocalizedText(nameKey);
    print('Practice: Getting name for $id -> $name');
    return name;
  }
  
  /// Get localized description
  String getDescription() {
    // This would use LanguageService.getText(descriptionKey) in production
    final description = _getLocalizedText(descriptionKey);
    print('Practice: Getting description for $id -> $description');
    return description;
  }
  
  /// Get practice type display name
  String getTypeName() {
    switch (type) {
      case PracticeType.soundMeditation:
        return 'Sound Meditation';
      case PracticeType.soundHealing:
        return 'Sound Healing';
      case PracticeType.guidedMeditation:
        return 'Guided Meditation';
      case PracticeType.cosmicMusic:
        return 'Cosmic Music';
      case PracticeType.myPractice:
        return 'My Practice';
    }
  }
  
  /// Helper method for localization (mock implementation)
  String _getLocalizedText(String key) {
    final translations = {
      // Sound Meditation
      'sound_meditation': 'Sound Meditation',
      'sound_meditation_desc': 'Immerse in healing frequencies and vibrational sounds',
      
      // Sound Healing
      'sound_healing': 'Sound Healing',
      'sound_healing_desc': 'Restore balance through therapeutic sound frequencies',
      
      // Guided Meditation
      'guided_meditation': 'Guided Meditation',
      'guided_meditation_desc': 'Follow gentle guidance into deep meditation states',
      
      // Cosmic Music
      'cosmic_music': 'Cosmic Music',
      'cosmic_music_desc': 'Connect with universal rhythms and cosmic consciousness',
      
      // My Practice
      'my_practice': 'My Practice',
      'my_practice_desc': 'Personalized practice based on your preferences',
    };
    
    return translations[key] ?? 'MISSING_TRANSLATION:$key';
  }
}

/// Available practices repository
class Practices {
  static const List<Practice> all = [
    Practice(
      id: 'sound_meditation_basic',
      type: PracticeType.soundMeditation,
      nameKey: 'sound_meditation',
      descriptionKey: 'sound_meditation_desc',
      duration: Duration(minutes: 15),
      audioUrl: 'assets/audio/sound_meditation_basic.mp3',
      icon: '🎵',
      benefits: ['Deep relaxation', 'Stress relief', 'Enhanced focus'],
      guideText: 'Let the healing sounds wash over you, releasing tension and bringing peace.',
    ),
    Practice(
      id: 'sound_healing_chakras',
      type: PracticeType.soundHealing,
      nameKey: 'sound_healing',
      descriptionKey: 'sound_healing_desc',
      duration: Duration(minutes: 20),
      audioUrl: 'assets/audio/sound_healing_chakras.mp3',
      icon: '🔊',
      benefits: ['Energy alignment', 'Chakra balancing', 'Emotional healing'],
      guideText: 'Feel the vibrations align your energy centers and restore natural harmony.',
    ),
    Practice(
      id: 'guided_meditation_breath',
      type: PracticeType.guidedMeditation,
      nameKey: 'guided_meditation',
      descriptionKey: 'guided_meditation_desc',
      duration: Duration(minutes: 12),
      audioUrl: 'assets/audio/guided_meditation_breath.mp3',
      icon: '🧘‍♀️',
      benefits: ['Mindfulness', 'Breath awareness', 'Mental clarity'],
      guideText: 'Follow the gentle guidance as you deepen into awareness and presence.',
    ),
    Practice(
      id: 'cosmic_music_journey',
      type: PracticeType.cosmicMusic,
      nameKey: 'cosmic_music',
      descriptionKey: 'cosmic_music_desc',
      duration: Duration(minutes: 25),
      audioUrl: 'assets/audio/cosmic_music_journey.mp3',
      icon: '🌌',
      benefits: ['Expanded consciousness', 'Cosmic connection', 'Transcendence'],
      guideText: 'Journey beyond the physical realm into cosmic consciousness and unity.',
    ),
    Practice(
      id: 'my_practice_custom',
      type: PracticeType.myPractice,
      nameKey: 'my_practice',
      descriptionKey: 'my_practice_desc',
      duration: Duration(minutes: 10),
      audioUrl: 'assets/audio/my_practice_custom.mp3',
      icon: '⭐',
      benefits: ['Personalized experience', 'Adaptive content', 'Growth tracking'],
      guideText: 'Your personalized practice, designed specifically for your journey.',
    ),
  ];
  
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
