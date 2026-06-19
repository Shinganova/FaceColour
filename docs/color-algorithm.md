# Color Algorithm Spec (platform-agnostic)

> **Purpose:** Single source of truth for FaceColour's color science. Written to be
> language-agnostic so the iOS (Swift) implementation and the later Android (Kotlin)
> implementation are *re-implementations of the same spec*. Keep this in sync with
> the code. The unit tests in `Tests/FaceColourTests` are the executable contract;
> the Android port must reproduce the same vectors.

## Status
- **Phase 2 (done):** sampling, color conversions, undertone + depth, confidence.
- **Phase 3/4:** season classification + shade matching (TBD).

## 1. Input
A face image (expected upright / EXIF-normalized) plus a face bounding box in image
pixel coordinates, top-left origin.

## 2. Sampling
- Three square patches placed geometrically from the bounding box (`w`,`h` = box size):
  - **Forehead:** center `(midX, minY + 0.18·h)`
  - **Left cheek:** center `(minX + 0.27·w, minY + 0.62·h)`
  - **Right cheek:** center `(minX + 0.73·w, minY + 0.62·h)`
  - Patch side = `0.16·w`. Clip patches to image bounds; drop patches < 2px.
- Each patch is downscaled to ≤ 24×24 before reading, to bound work. Pixels are read
  as 8-bit sRGB RGBA (device RGB treated as sRGB). Fully transparent pixels skipped.
- *(Future refinement: landmark-guided patches.)*

## 3. Color spaces
- **sRGB companding** (component `c` in 0..1): `c ≤ 0.04045 ? c/12.92 : ((c+0.055)/1.055)^2.4`.
- **Linear sRGB → XYZ (D65):**
  `X = 0.4124r + 0.3576g + 0.1805b`, `Y = 0.2126r + 0.7152g + 0.0722b`,
  `Z = 0.0193r + 0.1192g + 0.9505b`.
- **XYZ → CIELAB**, white point **D65** `(Xn,Yn,Zn) = (0.95047, 1.0, 1.08883)`,
  with `f(t) = t^(1/3) if t > (6/29)^3 else t/(3·(6/29)^2) + 4/29`:
  `L* = 116·f(Y/Yn) − 16`, `a* = 500·(f(X/Xn) − f(Y/Yn))`, `b* = 200·(f(Y/Yn) − f(Z/Zn))`.
- **HSV** standard; H in degrees 0..<360.
- **Distance:** CIE76 (Euclidean in Lab) for outlier rejection. *(Shade matching in
  Phase 4 will use CIEDE2000.)*

## 4. Sample filtering & aggregation
1. **Plausibility (HSV):** keep samples with `0.15 ≤ V ≤ 0.95` and `0.05 ≤ S ≤ 0.75`
   (drops specular highlights, deep shadows, gray/background, oversaturated pixels).
2. Convert survivors to Lab; compute the **per-channel median** Lab.
3. **Outlier rejection:** drop samples with `ΔE76(sample, median) > 12`.
4. **Representative** skin color = **mean** of inliers (computed in both Lab and RGB).
5. Require ≥ 5 inliers at steps 1 and 3, else return "no result".

## 5. Undertone & depth
- **Hue angle** `h = atan2(b*, a*)` (degrees, normalized 0..<360).
- **Undertone:** `h < 45 → cool`, `45 ≤ h ≤ 57 → neutral`, `h > 57 → warm`.
  (Higher angle = more yellow/golden; lower = more red/pink.)
- **ITA** (Individual Typology Angle) `= atan2(L* − 50, b*)` (degrees).
- **Depth** by ITA: `>55 veryLight`, `41–55 light`, `28–41 intermediate`,
  `10–28 tan`, `−30–10 brown`, `<−30 dark`.

## 6. Confidence
From inlier `count` and `spread` (mean ΔE76 of inliers to the representative):
- **high:** `count ≥ 100` AND `spread < 6`
- **low:** `count < 30` OR `spread > 14`
- **medium:** otherwise

## Locked decisions
- Season system: **4-season** for MVP, extensible to 12-season.
- Shade reference: **Monk Skin Tone scale** (open, 10 tones) as the base.

## Tunables
All thresholds in §4–6 live in `SkinThresholds` (Swift) and are **MVP values pending
calibration** against real-world photos. Changing one means updating this doc and the
classification tests together (iOS + Android).

## Test vectors (canonical, must match on all platforms)
- sRGB white → Lab (100, 0, 0); black → L 0; gray 0.5 → L≈53.4, a≈0, b≈0;
  red (1,0,0) → Lab ≈ (53.24, 80.09, 67.20).
- HSV: red → (0°, 1, 1); gray → S 0.
- Undertone bins and Depth/ITA bins per §5 (see `SkinClassificationTests`).
