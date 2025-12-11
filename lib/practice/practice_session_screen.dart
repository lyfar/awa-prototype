import 'dart:async';

import 'package:flutter/material.dart';

import '../models/meditation_models.dart';
import '../widgets/spiral_backdrop.dart';
import '../reactions/reaction_palette.dart';
import '../subscription/awa_journey_screen.dart';
import '../soul/awa_sphere.dart';

const LinearGradient _sessionSpiralOverlay = LinearGradient(
  colors: [Color(0xCCFFFFFF), Color(0x66FFFFFF)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

/// Result data returned when a practice session ends
class PracticeCompletionResult {
  final bool completed;
  final Practice practice;
  final Duration plannedDuration;
  final Duration actualDuration;
  final ReactionStateData? reaction;
  final String? modalityName;

  const PracticeCompletionResult({
    required this.completed,
    required this.practice,
    required this.plannedDuration,
    required this.actualDuration,
    this.reaction,
    this.modalityName,
  });

  factory PracticeCompletionResult.completed({
    required Practice practice,
    required Duration plannedDuration,
    required Duration actualDuration,
    ReactionStateData? reaction,
    String? modalityName,
  }) {
    return PracticeCompletionResult(
      completed: true,
      practice: practice,
      plannedDuration: plannedDuration,
      actualDuration: actualDuration,
      reaction: reaction,
      modalityName: modalityName,
    );
  }

  factory PracticeCompletionResult.aborted({
    required Practice practice,
    required Duration plannedDuration,
    Duration? actualDuration,
    String? modalityName,
  }) {
    return PracticeCompletionResult(
      completed: false,
      practice: practice,
      plannedDuration: plannedDuration,
      actualDuration: actualDuration ?? Duration.zero,
      modalityName: modalityName,
    );
  }
}

class PracticeSessionScreen extends StatefulWidget {
  final Practice practice;
  final Duration duration;
  final String? modalityName;
  final bool isPaidUser;
  final bool isFavorited;

  const PracticeSessionScreen({
    super.key,
    required this.practice,
    required this.duration,
    this.modalityName,
    this.isPaidUser = false,
    this.isFavorited = false,
  });

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  bool _hasStarted = false;
  bool _isPlaying = false;
  double _progress = 0;
  Timer? _timer;
  bool _sessionComplete = false;
  String? _selectedReactionKey;
  int _elapsedSeconds = 0;
  late bool _isFavorited;
  late bool _isPaid;

  @override
  void initState() {
    super.initState();
    print('PracticeSessionScreen: Starting session for ${widget.practice.getName()}');
    _isFavorited = widget.isFavorited;
    _isPaid = widget.isPaidUser;
    _hasStarted = true;
    _isPlaying = true;
    _startTimer();
  }

  void _startSession() {
    if (_sessionComplete) return;
    setState(() {
      _hasStarted = true;
      _isPlaying = true;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_isPlaying || _sessionComplete) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds =
            ((_elapsedSeconds + 1).clamp(0, widget.duration.inSeconds)).toInt();
        _progress = _elapsedSeconds / widget.duration.inSeconds;
        if (_elapsedSeconds >= widget.duration.inSeconds) {
          timer.cancel();
          _enterCompletionState(autoComplete: true);
        }
      });
    });
  }

  void _enterCompletionState({bool autoComplete = false}) {
    if (_sessionComplete) return;

    setState(() {
      _sessionComplete = true;
      _isPlaying = false;
      _hasStarted = true;
      _progress = 1.0;
      _elapsedSeconds = widget.duration.inSeconds;
    });

    _timer?.cancel();
    print('PracticeSessionScreen: Session completed - awaiting reaction');
  }

  void _endSession() {
    print('PracticeSessionScreen: Session ended early');
    Navigator.of(context).pop(
      PracticeCompletionResult.aborted(
        practice: widget.practice,
        plannedDuration: widget.duration,
        actualDuration: Duration(seconds: _elapsedSeconds),
        modalityName: widget.modalityName,
      ),
    );
  }

  void _togglePlayPause() {
    if (_sessionComplete) return;
    setState(() {
      _isPlaying = !_isPlaying;
    });
    print('PracticeSessionScreen: ${_isPlaying ? "Playing" : "Paused"}');
    if (_isPlaying) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void _toggleFavorite() {
    if (!_isPaid) {
      _openAwaJourney();
      return;
    }
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  Future<void> _openAwaJourney() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AwaJourneyScreen(
          isCurrentlySubscribed: _isPaid,
          onSubscribed: () {
            if (!mounted) return;
            setState(() {
              _isPaid = true;
              _isFavorited = true;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  ReactionStateData? _reactionFor(String? key) {
    if (key == null) return null;
    return reactionTaxonomy.firstWhere(
      (reaction) => reaction.key == key,
      orElse: () => reactionTaxonomy.first,
    );
  }

  void _selectReaction(String key) {
    setState(() {
      _selectedReactionKey = key;
    });
    print('PracticeSessionScreen: Selected reaction - $key');
  }

  void _finishSession() {
    final reaction = _reactionFor(_selectedReactionKey);
    if (reaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick how you feel to finish.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final actualSeconds =
        (_elapsedSeconds.clamp(1, widget.duration.inSeconds)).toInt();
    final actualDuration = Duration(seconds: actualSeconds);

    Navigator.of(context).pop(
      PracticeCompletionResult.completed(
        practice: widget.practice,
        plannedDuration: widget.duration,
        actualDuration: actualDuration,
        reaction: reaction,
        modalityName: widget.modalityName,
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildReactionChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: reactionTaxonomy.map((reaction) {
        final selected = _selectedReactionKey == reaction.key;
        return ChoiceChip(
          label: Text(
            reaction.label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? reaction.color : Colors.black87,
            ),
          ),
          selected: selected,
          onSelected: (_) => _selectReaction(reaction.key),
          selectedColor: reaction.color.withOpacity(0.2),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: selected
                ? reaction.color
                : Colors.black.withOpacity(0.12),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final clampedProgress = _progress.clamp(0.0, 1.0);
    final remainingSeconds = (widget.duration.inSeconds * (1 - clampedProgress))
        .clamp(0, widget.duration.inSeconds)
        .round();
    final remaining = Duration(seconds: remainingSeconds);
    final canFinish = _selectedReactionKey != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full screen spiral background
          Positioned.fill(
            child: SpiralBackdrop(
              height: screenHeight,
              bleedFactor: 1.4,
              offsetFactor: 0.0,
              overlayGradient: _sessionSpiralOverlay,
            ),
          ),
          // AwaSoul header vibe
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: screenHeight * 0.3,
              child: AwaSphereHeader(
                height: screenHeight * 0.3,
                halfScreen: true,
                interactive: true,
              ),
            ),
          ),

          // Minimal UI overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar - close + time
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _endSession,
                        icon: const Icon(Icons.close, color: Colors.black54, size: 28),
                      ),
                      _buildFavoritePill(),
                      const Spacer(),
                      Text(
                        _formatTime(remaining),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),

                // Body content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: clampedProgress,
                            backgroundColor: Colors.black.withOpacity(0.08),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFCB29C)),
                            minHeight: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom docked control
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'How do you feel now?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Log a pulse so AwaSoul can light the map for you.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            _buildReactionChips(),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.06),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      size: 24,
                                      color: const Color(0xFF2B2B3C),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isPlaying ? 'Pause' : 'Resume',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2B2B3C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: canFinish ? _finishSession : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2B2B3C),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Finish practice',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritePill() {
    final bool locked = !_isPaid;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTap: _toggleFavorite,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: locked
                ? Colors.black.withOpacity(0.04)
                : Colors.black.withOpacity(0.06),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: locked
                  ? Colors.black.withOpacity(0.08)
                  : const Color(0xFF2B2B3C).withOpacity(0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                locked
                    ? Icons.lock_outline
                    : (_isFavorited ? Icons.favorite : Icons.favorite_border),
                size: 16,
                color: locked
                    ? Colors.black54
                    : (_isFavorited ? Colors.redAccent : Colors.black87),
              ),
              const SizedBox(width: 6),
              Text(
                locked
                    ? 'Favorites'
                    : (_isFavorited ? 'Added' : 'Add to favorites'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: locked
                      ? Colors.black54
                      : (_isFavorited ? Colors.black : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
