import 'package:shared_preferences/shared_preferences.dart';

/// Language service for managing app localization
/// Supports English and Russian for the initial release
class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String defaultLanguage = 'en';

  /// Available languages in the app
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ru': 'Русский',
  };

  /// Current selected language code
  static String _currentLanguage = defaultLanguage;

  /// Get current language code
  static String get currentLanguage => _currentLanguage;

  /// Initialize language service and load saved language
  static Future<void> initialize() async {
    print('LanguageService: Initializing language service');
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? defaultLanguage;
    print('LanguageService: Loaded language: $_currentLanguage');
  }

  /// Change language and save to preferences
  static Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      print('LanguageService: ERROR - Unsupported language: $languageCode');
      return;
    }

    print(
      'LanguageService: Changing language from $_currentLanguage to $languageCode',
    );
    _currentLanguage = languageCode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    print('LanguageService: Language saved to preferences');
  }

  /// Get localized text for current language
  static String getText(String key) {
    final text =
        _translations[_currentLanguage]?[key] ??
        _translations[defaultLanguage]?[key] ??
        'Missing: $key';
    return text;
  }

  /// Check if language is RTL (for future Arabic support)
  static bool get isRTL => _currentLanguage == 'ar';
}

/// Translation data for all supported languages
const Map<String, Map<String, String>> _translations = {
  'en': {
    // Onboarding steps
    'welcome_step_1': 'Welcome to your mindfulness journey',
    'welcome_step_2': 'Connect with a global community of practitioners',
    'welcome_step_3': 'Discover mindfulness practices from around the world',
    'welcome_step_4': 'Ready to join our global community?',
    'welcome_state_1':
        "Breathe out. We've been waiting for you. You're safe. No ads, no algorithms, no selling data. Here you can be your true self. Only your soul matters here.",
    'welcome_state_2':
        'AWATERRA is the first spiritual social network. We make inner light visible. Every minute of your practice lights a spark on the living map of the world. That\'s how we find one another. This is the first map of conscious people on Earth.',
    'welcome_state_3':
        'Look: thousands of lights shine beside you. Across the Earth, millions of people right now choose the path to their Soul. This is the AWATERRA community. Together we make the world brighter.',
    'welcome_state_4':
        'Ignite your light. We will stay close. Welcome to AWATERRA. Welcome home.',
    'welcome_state_5':
        "Shall we get acquainted? What's your name? May we show your light on the map? We need your location for that.",

    // Welcome data handshake
    'welcome_name_label': 'Your Name',
    'welcome_name_placeholder': 'Enter your name',
    'welcome_name_error':
        'Please share your name so we can welcome you properly.',
    'welcome_policy_ack':
        'I agree to share my approximate location so AWATERRA can place my light on the map.',
    'welcome_policy_error':
        'Please accept the location note so we can continue.',

    // Actions
    'continue': 'Continue',
    'proceed': 'Proceed',
    'allow_location': 'Allow Location',
    'skip_location': 'Later',
    'language': 'Language',

    // Location permission
    'location_title': 'Connect with the World',
    'location_description':
        'Allow location access to connect with mindfulness practitioners near you and discover local events.',
    'location_privacy': 'Your location is kept private and secure',

    // Settings
    'location_required': 'Location Permission Required',
    'location_settings_message':
        'To connect you with mindfulness practitioners nearby, we need access to your location. Please enable location permissions in your device settings.',
    'cancel': 'Cancel',
    'open_settings': 'Open Settings',
    'practice_completed':
        'Practice completed! Your light now shines in the global community.',
    // Home
    'daily_practice': 'Daily Practice',
    'practice_completed_today': 'Completed today ✨',
    'start_your_journey': 'Start your mindful journey',
    'practice_completed_description':
        'Great work! Your light is now part of the global community. Come back tomorrow for another session.',
    'practice_description':
        'Connect with your inner self and join millions of practitioners around the world.',
    'completed_today': 'Completed Today ✨',
    'begin_session': 'Start',
    // Language
    'select_language': 'Select Language',
  },

  'ru': {
    // Onboarding steps
    'welcome_step_1': 'Добро пожаловать в ваше путешествие осознанности',
    'welcome_step_2': 'Присоединитесь к глобальному сообществу практикующих',
    'welcome_step_3': 'Откройте для себя практики осознанности со всего мира',
    'welcome_step_4': 'Готовы присоединиться к нашему глобальному сообществу?',
    'welcome_state_1':
        'Выдохни. Мы тебя ждали. Ты в безопасности. Без рекламы, без алгоритмов, без продажи данных. Здесь можно быть настоящим. Здесь важна только твоя душа.',
    'welcome_state_2':
        'AWATERRA — первая духовная социальная сеть. Мы делаем внутренний свет видимым. Каждая минута твоей практики зажигает искру на живой карте мира. Так мы находим друг друга. Это первая карта осознанных людей Земли.',
    'welcome_state_3':
        'Посмотри: тысячи огней сияют рядом с тобой. По всей Земле миллионы людей прямо сейчас выбирают путь к своей Душе. Это сообщество AWATERRA. Вместе мы делаем мир светлее.',
    'welcome_state_4':
        'Зажги свой свет. Мы будем рядом. Добро пожаловать в AWATERRA. Добро пожаловать домой.',
    'welcome_state_5':
        'Познакомимся? Как тебя зовут? Покажем твой свет на карте? Для этого нужна геолокация.',

    // Welcome data handshake
    'welcome_name_label': 'Твоё имя',
    'welcome_name_placeholder': 'Введите имя',
    'welcome_name_error':
        'Пожалуйста, поделись именем, чтобы мы могли обратиться к тебе по-настоящему.',
    'welcome_policy_ack':
        'Я согласен(-на) поделиться приблизительным местоположением, чтобы AWATERRA показала мой свет на карте.',
    'welcome_policy_error':
        'Пожалуйста, подтверди согласие с примечанием о геолокации.',

    // Actions
    'continue': 'Продолжить',
    'proceed': 'Продолжить',
    'allow_location': 'Разрешить геолокацию',
    'skip_location': 'Позже',
    'language': 'Язык',

    // Location permission
    'location_title': 'Связь с миром',
    'location_description':
        'Разрешите доступ к геолокации, чтобы связаться с практикующими осознанность рядом с вами и найти местные события.',
    'location_privacy': 'Ваше местоположение остается приватным и безопасным',

    // Settings
    'location_required': 'Требуется разрешение на геолокацию',
    'location_settings_message':
        'Для связи с практикующими осознанность рядом с вами нам нужен доступ к вашему местоположению. Пожалуйста, включите разрешения на геолокацию в настройках вашего устройства.',
    'cancel': 'Отмена',
    'open_settings': 'Открыть настройки',
    'practice_completed':
        'Практика завершена! Ваш свет теперь сияет в глобальном сообществе.',
    // Home
    'daily_practice': 'Ежедневная практика',
    'practice_completed_today': 'Завершено сегодня ✨',
    'start_your_journey': 'Начните свое осознанное путешествие',
    'practice_completed_description':
        'Отличная работа! Ваш свет теперь часть глобального сообщества. Возвращайтесь завтра для новой сессии.',
    'practice_description':
        'Соединитесь с собой и присоединитесь к миллионам практикующих по всему миру.',
    'completed_today': 'Завершено сегодня ✨',
    'begin_session': 'Начать сессию',
    // Language
    'select_language': 'Выберите язык',
  },
};
