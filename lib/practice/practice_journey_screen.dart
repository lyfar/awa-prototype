import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/meditation_models.dart';
import '../models/master_guide.dart';
import '../models/saved_practice.dart';
import 'lobby_cards_view.dart';

part 'components/practice_journey_cards.dart';
part 'components/practice_journey_info_sheets.dart';

const Color _midnight = Color(0xFF2B2B3C);

class PracticeJourneyScreen extends StatefulWidget {
  final List<Practice> practices;
  final Map<PracticeType, List<Duration>> durationOptions;
  final List<MasterGuide> masters;
  final List<SavedPractice> savedPractices;
  final bool isPaidUser;
  final Map<String, Map<String, int>> reactionSnapshots;
  final VoidCallback? onUpgradeRequested;

  const PracticeJourneyScreen({
    super.key,
    required this.practices,
    required this.durationOptions,
    required this.masters,
    required this.savedPractices,
    required this.isPaidUser,
    this.reactionSnapshots = const {},
    this.onUpgradeRequested,
  });

  @override
  State<PracticeJourneyScreen> createState() => _PracticeJourneyScreenState();
}

class _PracticeJourneyScreenState extends State<PracticeJourneyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LobbyCardsView(
          practices: widget.practices,
          masters: widget.masters,
          savedPractices: widget.savedPractices,
          isPaidUser: widget.isPaidUser,
          reactionSnapshots: widget.reactionSnapshots,
          onItemSelected: _handleLobbySelection,
        ),
      ),
    );
  }

  void _handleLobbySelection(dynamic item) {
    if (item is MasterGuide) {
      _handleMasterTap(item);
    } else if (item is SavedPractice) {
      if (!widget.isPaidUser) {
        widget.onUpgradeRequested?.call();
        return;
      }
      final normalizedDuration = _clampDurationForPractice(
        item.practice,
        item.duration,
      );
      Navigator.of(context).pop(
        PracticeSelectionResult.practice(
          practice: item.practice,
          duration: normalizedDuration,
        ),
      );
    } else if (item is Practice) {
      _showConfigurationSheet(item);
    }
  }

  void _showConfigurationSheet(Practice practice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: _PracticeConfiguration(
                practice: practice,
                durations: _durationsFor(practice.type),
                onConfirm: (duration) {
                  Navigator.of(context).pop(); // Close sheet
                  Navigator.of(context).pop(
                    PracticeSelectionResult.practice(
                      practice: practice,
                      duration: duration,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleMasterTap(MasterGuide master) {
    if (!_canJoinMaster(master)) {
      _showMasterUnavailableMessage(master);
      return;
    }
    Navigator.of(context).pop(PracticeSelectionResult.master(master: master));
  }

  bool _canJoinMaster(MasterGuide? master) {
    if (master == null) return false;
    return master.sessionState == MasterSessionState.lobby ||
        master.sessionState == MasterSessionState.live;
  }

  void _showMasterUnavailableMessage(MasterGuide master) {
    final messenger = ScaffoldMessenger.of(context);
    String message;
    switch (master.sessionState) {
      case MasterSessionState.upcoming:
        final countdown = _formatMasterCountdown(master.timeUntilStart);
        message = 'Doors open soon. Starts in $countdown.';
        break;
      case MasterSessionState.lobby:
        final countdown = _formatMasterCountdown(master.timeUntilStart);
        message = 'Lobby unlocks in $countdown.';
        break;
      case MasterSessionState.live:
        message = 'Joining now...';
        break;
      case MasterSessionState.sealed:
        message =
            'This circle sealed after the first minute so everyone travels together. Subscribe for reminders to join next time.';
        break;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  List<Duration> _durationsFor(PracticeType type) {
    final override = widget.durationOptions[type];
    if (override != null && override.isNotEmpty) {
      return override;
    }
    final fallback = _practiceFor(type)?.duration;
    if (fallback != null) {
      return [fallback];
    }
    return const [Duration(minutes: 10)];
  }

  Practice? _practiceFor(PracticeType type) {
    try {
      return widget.practices.firstWhere((practice) => practice.type == type);
    } catch (_) {
      return null;
    }
  }

  Duration _clampDurationForPractice(Practice practice, Duration duration) {
    var result = duration;
    final min = practice.minDuration;
    final max = practice.maxDuration;
    if (min != null && duration < min) {
      result = min;
    }
    if (max != null && result > max) {
      result = max;
    }
    return result;
  }
}

class PracticeSelectionResult {
  final Practice? practice;
  final Duration? duration;
  final MasterGuide? master;

  PracticeSelectionResult.practice({
    required this.practice,
    required this.duration,
  }) : master = null;

  PracticeSelectionResult.master({required this.master})
      : practice = null,
        duration = null;

  bool get isMasterSelection => master != null;
}

class _PracticeConfiguration extends StatefulWidget {
  final Practice practice;
  final List<Duration> durations;
  final ValueChanged<Duration> onConfirm;

  const _PracticeConfiguration({
    required this.practice,
    required this.durations,
    required this.onConfirm,
  });

  @override
  State<_PracticeConfiguration> createState() => _PracticeConfigurationState();
}

class _PracticeConfigurationState extends State<_PracticeConfiguration> {
  Duration? _selectedDuration;
  final TextEditingController _customDurationController = TextEditingController(
    text: '10',
  );
  String? _customDurationError;

  @override
  void initState() {
    super.initState();
    if (widget.durations.isNotEmpty) {
      _selectedDuration = widget.durations.first;
    }
    if (widget.practice.hasCustomDuration) {
      final fallback = widget.practice.duration.inMinutes;
      _customDurationController.text = '$fallback';
    }
  }

  @override
  void dispose() {
    _customDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.practice.getName(),
          style: const TextStyle(
            color: _midnight,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how this ritual should unfold.',
          style: TextStyle(color: Colors.black.withOpacity(0.65)),
        ),
        const SizedBox(height: 24),
        _buildDurationSection(),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _midnight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Start Practice',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    if (widget.practice.hasCustomDuration) {
      return _buildCustomDurationInput();
    }
    
    final profiles = _buildDurationProfiles(widget.durations);
    if (profiles.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 500;
        final double optionWidth =
            isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final profile in profiles)
              SizedBox(
                width: optionWidth,
                child: _DurationOptionCard(
                  profile: profile,
                  isSelected: _selectedDuration == profile.duration,
                  onTap: () {
                    setState(() {
                      _selectedDuration = profile.duration;
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCustomDurationInput() {
    final helper = _durationHelperText();
    return TextField(
      controller: _customDurationController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Minutes',
        hintText: '${widget.practice.duration.inMinutes}',
        suffixText: 'min',
        errorText: _customDurationError,
        helperText: helper,
        filled: true,
        fillColor: Colors.black.withOpacity(0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _midnight, width: 2),
        ),
      ),
      onChanged: (_) {
        if (_customDurationError != null) {
          setState(() => _customDurationError = null);
        }
      },
    );
  }

  void _handleConfirm() {
    Duration? duration = _selectedDuration;
    if (widget.practice.hasCustomDuration) {
      final minutes = int.tryParse(_customDurationController.text);
      if (minutes == null || minutes <= 0) {
        setState(() {
          _customDurationError = 'Enter minutes greater than zero.';
        });
        return;
      }
      final min = widget.practice.minDuration?.inMinutes;
      final max = widget.practice.maxDuration?.inMinutes;
      if (min != null && minutes < min) {
        setState(() {
          _customDurationError = 'Minimum allowed is $min minutes.';
        });
        return;
      }
      if (max != null && minutes > max) {
        setState(() {
          _customDurationError = 'Maximum allowed is $max minutes.';
        });
        return;
      }
      duration = Duration(minutes: minutes);
    }

    if (duration != null) {
      widget.onConfirm(duration);
    }
  }

  List<_DurationProfile> _buildDurationProfiles(List<Duration> durations) {
    const labels = ['Quick spark', 'Steady orbit', 'Deep repair', 'Long ceremony'];
    final List<_DurationProfile> profiles = [];
    for (int i = 0; i < durations.length; i++) {
      final safeIndex = i < labels.length ? i : labels.length - 1;
      profiles.add(
        _DurationProfile(
          duration: durations[i],
          label: labels[safeIndex],
        ),
      );
    }
    return profiles;
  }

  String? _durationHelperText() {
    final min = widget.practice.minDuration?.inMinutes;
    final max = widget.practice.maxDuration?.inMinutes;
    if (min != null && max != null) {
      return 'Min $min min • Max $max min';
    }
    if (min != null) {
      return 'Min $min min';
    }
    if (max != null) {
      return 'Max $max min';
    }
    return null;
  }
}
