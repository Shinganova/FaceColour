package com.facecolour.app.engine

/** Skin undertone. */
enum class Undertone {
    WARM, NEUTRAL, COOL;

    val displayName: String get() = name.lowercase().replaceFirstChar { it.uppercase() }

    companion object {
        /** From CIELAB hue angle (deg). Higher = warmer (golden); lower = cooler (pink). */
        fun classify(hueAngle: Double): Undertone = when {
            hueAngle < SkinThresholds.COOL_MAX_HUE -> COOL
            hueAngle >= SkinThresholds.WARM_MIN_HUE -> WARM
            else -> NEUTRAL
        }
    }
}

/** Estimated Fitzpatrick phototype (I–VI) from ITA. Approximation, not clinical. */
enum class Fitzpatrick(val roman: String) {
    TYPE_I("I"), TYPE_II("II"), TYPE_III("III"), TYPE_IV("IV"), TYPE_V("V"), TYPE_VI("VI");

    val displayName: String get() = "Type $roman"

    val depthDescription: String get() = when (this) {
        TYPE_I -> "Very light"
        TYPE_II -> "Light"
        TYPE_III -> "Intermediate"
        TYPE_IV -> "Tan"
        TYPE_V -> "Brown"
        TYPE_VI -> "Deep"
    }

    companion object {
        /** From ITA (deg) = atan2(L* - 50, b*). */
        fun classify(ita: Double): Fitzpatrick = when {
            ita >= 55 -> TYPE_I
            ita >= 41 -> TYPE_II
            ita >= 28 -> TYPE_III
            ita >= 10 -> TYPE_IV
            ita >= -30 -> TYPE_V
            else -> TYPE_VI
        }
    }
}

enum class Confidence {
    HIGH, MEDIUM, LOW;
    val displayName: String get() = name.lowercase().replaceFirstChar { it.uppercase() }
}

/** Tunable constants — kept in lockstep with iOS `SkinThresholds`. */
object SkinThresholds {
    const val COOL_MAX_HUE = 45.0
    const val WARM_MIN_HUE = 57.0

    const val MIN_VALUE = 0.15
    const val MAX_VALUE = 0.95
    const val MIN_SATURATION = 0.05
    const val MAX_SATURATION = 0.75

    const val OUTLIER_DELTA_E = 12.0
    const val MIN_INLIERS = 5

    const val HIGH_MIN_SAMPLES = 100
    const val LOW_MAX_SAMPLES = 30
    const val HIGH_MAX_SPREAD = 6.0
    const val LOW_MIN_SPREAD = 14.0
}

data class SkinToneResult(
    val representativeRgb: RgbColor,
    val lab: LabColor,
    val hueAngle: Double,
    val ita: Double,
    val undertone: Undertone,
    val fitzpatrick: Fitzpatrick,
    val confidence: Confidence,
    val sampleCount: Int
)
