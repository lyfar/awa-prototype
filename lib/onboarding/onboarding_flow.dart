import 'package:flutter/material.dart';
import 'steps/step_message.dart';
import '../services/language_service.dart';
import '../widgets/language_switcher.dart';
import 'steps/data_handshake_card.dart';

/// A simple model describing onboarding steps
class OnboardingStep {
  final String translationKey;
  const OnboardingStep(this.translationKey);

  /// Get localized message for current language
  String get message => LanguageService.getText(translationKey);
}

class OnboardingFlow extends StatefulWidget {
  final List<OnboardingStep> steps;
  final int currentIndex;
  final VoidCallback onContinue;
  final bool showDataHandshake;
  final bool isRequestingLocation;
  final VoidCallback onAllowLocation;
  final VoidCallback onSkipLocation;
  final AnimationController? locationSlideController;
  final TextEditingController? nameController;
  final FocusNode? nameFocusNode;
  final ValueChanged<String>? onNameChanged;
  final String? nameError;
  final bool hasAcceptedPolicy;
  final ValueChanged<bool>? onPolicyChanged;
  final bool policyError;

  const OnboardingFlow({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.onContinue,
    required this.showDataHandshake,
    required this.isRequestingLocation,
    required this.onAllowLocation,
    required this.onSkipLocation,
    this.locationSlideController,
    this.nameController,
    this.nameFocusNode,
    this.onNameChanged,
    this.nameError,
    this.hasAcceptedPolicy = false,
    this.onPolicyChanged,
    this.policyError = false,
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  bool _showLanguageSwitcher = false;

  void _toggleLanguageSwitcher() {
    print(
      'OnboardingFlow: Toggling language switcher - current: $_showLanguageSwitcher',
    );
    setState(() {
      _showLanguageSwitcher = !_showLanguageSwitcher;
    });
  }

  void _onLanguageChanged() {
    print('OnboardingFlow: Language changed, updating UI and closing drawer');
    setState(() {
      _showLanguageSwitcher = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
      'OnboardingFlow: Building flow - showDataHandshake=${widget.showDataHandshake}, currentIndex=${widget.currentIndex}, showLanguage=$_showLanguageSwitcher',
    );
    return Stack(
      children: [
        StepMessage(
          key: ValueKey(
            '${widget.currentIndex}_${LanguageService.currentLanguage}',
          ),
          text: widget.steps[widget.currentIndex].message,
          top: 40,
        ),

        // Language switcher stays accessible across states, including final handshake
        if (!widget.showDataHandshake ||
            widget.currentIndex == widget.steps.length - 1)
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: _toggleLanguageSwitcher,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.language,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ),
            ),
          ),

        // Language switcher drawer
        LanguageSwitcher(
          isVisible: _showLanguageSwitcher,
          onLanguageChanged: _onLanguageChanged,
        ),

        if (!widget.showDataHandshake)
          Positioned(
            bottom:
                _showLanguageSwitcher
                    ? 120
                    : 80, // Push down when language drawer is open
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              color: Colors.transparent,
              height: 80,
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    print(
                      'OnboardingFlow: Continue button tapped, index: ${widget.currentIndex}',
                    );
                    // Close language drawer if open
                    if (_showLanguageSwitcher) {
                      _onLanguageChanged();
                      return;
                    }
                    widget.onContinue();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      LanguageService.getText('continue'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (widget.showDataHandshake && widget.nameController != null)
          widget.locationSlideController != null
              ? AnimatedBuilder(
                animation: widget.locationSlideController!,
                builder: (context, child) {
                  return Positioned(
                    bottom:
                        (_showLanguageSwitcher ? 150 : 90) -
                        (120 * (1 - widget.locationSlideController!.value)),
                    left: 20,
                    right: 20,
                    child: Opacity(
                      opacity: widget.locationSlideController!.value,
                      child: DataHandshakeCard(
                        nameController: widget.nameController!,
                        nameFocusNode: widget.nameFocusNode,
                        onNameChanged: widget.onNameChanged,
                        nameError: widget.nameError,
                        hasAcceptedPolicy: widget.hasAcceptedPolicy,
                        policyError: widget.policyError,
                        onPolicyChanged: widget.onPolicyChanged,
                        isRequesting: widget.isRequestingLocation,
                        onAllow: widget.onAllowLocation,
                        onSkip: widget.onSkipLocation,
                      ),
                    ),
                  );
                },
              )
              : Positioned(
                bottom: _showLanguageSwitcher ? 150 : 90,
                left: 20,
                right: 20,
                child: DataHandshakeCard(
                  nameController: widget.nameController!,
                  nameFocusNode: widget.nameFocusNode,
                  onNameChanged: widget.onNameChanged,
                  nameError: widget.nameError,
                  hasAcceptedPolicy: widget.hasAcceptedPolicy,
                  policyError: widget.policyError,
                  onPolicyChanged: widget.onPolicyChanged,
                  isRequesting: widget.isRequestingLocation,
                  onAllow: widget.onAllowLocation,
                  onSkip: widget.onSkipLocation,
                ),
              ),
      ],
    );
  }
}
