import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/meditation_models.dart';
import 'my_practice_modality.dart';

/// Setup step enum - defines the flow stages
enum SetupStep {
  modality,           // My Practice: Choose modality type
  myPracticeDuration, // My Practice: Scroll duration picker
  variant,            // Choose today/yesterday version
  duration,           // Set duration (preset buttons)
  ready,              // Ready to start
}

/// Step: Choose My Practice modality
class ModalityStep extends StatelessWidget {
  final MyPracticeModality? selectedModality;
  final ValueChanged<MyPracticeModality> onSelect;
  final VoidCallback onContinue;

  const ModalityStep({
    super.key,
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
class MyPracticeDurationStep extends StatefulWidget {
  final Duration selectedDuration;
  final ValueChanged<Duration> onDurationChanged;
  final VoidCallback onContinue;

  const MyPracticeDurationStep({
    super.key,
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.onContinue,
  });

  @override
  State<MyPracticeDurationStep> createState() => _MyPracticeDurationStepState();
}

class _MyPracticeDurationStepState extends State<MyPracticeDurationStep> {
  late FixedExtentScrollController _scrollController;
  late int _selectedMinutes;
  
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
            child: RulerPicker(
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

/// Custom ruler picker widget for duration selection
class RulerPicker extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChanged;

  const RulerPicker({
    super.key,
    required this.controller,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = maxValue - minValue + 1;
    
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
        itemExtent: 20,
        perspective: 0.001,
        diameterRatio: 100,
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
                          ? const Color(0xFFB8860B)
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
class VariantStep extends StatelessWidget {
  final PracticeTypeGroup group;
  final Practice selectedPractice;
  final ValueChanged<Practice> onSelect;
  final VoidCallback onContinue;

  const VariantStep({
    super.key,
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
              child: VariantOption(
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

/// Variant option card (Today/Yesterday selection)
class VariantOption extends StatelessWidget {
  final Practice variant;
  final bool isSelected;
  final VoidCallback onTap;

  const VariantOption({
    super.key,
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
class DurationStep extends StatelessWidget {
  final Practice practice;
  final Duration selectedDuration;
  final ValueChanged<Duration> onSelect;
  final VoidCallback onContinue;

  const DurationStep({
    super.key,
    required this.practice,
    required this.selectedDuration,
    required this.onSelect,
    required this.onContinue,
  });

  List<Duration> get _presetDurations {
    final min = practice.minDuration?.inMinutes ?? 5;
    final max = practice.maxDuration?.inMinutes ?? 30;
    
    final presets = <int>[];
    for (final d in [5, 10, 15, 20, 25, 30, 45, 60]) {
      if (d >= min && d <= max) {
        presets.add(d);
      }
    }
    
    if (presets.isEmpty) {
      presets.add(min);
    }
    
    return presets.map((m) => Duration(minutes: m)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final presets = _presetDurations;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 4),
            
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
              'Choose your duration',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Duration preset buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: presets.map((duration) {
                final isSelected = duration == selectedDuration;
                return GestureDetector(
                  onTap: () => onSelect(duration),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2B2B3C) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF2B2B3C) 
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFF2B2B3C).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ] : null,
                    ),
                    child: Text(
                      '${duration.inMinutes} min',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const Spacer(flex: 2),
            
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
class ReadyStep extends StatelessWidget {
  final Practice practice;
  final Duration duration;
  final String? modalityName;
  final VoidCallback onStart;

  const ReadyStep({
    super.key,
    required this.practice,
    required this.duration,
    this.modalityName,
    required this.onStart,
  });

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 4),
            
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
}

