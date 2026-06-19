package com.facecolour.app.ui

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Color as AndroidColor
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.facecolour.app.analysis.AnalysisStatus
import com.facecolour.app.analysis.AnalysisViewModel
import com.facecolour.app.data.PaletteColor
import com.facecolour.app.data.SeasonGuide
import com.facecolour.app.engine.ShadeMatch
import com.facecolour.app.engine.SkinToneResult

@Composable
fun AnalysisScreen(vm: AnalysisViewModel = viewModel()) {
    val state = vm.state
    val context = LocalContext.current
    var showCamera by remember { mutableStateOf(false) }

    val galleryPicker = rememberLauncherForActivityResult(
        ActivityResultContracts.PickVisualMedia()
    ) { uri -> if (uri != null) vm.analyze(uri) }

    val cameraPermission = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted -> if (granted) showCamera = true }

    if (showCamera) {
        CameraScreen(
            onCaptured = { uri -> showCamera = false; vm.analyze(uri) },
            onCancel = { showCamera = false }
        )
        return
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("FaceColour", style = MaterialTheme.typography.headlineMedium)

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(360.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant),
            contentAlignment = Alignment.Center
        ) {
            val bmp = state.bitmap
            if (bmp != null) {
                Image(
                    bitmap = bmp.asImageBitmap(),
                    contentDescription = "Selected photo",
                    contentScale = ContentScale.Fit,
                    modifier = Modifier.fillMaxSize()
                )
            } else {
                Text("Choose a selfie to begin.", style = MaterialTheme.typography.titleMedium)
            }
            if (state.status == AnalysisStatus.DETECTING) {
                CircularProgressIndicator()
            }
        }

        StatusText(state.status, state.error)

        state.result?.let { result ->
            SkinCard(result)
            state.guide?.let { SeasonCard(it) }
            if (state.shades.isNotEmpty()) ShadeCard(state.shades)
        }

        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Button(onClick = {
                val granted = ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) ==
                    PackageManager.PERMISSION_GRANTED
                if (granted) showCamera = true else cameraPermission.launch(Manifest.permission.CAMERA)
            }) {
                Text("Take Photo")
            }
            Button(onClick = {
                galleryPicker.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
            }) {
                Text("Choose Photo")
            }
        }
    }
}

@Composable
private fun StatusText(status: AnalysisStatus, error: String?) {
    val message = when (status) {
        AnalysisStatus.NO_FACE -> "No face found — try better lighting and face the camera."
        AnalysisStatus.NO_SKIN -> "Couldn't read skin reliably — try better lighting."
        AnalysisStatus.FAILED -> error ?: "Something went wrong."
        else -> null
    } ?: return
    Text(message, color = MaterialTheme.colorScheme.error, textAlign = TextAlign.Center)
}

@Composable
private fun SkinCard(result: SkinToneResult) {
    Card {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Swatch(rgbColor(result.representativeRgb.r, result.representativeRgb.g, result.representativeRgb.b), 64.dp)
            Column {
                Text("Undertone: ${result.undertone.displayName}", style = MaterialTheme.typography.titleMedium)
                Text("Skin type: ${result.fitzpatrick.displayName} (${result.fitzpatrick.depthDescription})")
                Text("Confidence: ${result.confidence.displayName}", style = MaterialTheme.typography.bodyMedium)
            }
        }
    }
}

@Composable
private fun SeasonCard(guide: SeasonGuide) {
    Card {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text("Season: ${guide.title}", style = MaterialTheme.typography.titleLarge)
            Text(guide.summary, style = MaterialTheme.typography.bodyMedium)
            Text("Your palette", style = MaterialTheme.typography.titleSmall)
            SwatchRow(guide.palette)
            Text("Colors to avoid", style = MaterialTheme.typography.titleSmall)
            SwatchRow(guide.avoid)
        }
    }
}

@Composable
private fun ShadeCard(shades: List<ShadeMatch>) {
    Card {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text("Closest skin-tone shades", style = MaterialTheme.typography.titleMedium)
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                shades.forEach { match ->
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Swatch(hexToColor(match.tone.hex), 44.dp)
                        Text("${match.tone.tone}", style = MaterialTheme.typography.labelSmall)
                        Text("ΔE ${"%.1f".format(match.deltaE)}", style = MaterialTheme.typography.labelSmall)
                    }
                }
            }
        }
    }
}

@Composable
private fun SwatchRow(colors: List<PaletteColor>) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        colors.forEach { c ->
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Swatch(hexToColor(c.hex), 44.dp)
                Text(c.name, style = MaterialTheme.typography.labelSmall)
            }
        }
    }
}

@Composable
private fun Swatch(color: Color, size: androidx.compose.ui.unit.Dp) {
    Box(
        modifier = Modifier
            .size(size)
            .clip(RoundedCornerShape(8.dp))
            .background(color)
    )
}

@Composable
private fun Card(content: @Composable ColumnScope.() -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant)
            .padding(16.dp),
        content = content
    )
}

private fun rgbColor(r: Double, g: Double, b: Double): Color = Color(r.toFloat(), g.toFloat(), b.toFloat())

private fun hexToColor(hex: String): Color =
    runCatching { Color(AndroidColor.parseColor(hex)) }.getOrDefault(Color.Gray)
