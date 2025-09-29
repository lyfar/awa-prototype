import 'package:flutter/material.dart';
import '../globe/globe_widget.dart';
import '../globe/globe_states.dart';
import '../services/practice_service.dart';
import '../services/language_service.dart';
import '../models/meditation_models.dart';
import '../home/components/profile_panel.dart';
// Removed daily practice card for full-screen globe layout
import '../home/components/home_header.dart';

/// Home screen with practice flow
///
/// This screen manages the complete practice journey:
/// 1. Home state - Shows globe and daily practice card
/// 2. Practice selection - Awa Soul guides user to choose practice
/// 3. Practice session - Audio player with controls
/// 4. Practice completion - Celebration and globe transition
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // User state
  bool _hasPracticedToday = false;
  double? _userLatitude;
  double? _userLongitude;
  bool _isLoading = true;

  // Practice flow state
  PracticeFlowState _practiceState = PracticeFlowState.home;
  Practice? _selectedPractice;

  // User profile state
  bool _showUserProfile = false;

  @override
  void initState() {
    super.initState();
    print('HomeScreen: Initializing home screen');

    _initializeHomeScreen();
  }

  /// Initialize home screen data
  Future<void> _initializeHomeScreen() async {
    print('HomeScreen: Loading initial data');

    try {
      // Initialize language service
      print('HomeScreen: Language service initialized');

      // Check practice status
      final hasPracticed = await PracticeService.hasPracticedToday();
      print('HomeScreen: User practiced today: $hasPracticed');

      // Get user location
      final location = await PracticeService.getUserLocation();
      print(
        'HomeScreen: User location - lat: ${location['latitude']}, lng: ${location['longitude']}',
      );

      setState(() {
        _hasPracticedToday = hasPracticed;
        _userLatitude = location['latitude'];
        _userLongitude = location['longitude'];
        _isLoading = false;
      });

      print(
        'HomeScreen: Initialized - practiced: $hasPracticed, location: $_userLatitude, $_userLongitude',
      );
    } catch (e) {
      print('HomeScreen: ERROR during initialization: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Start the practice flow
  void _startPracticeFlow() {
    print('HomeScreen: Starting practice flow');
    setState(() {
      _practiceState = PracticeFlowState.practiceSelect;
    });
  }

  /// Complete the practice session
  Future<void> _completePractice() async {
    print('HomeScreen: Completing practice session');

    setState(() {
      _practiceState = PracticeFlowState.completing;
    });

    try {
      // Save current location if not already saved
      if (_userLatitude == null || _userLongitude == null) {
        await PracticeService.saveCurrentLocation();
        final location = await PracticeService.getUserLocation();
        setState(() {
          _userLatitude = location['latitude'];
          _userLongitude = location['longitude'];
        });
      }

      // Mark practice as completed
      await PracticeService.markPracticeCompleted();

      // Wait for transition animation
      await Future.delayed(const Duration(milliseconds: 2000));

      setState(() {
        _hasPracticedToday = true;
        _practiceState = PracticeFlowState.home;
        _selectedPractice = null;
      });

      print(
        'HomeScreen: Practice completed, user light should now appear on globe',
      );

      // Show completion feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LanguageService.getText('practice_completed') ??
                  'Practice completed! Your light now shines in the global community.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green.withOpacity(0.8),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('HomeScreen: ERROR completing practice: $e');
      _exitPractice();
    }
  }

  /// Exit practice flow and return to home
  void _exitPractice() {
    print('HomeScreen: Exiting practice flow');
    setState(() {
      _practiceState = PracticeFlowState.home;
      _selectedPractice = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  GlobeConfig _buildGlobeConfig() {
    final screenHeight = MediaQuery.of(context).size.height;
    if (_practiceState != PracticeFlowState.home) {
      return GlobeConfig.awaSoul(
        height: screenHeight,
        disableInteraction: _showUserProfile,
      );
    }

    return GlobeConfig.globe(
      height: screenHeight,
      showUserLight: _hasPracticedToday,
      userLatitude: _userLatitude,
      userLongitude: _userLongitude,
      disableInteraction: _showUserProfile,
    );
  }

  Widget _buildGlobeView() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white.withOpacity(0.7),
        ),
      );
    }

    return IgnorePointer(
      ignoring: _showUserProfile,
      child: GlobeWidget(
        config: _buildGlobeConfig(),
      ),
    );
  }

  Widget _buildPracticeCard() {
    final title = LanguageService.getText('daily_practice') ?? 'Daily Practice';
    final subtitle = _hasPracticedToday
        ? LanguageService.getText('practice_completed_today') ?? 'Completed today ✨'
        : LanguageService.getText('start_your_journey') ?? 'Start your mindful journey';

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(48),
            topRight: Radius.circular(48),
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0C1226),
                  Color(0xFF1B2B56),
                  Color(0xFF2E2B68),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0C1226).withOpacity(0.45),
                  blurRadius: 40,
                  spreadRadius: 6,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: _startPracticeFlow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: Text(
                        LanguageService.getText('begin_session') ?? 'Start',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
      'HomeScreen: Building UI - practiceState: ${_practiceState.name}, isLoading: $_isLoading',
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: HomeHeader(
                    onProfileTap: () {
                      setState(() {
                        _showUserProfile = !_showUserProfile;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildGlobeView(),
                    ),
                    _buildPracticeCard(),
                  ],
                ),
              ),
            ],
          ),

          // Background overlay when profile is visible (captures all events)
          if (_showUserProfile)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Close profile when tapping outside
                  print('HomeScreen: Background tapped, closing profile');
                  setState(() {
                    _showUserProfile = false;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),

          // Profile panel overlay
          if (_showUserProfile)
            ProfilePanel(
              isVisible: _showUserProfile,
              onClose: () {
                setState(() {
                  _showUserProfile = false;
                });
              },
              hasPracticedToday: _hasPracticedToday,
              userLatitude: _userLatitude,
              userLongitude: _userLongitude,
              practiceState: _practiceState,
              onPracticeStateChanged: (practiced) {
                setState(() {
                  _hasPracticedToday = practiced;
                });
              },
            ),
        ],
      ),
    );
  }
}
