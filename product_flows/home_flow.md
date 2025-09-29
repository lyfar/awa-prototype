# Home Screen Flow

Goal: provide a calm landing surface with the globe as hero, highlighting daily practice and access to profile.

## Layout anatomy

1. **Header strip (SafeArea)**
   - Component: `HomeHeader`.
   - Contents: profile avatar toggle (opens profile panel), optional settings slot.
   - Interaction: tapping avatar toggles `_showUserProfile`.

2. **Hero globe section**
   - Widget: `GlobeWidget(config: _buildGlobeConfig())`.
   - Config rules:
     - Default: `GlobeConfig.globe` with `showUserLight` based on `_hasPracticedToday` + stored lat/lng.
     - While in practice selection or session: switch to `GlobeConfig.awaSoul` to echo the meditative particle field.
   - Height: `MediaQuery.of(context).size.height` (full viewport minus overlays).
   - Interaction: pointer events disabled when profile panel is open.

3. **Bottom card (two-thirds overlay)**
   - Visual: Glassy gradient card with pill handle, central copy, dot indicators, and `Start` button.
   - Copy sources:
     - Title: `daily_practice`.
     - Subtitle: `practice_completed_today` if practiced, else `start_your_journey`.
   - Action button: `LanguageService.getText('begin_session')` (displayed as “Start”).
   - Button tap: triggers `_startPracticeFlow()` → practice selection scene.

4. **Profile side panel (overlay)**
   - Trigger: header avatar.
   - Behavior: slides in from right, blocks globe interaction via `IgnorePointer`.
   - Dismiss: tap outside or close control.

## State machine

- `_practiceState`
  - `home`: Show globe state with optional user light. Bottom card CTA begins practice.
  - `practiceSelect` / `inSession`: Swap globe config to `awaSoul` and surface corresponding practice UI (defined in `practice_flow.md`).
  - `completing`: Wait for backend confirmation, then mark practiced and return to `home`.

- `_hasPracticedToday`
  - True: show celebratory subtitle, enable user light on globe and reduce CTA urgency.
  - False: default copy encourages starting session.

- `_userLatitude` / `_userLongitude`
  - Populated via `PracticeService.getUserLocation()` once location permissions granted.
  - When present + `_hasPracticedToday == true`, pass to `GlobeConfig.globe` to render personal light.

## Navigation hooks

- `Navigator.pushReplacementNamed('/home')` executed from welcome flow or after practice completion.
- Future modules (e.g., course library) should originate from the bottom card or header icons and be documented here when defined.

## Visual goals

- Maintain black-to-indigo gradient behind the globe.
- Keep the bottom card at ~38% of screen height with generous corner radius.
- Globe should remain interactive (drag + zoom) except when overlays set `disableInteraction`.

