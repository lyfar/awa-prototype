/// Globe state definitions for the AWA mindfulness app
///
/// The globe visualization has 3 main states that represent different stages
/// of the user's journey with smooth transitions between them:
///
/// 1. **Light**: Single bright dot representing the user's inner light (welcome step 1)
/// 2. **AwaSoul**: Cloud of particles representing connected consciousness (welcome step 2, practice mode)
/// 3. **Globe**: Earth with particles representing global community (welcome step 3, home screen)
library;

enum GlobeState {
  /// Single bright dot - user's inner light (welcome onboarding step 1)
  light,

  /// Cloud of particles - Awa Soul consciousness (welcome step 2, practice sessions)
  awaSoul,

  /// Earth with community particles (welcome step 3, home screen)
  globe,
}

/// Transition states for smooth animations between main states
enum GlobeTransitionState {
  /// Transitioning from light to awaSoul (zooming out, particles appearing)
  lightToAwaSoul,

  /// Transitioning from awaSoul to globe (earth texture fading in)
  awaSoulToGlobe,

  /// Transitioning from globe to awaSoul (earth texture fading out)
  globeToAwaSoul,

  /// Transitioning from awaSoul to light (zooming in, particles disappearing)
  awaSoulToLight,
}

/// Configuration for globe appearance and behavior
class GlobeConfig {
  final GlobeState state;
  final GlobeTransitionState? transitionState;
  final bool showUserLight;
  final double? userLatitude;
  final double? userLongitude;
  final bool disableInteraction;
  final double height;
  final Duration transitionDuration;
  final bool isTransitioning;

  const GlobeConfig({
    required this.state,
    this.transitionState,
    this.showUserLight = false,
    this.userLatitude,
    this.userLongitude,
    this.disableInteraction = false,
    this.height = 200,
    this.transitionDuration = const Duration(milliseconds: 2000),
    this.isTransitioning = false,
  });

  /// Factory for welcome screen step 1 - single light
  factory GlobeConfig.light({
    double height = 200,
    bool disableInteraction = false,
  }) {
    return GlobeConfig(
      state: GlobeState.light,
      height: height,
      disableInteraction: disableInteraction,
    );
  }

  /// Factory for welcome screen step 2 / practice mode - particle cloud
  factory GlobeConfig.awaSoul({
    double height = 200,
    bool disableInteraction = false,
  }) {
    return GlobeConfig(
      state: GlobeState.awaSoul,
      height: height,
      disableInteraction: disableInteraction,
    );
  }

  /// Factory for welcome screen step 3 / home screen - earth with particles
  factory GlobeConfig.globe({
    double height = 200,
    bool showUserLight = false,
    double? userLatitude,
    double? userLongitude,
    bool disableInteraction = false,
  }) {
    return GlobeConfig(
      state: GlobeState.globe,
      showUserLight: showUserLight,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      disableInteraction: disableInteraction,
      height: height,
    );
  }

  /// Factory for transitioning from light to awaSoul
  factory GlobeConfig.lightToAwaSoul({
    double height = 200,
    bool disableInteraction = false,
    Duration transitionDuration = const Duration(milliseconds: 2000),
  }) {
    return GlobeConfig(
      state: GlobeState.light,
      transitionState: GlobeTransitionState.lightToAwaSoul,
      height: height,
      disableInteraction: disableInteraction,
      transitionDuration: transitionDuration,
      isTransitioning: true,
    );
  }

  /// Factory for transitioning from awaSoul to globe
  factory GlobeConfig.awaSoulToGlobe({
    double height = 200,
    bool showUserLight = false,
    double? userLatitude,
    double? userLongitude,
    bool disableInteraction = false,
    Duration transitionDuration = const Duration(milliseconds: 2000),
  }) {
    return GlobeConfig(
      state: GlobeState.awaSoul,
      transitionState: GlobeTransitionState.awaSoulToGlobe,
      showUserLight: showUserLight,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      height: height,
      disableInteraction: disableInteraction,
      transitionDuration: transitionDuration,
      isTransitioning: true,
    );
  }

  /// Factory for transitioning from globe to awaSoul
  factory GlobeConfig.globeToAwaSoul({
    double height = 200,
    bool disableInteraction = false,
    Duration transitionDuration = const Duration(milliseconds: 2000),
  }) {
    return GlobeConfig(
      state: GlobeState.globe,
      transitionState: GlobeTransitionState.globeToAwaSoul,
      height: height,
      disableInteraction: disableInteraction,
      transitionDuration: transitionDuration,
      isTransitioning: true,
    );
  }

  /// Factory for transitioning from awaSoul to light
  factory GlobeConfig.awaSoulToLight({
    double height = 200,
    bool disableInteraction = false,
    Duration transitionDuration = const Duration(milliseconds: 2000),
  }) {
    return GlobeConfig(
      state: GlobeState.awaSoul,
      transitionState: GlobeTransitionState.awaSoulToLight,
      height: height,
      disableInteraction: disableInteraction,
      transitionDuration: transitionDuration,
      isTransitioning: true,
    );
  }

  /// Create a copy of this config with updated values
  GlobeConfig copyWith({
    GlobeState? state,
    GlobeTransitionState? transitionState,
    bool? showUserLight,
    double? userLatitude,
    double? userLongitude,
    bool? disableInteraction,
    double? height,
    Duration? transitionDuration,
    bool? isTransitioning,
  }) {
    return GlobeConfig(
      state: state ?? this.state,
      transitionState: transitionState ?? this.transitionState,
      showUserLight: showUserLight ?? this.showUserLight,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      disableInteraction: disableInteraction ?? this.disableInteraction,
      height: height ?? this.height,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      isTransitioning: isTransitioning ?? this.isTransitioning,
    );
  }
}
