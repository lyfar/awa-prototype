# Practice Flow

Describes how users move from home CTA into a guided meditation session and return with their light recorded on the globe.

## Entry

1. Home `Start` button → `_startPracticeFlow()` sets `_practiceState = PracticeFlowState.practiceSelect`.
2. UI expectation: modal or full screen list of available practices (design TBD). While this surface is open, globe stays in `Awa Soul` mode.

## Practice selection

- Data source: `PracticeService.fetchPractices()` (placeholder in current code).
- User selects a `Practice` item, stored in `_selectedPractice`.
- Transition to `PracticeFlowState.inSession`.

## Session state

- UI: playback controls, timer, and a minimal description (to be defined once audio assets exist).
- Globe remains in `Awa Soul` state for ambient feel.
- Optional: fade screen edges to emphasize focus.

## Completion

1. When session finishes, `_completePractice()` is invoked.
2. Steps inside `_completePractice()`:
   - Set `_practiceState = PracticeFlowState.completing` to disable controls.
   - Ensure location is saved via `PracticeService.saveCurrentLocation()`.
   - Mark practice complete: `PracticeService.markPracticeCompleted()` → sets persisted flag for “today”.
   - Delay 2 seconds for celebratory animation opportunity.
   - Update `_hasPracticedToday = true`, clear `_selectedPractice`, and revert `_practiceState = PracticeFlowState.home`.
   - Show snackbar copy `practice_completed`.
3. After state reset, home screen rebuilds globe with `showUserLight = true`, so user’s light appears on the planet.

## Error handling

- If location fetch or save fails, continue to home without user light and log error.
- If practice completion throws, call `_exitPractice()` to revert to home gracefully.

## Future enhancements

- Replace snackbar with a visual celebration banner or confetti around the globe.
- Support streak tracking: expose counters in this document when designed.
- Add analytics events (`practice_started`, `practice_completed`).

