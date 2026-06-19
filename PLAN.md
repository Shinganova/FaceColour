# FaceColour — Development Plan

A mobile app that analyzes a selfie to:
1. **Color season analysis** — determine the user's seasonal color type and recommend flattering clothing / makeup / hair colors.
2. **Skin-tone shade matching** — detect skin tone and match it to foundation / product shades.

## Strategy

- **Native, phased.** Build iOS first and completely; defer Android until iOS is solid.
- **iOS stack:** Swift + SwiftUI, Apple Vision (face detection/landmarks), AVFoundation (camera), Core Image/Core Graphics (pixel sampling & color math). No backend for MVP — fully on-device (cheaper, faster, privacy-friendly).
- **Token-spend discipline:**
  - Build in **vertical slices**, one phase at a time. Each phase is independently runnable and verifiable before moving on.
  - The color-science engine is written **once as a platform-agnostic spec** (`docs/color-algorithm.md`) with pure, documented functions and named constants. When Android comes, it's a re-implementation against that spec — not a redesign.
  - Defer anything not needed for a working MVP (accounts, cloud sync, social) to a clearly marked "Later" bucket.

## Architecture (iOS)

```
Capture/Pick selfie
   → Face detection + landmarks (Vision)
   → Sample skin pixels (cheeks/forehead) (Core Image)
   → Color science: RGB → Lab/HSV; undertone + depth
   → ├─ Season classifier  → palette recommendations  (Feature 1)
      └─ Shade matcher (nearest-shade in local DB)     (Feature 2)
   → Results UI (+ optional saved history)
```

- **Color engine** = pure Swift functions, no UIKit/SwiftUI dependency, mirrors `docs/color-algorithm.md`. This is the reusable core.
- **Local data:** `seasons.json` (palettes per season) and `shades.json` (foundation/product shade DB) bundled with the app.

## Phases (each is a stop-and-verify checkpoint)

**Phase 0 — Project setup**
- Xcode project, SwiftUI app skeleton, folder structure, git hygiene.
- Stub `docs/color-algorithm.md`.
- *Done when:* empty app builds and runs on simulator.

**Phase 1 — Capture & face detection**
- Camera + photo-library picker; permissions.
- Vision face detection + landmarks; overlay to confirm a face is found.
- *Done when:* user can take/pick a selfie and see the face detected.

**Phase 2 — Skin-tone extraction (color-science core)**
- Sample skin regions (cheeks/forehead) using landmarks; reject occlusions/poor lighting.
- Convert to Lab/HSV; compute **undertone** (warm/cool/neutral) and **depth** (light→deep).
- Write the algorithm into `docs/color-algorithm.md` as the spec.
- *Done when:* app shows a stable detected skin color + undertone/depth for a photo.

**Phase 3 — Season analysis + palettes (Feature 1)**
- Classify into seasonal type (start with 4-season; design for 12-season extension).
- `seasons.json` palettes; results screen with recommended colors.
- *Done when:* a selfie yields a season + a recommended color palette.

**Phase 4 — Shade matcher (Feature 2)**
- `shades.json` foundation/product DB; nearest-shade match (ΔE in Lab).
- Results screen with top matches.
- *Done when:* a selfie yields ranked shade matches.

**Phase 5 — Results, history & polish**
- Unified results screen, share/export, optional on-device saved history.
- Empty/error states, accessibility, loading UX.
- *Done when:* end-to-end flow feels like a real app.

**Phase 6 — Product shop (shop the colors)**
- Curated storefront that surfaces real products tied to the user's results:
  foundation/makeup matched to the detected shade (Feature 2), and clothing/makeup
  in the recommended seasonal palette (Feature 1).
- Filter/sort the catalog by season palette and matched shade; product cards with
  image, name, price, and a color swatch showing why it was recommended.
- MVP commerce model: **affiliate / deep-link out** to retailers (no in-app payments,
  no cart) — cheapest and avoids PCI/checkout scope. In-app purchase/cart deferred.
- Product data: start with a small bundled/curated `products.json`; design the data
  layer so it can later point at a remote catalog or affiliate API.
- *Done when:* from a results screen the user can tap into a shop and see products
  filtered to their palette/shade and open one at a retailer.

**Phase 7 — App Store prep**
- App icon, screenshots, privacy strings, TestFlight, submission checklist.

**Later (separate budgeted effort) — Android port**
- Kotlin + Jetpack Compose, ML Kit (face) + CameraX (camera).
- Re-implement the color engine directly from `docs/color-algorithm.md`; reuse `seasons.json` / `shades.json` / `products.json` unchanged.

## Open questions to resolve before/along the way
- Season system: 4-season MVP vs. full 12-season? (Plan assumes 4 → 12.)
- Shade DB source: curated small set, a standard scale (Monk/Fitzpatrick), or licensed brand data?
- Accuracy bar for MVP, and how lighting variability is communicated to users.
- iOS minimum version + target devices.
