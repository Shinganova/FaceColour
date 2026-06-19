# Color Algorithm Spec (platform-agnostic)

> **Purpose:** This is the single source of truth for FaceColour's color science.
> It is written to be language-agnostic so the iOS (Swift) implementation and the
> later Android (Kotlin) implementation are *re-implementations of the same spec*,
> not independent designs. Keep this in sync with the code.

## Status
- **Phase 0:** stub. Filled in during **Phase 2** (skin-tone extraction) and
  **Phase 3/4** (season classification + shade matching).

## Pipeline (to be specified)
1. **Input** — face image + face landmarks.
2. **Sampling** — which face regions (cheeks, forehead), how many pixels, outlier
   rejection (occlusion, specular highlights, shadow), aggregation to a single
   representative skin color.
3. **Color spaces** — sRGB → linear → CIELab / HSV. Define exact conversion
   constants and white point (D65).
4. **Undertone** — warm / cool / neutral. Define decision boundaries.
5. **Depth** — light → deep scale. Define bins.
6. **Season classification (4-season MVP)** — map (undertone, depth, contrast) to
   Spring / Summer / Autumn / Winter. Designed to extend to a 12-season model.
7. **Shade matching** — nearest shade in the Monk Skin Tone scale (10 tones) via
   CIEDE2000 (ΔE) distance in Lab. Curated product shades layer on top later.

## Locked decisions
- Season system: **4-season** for MVP, extensible to 12-season.
- Shade reference: **Monk Skin Tone scale** (open, 10 tones) as the base.

## Test vectors
- TBD: a table of known input colors → expected undertone/depth/season/shade,
  used identically by Swift and Kotlin unit tests.
