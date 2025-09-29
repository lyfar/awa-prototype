# Welcome Flow

Goal: move a first-time user through three emotive globe states before requesting location permission.

## High-level beats

1. **Light Ignition**
   - Visual: Single white core with soft halo, background nearly black.
   - Copy cue: `Welcome to your mindfulness journey`.
   - Globe config: `GlobeConfig.light(height: screenHeight)`.
   - Motion: No rotation, gentle pulse only.
   - Exit trigger: user taps `Continue`.

2. **Awa Soul Expansion**
   - Visual: Particle halo orbiting a darkened globe silhouette (no earth texture).
   - Copy cue: `Connect with a global community of practitioners`.
   - Globe config: `GlobeConfig.awaSoul(height: screenHeight)`.
   - Motion: Slow orbital drift, particles at varying altitudes.
   - Exit trigger: `Continue`.

3. **Global Community Reveal**
   - Visual: Earth blue marble texture fades in, clusters of community lights appear.
   - Copy cue: `Discover mindfulness practices from around the world`.
   - Globe config: `GlobeConfig.globe(height: screenHeight)`.
   - Motion: Planet rotates slowly; community dots shimmer.
   - Exit trigger: `Continue` leading to location permission card slide-up.

4. **Location Permission Card**
   - Visual: Slide-up card with `Enable Location` / `Skip` actions.
   - Behaviour: If permit granted → navigate to home. If skipped or denied → still navigate but without user light.

## Interaction notes

- Transitions are instantaneous (no intermediate animation config) while we simplify the renderer.
- Each `Continue` tap advances `_currentStep` and rebuilds the globe with the target config.
- Logging confirms step progression: watch for `WelcomeScreen: Transitioning from ...` lines.

## Copy references

- Strings live in `lib/services/language_service.dart`.
- Step 1: `welcome_step_1`
- Step 2: `welcome_step_2`
- Step 3: `welcome_step_3`
- Location: `location_title`, `allow_location`, `skip_location`.

## Future considerations

- When the renderer supports smooth transitions again, re-enable `GlobeConfig.lightToAwaSoul` and `awaSoulToGlobe` states and document timing requirements here.
- Add analytics events once product decides on onboarding funnel metrics.

