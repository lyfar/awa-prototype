import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/location_service.dart';
import '../services/language_service.dart';
import '../services/user_profile_service.dart';
import '../globe/globe_widget.dart';
import '../globe/globe_states.dart';
import '../onboarding/onboarding_flow.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _textAnimationController;
  late AnimationController _globeAnimationController;
  late AnimationController _locationSlideController;

  bool _showGlobe = false;
  bool _showText = false;
  bool _showDataHandshake = false;
  bool _isRequestingLocation = false;
  bool _hasAcceptedPolicy = false;
  bool _policyError = false;
  String? _nameError;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  int _currentStep = 0;

  final List<OnboardingStep> _steps = const [
    OnboardingStep('welcome_state_1'),
    OnboardingStep('welcome_state_2'),
    OnboardingStep('welcome_state_3'),
    OnboardingStep('welcome_state_4'),
    OnboardingStep('welcome_state_5'),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize language service and cached profile data
    _initializeLanguage();
    _loadStoredProfile();

    _textAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _globeAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _locationSlideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start the sequence
    _startWelcomeSequence();
  }

  Future<void> _initializeLanguage() async {
    print('WelcomeScreen: Initializing language service');
    await LanguageService.initialize();
    print(
      'WelcomeScreen: Language service initialized with: ${LanguageService.currentLanguage}',
    );
  }

  Future<void> _loadStoredProfile() async {
    final storedName = await UserProfileService.getDisplayName();
    if (!mounted) return;

    if (storedName != null) {
      print('WelcomeScreen: Restoring stored display name');
      _nameController.text = storedName;
    }
  }

  void _startWelcomeSequence() async {
    // Initial: show globe with single particle and first message
    setState(() {
      _showGlobe = true;
      _showText = true;
      _currentStep = 0;
    });
  }

  void _onContinue() {
    print('WelcomeScreen: Continue pressed, current step: $_currentStep');

    if (_currentStep < 3) {
      final nextStep = _currentStep + 1;
      print('WelcomeScreen: Advancing to globe step $nextStep');
      setState(() {
        _currentStep = nextStep;
        _showDataHandshake = false;
      });
      return;
    }

    if (_currentStep == 3) {
      print('WelcomeScreen: Transitioning to data handshake state');
      setState(() {
        _currentStep = 4;
        _showDataHandshake = true;
      });
      _locationSlideController.forward(from: 0);
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isRequestingLocation = true);

    try {
      final permission = await Permission.location.request();

      if (permission.isGranted) {
        // Get current location
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Save location to backend
        await LocationService.saveUserLocation(position);

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else if (permission.isPermanentlyDenied) {
        // Show dialog to open settings
        _showSettingsDialog();
      } else {
        // Permission denied, go to home anyway
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      // Handle error, go to home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } finally {
      if (mounted) {
        setState(() => _isRequestingLocation = false);
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _onPolicyChanged(bool value) {
    setState(() {
      _hasAcceptedPolicy = value;
      if (value) {
        _policyError = false;
      }
    });
  }

  void _onNameChanged(String value) {
    if (_nameError != null && value.trim().isNotEmpty) {
      setState(() => _nameError = null);
    }
  }

  Future<bool> _persistProfileBeforeAction({
    required bool requiresPolicy,
  }) async {
    final trimmedName = _nameController.text.trim();
    bool hasError = false;

    if (trimmedName.isEmpty) {
      hasError = true;
      setState(
        () => _nameError = LanguageService.getText('welcome_name_error'),
      );
    } else if (_nameError != null) {
      setState(() => _nameError = null);
    }

    if (requiresPolicy && !_hasAcceptedPolicy) {
      hasError = true;
      setState(() => _policyError = true);
    } else if (_policyError) {
      setState(() => _policyError = false);
    }

    if (hasError) {
      if (trimmedName.isEmpty) {
        _nameFocusNode.requestFocus();
      }
      return false;
    }

    await UserProfileService.saveDisplayName(trimmedName);
    return true;
  }

  Future<void> _handleAllowLocation() async {
    final canProceed = await _persistProfileBeforeAction(requiresPolicy: true);
    if (!canProceed) return;
    await _requestLocationPermission();
  }

  Future<void> _handleSkipLocation() async {
    final canProceed = await _persistProfileBeforeAction(requiresPolicy: false);
    if (!canProceed) return;
    _navigateToHome();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white.withValues(alpha: 0.95),
            title: Text(
              LanguageService.getText('location_required'),
              style: TextStyle(color: Colors.black87),
            ),
            content: Text(
              LanguageService.getText('location_settings_message'),
              style: TextStyle(color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(LanguageService.getText('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                child: Text(LanguageService.getText('open_settings')),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    _globeAnimationController.dispose();
    _locationSlideController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  GlobeConfig _buildGlobeConfig() {
    final screenHeight = MediaQuery.of(context).size.height;

    // Pick the appropriate globe state for the current welcome step
    GlobeConfig config;
    switch (_currentStep) {
      case 0:
        // Step 1: Light state
        config = GlobeConfig.light(
          height: screenHeight,
          disableInteraction: true,
        );
        break;
      case 1:
        // Step 2: Awa Soul particle field
        config = GlobeConfig.awaSoul(
          height: screenHeight,
          disableInteraction: true,
        );
        break;
      case 2:
        // Step 3: Globe reveal, interaction still locked
        config = GlobeConfig.globe(
          height: screenHeight,
          disableInteraction: true,
        );
        break;
      case 3:
        // Step 4: Invitation, keep globe centered but still non-interactive
        config = GlobeConfig.globe(
          height: screenHeight,
          disableInteraction: true,
        );
        break;
      default:
        // Step 5: Data handshake, disable interaction while form is active
        config = GlobeConfig.globe(
          height: screenHeight,
          disableInteraction: true,
        );
        break;
    }

    print(
      'WelcomeScreen: Building config for step $_currentStep - state: ${config.state.name}, interactionDisabled: ${config.disableInteraction}',
    );
    return config;
  }

  @override
  Widget build(BuildContext context) {
    print(
      'WelcomeScreen: Building UI - showText=$_showText, showDataHandshake=$_showDataHandshake, step=$_currentStep',
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Globe Background (web: Globe.gl | other: empty)
          if (_showGlobe)
            Positioned.fill(child: GlobeWidget(config: _buildGlobeConfig())),

          // Onboarding message and controls
          if (_showText)
            OnboardingFlow(
              steps: _steps,
              currentIndex: _currentStep,
              onContinue: _onContinue,
              showDataHandshake: _showDataHandshake,
              isRequestingLocation: _isRequestingLocation,
              onAllowLocation: _handleAllowLocation,
              onSkipLocation: _handleSkipLocation,
              locationSlideController: _locationSlideController,
              nameController: _nameController,
              nameFocusNode: _nameFocusNode,
              onNameChanged: _onNameChanged,
              nameError: _nameError,
              hasAcceptedPolicy: _hasAcceptedPolicy,
              onPolicyChanged: _onPolicyChanged,
              policyError: _policyError,
            ),
        ],
      ),
    );
  }
}
