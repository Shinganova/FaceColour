package com.facecolour.app.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
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
import androidx.compose.ui.unit.dp
import com.facecolour.app.analysis.AnalysisViewModel
import com.facecolour.app.data.AnalysisRecord
import com.facecolour.app.data.DataLoaders
import com.facecolour.app.engine.MonkTone
import com.facecolour.app.engine.RgbColor
import com.facecolour.app.engine.ShadeMatch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun HistoryScreen(vm: AnalysisViewModel, onClose: () -> Unit) {
    var selected by remember { mutableStateOf<AnalysisRecord?>(null) }

    val current = selected
    if (current != null) {
        HistoryDetail(vm, current, onBack = { selected = null })
        return
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text("History", style = MaterialTheme.typography.headlineMedium)
            Spacer(Modifier.weight(1f))
            TextButton(onClick = onClose) { Text("Done") }
        }

        if (vm.records.isEmpty()) {
            Text("No saved analyses yet.", style = MaterialTheme.typography.bodyMedium)
        } else {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                items(vm.records, key = { it.id }) { record ->
                    HistoryRow(
                        vm = vm,
                        record = record,
                        onOpen = { selected = record },
                        onDelete = { vm.delete(record) }
                    )
                }
            }
        }
    }
}

@Composable
private fun HistoryRow(
    vm: AnalysisViewModel,
    record: AnalysisRecord,
    onOpen: () -> Unit,
    onDelete: () -> Unit
) {
    CardBox {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            val thumb = remember(record.id) { vm.thumbnail(record) }
            if (thumb != null) {
                Image(
                    bitmap = thumb.asImageBitmap(),
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.size(48.dp).clip(RoundedCornerShape(8.dp))
                )
            } else {
                Box(
                    Modifier.size(48.dp).clip(RoundedCornerShape(8.dp))
                        .background(hexToColor(record.representativeHex))
                )
            }
            Column(Modifier.weight(1f)) {
                Text(record.season.displayName, style = MaterialTheme.typography.titleMedium)
                Text(
                    "${record.undertone.displayName} · ${record.fitzpatrick.displayName}",
                    style = MaterialTheme.typography.bodySmall
                )
                Text(formatDate(record.date), style = MaterialTheme.typography.labelSmall)
            }
            TextButton(onClick = onOpen) { Text("Open") }
            TextButton(onClick = onDelete) { Text("Delete") }
        }
    }
}

@Composable
private fun HistoryDetail(vm: AnalysisViewModel, record: AnalysisRecord, onBack: () -> Unit) {
    val context = LocalContext.current
    val guide = remember(record.season) { DataLoaders.loadSeasonGuide(context)?.get(record.season) }
    val shades = remember(record.id) {
        record.shadeMatches.map { ShadeMatch(MonkTone(it.tone, it.hex), it.deltaE) }
    }
    val repRgb = remember(record.representativeHex) {
        RgbColor.fromHex(record.representativeHex) ?: RgbColor(0.8, 0.6, 0.5)
    }
    val thumb = remember(record.id) { vm.thumbnail(record) }

    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            TextButton(onClick = onBack) { Text("Back") }
            Spacer(Modifier.weight(1f))
            Text(record.season.displayName, style = MaterialTheme.typography.titleLarge)
        }
        thumb?.let {
            Image(
                bitmap = it.asImageBitmap(),
                contentDescription = null,
                contentScale = ContentScale.Fit,
                modifier = Modifier.fillMaxWidth().height(240.dp).clip(RoundedCornerShape(16.dp))
            )
        }
        ResultsContent(
            representativeRgb = repRgb,
            undertone = record.undertone,
            fitzpatrick = record.fitzpatrick,
            confidence = record.confidence,
            guide = guide,
            shades = shades
        )
    }
}

private fun formatDate(epochMillis: Long): String =
    SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date(epochMillis))
