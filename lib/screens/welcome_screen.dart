import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/user_profile_service.dart';
import '../soul/awa_sphere.dart';
import '../onboarding/steps/mock_video_step.dart';
import '../onboarding/steps/safe_hands_step.dart';
import '../onboarding/steps/ignition_step.dart';
import '../onboarding/steps/welcome_step.dart';
import '../onboarding/steps/name_input_step.dart';
import '../onboarding/steps/awa_soul_text_step.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

enum OnboardingPhase {
  video,
  safeHands,
  ignition,
  welcome,      // Added: Welcome step after ignition
  nameInput,
  ecology,
  community,
  finalStep,
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  OnboardingPhase _phase = OnboardingPhase.video;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    print('WelcomeScreen: Initializing onboarding flow');
    _initializeLanguage();
    _loadStoredProfile();
  }

  Future<void> _initializeLanguage() async {
    await LanguageService.initialize();
  }

  Future<void> _loadStoredProfile() async {
    final storedName = await UserProfileService.getDisplayName();
    if (mounted && storedName != null) {
      setState(() {
        _userName = storedName;
      });
    }
  }

  void _nextPhase() {
    print('WelcomeScreen: Advancing from phase ${_phase.name}');
    setState(() {
      final nextIndex = _phase.index + 1;
      if (nextIndex < OnboardingPhase.values.length) {
        _phase = OnboardingPhase.values[nextIndex];
        print('WelcomeScreen: Now on phase ${_phase.name}');
      } else {
        _completeOnboarding();
      }
    });
  }

  void _completeOnboarding() {
    print('WelcomeScreen: Completing onboarding, navigating to home');
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _handleNameSubmitted(String name) {
    print('WelcomeScreen: Name submitted - $name');
    setState(() {
      _userName = name;
    });
    UserProfileService.saveDisplayName(name);
    _nextPhase();
  }

  Widget _buildCurrentStep() {
    switch (_phase) {
      case OnboardingPhase.video:
        return MockVideoStep(onContinue: _nextPhase);
      case OnboardingPhase.safeHands:
        return SafeHandsStep(onContinue: _nextPhase);
      case OnboardingPhase.ignition:
        return IgnitionStep(onIgnite: _nextPhase);
      case OnboardingPhase.welcome:
        return WelcomeStep(onContinue: _nextPhase);
      case OnboardingPhase.nameInput:
        return NameInputStep(
          onNameSubmitted: _handleNameSubmitted,
          initialName: _userName,
        );
      case OnboardingPhase.ecology:
        return AwaSoulTextStep(
          title: "Ecology of Life",
          description: "You're home here.\nA quiet pause from the noise.\nNo content – just presence.\nHere, the unseen becomes visible.\nYour inner light appears\non the living map.",
          buttonText: "Continue",
          onContinue: _nextPhase,
        );
      case OnboardingPhase.community:
        return AwaSoulTextStep(
          title: "Become Part of Us",
          description: "Millions are choosing to live awake\nno longer on autopilot.\nAWATERRA is where conscious people\nmeet.\nPause.",
          buttonText: "Continue",
          onContinue: _nextPhase,
        );
      case OnboardingPhase.finalStep:
        return AwaSoulTextStep(
          title: "Take a moment",
          description: "Begin your first practice.\nLet your light unfold.",
          buttonText: "Start Journey",
          onContinue: _completeOnboarding,
          isStartJourney: true,
        );
    }
  }

  bool get _isLightMode {
    return _phase.index >= OnboardingPhase.welcome.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isLightMode ? Colors.white : Colors.black,
      body: Stack(
        children: [
          // AwaSphere at top (Only for Light phases)
          // AwaSphere at top - half screen size
          if (_isLightMode)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AwaSphereHeader(
                halfScreen: true,
                interactive: true,
              ),
            ),

          // Content with Transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: KeyedSubtree(
              key: ValueKey(_phase),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }
}
