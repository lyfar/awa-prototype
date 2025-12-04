import 'package:flutter/material.dart';

class FaqItem {
  final String question;
  final String answer;
  final String category;
  final IconData icon;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
    this.icon = Icons.help_outline,
  });
}
