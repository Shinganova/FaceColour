package com.facecolour.app.data

import com.facecolour.app.engine.Confidence
import com.facecolour.app.engine.Fitzpatrick
import com.facecolour.app.engine.Season
import com.facecolour.app.engine.Undertone

data class ShadeMatchRecord(val tone: Int, val hex: String, val deltaE: Double)

/** A saved analysis — enough to render the results screen and a history row. */
data class AnalysisRecord(
    val id: String,
    val date: Long,
    val representativeHex: String,
    val undertone: Undertone,
    val fitzpatrick: Fitzpatrick,
    val confidence: Confidence,
    val season: Season,
    val shadeMatches: List<ShadeMatchRecord>,
    val thumbnailFileName: String?
)
