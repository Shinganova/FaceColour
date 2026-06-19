# Threshold Calibration

The skin pipeline math is sound, but the **threshold constants are first-pass and
uncalibrated**. This doc is the procedure to tune them against real faces.

## What we already know (desk analysis)
Running the engine over the 10 Monk reference tones:

| Monk | hue° | ITA° | undertone | Fitzpatrick | season |
|---|---|---|---|---|---|
| 1 | 74.4 | 83.0 | warm | I | Spring |
| 2 | 74.2 | 80.2 | warm | I | Spring |
| 3 | 89.1 | 71.8 | warm | I | Spring |
| 4 | 88.5 | 64.7 | warm | I | Spring |
| 5 | 81.5 | 50.3 | warm | II | Spring |
| 6 | 73.8 | 10.9 | warm | IV | Autumn |
| 7 | 59.0 | -20.1 | warm | V | Autumn |
| 8 | 48.8 | -55.4 | neutral | VI | Winter |
| 9 | 65.7 | -78.4 | warm | VI | Autumn |
| 10 | 67.2 | -84.3 | warm | VI | Autumn |

**Conclusions**
- **Depth (ITA → Fitzpatrick) looks correct** — light tones → I/II, deep → V/VI.
- **Undertone bands are wrong for skin.** Real skin hue rarely drops below ~50°, so
  with `cool <45 / neutral 45–57 / warm >57` almost everything reads **warm**, and
  **Summer/Winter become nearly unreachable**. The bands must be recentered to where
  skin hue actually varies (~55–80°) — but the right split needs labeled data.

## How to collect data (in the app)
1. Build & run (`docs/release-checklist.md`).
2. Analyze a face whose "true" undertone/season you know (cool vs warm, and ideally a
   season guess).
3. Expand **Analysis details** under the result and tap **Copy details**. You get:
   ```
   hex=#... 
   L=.. a=.. b=..
   hue=.. ITA=..
   undertone=.. fitz=.. season=..
   samples=.. confidence=..
   shade=Monk.. dE=..
   ```
4. Paste it into the table below with your own label for that person.

Aim for ~12–20 faces spanning light↔deep and warm↔cool, varied lighting.

## Data log (fill in)
| label (truth) | hue° | ITA° | app undertone | app season | notes |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## Fitting the thresholds
Once the log has data, we set:
- `SkinThresholds.coolMaxHue` / `warmMinHue` — from where warm vs cool faces actually
  separate in `hue°` (likely much higher than 45/57).
- `SeasonThresholds.neutralWarmHue` — the neutral tie-break, consistent with the above.
- ITA bins in `Fitzpatrick.classify` — only if depth labels disagree (looks fine so far).

Update the constants, then update the locked vectors in
`SkinClassificationTests` / `SeasonTests` and `docs/color-algorithm.md` together
(iOS + future Android).
