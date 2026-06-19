package com.facecolour.app.engine

/** One reference tone on the Monk Skin Tone scale (1 = lightest … 10 = deepest). */
data class MonkTone(val tone: Int, val hex: String)

data class ShadeReference(val tones: List<MonkTone>)

data class ShadeMatch(val tone: MonkTone, val deltaE: Double)

/** Matches a skin color to reference tones by CIEDE2000. Mirrors iOS `ShadeMatcher`. */
class ShadeMatcher {
    fun match(skin: LabColor, tones: List<MonkTone>, topN: Int = 3): List<ShadeMatch> =
        tones.mapNotNull { tone ->
            RgbColor.fromHex(tone.hex)?.let { rgb ->
                ShadeMatch(tone, ColorConversions.deltaE2000(skin, ColorConversions.toLab(rgb)))
            }
        }.sortedBy { it.deltaE }.take(topN)
}
