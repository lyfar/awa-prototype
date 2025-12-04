import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/practice_service.dart';
import '../../theme/home_colors.dart';
import 'awasoul_debug_screen.dart';

const Color _ink = Colors.white;
const Color _muted = Color(0xFFC3BCD8);

/// Debug section component for profile panel
class DebugSection extends StatefulWidget {
  final Function(bool) onPracticeStateChanged;
  final bool isPaidUser;
  final ValueChanged<bool> onPaidStatusChanged;
  final int awawayDay;
  final int awawayCycleLength;
  final ValueChanged<int> onAwawayDayChanged;

  const DebugSection({
    super.key,
    required this.onPracticeStateChanged,
    required this.isPaidUser,
    required this.onPaidStatusChanged,
    required this.awawayDay,
    required this.awawayCycleLength,
    required this.onAwawayDayChanged,
  });

  @override
  State<DebugSection> createState() => _DebugSectionState();
}

class _DebugSectionState extends State<DebugSection> {
  late double _previewDay;

  @override
  void initState() {
    super.initState();
    _previewDay = _clampDay(widget.awawayDay).toDouble();
  }

  @override
  void didUpdateWidget(covariant DebugSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.awawayDay != widget.awawayDay ||
        oldWidget.awawayCycleLength != widget.awawayCycleLength) {
      _previewDay = _clampDay(widget.awawayDay).toDouble();
    }
  }

  int get _effectiveCycleLength => widget.awawayCycleLength <= 0 ? 1 : widget.awawayCycleLength;

  int _clampDay(int day) {
    if (day < 1) {
      return 1;
    }
    if (day > _effectiveCycleLength) {
      return _effectiveCycleLength;
    }
    return day;
  }

  void _handleDaySliderChange(double value) {
    final int day = value.round();
    setState(() {
      _previewDay = day.toDouble();
    });
    widget.onAwawayDayChanged(day);
  }

  void _handlePresetSelected(int day) {
    setState(() {
      _previewDay = day.toDouble();
    });
    widget.onAwawayDayChanged(day);
  }

  @override
  Widget build(BuildContext context) {
    final presets =
        _streakPresets.where((preset) => preset.day <= _effectiveCycleLength).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Debug Controls',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: SwitchListTile(
            value: widget.isPaidUser,
            onChanged: widget.onPaidStatusChanged,
            title: const Text(
              'Premium mode',
              style: TextStyle(
                color: _ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Toggle to preview paid-only navigation and badges.',
              style: TextStyle(
                color: _muted.withValues(alpha: 0.9),
              ),
            ),
            activeColor: Colors.black,
            activeTrackColor: HomeColors.peach,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
          ),
        ),

        const SizedBox(height: 18),
        _buildStreakPreviewCard(presets),

        const SizedBox(height: 18),

        // Reset practice state button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () async {
                print('DebugSection: RESET BUTTON TAPPED!');
                try {
                  await PracticeService.resetPracticeData();
                  widget.onPracticeStateChanged(false);
                  print('DebugSection: Reset completed successfully');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Practice state reset successfully!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green.withValues(alpha: 0.8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  print('DebugSection: ERROR resetting practice state: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Failed to reset practice state',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.withValues(alpha: 0.8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
                ),
                child: const Text(
                  'RESET PRACTICE STATE',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Mark practice complete button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: Colors.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () async {
                print('DebugSection: MARK COMPLETE BUTTON TAPPED!');
                try {
                  await PracticeService.markPracticeCompleted();
                  widget.onPracticeStateChanged(true);
                  print('DebugSection: Mark complete finished successfully');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Practice marked as completed!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green.withValues(alpha: 0.8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  print('DebugSection: ERROR marking practice complete: $e');
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1),
                ),
                child: const Text(
                  'MARK PRACTICE COMPLETE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Reset location button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: Colors.orange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () async {
                print('DebugSection: RESET LOCATION BUTTON TAPPED!');
                try {
                  // Clear stored location data
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('last_location');
                  await prefs.remove('user_location_saved');

                  print('DebugSection: Location data reset successfully');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Location reset! You can now test the location permission feature.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.orange.withValues(alpha: 0.8),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  print('DebugSection: ERROR resetting location: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Failed to reset location data',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.withValues(alpha: 0.8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1),
                ),
                child: const Text(
                  'RESET LOCATION DATA',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        
        // AwaSoul Debug Section
        const Text(
          'Visual Debug',
          style: TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // AwaSoul Debug button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                print('DebugSection: Opening AwaSoul Debug screen');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AwaSoulDebugScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFB07C).withValues(alpha: 0.2),
                      const Color(0xFFE8967C).withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFB07C).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB07C).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.blur_circular,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AwaSoul Debug',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tweak particles, colors, bloom & animations',
                            style: TextStyle(
                              color: _muted.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: _muted,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakPreviewCard(List<_StreakPreset> presets) {
    final int dayLabel = _previewDay.round();
    final double sliderValue =
        _previewDay.clamp(1, _effectiveCycleLength.toDouble());
    final int? divisions = _effectiveCycleLength > 1 ? _effectiveCycleLength - 1 : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AWAWAY streak preview',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Preview day $dayLabel of $_effectiveCycleLength to debug sacred geometry states.',
            style: TextStyle(color: _muted, height: 1.3),
          ),
          Slider(
            value: sliderValue,
            min: 1,
            max: _effectiveCycleLength.toDouble(),
            divisions: divisions,
            activeColor: HomeColors.peach,
            inactiveColor: Colors.white.withValues(alpha: 0.2),
            label: 'Day $dayLabel',
            onChanged: _handleDaySliderChange,
          ),
          if (presets.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets
                  .map(
                    (preset) => ChoiceChip(
                      label: Text(preset.label),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color:
                            dayLabel == preset.day ? Colors.black : _muted,
                        fontWeight: FontWeight.w600,
                      ),
                      selected: dayLabel == preset.day,
                      onSelected: (_) => _handlePresetSelected(preset.day),
                      selectedColor: HomeColors.peach,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakPreset {
  final String label;
  final int day;

  const _StreakPreset(this.label, this.day);
}

const List<_StreakPreset> _streakPresets = [
  _StreakPreset('Seed circle', 1),
  _StreakPreset('Orbit bloom', 3),
  _StreakPreset('Triad weave', 6),
  _StreakPreset('Halo spiral', 9),
];
