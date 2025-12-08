import 'package:flutter/material.dart';

enum AnnouncementType { mission, master, practice, update, feedback, urgent }

class AnnouncementStory {
  final String id;
  final String title;
  final String body;
  final String caption;
  final String ctaLabel;
  final String? secondaryCtaLabel;
  final AnnouncementType type;
  final Gradient gradient;
  bool isNew;
  final VoidCallback? onCta;
  final VoidCallback? onSecondaryCta;

  AnnouncementStory({
    required this.id,
    required this.title,
    required this.body,
    required this.caption,
    required this.ctaLabel,
    required this.type,
    required this.gradient,
    this.isNew = true,
    this.onCta,
    this.secondaryCtaLabel,
    this.onSecondaryCta,
  });
}
