import 'package:flutter/material.dart';

class ReactionStateData {
  final String key;
  final String label;
  final String description;
  final Color color;

  const ReactionStateData({
    required this.key,
    required this.label,
    required this.description,
    required this.color,
  });
}

const List<ReactionStateData> reactionTaxonomy = [
  ReactionStateData(
    key: 'grounded',
    label: 'Grounded',
    description: 'Rooted, steady, supported.',
    color: Color(0xFF6E7F6A),
  ),
  ReactionStateData(
    key: 'joy',
    label: 'Joy',
    description: 'Light, expansive, delighted.',
    color: Color(0xFFFFB5A7),
  ),
  ReactionStateData(
    key: 'energy',
    label: 'Energy',
    description: 'Activated, buzzing, ready to move.',
    color: Color(0xFFFFD166),
  ),
  ReactionStateData(
    key: 'peace',
    label: 'Peace',
    description: 'Calm, soft, and rested.',
    color: Color(0xFFB8C0FF),
  ),
  ReactionStateData(
    key: 'release',
    label: 'Release',
    description: 'Let go of weight or tension.',
    color: Color(0xFF94A3B8),
  ),
  ReactionStateData(
    key: 'insight',
    label: 'Insight',
    description: 'Gained clarity or perspective.',
    color: Color(0xFF9D8DF1),
  ),
  ReactionStateData(
    key: 'unity',
    label: 'Unity',
    description: 'Deeply connected to others.',
    color: Color(0xFF80CED7),
  ),
];
