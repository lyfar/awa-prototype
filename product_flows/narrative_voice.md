# Narrative Voice & Copy Direction

Purpose: keep onboarding and practice copy aligned with the brand ethos when rewriting or translating.

## Tone pillars

1. **Guiding** - Speak like a gentle mentor, not a coach or authority figure.
2. **Collective** - Emphasize connection and shared experience (“our globe”, “global community”).
3. **Illuminating** - Reference light, glow, resonance rather than generic wellness terms.

## Language patterns

- Use short sentences (under 12 words) for primary onboarding copy.
- Avoid questions unless they prompt action (e.g., “Ready to join our global community?”).
- Prefer verbs like *connect*, *discover*, *ignite*, *share*.
- Emojis: ✨ allowed on celebratory lines; keep usage sparse.

## Key strings snapshot (English)

| Context | Key | Copy |
| --- | --- | --- |
| Welcome step 1 | `welcome_step_1` | “Welcome to your mindfulness journey” |
| Welcome step 2 | `welcome_step_2` | “Connect with a global community of practitioners” |
| Welcome step 3 | `welcome_step_3` | “Discover mindfulness practices from around the world” |
| Home CTA | `daily_practice` | “Daily Practice” |
| Home CTA (done) | `practice_completed_today` | “Completed today ✨” |
| Practice celebration | `practice_completed` | “Practice completed! Your light now shines in the global community.” |

## Localization guidance

- Russian translation already exists in `LanguageService` - treat it as canonical for tone in Cyrillic markets.
- For new locales, keep metaphors consistent: translate *light* literally, avoid introducing fire/flame imagery.

## Future work

- Add push notification copy templates once messaging strategy is defined.
- Document error-state language (e.g., connectivity, location denial) when finalised.
