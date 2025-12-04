import '../services/practice_service.dart';

class HomeInitializationResult {
  final bool hasPracticed;
  final double? latitude;
  final double? longitude;

  const HomeInitializationResult({
    required this.hasPracticed,
    required this.latitude,
    required this.longitude,
  });
}

Future<HomeInitializationResult> loadHomeScreenState() async {
  final hasPracticed = await PracticeService.hasPracticedToday();
  final location = await PracticeService.getUserLocation();
  return HomeInitializationResult(
    hasPracticed: hasPracticed,
    latitude: location['latitude'],
    longitude: location['longitude'],
  );
}
