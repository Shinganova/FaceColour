package com.facecolour.app.analysis

import android.app.Application
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.facecolour.app.data.AnalysisRecord
import com.facecolour.app.data.DataLoaders
import com.facecolour.app.data.HistoryRepository
import com.facecolour.app.data.SeasonGuide
import com.facecolour.app.data.ShadeMatchRecord
import com.facecolour.app.engine.Season
import java.util.UUID
import com.facecolour.app.engine.ShadeMatch
import com.facecolour.app.engine.ShadeMatcher
import com.facecolour.app.engine.SkinToneAnalyzer
import com.facecolour.app.engine.SkinToneResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

enum class AnalysisStatus { EMPTY, DETECTING, DONE, NO_FACE, NO_SKIN, FAILED }

data class AnalysisUiState(
    val bitmap: Bitmap? = null,
    val status: AnalysisStatus = AnalysisStatus.EMPTY,
    val result: SkinToneResult? = null,
    val season: Season? = null,
    val guide: SeasonGuide? = null,
    val shades: List<ShadeMatch> = emptyList(),
    val error: String? = null
)

class AnalysisViewModel(app: Application) : AndroidViewModel(app) {
    var state by mutableStateOf(AnalysisUiState())
        private set

    var records by mutableStateOf<List<AnalysisRecord>>(emptyList())
        private set

    var saved by mutableStateOf(false)
        private set

    private val analyzer = SkinToneAnalyzer()
    private val matcher = ShadeMatcher()
    private val guideBook = DataLoaders.loadSeasonGuide(app)
    private val shadeRef = DataLoaders.loadShades(app)
    private val history = HistoryRepository(app)

    init {
        records = history.load()
    }

    fun analyze(uri: Uri) {
        viewModelScope.launch {
            saved = false
            state = AnalysisUiState(status = AnalysisStatus.DETECTING)
            try {
                val bitmap = withContext(Dispatchers.IO) { loadBitmap(uri) }
                    ?: run {
                        state = state.copy(status = AnalysisStatus.FAILED, error = "Couldn't read that image.")
                        return@launch
                    }
                state = state.copy(bitmap = bitmap)

                val faces = FaceDetectionService.detect(bitmap)
                val primary = faces.maxByOrNull { it.width() * it.height() }
                if (primary == null) {
                    state = state.copy(status = AnalysisStatus.NO_FACE)
                    return@launch
                }

                val samples = withContext(Dispatchers.Default) { SkinSampler.sample(bitmap, primary) }
                val result = analyzer.analyze(samples)
                if (result == null) {
                    state = state.copy(status = AnalysisStatus.NO_SKIN)
                    return@launch
                }

                val season = Season.classify(result.undertone, result.fitzpatrick, result.hueAngle)
                val guide = guideBook?.get(season)
                val shades = shadeRef?.tones?.let { matcher.match(result.lab, it, topN = 3) } ?: emptyList()

                state = state.copy(
                    status = AnalysisStatus.DONE,
                    result = result,
                    season = season,
                    guide = guide,
                    shades = shades
                )
            } catch (e: Exception) {
                state = state.copy(status = AnalysisStatus.FAILED, error = e.message ?: "Analysis failed.")
            }
        }
    }

    fun saveCurrent() {
        val result = state.result ?: return
        val season = state.season ?: return
        if (saved) return

        val id = UUID.randomUUID().toString()
        val thumbName = state.bitmap?.let { history.saveThumbnail(scaleThumbnail(it), id) }

        val record = AnalysisRecord(
            id = id,
            date = System.currentTimeMillis(),
            representativeHex = result.representativeRgb.toHex(),
            undertone = result.undertone,
            fitzpatrick = result.fitzpatrick,
            confidence = result.confidence,
            season = season,
            shadeMatches = state.shades.map { ShadeMatchRecord(it.tone.tone, it.tone.hex, it.deltaE) },
            thumbnailFileName = thumbName
        )
        records = listOf(record) + records
        history.save(records)
        saved = true
    }

    fun delete(record: AnalysisRecord) {
        records = records.filterNot { it.id == record.id }
        history.save(records)
        record.thumbnailFileName?.let { history.deleteThumbnail(it) }
    }

    fun thumbnail(record: AnalysisRecord): Bitmap? =
        record.thumbnailFileName?.let { history.loadThumbnail(it) }

    private fun loadBitmap(uri: Uri): Bitmap? =
        getApplication<Application>().contentResolver.openInputStream(uri)?.use {
            BitmapFactory.decodeStream(it)
        }

    private fun scaleThumbnail(bitmap: Bitmap, max: Int = 240): Bitmap {
        val longest = maxOf(bitmap.width, bitmap.height)
        if (longest <= max || longest == 0) return bitmap
        val scale = max.toFloat() / longest
        return Bitmap.createScaledBitmap(bitmap, (bitmap.width * scale).toInt(), (bitmap.height * scale).toInt(), true)
    }
}
