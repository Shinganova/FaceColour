package com.facecolour.app.engine

import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cbrt
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.math.PI

/**
 * Pure color-space conversions — Kotlin port of the iOS engine, mirroring
 * docs/color-algorithm.md §3 so both platforms produce identical numbers.
 */
object ColorConversions {

    fun linearize(c: Double): Double =
        if (c <= 0.04045) c / 12.92 else ((c + 0.055) / 1.055).pow(2.4)

    fun toLab(c: RgbColor): LabColor {
        val r = linearize(c.r); val g = linearize(c.g); val b = linearize(c.b)
        val x = 0.4124 * r + 0.3576 * g + 0.1805 * b
        val y = 0.2126 * r + 0.7152 * g + 0.0722 * b
        val z = 0.0193 * r + 0.1192 * g + 0.9505 * b
        val xn = 0.95047; val yn = 1.0; val zn = 1.08883
        val fx = labF(x / xn); val fy = labF(y / yn); val fz = labF(z / zn)
        return LabColor(116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))
    }

    private fun labF(t: Double): Double {
        val d = 6.0 / 29.0
        return if (t > d * d * d) cbrt(t) else (t / (3 * d * d) + 4.0 / 29.0)
    }

    fun toHsv(c: RgbColor): HsvColor {
        val maxV = maxOf(c.r, c.g, c.b)
        val minV = minOf(c.r, c.g, c.b)
        val delta = maxV - minV
        var h = 0.0
        if (delta > 0) {
            h = when (maxV) {
                c.r -> 60 * (((c.g - c.b) / delta) % 6)
                c.g -> 60 * ((c.b - c.r) / delta + 2)
                else -> 60 * ((c.r - c.g) / delta + 4)
            }
        }
        if (h < 0) h += 360
        val s = if (maxV == 0.0) 0.0 else delta / maxV
        return HsvColor(h, s, maxV)
    }

    /** CIE76 (Euclidean in Lab) — outlier rejection. */
    fun deltaE76(x: LabColor, y: LabColor): Double {
        val dL = x.L - y.L; val da = x.a - y.a; val db = x.b - y.b
        return sqrt(dL * dL + da * da + db * db)
    }

    /** CIEDE2000 (kL=kC=kH=1) — shade matching. Sharma, Wu & Dalal (2005). */
    fun deltaE2000(x: LabColor, y: LabColor): Double {
        val deg = PI / 180
        val c1 = sqrt(x.a * x.a + x.b * x.b)
        val c2 = sqrt(y.a * y.a + y.b * y.b)
        val cBar = (c1 + c2) / 2
        val cBar7 = cBar.pow(7)
        val g = 0.5 * (1 - sqrt(cBar7 / (cBar7 + 25.0.pow(7))))

        val a1p = (1 + g) * x.a
        val a2p = (1 + g) * y.a
        val c1p = sqrt(a1p * a1p + x.b * x.b)
        val c2p = sqrt(a2p * a2p + y.b * y.b)

        fun hue(b: Double, ap: Double): Double {
            if (ap == 0.0 && b == 0.0) return 0.0
            var h = atan2(b, ap) / deg
            if (h < 0) h += 360
            return h
        }
        val h1p = hue(x.b, a1p)
        val h2p = hue(y.b, a2p)

        val dLp = y.L - x.L
        val dCp = c2p - c1p
        var dhp = 0.0
        if (c1p * c2p != 0.0) {
            val diff = h2p - h1p
            dhp = when {
                abs(diff) <= 180 -> diff
                diff > 180 -> diff - 360
                else -> diff + 360
            }
        }
        val dHp = 2 * sqrt(c1p * c2p) * sin((dhp / 2) * deg)

        val lBarp = (x.L + y.L) / 2
        val cBarp = (c1p + c2p) / 2
        var hBarp = h1p + h2p
        if (c1p * c2p != 0.0) {
            hBarp = when {
                abs(h1p - h2p) <= 180 -> (h1p + h2p) / 2
                (h1p + h2p) < 360 -> (h1p + h2p + 360) / 2
                else -> (h1p + h2p - 360) / 2
            }
        }

        val t = 1 - 0.17 * cos((hBarp - 30) * deg) +
            0.24 * cos((2 * hBarp) * deg) +
            0.32 * cos((3 * hBarp + 6) * deg) -
            0.20 * cos((4 * hBarp - 63) * deg)

        val dTheta = 30 * exp(-((hBarp - 275) / 25).pow(2))
        val cBarp7 = cBarp.pow(7)
        val rc = 2 * sqrt(cBarp7 / (cBarp7 + 25.0.pow(7)))
        val sl = 1 + (0.015 * (lBarp - 50).pow(2)) / sqrt(20 + (lBarp - 50).pow(2))
        val sc = 1 + 0.045 * cBarp
        val sh = 1 + 0.015 * cBarp * t
        val rt = -sin(2 * dTheta * deg) * rc

        val termL = dLp / sl
        val termC = dCp / sc
        val termH = dHp / sh
        return sqrt(termL * termL + termC * termC + termH * termH + rt * termC * termH)
    }
}
