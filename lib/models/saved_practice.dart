import 'meditation_models.dart';

/// Represents a saved practice shortcut for quick access.
class SavedPractice {
  final String id;
  final Practice practice;
  final Duration duration;
  final String? note;
  final DateTime? savedAt;

  const SavedPractice({
    required this.id,
    required this.practice,
    required this.duration,
    this.note,
    this.savedAt,
  });

  @override
  bool operator ==(Object other) {
    return other is SavedPractice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SavedPractice(id: $id, practice: ${practice.id}, duration: ${duration.inMinutes}m)';
  }
}
