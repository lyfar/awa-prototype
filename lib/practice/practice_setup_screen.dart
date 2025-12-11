import 'package:flutter/material.dart';
import '../models/meditation_models.dart';
import '../soul/awa_sphere.dart';
import 'practice_session_screen.dart';
import 'components/my_practice_modality.dart';
import 'components/setup_steps.dart';

/// Practice setup screen - AwaSoul guided flow for configuring practice
/// Each setting is one step where AwaSoul asks the user
class PracticeSetupScreen extends StatefulWidget {
  final PracticeTypeGroup practiceGroup;
  final Practice? preselectedPractice;
  final Duration? preselectedDuration;
  final bool isPaidUser;

  const PracticeSetupScreen({
    super.key,
    required this.practiceGroup,
    this.preselectedPractice,
    this.preselectedDuration,
    this.isPaidUser = false,
  });

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  int _currentStep = 0;
  late Practice _selectedPractice;
  late Duration _selectedDuration;
  MyPracticeModality? _selectedModality;
  late List<SetupStep> _steps;
  
  bool get _isMyPractice => widget.practiceGroup.type == PracticeType.myPractice;

  @override
  void initState() {
    super.initState();
    print('PracticeSetupScreen: Initializing for ${widget.practiceGroup.displayName}');
    _selectedPractice = widget.preselectedPractice ?? widget.practiceGroup.primaryPractice;
    _selectedDuration = widget.preselectedDuration ?? _selectedPractice.duration;
    if (_isMyPractice) {
      _selectedModality = MyPracticeModality.all.first;
      _selectedDuration = const Duration(minutes: 15);
    }
    _buildSteps();
  }

  void _buildSteps() {
    _steps = [];
    
    if (_isMyPractice) {
      _steps.add(SetupStep.modality);
      _steps.add(SetupStep.myPracticeDuration);
      _steps.add(SetupStep.ready);
    } else {
      final bool shouldShowVariantStep =
          widget.practiceGroup.hasRotation &&
          widget.practiceGroup.variants.length > 1 &&
          widget.preselectedPractice == null;
      if (shouldShowVariantStep) {
        _steps.add(SetupStep.variant);
      }
      if (_selectedPractice.hasCustomDuration) {
        _steps.add(SetupStep.duration);
      }
      _steps.add(SetupStep.ready);
    }
    
    print('PracticeSetupScreen: Built ${_steps.length} steps: ${_steps.map((s) => s.name).join(", ")}');
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _startPractice();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _startPractice() async {
    final modalityInfo = _isMyPractice && _selectedModality != null 
        ? ' (${_selectedModality!.name})' 
        : '';
    print('PracticeSetupScreen: Starting practice - ${_selectedPractice.getName()}$modalityInfo for ${_selectedDuration.inMinutes} min');
    final result = await Navigator.of(context).push<PracticeCompletionResult>(
      MaterialPageRoute(
        builder: (context) => PracticeSessionScreen(
          practice: _selectedPractice,
          duration: _selectedDuration,
          modalityName: _selectedModality?.name,
          isPaidUser: widget.isPaidUser,
        ),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(result);
    }
  }

  void _selectVariant(Practice variant) {
    print('PracticeSetupScreen: Selected variant - ${variant.freshnessBadge}');
    setState(() {
      _selectedPractice = variant;
      if (!variant.hasCustomDuration) {
        _selectedDuration = variant.duration;
      }
      _buildSteps();
    });
  }

  void _selectDuration(Duration duration) {
    print('PracticeSetupScreen: Selected duration - ${duration.inMinutes} min');
    setState(() => _selectedDuration = duration);
  }

  void _selectModality(MyPracticeModality modality) {
    print('PracticeSetupScreen: Selected modality - ${modality.name}');
    setState(() => _selectedModality = modality);
  }

  Widget _buildCurrentStep() {
    if (_steps.isEmpty) {
      return ReadyStep(
        practice: _selectedPractice,
        duration: _selectedDuration,
        modalityName: _selectedModality?.name,
        onStart: _startPractice,
      );
    }
    
    final step = _steps[_currentStep];
    switch (step) {
      case SetupStep.modality:
        return ModalityStep(
          selectedModality: _selectedModality,
          onSelect: _selectModality,
          onContinue: _nextStep,
        );
      case SetupStep.myPracticeDuration:
        return MyPracticeDurationStep(
          selectedDuration: _selectedDuration,
          onDurationChanged: _selectDuration,
          onContinue: _nextStep,
        );
      case SetupStep.variant:
        return VariantStep(
          group: widget.practiceGroup,
          selectedPractice: _selectedPractice,
          onSelect: _selectVariant,
          onContinue: _nextStep,
        );
      case SetupStep.duration:
        return DurationStep(
          practice: _selectedPractice,
          selectedDuration: _selectedDuration,
          onSelect: _selectDuration,
          onContinue: _nextStep,
        );
      case SetupStep.ready:
        return ReadyStep(
          practice: _selectedPractice,
          duration: _selectedDuration,
          modalityName: _selectedModality?.name,
          onStart: _startPractice,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // AwaSphere at top - half screen size
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AwaSphereHeader(
              halfScreen: true,
              interactive: true,
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              onPressed: _goBack,
              icon: Icon(
                _currentStep == 0 ? Icons.close : Icons.arrow_back,
                color: Colors.black54,
              ),
            ),
          ),

          // Step indicator
          if (_steps.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: _buildStepIndicator(),
            ),

          // Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: KeyedSubtree(
              key: ValueKey(_currentStep),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (index) {
        final isActive = index == _currentStep;
        final isPast = index < _currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive 
                ? const Color(0xFFFCB29C) 
                : isPast 
                    ? const Color(0xFFFCB29C).withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.1),
          ),
        );
      }),
    );
  }
}
