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
import com.facecolour.app.data.DataLoaders
import com.facecolour.app.data.SeasonGuide
import com.facecolour.app.engine.Season
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

    private val analyzer = SkinToneAnalyzer()
    private val matcher = ShadeMatcher()
    private val guideBook = DataLoaders.loadSeasonGuide(app)
    private val shadeRef = DataLoaders.loadShades(app)

    fun analyze(uri: Uri) {
        viewModelScope.launch {
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

    private fun loadBitmap(uri: Uri): Bitmap? =
        getApplication<Application>().contentResolver.openInputStream(uri)?.use {
            BitmapFactory.decodeStream(it)
        }
}
