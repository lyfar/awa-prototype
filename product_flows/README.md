# Product Flow Guide

This folder captures the experience design for the AWA prototype. The goal is to provide a single source of truth for onboarding, home interactions, and practice progression so we can rebuild the app in any environment (Flutter, SwiftUI, native iOS, etc.) without hunting through code comments.

| Document | Purpose |
| --- | --- |
| `welcome_flow.md` | Step-by-step onboarding globe sequence and copy blocks |
| `home_flow.md` | Layout and interactions for the home screen, including the globe, card, and entry points |
| `practice_flow.md` | Practice selection, session states, completion moments, and how they affect the globe |
| `visual_language.md` | Visual cues, color atmosphere, particle expectations, and motion intent |
| `narrative_voice.md` | Tone and wording guidelines for copy so future builds stay aligned |

## How to use this folder

1. **Build parity** - When recreating the project in Xcode (SwiftUI/UIKit), follow the flows document to reconstruct UI state machines instead of reverse-engineering the Flutter implementation.
2. **Design feedback** - Product, design, or stakeholders can annotate these Markdown files with proposed revisions without touching source code.
3. **Engineering hand-off** - Each flow references the matching `GlobeConfig` state so engineers know which assets or particle systems to trigger.

> Tip: When flows change, update the relevant Markdown file first. Implementation teams can subscribe to the repository and receive diffs before coding.
