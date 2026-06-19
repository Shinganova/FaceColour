package com.facecolour.app.engine

import kotlin.math.roundToInt

/** sRGB color, components in 0..1. */
data class RgbColor(val r: Double, val g: Double, val b: Double) {
    /** `#RRGGBB` (uppercase), clamped to 0..255. */
    fun toHex(): String {
        fun ch(v: Double) = (v * 255).roundToInt().coerceIn(0, 255)
        return "#%02X%02X%02X".format(ch(r), ch(g), ch(b))
    }

    companion object {
        fun from8(r: Int, g: Int, b: Int) = RgbColor(r / 255.0, g / 255.0, b / 255.0)

        /** From `#RRGGBB` or `RRGGBB`; null if malformed. */
        fun fromHex(hex: String): RgbColor? {
            var s = hex.trim()
            if (s.startsWith("#")) s = s.substring(1)
            if (s.length != 6) return null
            val v = s.toIntOrNull(16) ?: return null
            return from8((v shr 16) and 0xFF, (v shr 8) and 0xFF, v and 0xFF)
        }
    }
}

/** CIELAB color (D65 white point). */
data class LabColor(val L: Double, val a: Double, val b: Double)

/** HSV color: h in 0..<360 degrees, s and v in 0..1. */
data class HsvColor(val h: Double, val s: Double, val v: Double)
