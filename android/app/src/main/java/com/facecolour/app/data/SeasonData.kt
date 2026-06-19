package com.facecolour.app.data

import android.content.Context
import com.facecolour.app.engine.Season
import com.facecolour.app.engine.ShadeReference
import com.google.gson.Gson

data class PaletteColor(val name: String, val hex: String)

data class SeasonGuide(
    val title: String,
    val summary: String,
    val palette: List<PaletteColor>,
    val avoid: List<PaletteColor>
)

data class SeasonGuideBook(
    val spring: SeasonGuide,
    val summer: SeasonGuide,
    val autumn: SeasonGuide,
    val winter: SeasonGuide
) {
    operator fun get(season: Season): SeasonGuide = when (season) {
        Season.SPRING -> spring
        Season.SUMMER -> summer
        Season.AUTUMN -> autumn
        Season.WINTER -> winter
    }
}

/** Loads the shared `seasons.json` / `shades.json` from app assets (Gson). */
object DataLoaders {
    private val gson = Gson()

    fun loadSeasonGuide(context: Context): SeasonGuideBook? =
        readAsset(context, "seasons.json")?.let {
            runCatching { gson.fromJson(it, SeasonGuideBook::class.java) }.getOrNull()
        }

    fun loadShades(context: Context): ShadeReference? =
        readAsset(context, "shades.json")?.let {
            runCatching { gson.fromJson(it, ShadeReference::class.java) }.getOrNull()
        }

    private fun readAsset(context: Context, name: String): String? =
        runCatching {
            context.assets.open(name).bufferedReader().use { it.readText() }
        }.getOrNull()
}
