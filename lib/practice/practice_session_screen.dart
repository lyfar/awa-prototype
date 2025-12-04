import 'dart:async';

import 'package:flutter/material.dart';

import '../models/meditation_models.dart';
import '../widgets/spiral_backdrop.dart';
import 'practice_feedback_screen.dart';

const LinearGradient _sessionSpiralOverlay = LinearGradient(
  colors: [Color(0xCCFFFFFF), Color(0x66FFFFFF)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

class PracticeSessionScreen extends StatefulWidget {
  final Practice practice;
  final Duration duration;
  final String? modalityName;

  const PracticeSessionScreen({
    super.key,
    required this.practice,
    required this.duration,
    this.modalityName,
  });

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  bool _isPlaying = true;
  double _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    print('PracticeSessionScreen: Starting session for ${widget.practice.getName()}');
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_isPlaying) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 1 / widget.duration.inSeconds;
        if (_progress >= 1) {
          _progress = 1;
          timer.cancel();
          _completeSession();
        }
      });
    });
  }

  void _completeSession() async {
    print('PracticeSessionScreen: Session completed, opening feedback');
    
    // Navigate to feedback screen
    final result = await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PracticeFeedbackScreen(
          practice: widget.practice,
          duration: widget.duration,
          modalityName: widget.modalityName,
        ),
      ),
    );
    
    // Result will be handled by the feedback screen's pop
  }

  void _endSession() {
    print('PracticeSessionScreen: Session ended early');
    Navigator.of(context).pop(false);
  }

  void _togglePlayPause() {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final remaining = widget.duration * (1 - _progress);

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

          // Minimal UI overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar - just close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _endSession,
                        icon: const Icon(Icons.close, color: Colors.black54, size: 28),
                      ),
                      const Spacer(),
                      // Time remaining
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

                const Spacer(),

                // Center - Play/Pause button
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 50,
                      color: const Color(0xFF2B2B3C),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Progress indicator (minimal)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.black.withOpacity(0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFCB29C)),
                      minHeight: 4,
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom - End button
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2B2B3C),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
