import 'package:flutter/material.dart';

enum MasterSessionState {
  upcoming,
  lobby,
  live,
  sealed,
}

class MasterGuide {
  final String id;
  final String name;
  final String title;
  final String description;
  final String startTime;
  final Duration duration;
  final int participantCount;
  final Gradient gradient;
  final MasterSessionState sessionState;
  final Duration? timeUntilStart;
  final Duration? timeRemaining;

  const MasterGuide({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.startTime,
    required this.duration,
    required this.participantCount,
    required this.gradient,
    this.sessionState = MasterSessionState.upcoming,
    this.timeUntilStart,
    this.timeRemaining,
  });
}
