class Mission {
  final String id;
  final String title;
  final String description;
  final int unitCost;
  final int pagesPerContribution;
  final double progress;
  final int totalPages;
  final int userPages;
  final String manuscriptLocation;
  final String manuscriptEra;
  final String importance;
  final String preservationProcess;
  final bool isNew;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.unitCost,
    required this.pagesPerContribution,
    required this.progress,
    required this.totalPages,
    required this.userPages,
    required this.manuscriptLocation,
    required this.manuscriptEra,
    required this.importance,
    required this.preservationProcess,
    this.isNew = false,
  });
}
