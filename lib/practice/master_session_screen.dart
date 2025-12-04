import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/master_guide.dart';
import '../reactions/reaction_palette.dart';
import 'components/master_presence_card.dart';
import 'components/master_session_sections.dart';
import 'components/session_player.dart';
import 'master_session_feedback_screen.dart';

class MasterSessionScreen extends StatefulWidget {
  final MasterGuide master;

  const MasterSessionScreen({super.key, required this.master});

  @override
  State<MasterSessionScreen> createState() => _MasterSessionScreenState();
}

class _MasterSessionScreenState extends State<MasterSessionScreen> {
  bool _isPlaying = true;
  double _progress = 0;
  Timer? _timer;
  bool _sessionFinished = false;
  late Map<String, int> _presenceFeelingCounts;
  ReactionStateData? _selectedLiveFeeling;
  final List<PresenceFeelingMarker> _liveFeelingMarkers = [];

  @override
  void initState() {
    super.initState();
    _seedPresenceData();
    _startFakeProgress();
  }

  void _startFakeProgress() {
    _timer?.cancel();
    if (!_isPlaying) return;
    final totalSeconds = widget.master.duration.inSeconds;
    if (totalSeconds == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 1 / totalSeconds;
        if (_progress >= 1) {
          _progress = 1;
          _sessionFinished = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _seedPresenceData() {
    final random = math.Random();
    _presenceFeelingCounts = {
      for (final reaction in reactionTaxonomy) reaction.key: 3 + random.nextInt(6),
    };
    _liveFeelingMarkers.clear();
    for (int i = 0; i < 3; i++) {
      final reaction = reactionTaxonomy[random.nextInt(reactionTaxonomy.length)];
      final progress = (i + 1) / 8;
      _liveFeelingMarkers.add(
        PresenceFeelingMarker(
          progress: progress,
          reaction: reaction,
          label: _formatMarkerLabel(progress),
        ),
      );
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _startFakeProgress();
    } else {
      _timer?.cancel();
    }
  }

  void _handleLiveFeelingSelected(ReactionStateData reaction) {
    if (!_isPlaying || _sessionFinished) return;
    setState(() {
      _selectedLiveFeeling = reaction;
      _presenceFeelingCounts[reaction.key] =
          (_presenceFeelingCounts[reaction.key] ?? 0) + 1;
      final marker = PresenceFeelingMarker(
        progress: _progress.clamp(0, 1),
        reaction: reaction,
        label: _formatMarkerLabel(_progress),
      );
      _liveFeelingMarkers.add(marker);
      if (_liveFeelingMarkers.length > 20) {
        _liveFeelingMarkers.removeAt(0);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared ${reaction.label} with everyone in the room'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatMarkerLabel(double progress) {
    final totalSeconds = widget.master.duration.inSeconds;
    final seconds = (totalSeconds * progress).clamp(0, totalSeconds).round();
    final duration = Duration(seconds: seconds);
    final minutesStr = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secondsStr = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    setState(() {
      _sessionFinished = true;
      _progress = 1;
      _isPlaying = false;
    });
    final reaction = await Navigator.of(context).push<ReactionStateData>(
      MaterialPageRoute(
        builder: (_) => MasterSessionFeedbackScreen(master: widget.master),
      ),
    );
    if (!mounted) return;
    if (reaction != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shared ${reaction.label} with ${widget.master.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final master = widget.master;
    final textTheme = Theme.of(context).textTheme;
    final duration = master.duration;
    final elapsed = duration * _progress;
    final remaining = duration * (1 - _progress);
    final accent = master.gradient.colors.first;
    final statusLabel =
        _sessionFinished
            ? 'Complete'
            : (_isPlaying ? 'Master session in progress' : 'Paused');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(master.title, style: const TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 160),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildHeroCard(master, textTheme),
            const SizedBox(height: 24),
            MasterPresenceCard(
              participantCount: master.participantCount,
              startTime: master.startTime,
              sessionProgress: _progress,
              reactions: reactionTaxonomy,
              feelingCounts: _presenceFeelingCounts,
              feelingMarkers: List.unmodifiable(_liveFeelingMarkers),
              selectedFeeling: _selectedLiveFeeling,
              allowFeelingSelection: !_sessionFinished,
              onFeelingSelected: _handleLiveFeelingSelected,
            ),
            const SizedBox(height: 24),
            SessionPlayer(
              statusLabel: statusLabel,
              isPlaying: _isPlaying,
              progress: _progress,
              elapsed: elapsed,
              remaining: remaining,
              accentColor: accent,
              onToggle: _sessionFinished ? null : _togglePlayPause,
            ),
            const SizedBox(height: 24),
            MasterSessionStatsRow(master: master),
            const SizedBox(height: 24),
            MasterLobbyCard(master: master),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _finishSession,
              icon: const Icon(Icons.favorite_border),
              label: const Text('Finish & leave feeling'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(MasterGuide master, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: master.gradient,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            master.title,
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'with ${master.name} • ${master.startTime}',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Text(
            master.description,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
