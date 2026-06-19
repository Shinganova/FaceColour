package com.facecolour.app.engine

import kotlin.math.atan2
import kotlin.math.PI

/** Pure skin-tone analysis — Kotlin port mirroring iOS `SkinToneAnalyzer`. */
class SkinToneAnalyzer {

    fun analyze(samples: List<RgbColor>): SkinToneResult? {
        val plausible = samples.filter { isPlausibleSkin(it) }
        if (plausible.size < SkinThresholds.MIN_INLIERS) return null

        val labs = plausible.map { ColorConversions.toLab(it) }
        val median = LabColor(
            median(labs.map { it.L }),
            median(labs.map { it.a }),
            median(labs.map { it.b })
        )

        val inliers = plausible.zip(labs)
            .filter { ColorConversions.deltaE76(it.second, median) <= SkinThresholds.OUTLIER_DELTA_E }
        if (inliers.size < SkinThresholds.MIN_INLIERS) return null

        val inLabs = inliers.map { it.second }
        val rep = LabColor(
            mean(inLabs.map { it.L }),
            mean(inLabs.map { it.a }),
            mean(inLabs.map { it.b })
        )
        val repRgb = RgbColor(
            mean(inliers.map { it.first.r }),
            mean(inliers.map { it.first.g }),
            mean(inliers.map { it.first.b })
        )

        val hueDeg = hueAngle(rep)
        val itaDeg = ita(rep)
        val spread = mean(inLabs.map { ColorConversions.deltaE76(it, rep) })

        return SkinToneResult(
            representativeRgb = repRgb,
            lab = rep,
            hueAngle = hueDeg,
            ita = itaDeg,
            undertone = Undertone.classify(hueDeg),
            fitzpatrick = Fitzpatrick.classify(itaDeg),
            confidence = confidence(inliers.size, spread),
            sampleCount = inliers.size
        )
    }

    fun isPlausibleSkin(c: RgbColor): Boolean {
        val hsv = ColorConversions.toHsv(c)
        return hsv.v >= SkinThresholds.MIN_VALUE && hsv.v <= SkinThresholds.MAX_VALUE &&
            hsv.s >= SkinThresholds.MIN_SATURATION && hsv.s <= SkinThresholds.MAX_SATURATION
    }

    companion object {
        fun hueAngle(lab: LabColor): Double {
            val deg = atan2(lab.b, lab.a) * 180 / PI
            return if (deg < 0) deg + 360 else deg
        }

        fun ita(lab: LabColor): Double = atan2(lab.L - 50, lab.b) * 180 / PI

        fun confidence(count: Int, spread: Double): Confidence {
            if (count >= SkinThresholds.HIGH_MIN_SAMPLES && spread < SkinThresholds.HIGH_MAX_SPREAD) return Confidence.HIGH
            if (count < SkinThresholds.LOW_MAX_SAMPLES || spread > SkinThresholds.LOW_MIN_SPREAD) return Confidence.LOW
            return Confidence.MEDIUM
        }

        fun mean(xs: List<Double>): Double = if (xs.isEmpty()) 0.0 else xs.sum() / xs.size

        fun median(xs: List<Double>): Double {
            if (xs.isEmpty()) return 0.0
            val s = xs.sorted()
            val m = s.size / 2
            return if (s.size % 2 == 0) (s[m - 1] + s[m]) / 2 else s[m]
        }
    }
}
