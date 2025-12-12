import 'package:flutter/material.dart';

/// My Practice modality options - different types of personal practices users can log
class MyPracticeModality {
  final String id;
  final String name;
  final String nameRu;
  final IconData icon;

  const MyPracticeModality({
    required this.id,
    required this.name,
    required this.nameRu,
    required this.icon,
  });

  static const List<MyPracticeModality> all = [
    MyPracticeModality(
      id: 'meditation',
      name: 'Meditation',
      nameRu: 'Медитация',
      icon: Icons.self_improvement,
    ),
    MyPracticeModality(
      id: 'breathing',
      name: 'Breathing',
      nameRu: 'Дыхание',
      icon: Icons.air,
    ),
    MyPracticeModality(
      id: 'yoga',
      name: 'Yoga',
      nameRu: 'Йога',
      icon: Icons.accessibility_new,
    ),
    MyPracticeModality(
      id: 'trataka',
      name: 'Trataka',
      nameRu: 'Тратака',
      icon: Icons.remove_red_eye_outlined,
    ),
    MyPracticeModality(
      id: 'shadow_work',
      name: 'Shadow Work',
      nameRu: 'Работа с тенью',
      icon: Icons.nights_stay_outlined,
    ),
    MyPracticeModality(
      id: 'gratitude',
      name: 'Gratitude',
      nameRu: 'Благодарность',
      icon: Icons.favorite_outline,
    ),
    MyPracticeModality(
      id: 'affirmation',
      name: 'Affirmation',
      nameRu: 'Аффирмация',
      icon: Icons.record_voice_over_outlined,
    ),
    MyPracticeModality(
      id: 'silence',
      name: 'Silence',
      nameRu: 'Тишина',
      icon: Icons.volume_off_outlined,
    ),
    MyPracticeModality(
      id: 'visualization',
      name: 'Visualization',
      nameRu: 'Визуализация',
      icon: Icons.visibility_outlined,
    ),
    MyPracticeModality(
      id: 'journaling',
      name: 'Journaling',
      nameRu: 'Дневник',
      icon: Icons.edit_note,
    ),
    MyPracticeModality(
      id: 'body_scan',
      name: 'Body Scan',
      nameRu: 'Сканирование тела',
      icon: Icons.accessibility_outlined,
    ),
    MyPracticeModality(
      id: 'sound_bath',
      name: 'Sound Bath',
      nameRu: 'Звуковая ванна',
      icon: Icons.graphic_eq,
    ),
    MyPracticeModality(
      id: 'contemplation',
      name: 'Contemplation',
      nameRu: 'Созерцание',
      icon: Icons.lightbulb_outline,
    ),
    MyPracticeModality(
      id: 'mantra',
      name: 'Mantra',
      nameRu: 'Мантра',
      icon: Icons.music_note_outlined,
    ),
    MyPracticeModality(
      id: 'tai_chi',
      name: 'Tai Chi',
      nameRu: 'Тайцзи',
      icon: Icons.sports_martial_arts,
    ),
    MyPracticeModality(
      id: 'qi_gong',
      name: 'Qi Gong',
      nameRu: 'Цигун',
      icon: Icons.spa_outlined,
    ),
    MyPracticeModality(
      id: 'presence_walk',
      name: 'Presence Walk',
      nameRu: 'Прогулка в присутствии',
      icon: Icons.directions_walk,
    ),
    MyPracticeModality(
      id: 'nature_gazing',
      name: 'Nature Gazing',
      nameRu: 'Созерцание природы',
      icon: Icons.park_outlined,
    ),
    MyPracticeModality(
      id: 'dynamic',
      name: 'Dynamic Practices',
      nameRu: 'Динамические практики',
      icon: Icons.fitness_center,
    ),
    MyPracticeModality(
      id: 'dreamwork',
      name: 'Dreamwork',
      nameRu: 'Работа с снами',
      icon: Icons.bedtime_outlined,
    ),
  ];
}











