import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/meditation_models.dart';
import '../soul/awa_sphere.dart';
import 'practice_session_screen.dart';

/// My Practice modality options
class MyPracticeModality {
  final String id;
  final String name;
  final String nameRu;
  final IconData icon;

  const MyPracticeModality({
    required this.id,
    required this.name,
    required this.nameRu,
    required this.icon,
  });

  static const List<MyPracticeModality> all = [
    MyPracticeModality(id: 'meditation', name: 'Meditation', nameRu: 'Медитация', icon: Icons.self_improvement),
    MyPracticeModality(id: 'breathing', name: 'Breathing', nameRu: 'Дыхание', icon: Icons.air),
    MyPracticeModality(id: 'yoga', name: 'Yoga', nameRu: 'Йога', icon: Icons.accessibility_new),
    MyPracticeModality(id: 'trataka', name: 'Trataka', nameRu: 'Тратака', icon: Icons.remove_red_eye_outlined),
    MyPracticeModality(id: 'shadow_work', name: 'Shadow Work', nameRu: 'Работа с тенью', icon: Icons.nights_stay_outlined),
    MyPracticeModality(id: 'gratitude', name: 'Gratitude', nameRu: 'Благодарность', icon: Icons.favorite_outline),
    MyPracticeModality(id: 'affirmation', name: 'Affirmation', nameRu: 'Аффирмация', icon: Icons.record_voice_over_outlined),
    MyPracticeModality(id: 'silence', name: 'Silence', nameRu: 'Тишина', icon: Icons.volume_off_outlined),
    MyPracticeModality(id: 'visualization', name: 'Visualization', nameRu: 'Визуализация', icon: Icons.visibility_outlined),
    MyPracticeModality(id: 'journaling', name: 'Journaling', nameRu: 'Дневник', icon: Icons.edit_note),
    MyPracticeModality(id: 'body_scan', name: 'Body Scan', nameRu: 'Сканирование тела', icon: Icons.accessibility_outlined),
    MyPracticeModality(id: 'sound_bath', name: 'Sound Bath', nameRu: 'Звуковая ванна', icon: Icons.graphic_eq),
    MyPracticeModality(id: 'contemplation', name: 'Contemplation', nameRu: 'Созерцание', icon: Icons.lightbulb_outline),
    MyPracticeModality(id: 'mantra', name: 'Mantra', nameRu: 'Мантра', icon: Icons.music_note_outlined),
    MyPracticeModality(id: 'tai_chi', name: 'Tai Chi', nameRu: 'Тайцзи', icon: Icons.sports_martial_arts),
    MyPracticeModality(id: 'qi_gong', name: 'Qi Gong', nameRu: 'Цигун', icon: Icons.spa_outlined),
    MyPracticeModality(id: 'presence_walk', name: 'Presence Walk', nameRu: 'Прогулка в присутствии', icon: Icons.directions_walk),
    MyPracticeModality(id: 'nature_gazing', name: 'Nature Gazing', nameRu: 'Созерцание природы', icon: Icons.park_outlined),
    MyPracticeModality(id: 'dynamic', name: 'Dynamic Practices', nameRu: 'Динамические практики', icon: Icons.fitness_center),
    MyPracticeModality(id: 'dreamwork', name: 'Dreamwork', nameRu: 'Работа с снами', icon: Icons.bedtime_outlined),
  ];
}

/// Practice setup screen - AwaSoul guided flow for configuring practice
/// Each setting is one step where AwaSoul asks the user
class PracticeSetupScreen extends StatefulWidget {
  final PracticeTypeGroup practiceGroup;
  final Practice? preselectedPractice;
  final Duration? preselectedDuration;

  const PracticeSetupScreen({
    super.key,
    required this.practiceGroup,
    this.preselectedPractice,
    this.preselectedDuration,
  });

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  // Current step index
  int _currentStep = 0;
  
  // Selected practice variant (for rotation practices)
  late Practice _selectedPractice;
  
  // Selected duration (for practices with custom duration)
  late Duration _selectedDuration;
  
  // Selected modality (for My Practice)
  MyPracticeModality? _selectedModality;

  // Build steps dynamically based on practice type
  late List<_SetupStep> _steps;
  
  // Check if this is "My Practice"
  bool get _isMyPractice => widget.practiceGroup.type == PracticeType.myPractice;

  @override
  void initState() {
    super.initState();
    print('PracticeSetupScreen: Initializing for ${widget.practiceGroup.displayName}');
    _selectedPractice = widget.preselectedPractice ?? widget.practiceGroup.primaryPractice;
    _selectedDuration = widget.preselectedDuration ?? _selectedPractice.duration;
    if (_isMyPractice) {
      _selectedModality = MyPracticeModality.all.first;
      _selectedDuration = const Duration(minutes: 15); // Default for My Practice
    }
    _buildSteps();
  }

  void _buildSteps() {
    _steps = [];
    
    if (_isMyPractice) {
      // My Practice flow: Modality -> Duration -> Ready
      _steps.add(_SetupStep.modality);
      _steps.add(_SetupStep.myPracticeDuration);
      _steps.add(_SetupStep.ready);
    } else {
      // Regular practice flow
      // Step 1: Variant selection (only if practice has rotation/multiple versions)
      if (widget.practiceGroup.hasRotation && widget.practiceGroup.variants.length > 1) {
        _steps.add(_SetupStep.variant);
      }
      
      // Step 2: Duration selection (only if practice allows custom duration)
      if (_selectedPractice.hasCustomDuration) {
        _steps.add(_SetupStep.duration);
      }
      
      // Final step: Ready to start
      _steps.add(_SetupStep.ready);
    }
    
    print('PracticeSetupScreen: Built ${_steps.length} steps: ${_steps.map((s) => s.name).join(", ")}');
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _startPractice();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _startPractice() {
    final modalityInfo = _isMyPractice && _selectedModality != null 
        ? ' (${_selectedModality!.name})' 
        : '';
    print('PracticeSetupScreen: Starting practice - ${_selectedPractice.getName()}$modalityInfo for ${_selectedDuration.inMinutes} min');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PracticeSessionScreen(
          practice: _selectedPractice,
          duration: _selectedDuration,
          modalityName: _selectedModality?.name,
        ),
      ),
    );
  }

  void _selectVariant(Practice variant) {
    print('PracticeSetupScreen: Selected variant - ${variant.freshnessBadge}');
    setState(() {
      _selectedPractice = variant;
      // Update duration if practice has custom duration
      if (!variant.hasCustomDuration) {
        _selectedDuration = variant.duration;
      }
      // Rebuild steps in case duration step needs to be added/removed
      _buildSteps();
    });
  }

  void _selectDuration(Duration duration) {
    print('PracticeSetupScreen: Selected duration - ${duration.inMinutes} min');
    setState(() {
      _selectedDuration = duration;
    });
  }

  void _selectModality(MyPracticeModality modality) {
    print('PracticeSetupScreen: Selected modality - ${modality.name}');
    setState(() {
      _selectedModality = modality;
    });
  }

  Widget _buildCurrentStep() {
    if (_steps.isEmpty) {
      // No configuration needed, go straight to ready
      return _ReadyStep(
        practice: _selectedPractice,
        duration: _selectedDuration,
        modalityName: _selectedModality?.name,
        onStart: _startPractice,
      );
    }
    
    final step = _steps[_currentStep];
    switch (step) {
      case _SetupStep.modality:
        return _ModalityStep(
          selectedModality: _selectedModality,
          onSelect: _selectModality,
          onContinue: _nextStep,
        );
      case _SetupStep.myPracticeDuration:
        return _MyPracticeDurationStep(
          selectedDuration: _selectedDuration,
          onDurationChanged: _selectDuration,
          onContinue: _nextStep,
        );
      case _SetupStep.variant:
        return _VariantStep(
          group: widget.practiceGroup,
          selectedPractice: _selectedPractice,
          onSelect: _selectVariant,
          onContinue: _nextStep,
        );
      case _SetupStep.duration:
        return _DurationStep(
          practice: _selectedPractice,
          selectedDuration: _selectedDuration,
          onSelect: _selectDuration,
          onContinue: _nextStep,
        );
      case _SetupStep.ready:
        return _ReadyStep(
          practice: _selectedPractice,
          duration: _selectedDuration,
          modalityName: _selectedModality?.name,
          onStart: _startPractice,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDurationStep = _isMyPractice && _steps.isNotEmpty && _steps[_currentStep] == _SetupStep.myPracticeDuration;

    return Scaffold(
      backgroundColor: isDurationStep ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // AwaSphere at top (only for non-black screens) - standard size
          if (!isDurationStep)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AwaSphereHeader(
                interactive: false,
                secondaryColor: const Color(0xFFE8D5D0),
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
                color: _isMyPractice && _steps.isNotEmpty && _steps[_currentStep] == _SetupStep.myPracticeDuration
                    ? Colors.white54
                    : Colors.black54,
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
    final isDarkMode = _isMyPractice && _steps.isNotEmpty && _steps[_currentStep] == _SetupStep.myPracticeDuration;
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
                    : isDarkMode 
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1),
          ),
        );
      }),
    );
  }
}

enum _SetupStep {
  modality,         // My Practice: Choose modality type
  myPracticeDuration, // My Practice: Scroll duration picker
  variant,          // Choose today/yesterday version
  duration,         // Set duration (preset buttons)
  ready,            // Ready to start
}

/// Step: Choose My Practice modality
class _ModalityStep extends StatelessWidget {
  final MyPracticeModality? selectedModality;
  final ValueChanged<MyPracticeModality> onSelect;
  final VoidCallback onContinue;

  const _ModalityStep({
    required this.selectedModality,
    required this.onSelect,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 60),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'What type of\npractice today?',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Your practice can take any form',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Modality grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.8,
              ),
              itemCount: MyPracticeModality.all.length,
              itemBuilder: (context, index) {
                final modality = MyPracticeModality.all[index];
                final isSelected = selectedModality?.id == modality.id;
                
                return GestureDetector(
                  onTap: () => onSelect(modality),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF2B2B3C) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF2B2B3C) 
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFF2B2B3C).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ] : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          modality.icon,
                          size: 20,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            modality.name,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedModality != null ? onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B2B3C),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Step: My Practice duration with scroll picker (up to 180 min)
class _MyPracticeDurationStep extends StatefulWidget {
  final Duration selectedDuration;
  final ValueChanged<Duration> onDurationChanged;
  final VoidCallback onContinue;

  const _MyPracticeDurationStep({
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.onContinue,
  });

  @override
  State<_MyPracticeDurationStep> createState() => _MyPracticeDurationStepState();
}

class _MyPracticeDurationStepState extends State<_MyPracticeDurationStep> {
  late FixedExtentScrollController _scrollController;
  late int _selectedMinutes;
  
  // Min 1 minute, max 180 minutes
  static const int minMinutes = 1;
  static const int maxMinutes = 180;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.selectedDuration.inMinutes.clamp(minMinutes, maxMinutes);
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedMinutes - minMinutes,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 2),
          
          // Large number display
          Text(
            '$_selectedMinutes',
            style: GoogleFonts.urbanist(
              fontSize: 96,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              height: 1,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Ruler picker
          SizedBox(
            height: 60,
            child: _RulerPicker(
              controller: _scrollController,
              minValue: minMinutes,
              maxValue: maxMinutes,
              value: _selectedMinutes,
              onChanged: (value) {
                setState(() {
                  _selectedMinutes = value;
                });
                widget.onDurationChanged(Duration(minutes: value));
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'minutes',
            style: GoogleFonts.urbanist(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
          
          const Spacer(flex: 3),
          
          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Set $_selectedMinutes minutes',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom ruler picker widget
class _RulerPicker extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChanged;

  const _RulerPicker({
    required this.controller,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = maxValue - minValue + 1;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final index = controller.selectedItem;
          onChanged(minValue + index);
        }
        return true;
      },
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 20, // Width between ticks
        perspective: 0.001,
        diameterRatio: 100, // Very flat wheel for horizontal feel
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onChanged(minValue + index);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final tickValue = minValue + index;
            final isSelected = tickValue == value;
            final isMajor = tickValue % 5 == 0;
            final isHighlight = tickValue % 10 == 0;
            
            return Center(
              child: Container(
                width: 2,
                height: isHighlight ? 32 : (isMajor ? 24 : 16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white 
                      : isHighlight 
                          ? const Color(0xFFB8860B) // Gold for 10s
                          : isMajor 
                              ? Colors.white54 
                              : Colors.white24,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Step: Choose practice variant (Today/Yesterday)
class _VariantStep extends StatelessWidget {
  final PracticeTypeGroup group;
  final Practice selectedPractice;
  final ValueChanged<Practice> onSelect;
  final VoidCallback onContinue;

  const _VariantStep({
    required this.group,
    required this.selectedPractice,
    required this.onSelect,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 4),
            
            // AwaSoul question
            Text(
              'Which version\nwould you like?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New practices rotate daily',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Variant options
            ...group.variants.map((variant) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VariantOption(
                variant: variant,
                isSelected: variant.id == selectedPractice.id,
                onTap: () => onSelect(variant),
              ),
            )),
            
            const Spacer(flex: 2),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B2B3C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _VariantOption extends StatelessWidget {
  final Practice variant;
  final bool isSelected;
  final VoidCallback onTap;

  const _VariantOption({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  Color get _badgeColor {
    switch (variant.freshness) {
      case PracticeFreshness.today:
        return const Color(0xFF4CAF50);
      case PracticeFreshness.yesterday:
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  String get _badgeText {
    switch (variant.freshness) {
      case PracticeFreshness.today:
        return 'Today\'s New';
      case PracticeFreshness.yesterday:
        return 'Yesterday\'s';
      default:
        return variant.freshnessBadge;
    }
  }

  String get _subtitleText {
    switch (variant.freshness) {
      case PracticeFreshness.today:
        return 'Fresh content available now';
      case PracticeFreshness.yesterday:
        return 'Last chance before it expires';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF7F3) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFCB29C) : Colors.black.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFFFCB29C).withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _badgeText,
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant.availabilityLabel,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (_subtitleText.isNotEmpty)
                    Text(
                      _subtitleText,
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        color: Colors.black45,
                      ),
                    ),
                ],
              ),
            ),
            
            // Check
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFFCB29C) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFCB29C) : Colors.black.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Step: Set duration (preset buttons for regular practices)
class _DurationStep extends StatelessWidget {
  final Practice practice;
  final Duration selectedDuration;
  final ValueChanged<Duration> onSelect;
  final VoidCallback onContinue;

  const _DurationStep({
    required this.practice,
    required this.selectedDuration,
    required this.onSelect,
    required this.onContinue,
  });

  List<Duration> get _presetDurations {
    final min = practice.minDuration?.inMinutes ?? 5;
    final max = practice.maxDuration?.inMinutes ?? 30;
    
    final presets = <int>[];
    if (min <= 5 && max >= 5) presets.add(5);
    if (min <= 10 && max >= 10) presets.add(10);
    if (min <= 15 && max >= 15) presets.add(15);
    if (min <= 20 && max >= 20) presets.add(20);
    if (min <= 30 && max >= 30) presets.add(30);
    
    if (presets.isEmpty) presets.add(min);
    
    return presets.map((m) => Duration(minutes: m)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 4),
            
            // AwaSoul question
            Text(
              'How long would\nyou like to practice?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what feels right today',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Duration options - grid layout
            Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: _presetDurations.map((duration) {
                  final isSelected = duration == selectedDuration;
                  return GestureDetector(
                    onTap: () => onSelect(duration),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2B2B3C) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF2B2B3C) 
                              : Colors.black.withValues(alpha: 0.1),
                          width: 2,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: const Color(0xFF2B2B3C).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ] : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${duration.inMinutes}',
                            style: GoogleFonts.urbanist(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'min',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: isSelected ? Colors.white70 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const Spacer(flex: 2),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B2B3C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Step: Ready to start
class _ReadyStep extends StatelessWidget {
  final Practice practice;
  final Duration duration;
  final String? modalityName;
  final VoidCallback onStart;

  const _ReadyStep({
    required this.practice,
    required this.duration,
    this.modalityName,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 4),
            
            // Title
            Text(
              'Ready when\nyou are',
              style: GoogleFonts.playfairDisplay(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            
            // Guide text
            Text(
              'Find a quiet space.\nSettle in. Let the practice guide you.',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.black45,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCB29C).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getPracticeIcon(practice.type),
                      size: 26,
                      color: const Color(0xFFE88A6E),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          modalityName ?? practice.getName(),
                          style: GoogleFonts.urbanist(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2B2B3C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${duration.inMinutes} minutes',
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 2),
            
            // Start button (gradient)
            GestureDetector(
              onTap: onStart,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE8D5D0),
                      Color(0xFFD4A5B0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Start Practice',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  IconData _getPracticeIcon(PracticeType type) {
    switch (type) {
      case PracticeType.lightPractice:
        return Icons.wb_sunny_outlined;
      case PracticeType.guidedMeditation:
        return Icons.headphones_outlined;
      case PracticeType.soundMeditation:
        return Icons.graphic_eq;
      case PracticeType.myPractice:
        return Icons.self_improvement;
      case PracticeType.specialPractice:
        return Icons.auto_awesome;
    }
  }
}
