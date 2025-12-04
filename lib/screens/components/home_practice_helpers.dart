part of 'package:awa_01_spark/screens/home_screen.dart';

String practiceCanvasHeadline(PracticeFlowState state) {
  switch (state) {
    case PracticeFlowState.practiceSelect:
      return 'AWA Soul is ready to guide you';
    case PracticeFlowState.practicing:
      return 'Session in progress';
    case PracticeFlowState.completing:
      return 'Sealing your light';
    case PracticeFlowState.home:
      return 'Awaiting the next practice';
  }
}

String practiceCanvasDescription(PracticeFlowState state) {
  switch (state) {
    case PracticeFlowState.practiceSelect:
      return 'Choose intention and settle into the white canvas to begin.';
    case PracticeFlowState.practicing:
      return 'Follow the scripted prompts. Your globe light will brighten soon.';
    case PracticeFlowState.completing:
      return 'Recording the session and preparing Light Ignition.';
    case PracticeFlowState.home:
      return 'Return to the globe whenever you are ready.';
  }
}

List<String> practiceScriptFor({
  required PracticeType? chosenType,
  required Practice? selectedPractice,
  required Map<PracticeType, List<String>> scripts,
}) {
  final type = chosenType ?? selectedPractice?.type;
  if (type != null && scripts.containsKey(type)) {
    return scripts[type]!;
  }
  return scripts[PracticeType.lightPractice] ?? const [];
}

List<Practice> availablePracticeSummaries() {
  // Surface all active variants (e.g., Day 1/Day 2 rotations) instead of
  // collapsing by type so availability rules stay visible in the Lobby.
  return List<Practice>.from(Practices.all);
}

Practice findPracticeForType(PracticeType type) {
  return Practices.all.firstWhere(
    (practice) => practice.type == type,
    orElse: () => Practices.all.first,
  );
}
