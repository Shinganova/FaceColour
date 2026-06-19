package com.facecolour.app.shop

import com.facecolour.app.BuildConfig
import com.facecolour.app.engine.Product
import com.facecolour.app.engine.ProductCategory
import com.facecolour.app.engine.ProductMatcher
import com.facecolour.app.engine.Season
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder

/** Source of shoppable products for an analysis result. */
interface ProductService {
    suspend fun products(season: Season?, monkTone: Int?): List<Product>
}

/** JSON contract our remote/affiliate endpoint is expected to return. */
data class ProductListResponse(val products: List<Product>)

/** Local sample catalog so the shop works with no API key (default). */
class MockProductService(private val catalog: List<Product> = MockCatalog.all) : ProductService {
    override suspend fun products(season: Season?, monkTone: Int?): List<Product> =
        ProductMatcher.filter(catalog, season, monkTone)
}

/** Provider-agnostic remote client (bearer auth, our JSON contract). */
class RemoteProductService(
    private val baseUrl: String,
    private val apiKey: String
) : ProductService {
    private val gson = Gson()

    override suspend fun products(season: Season?, monkTone: Int?): List<Product> =
        withContext(Dispatchers.IO) {
            val params = buildList {
                season?.let { add("season=" + URLEncoder.encode(it.name, "UTF-8")) }
                monkTone?.let { add("monkTone=$it") }
            }
            val query = if (params.isEmpty()) "" else "?" + params.joinToString("&")
            val conn = (URL("$baseUrl/products$query").openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                setRequestProperty("Authorization", "Bearer $apiKey")
                connectTimeout = 10_000
                readTimeout = 10_000
            }
            try {
                val code = conn.responseCode
                if (code !in 200..299) throw RuntimeException("The shop service returned an error ($code).")
                val text = conn.inputStream.bufferedReader().use { it.readText() }
                gson.fromJson(text, ProductListResponse::class.java).products
            } finally {
                conn.disconnect()
            }
        }
}

/** Remote when configured (BuildConfig PRODUCT_API_*), otherwise mock. */
object ProductServiceFactory {
    fun make(): ProductService {
        val url = BuildConfig.PRODUCT_API_BASE_URL
        val key = BuildConfig.PRODUCT_API_KEY
        return if (url.isNotEmpty() && key.isNotEmpty()) RemoteProductService(url, key) else MockProductService()
    }
}

object MockCatalog {
    val all: List<Product> = listOf(
        Product("m1", "Coral Lipstick", "Sample Beauty", "$18", null, "https://example.com/p/m1", "#FF7F50", ProductCategory.MAKEUP, listOf(Season.SPRING), null),
        Product("m2", "Warm Turquoise Scarf", "Sample Apparel", "$32", null, "https://example.com/p/m2", "#2EC4B6", ProductCategory.CLOTHING, listOf(Season.SPRING, Season.WINTER), null),
        Product("m3", "Dusty Rose Blush", "Sample Beauty", "$22", null, "https://example.com/p/m3", "#D8A1A1", ProductCategory.MAKEUP, listOf(Season.SUMMER), null),
        Product("m4", "Rust Knit Sweater", "Sample Apparel", "$54", null, "https://example.com/p/m4", "#B7410E", ProductCategory.CLOTHING, listOf(Season.AUTUMN), null),
        Product("m5", "Emerald Silk Top", "Sample Apparel", "$48", null, "https://example.com/p/m5", "#009B77", ProductCategory.CLOTHING, listOf(Season.WINTER), null),
        Product("f1", "Foundation — Light Tone 4", "Sample Beauty", "$29", null, "https://example.com/p/f1", "#eadaba", ProductCategory.FOUNDATION, null, 4),
        Product("f2", "Foundation — Medium Tone 6", "Sample Beauty", "$29", null, "https://example.com/p/f2", "#a07e56", ProductCategory.FOUNDATION, null, 6),
        Product("f3", "Foundation — Deep Tone 9", "Sample Beauty", "$29", null, "https://example.com/p/f3", "#3a312a", ProductCategory.FOUNDATION, null, 9)
    )
}
