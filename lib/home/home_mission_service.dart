import 'package:flutter/material.dart';

import '../home/pages/units_section.dart';
import '../missions/mission_models.dart';

class MissionContributionResult {
  final List<UnitTransaction> updatedHistory;
  final List<Mission> updatedMissions;
  final int updatedBalance;
  final int updatedSpent;
  final Mission mission;
  final int pages;
  final int cost;

  MissionContributionResult({
    required this.updatedHistory,
    required this.updatedMissions,
    required this.updatedBalance,
    required this.updatedSpent,
    required this.mission,
    required this.pages,
    required this.cost,
  });
}

MissionContributionResult applyMissionContribution({
  required Mission mission,
  required int multiplier,
  required int currentBalance,
  required int spentThisWeek,
  required List<UnitTransaction> history,
  required List<Mission> missions,
}) {
  final cost = mission.unitCost * multiplier;
  final pages = mission.pagesPerContribution * multiplier;

  final newHistory = [
    UnitTransaction(
      title: mission.title,
      description: 'Contribution to digitize $pages page(s).',
      amount: -cost,
      icon: Icons.auto_awesome,
    ),
    ...history,
  ];

  final updatedMissions = missions.map((m) {
    if (m.id != mission.id) return m;
    final double contributedPages = (m.progress * m.totalPages) + pages;
    final double newProgress =
        (contributedPages / m.totalPages).clamp(0, 1).toDouble();
    return Mission(
      id: m.id,
      title: m.title,
      description: m.description,
      unitCost: m.unitCost,
      pagesPerContribution: m.pagesPerContribution,
      progress: newProgress,
      totalPages: m.totalPages,
      userPages: m.userPages + pages,
      manuscriptLocation: m.manuscriptLocation,
      manuscriptEra: m.manuscriptEra,
      importance: m.importance,
      preservationProcess: m.preservationProcess,
      isNew: false,
    );
  }).toList();

  return MissionContributionResult(
    updatedHistory: newHistory,
    updatedMissions: updatedMissions,
    updatedBalance: currentBalance - cost,
    updatedSpent: spentThisWeek + cost,
    mission: mission,
    pages: pages,
    cost: cost,
  );
}
