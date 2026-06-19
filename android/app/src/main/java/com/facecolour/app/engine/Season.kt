package com.facecolour.app.engine

/** 4-season color type (MVP), extensible to 12-season later. */
enum class Season {
    SPRING, SUMMER, AUTUMN, WINTER;

    val displayName: String get() = name.lowercase().replaceFirstChar { it.uppercase() }

    companion object {
        /** From undertone + Fitzpatrick depth; neutral leans by hue angle. */
        fun classify(undertone: Undertone, fitzpatrick: Fitzpatrick, hueAngle: Double): Season {
            val warm = when (undertone) {
                Undertone.WARM -> true
                Undertone.COOL -> false
                Undertone.NEUTRAL -> hueAngle >= SeasonThresholds.NEUTRAL_WARM_HUE
            }
            val deep = fitzpatrick in SeasonThresholds.DEEP_TYPES
            return when {
                warm && !deep -> SPRING
                warm && deep -> AUTUMN
                !warm && !deep -> SUMMER
                else -> WINTER
            }
        }
    }
}

object SeasonThresholds {
    const val NEUTRAL_WARM_HUE = 51.0
    val DEEP_TYPES = setOf(Fitzpatrick.TYPE_IV, Fitzpatrick.TYPE_V, Fitzpatrick.TYPE_VI)
}
