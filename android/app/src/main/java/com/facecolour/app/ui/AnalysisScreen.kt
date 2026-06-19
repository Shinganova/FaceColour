package com.facecolour.app.ui

import android.Manifest
import android.content.pm.PackageManager
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.lifecycle.viewmodel.compose.viewModel
import com.facecolour.app.analysis.AnalysisStatus
import com.facecolour.app.analysis.AnalysisViewModel

@Composable
fun AnalysisScreen(vm: AnalysisViewModel = viewModel()) {
    val state = vm.state
    val context = LocalContext.current
    var showCamera by remember { mutableStateOf(false) }
    var showHistory by remember { mutableStateOf(false) }
    var showShop by remember { mutableStateOf(false) }

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

    if (showHistory) {
        HistoryScreen(vm = vm, onClose = { showHistory = false })
        return
    }

    if (showShop) {
        ShopScreen(
            season = state.season,
            monkTone = state.shades.firstOrNull()?.tone?.tone,
            onClose = { showShop = false }
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
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("FaceColour", style = MaterialTheme.typography.headlineMedium)
            Spacer(Modifier.weight(1f))
            TextButton(onClick = { showHistory = true }) { Text("History") }
        }

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
            ResultsContent(
                representativeRgb = result.representativeRgb,
                undertone = result.undertone,
                fitzpatrick = result.fitzpatrick,
                confidence = result.confidence,
                guide = state.guide,
                shades = state.shades
            )
            Button(onClick = { vm.saveCurrent() }, enabled = !vm.saved) {
                Text(if (vm.saved) "Saved" else "Save to history")
            }
            Button(onClick = { showShop = true }) {
                Text("Shop your colors")
            }
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
