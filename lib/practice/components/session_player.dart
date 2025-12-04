import 'package:flutter/material.dart';

class SessionPlayer extends StatelessWidget {
  final String statusLabel;
  final bool isPlaying;
  final double progress;
  final Duration elapsed;
  final Duration remaining;
  final Color accentColor;
  final VoidCallback? onToggle;
  final IconData playIcon;
  final IconData pauseIcon;

  const SessionPlayer({
    super.key,
    required this.statusLabel,
    required this.isPlaying,
    required this.progress,
    required this.elapsed,
    required this.remaining,
    required this.accentColor,
    this.onToggle,
    this.playIcon = Icons.play_arrow,
    this.pauseIcon = Icons.pause,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          statusLabel,
          style: TextStyle(
            color: Colors.black.withOpacity(0.75),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 148,
          height: 148,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: clampedProgress,
                strokeWidth: 6,
                backgroundColor: Colors.black.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation(accentColor),
              ),
              Material(
                color:
                    onToggle == null ? Colors.black54 : Colors.black,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onToggle,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(
                      isPlaying ? pauseIcon : playIcon,
                      color: Colors.white.withOpacity(onToggle == null ? 0.4 : 1),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${_formatDuration(elapsed)} elapsed · ${_formatDuration(remaining)} left',
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
