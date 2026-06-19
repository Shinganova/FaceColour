# App Store Listing — Draft

Draft copy for App Store Connect. Tweak before submission; character limits noted.

## Identity
- **App name** (≤30): `FaceColour`
- **Subtitle** (≤30): `Find your colors`
- **Primary category:** Lifestyle  (alt: Health & Fitness / no Beauty category exists)
- **Bundle ID:** `com.faceColour.app` (matches `project.yml`)

## Promotional text (≤170, updatable without review)
> Snap a selfie and discover your seasonal color palette and your closest skin‑tone
> shade match — all analyzed privately on your device.

## Description
> FaceColour turns a single selfie into a personal color guide.
>
> • Color season analysis — find out whether you're a Spring, Summer, Autumn, or
>   Winter, and see a palette of clothing and makeup colors that flatter you.
> • Skin‑tone shade match — get your closest match on the Monk Skin Tone scale to
>   help choose foundation and product shades.
> • Shop your colors — browse products that fit your palette and shade.
> • Private by design — your photo is analyzed on your device and never uploaded.
>   Save results to your personal history or share them.
>
> How it works: take or choose a selfie, and FaceColour detects your face, samples
> your skin tone, and computes your undertone and depth to recommend your colors.
>
> Note: results are guidance based on your photo and lighting, not a clinical or
> dermatological assessment.

## Keywords (≤100, comma‑separated, no spaces needed)
> color analysis,color season,skin tone,undertone,foundation shade,palette,makeup,outfit,colour,selfie

## What's New (first release)
> First release: color season analysis, skin‑tone shade matching, palettes, saved
> history, sharing, and shop‑your‑colors.

## URLs
- **Support URL:** _[add — e.g. a simple GitHub Pages or site page]_
- **Marketing URL** (optional): _[add]_
- **Privacy Policy URL:** _[host PRIVACY.md and put the URL here — required]_

## App Privacy questionnaire (App Store Connect → App Privacy)
- Data collection: **No, we do not collect data from this app.**
  (On‑device processing only; history stored locally; default build makes no network calls.)
- If you later enable a remote product provider, revisit this and disclose the
  season/shade query sent to that provider.

## Age rating
- Expected **4+** (no objectionable content). Complete the questionnaire to confirm.

## Export compliance
- `ITSAppUsesNonExemptEncryption = false` is set in `Info.plist` (only exempt/HTTPS),
  so no encryption documentation is required.
