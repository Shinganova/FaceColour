package com.facecolour.app.shop

import com.facecolour.app.engine.Season
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertTrue
import org.junit.Test

class ShopServiceTest {

    @Test fun factoryDefaultsToMockWithoutConfig() {
        assertTrue(ProductServiceFactory.make() is MockProductService)
    }

    @Test fun mockFiltersBySeason() = runBlocking {
        val items = MockProductService().products(Season.SUMMER, monkTone = null)
        assertTrue(items.isNotEmpty())
        assertTrue(items.all { it.seasons.isNullOrEmpty() || it.seasons!!.contains(Season.SUMMER) })
    }

    @Test fun mockFiltersByTone() = runBlocking {
        val items = MockProductService().products(season = null, monkTone = 5)
        // Foundations are tone-tagged; only those within tolerance survive.
        assertTrue(items.none { it.monkTone != null && kotlin.math.abs(it.monkTone!! - 5) > 1 })
    }
}
