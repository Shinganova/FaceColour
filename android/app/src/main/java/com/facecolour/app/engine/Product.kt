package com.facecolour.app.engine

import kotlin.math.abs

enum class ProductCategory { MAKEUP, FOUNDATION, CLOTHING, ACCESSORY, OTHER }

/** Shoppable product. `productUrl` is the retailer deep-link (no in-app checkout). */
data class Product(
    val id: String,
    val title: String,
    val brand: String?,
    val price: String?,
    val imageUrl: String?,
    val productUrl: String,
    val colorHex: String?,
    val category: ProductCategory?,
    val seasons: List<Season>?,
    val monkTone: Int?
)

/** Pure relevance filtering — mirrors iOS `ProductMatcher`. */
object ProductMatcher {
    fun filter(
        products: List<Product>,
        season: Season?,
        monkTone: Int?,
        toneTolerance: Int = 1
    ): List<Product> = products.filter { p ->
        val seasonOk = if (season != null && !p.seasons.isNullOrEmpty()) p.seasons.contains(season) else true
        val toneOk = if (monkTone != null && p.monkTone != null) abs(p.monkTone - monkTone) <= toneTolerance else true
        seasonOk && toneOk
    }
}
