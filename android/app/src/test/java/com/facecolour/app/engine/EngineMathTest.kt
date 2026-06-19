package com.facecolour.app.engine

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertNotNull
import org.junit.Test

/** Canonical color-math vectors — must match the iOS engine (cross-platform contract). */
class EngineMathTest {

    @Test fun labWhite() {
        val lab = ColorConversions.toLab(RgbColor(1.0, 1.0, 1.0))
        assertEquals(100.0, lab.L, 0.1)
        assertEquals(0.0, lab.a, 0.1)
        assertEquals(0.0, lab.b, 0.1)
    }

    @Test fun labMidGray() {
        val lab = ColorConversions.toLab(RgbColor(0.5, 0.5, 0.5))
        assertEquals(53.4, lab.L, 0.5)
        assertEquals(0.0, lab.a, 0.2)
        assertEquals(0.0, lab.b, 0.2)
    }

    @Test fun labRed() {
        val lab = ColorConversions.toLab(RgbColor(1.0, 0.0, 0.0))
        assertEquals(53.24, lab.L, 0.5)
        assertEquals(80.09, lab.a, 0.5)
        assertEquals(67.20, lab.b, 0.5)
    }

    @Test fun hsvRed() {
        val hsv = ColorConversions.toHsv(RgbColor(1.0, 0.0, 0.0))
        assertEquals(0.0, hsv.h, 0.001)
        assertEquals(1.0, hsv.s, 0.001)
        assertEquals(1.0, hsv.v, 0.001)
    }

    @Test fun deltaE2000ReferencePairs() {
        assertEquals(2.0425,
            ColorConversions.deltaE2000(LabColor(50.0, 2.6772, -79.7751), LabColor(50.0, 0.0, -82.7485)), 0.001)
        assertEquals(2.3669,
            ColorConversions.deltaE2000(LabColor(50.0, 0.0, 0.0), LabColor(50.0, -1.0, 2.0)), 0.001)
        assertEquals(7.1792,
            ColorConversions.deltaE2000(LabColor(50.0, 2.49, -0.001), LabColor(50.0, -2.49, 0.0009)), 0.001)
    }

    @Test fun hexRoundTrip() {
        assertEquals("#3A7BD5", RgbColor.fromHex("#3A7BD5")!!.toHex())
        assertNotNull(RgbColor.fromHex("FFFFFF"))
        assertNull(RgbColor.fromHex("#FFF"))
        assertNull(RgbColor.fromHex("#ZZZZZZ"))
    }

    @Test fun undertoneBands() {
        assertEquals(Undertone.COOL, Undertone.classify(44.9))
        assertEquals(Undertone.NEUTRAL, Undertone.classify(50.0))
        assertEquals(Undertone.WARM, Undertone.classify(57.0))
    }

    @Test fun fitzpatrickBands() {
        assertEquals(Fitzpatrick.TYPE_I, Fitzpatrick.classify(60.0))
        assertEquals(Fitzpatrick.TYPE_II, Fitzpatrick.classify(41.0))
        assertEquals(Fitzpatrick.TYPE_III, Fitzpatrick.classify(35.0))
        assertEquals(Fitzpatrick.TYPE_IV, Fitzpatrick.classify(20.0))
        assertEquals(Fitzpatrick.TYPE_V, Fitzpatrick.classify(-30.0))
        assertEquals(Fitzpatrick.TYPE_VI, Fitzpatrick.classify(-40.0))
    }
}
