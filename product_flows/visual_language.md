# Visual Language

Defines atmosphere and mood cues for the globe experiences so designers/developers reproduce the same feeling in new projects.

## Palette anchors

| Element | Hex / Description |
| --- | --- |
| Background base | `#000000` → deep space black |
| Aura gradient | `#0C1226`, `#1B2B56`, `#2E2B68` (used on bottom card) |
| Particle colors | `#90F5FF`, `#9D7BFF`, `#FF8FFB`, `#7CFFB2`, `#FFE27A` |
| User light | Pure white `#FFFFFF`, full opacity |

## Globe states

1. **Light**
   - Only the ignition core and sparse sparks are visible.
   - Background card: none; keep total focus on the core.
   - Atmosphere disabled (`globe.showAtmosphere(false)`).

2. **Awa Soul**
   - Dark silhouette with luminous orbiting particles.
   - No earth texture; keep a sense of anticipation.
   - Particles drift slowly (speed multiplier ~0.6-1.2).

3. **Globe**
   - Use NASA blue marble texture for clarity.
   - Community dots cluster around major population centers.
   - Atmosphere color `#90F5FF` with altitude ~0.22.
   - Optional: spotlight user light with a subtle bloom (1.2x size).

## Motion principles

- Avoid sudden camera jumps; use `pointOfView` transitions >= 1.5 seconds if animating.
- Pulses should be subtle (scale ±8% over 3 seconds).
- Particle opacity eases should use smoothstep/ease-out to avoid strobing.

## Typography

- Primary headings: system font, weight 600, size 24-28.
- Secondary copy: system font, weight 400, size 14-16, color opacity ≤ 0.8.
- Buttons: uppercase not required; prefer title case.

## Assets checklist

- Blue marble texture (currently remote CDN). Mirror locally before production.
- Particle shader values: additive blending, no depth test.
- Gradient card uses same palette listed above, to be replicated in native implementations.
