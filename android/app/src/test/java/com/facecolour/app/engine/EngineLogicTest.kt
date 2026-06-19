package com.facecolour.app.engine

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class EngineLogicTest {

    private val analyzer = SkinToneAnalyzer()

    @Test fun analyzerReturnsNullForTooFewSamples() {
        assertNull(analyzer.analyze(emptyList()))
        assertNull(analyzer.analyze(listOf(RgbColor(0.8, 0.6, 0.5))))
    }

    @Test fun uniformSkinGivesRepresentativeAndHighConfidence() {
        val skin = RgbColor(0.80, 0.62, 0.50)
        val result = analyzer.analyze(List(200) { skin })
        assertNotNull(result)
        assertEquals(200, result!!.sampleCount)
        assertEquals(0.80, result.representativeRgb.r, 0.01)
        assertEquals(0.62, result.representativeRgb.g, 0.01)
        assertEquals(0.50, result.representativeRgb.b, 0.01)
        assertEquals(Confidence.HIGH, result.confidence)
    }

    @Test fun highlightsAndShadowsFilteredOut() {
        val samples = List(200) { RgbColor(0.80, 0.62, 0.50) } +
            List(50) { RgbColor(1.0, 1.0, 1.0) } +
            List(50) { RgbColor(0.02, 0.02, 0.02) }
        assertEquals(200, analyzer.analyze(samples)!!.sampleCount)
    }

    @Test fun plausibilityRejectsGrayAndOversaturated() {
        assertFalse(analyzer.isPlausibleSkin(RgbColor(0.5, 0.5, 0.5)))
        assertFalse(analyzer.isPlausibleSkin(RgbColor(1.0, 0.0, 0.0)))
        assertTrue(analyzer.isPlausibleSkin(RgbColor(0.80, 0.62, 0.50)))
    }

    @Test fun seasonMapping() {
        assertEquals(Season.SPRING, Season.classify(Undertone.WARM, Fitzpatrick.TYPE_II, 60.0))
        assertEquals(Season.AUTUMN, Season.classify(Undertone.WARM, Fitzpatrick.TYPE_VI, 60.0))
        assertEquals(Season.SUMMER, Season.classify(Undertone.COOL, Fitzpatrick.TYPE_II, 40.0))
        assertEquals(Season.WINTER, Season.classify(Undertone.COOL, Fitzpatrick.TYPE_VI, 40.0))
        // Neutral leans by hue angle (>= 51 warm).
        assertEquals(Season.SPRING, Season.classify(Undertone.NEUTRAL, Fitzpatrick.TYPE_II, 55.0))
        assertEquals(Season.SUMMER, Season.classify(Undertone.NEUTRAL, Fitzpatrick.TYPE_II, 48.0))
    }

    private val tones = listOf(
        MonkTone(1, "#f6ede4"),
        MonkTone(5, "#d7bd96"),
        MonkTone(10, "#292420")
    )

    @Test fun shadeNearestAndExact() {
        val matcher = ShadeMatcher()
        val light = ColorConversions.toLab(RgbColor.fromHex("#f5ecdf")!!)
        assertEquals(1, matcher.match(light, tones).first().tone.tone)

        val exact = ColorConversions.toLab(RgbColor.fromHex("#d7bd96")!!)
        val best = matcher.match(exact, tones).first()
        assertEquals(5, best.tone.tone)
        assertEquals(0.0, best.deltaE, 1e-6)

        assertEquals(2, matcher.match(light, tones, topN = 2).size)
    }

    private fun product(id: String, seasons: List<Season>?, monkTone: Int?) =
        Product(id, id, null, null, null, "https://example.com/$id", null, null, seasons, monkTone)

    @Test fun productSeasonAndToneFilter() {
        val items = listOf(
            product("autumn", listOf(Season.AUTUMN), null),
            product("summer", listOf(Season.SUMMER), null),
            product("general", null, null),
            product("t4", null, 4),
            product("t9", null, 9)
        )
        val bySeason = ProductMatcher.filter(items, Season.AUTUMN, null).map { it.id }.toSet()
        assertTrue(bySeason.containsAll(listOf("autumn", "general", "t4", "t9")))
        assertFalse(bySeason.contains("summer"))

        val byTone = ProductMatcher.filter(items, null, 5).map { it.id }.toSet()
        assertTrue(byTone.contains("t4"))   // |4-5| <= 1
        assertFalse(byTone.contains("t9"))  // |9-5| > 1
    }
}
