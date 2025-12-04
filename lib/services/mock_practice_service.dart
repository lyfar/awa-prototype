import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meditation_models.dart';

/// Mock practice service with comprehensive logging and error handling
/// 
/// This service simulates:
/// - Practice session management
/// - Audio loading and playback
/// - Progress tracking
/// - Error scenarios for testing
/// - Local data persistence
/// 
/// All operations include detailed logging for debugging and documentation
class MockPracticeService {
  static MockPracticeService? _instance;
  static MockPracticeService get instance => _instance ??= MockPracticeService._();
  
  MockPracticeService._();
  
  // Service state
  bool _isInitialized = false;
  Practice? _currentPractice;
  PracticeSessionState _sessionState = PracticeSessionState.preparing;
  Duration _sessionProgress = Duration.zero;
  String? _lastErrorMessage;
  
  // Mock settings for testing different scenarios
  final bool _simulateNetworkErrors = false; // Set to true to test error flows
  final bool _simulateSlowLoading = true;   // Set to true to test loading states
  final double _errorRate = 0.1;            // 10% chance of random errors

  /// Initialize the mock service
  Future<void> initialize() async {
    print('MockPracticeService: Initializing practice service');
    
    try {
      if (_simulateSlowLoading) {
        print('MockPracticeService: Simulating slow initialization');
        await Future.delayed(const Duration(milliseconds: 800));
      }
      
      // Simulate initialization error (rare)
      if (_simulateNetworkErrors && Random().nextDouble() < 0.05) {
        throw Exception('Service initialization failed - network unreachable');
      }
      
      _isInitialized = true;
      print('MockPracticeService: Service initialized successfully');
      
    } catch (e) {
      print('MockPracticeService: ERROR during initialization: $e');
      _lastErrorMessage = e.toString();
      rethrow;
    }
  }

  /// Start a practice session
  Future<PracticeSessionResult> startPractice(Practice practice) async {
    print('MockPracticeService: Starting practice session for ${practice.getName()}');
    
    if (!_isInitialized) {
      const error = 'Service not initialized';
      print('MockPracticeService: ERROR - $error');
      return PracticeSessionResult.error(error);
    }
    
    try {
      _currentPractice = practice;
      _sessionState = PracticeSessionState.preparing;
      _sessionProgress = Duration.zero;
      
      print('MockPracticeService: Loading audio from ${practice.audioUrl}');
      
      // Simulate audio loading
      if (_simulateSlowLoading) {
        await Future.delayed(const Duration(milliseconds: 1200));
      }
      
      // Simulate loading error
      if (_simulateNetworkErrors && Random().nextDouble() < _errorRate) {
        throw Exception('Failed to load audio: Network timeout');
      }
      
      _sessionState = PracticeSessionState.playing;
      
      print('MockPracticeService: Practice session started successfully');
      print('MockPracticeService: Session details - Type: ${practice.getTypeName()}, Duration: ${practice.duration.inMinutes}min');
      
      return PracticeSessionResult.success(_sessionState);
      
    } catch (e) {
      print('MockPracticeService: ERROR starting practice: $e');
      _sessionState = PracticeSessionState.failed;
      _lastErrorMessage = e.toString();
      return PracticeSessionResult.error(e.toString());
    }
  }

  /// Pause the current practice session
  Future<PracticeSessionResult> pausePractice() async {
    print('MockPracticeService: Pausing practice session');
    
    if (_currentPractice == null) {
      const error = 'No active practice session';
      print('MockPracticeService: ERROR - $error');
      return PracticeSessionResult.error(error);
    }
    
    if (_sessionState != PracticeSessionState.playing) {
      final error = 'Cannot pause - session state: $_sessionState';
      print('MockPracticeService: ERROR - $error');
      return PracticeSessionResult.error(error);
    }
    
    _sessionState = PracticeSessionState.paused;
    print('MockPracticeService: Practice paused at ${_formatDuration(_sessionProgress)}');
    
    return PracticeSessionResult.success(_sessionState);
  }

  /// Resume the current practice session
  Future<PracticeSessionResult> resumePractice() async {
    print('MockPracticeService: Resuming practice session');
    
    if (_currentPractice == null) {
      const error = 'No active practice session';
      print('MockPracticeService: ERROR - $error');
      return PracticeSessionResult.error(error);
    }
    
    if (_sessionState != PracticeSessionState.paused) {
      final error = 'Cannot resume - session state: $_sessionState';
      print('MockPracticeService: ERROR - $error');
      return PracticeSessionResult.error(error);
    }
    
    _sessionState = PracticeSessionState.playing;
    print('MockPracticeService: Practice resumed from ${_formatDuration(_sessionProgress)}');
    
    return PracticeSessionResult.success(_sessionState);
  }

  /// Seek to a specific position in the practice
  Future<PracticeSessionResult> seekTo(Duration position) async {
    print('MockPracticeService: Seeking to ${_formatDuration(position)}');
    
    if (_currentPractice == null) {
      const error = 'No active practice session';
      print('MockPracticeService: ERROR - $error');
      return PracticeSessionResult.error(error);
    }
    
    if (position > _currentPractice!.duration) {
      final error = 'Cannot seek beyond practice duration (${_formatDuration(_currentPractice!.duration)})';
      print('MockPracticeService: ERROR - $error');
      return PracticeSessionResult.error(error);
    }
    
    if (position.isNegative) {
      final error = 'Cannot seek to negative position';
      print('MockPracticeService: ERROR - $error');
      return PracticeSessionResult.error(error);
    }
    
    _sessionProgress = position;
    print('MockPracticeService: Successfully seeked to ${_formatDuration(position)}');
    
    return PracticeSessionResult.success(_sessionState);
  }

  /// Complete the current practice session
  Future<PracticeSessionResult> completePractice() async {
    print('MockPracticeService: Completing practice session');
    
    if (_currentPractice == null) {
      const error = 'No active practice session';
      print('MockPracticeService: ERROR - $error');
      return PracticeSessionResult.error(error);
    }
    
    try {
      final practice = _currentPractice!;
      _sessionState = PracticeSessionState.completed;
      _sessionProgress = practice.duration;
      
      // Save completion data
      await _savePracticeCompletion(practice);
      
      print('MockPracticeService: Practice completed successfully');
      print('MockPracticeService: Completion stats - Practice: ${practice.getName()}, Duration: ${practice.duration.inMinutes}min');
      print('MockPracticeService: Highlights: ${practice.highlights.join(', ')}');
      
      // Clean up session
      _currentPractice = null;
      _sessionProgress = Duration.zero;
      
      return PracticeSessionResult.success(_sessionState);
      
    } catch (e) {
      print('MockPracticeService: ERROR completing practice: $e');
      _sessionState = PracticeSessionState.failed;
      _lastErrorMessage = e.toString();
      return PracticeSessionResult.error(e.toString());
    }
  }

  /// Cancel the current practice session
  Future<void> cancelPractice() async {
    print('MockPracticeService: Cancelling practice session');
    
    if (_currentPractice != null) {
      print('MockPracticeService: Cancelled ${_currentPractice!.getName()} at ${_formatDuration(_sessionProgress)}');
    }
    
    _currentPractice = null;
    _sessionState = PracticeSessionState.preparing;
    _sessionProgress = Duration.zero;
    
    print('MockPracticeService: Practice session cancelled');
  }

  /// Get current session state
  PracticeSessionState get currentSessionState => _sessionState;
  
  /// Get current practice
  Practice? get currentPractice => _currentPractice;
  
  /// Get current progress
  Duration get currentProgress => _sessionProgress;
  
  /// Get last error message
  String? get lastError => _lastErrorMessage;

  /// Check if user has practiced today
  Future<bool> hasPracticedToday() async {
    print('MockPracticeService: Checking if user practiced today');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPracticeDate = prefs.getString('last_practice_date');
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final hasPracticed = lastPracticeDate == today;
      print('MockPracticeService: User ${hasPracticed ? 'has' : 'has not'} practiced today');
      
      return hasPracticed;
    } catch (e) {
      print('MockPracticeService: ERROR checking practice status: $e');
      return false;
    }
  }

  /// Get user's practice statistics
  Future<PracticeStats> getPracticeStats() async {
    print('MockPracticeService: Retrieving practice statistics');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalSessions = prefs.getInt('total_sessions') ?? 0;
      final totalMinutes = prefs.getInt('total_minutes') ?? 0;
      final streakDays = prefs.getInt('streak_days') ?? 0;
      
      final stats = PracticeStats(
        totalSessions: totalSessions,
        totalMinutes: totalMinutes,
        currentStreak: streakDays,
        lastPracticeDate: prefs.getString('last_practice_date'),
      );
      
      print('MockPracticeService: Stats retrieved - Sessions: $totalSessions, Minutes: $totalMinutes, Streak: $streakDays days');
      
      return stats;
    } catch (e) {
      print('MockPracticeService: ERROR retrieving stats: $e');
      return PracticeStats.empty();
    }
  }

  /// Save practice completion
  Future<void> _savePracticeCompletion(Practice practice) async {
    print('MockPracticeService: Saving practice completion data');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Update practice date
      await prefs.setString('last_practice_date', today);
      
      // Update statistics
      final totalSessions = (prefs.getInt('total_sessions') ?? 0) + 1;
      final totalMinutes = (prefs.getInt('total_minutes') ?? 0) + practice.duration.inMinutes;
      
      await prefs.setInt('total_sessions', totalSessions);
      await prefs.setInt('total_minutes', totalMinutes);
      
      // Update streak (simplified logic)
      final streakDays = (prefs.getInt('streak_days') ?? 0) + 1;
      await prefs.setInt('streak_days', streakDays);
      
      print('MockPracticeService: Completion data saved - Session $totalSessions, Total: ${totalMinutes}min, Streak: ${streakDays}d');
      
    } catch (e) {
      print('MockPracticeService: ERROR saving completion data: $e');
      throw Exception('Failed to save practice data: $e');
    }
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Reset all practice data (for testing)
  Future<void> resetAllData() async {
    print('MockPracticeService: Resetting all practice data');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_practice_date');
      await prefs.remove('total_sessions');
      await prefs.remove('total_minutes');
      await prefs.remove('streak_days');
      
      print('MockPracticeService: All practice data reset');
    } catch (e) {
      print('MockPracticeService: ERROR resetting data: $e');
    }
  }
}

/// Practice session result wrapper
class PracticeSessionResult {
  final bool isSuccess;
  final PracticeSessionState? state;
  final String? errorMessage;
  
  PracticeSessionResult.success(this.state) 
      : isSuccess = true, 
        errorMessage = null;
  
  PracticeSessionResult.error(this.errorMessage) 
      : isSuccess = false, 
        state = null;
}

/// Practice statistics data class
class PracticeStats {
  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final String? lastPracticeDate;
  
  const PracticeStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.currentStreak,
    this.lastPracticeDate,
  });
  
  factory PracticeStats.empty() {
    return const PracticeStats(
      totalSessions: 0,
      totalMinutes: 0,
      currentStreak: 0,
    );
  }
  
  @override
  String toString() {
    return 'PracticeStats(sessions: $totalSessions, minutes: $totalMinutes, streak: $currentStreak days)';
  }
}
