package com.facecolour.app.ui

import android.graphics.Color as AndroidColor
import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.facecolour.app.data.PaletteColor
import com.facecolour.app.data.SeasonGuide
import com.facecolour.app.engine.Confidence
import com.facecolour.app.engine.Fitzpatrick
import com.facecolour.app.engine.RgbColor
import com.facecolour.app.engine.ShadeMatch
import com.facecolour.app.engine.Undertone

/** Shared results rendering — used by the live analysis screen and history detail. */
@Composable
fun ResultsContent(
    representativeRgb: RgbColor,
    undertone: Undertone,
    fitzpatrick: Fitzpatrick,
    confidence: Confidence,
    guide: SeasonGuide?,
    shades: List<ShadeMatch>
) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        SkinCard(representativeRgb, undertone, fitzpatrick, confidence)
        if (guide != null) SeasonCard(guide)
        if (shades.isNotEmpty()) ShadeCard(shades)
    }
}

@Composable
private fun SkinCard(rgb: RgbColor, undertone: Undertone, fitzpatrick: Fitzpatrick, confidence: Confidence) {
    CardBox {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Swatch(Color(rgb.r.toFloat(), rgb.g.toFloat(), rgb.b.toFloat()), 64.dp)
            Column {
                Text("Undertone: ${undertone.displayName}", style = MaterialTheme.typography.titleMedium)
                Text("Skin type: ${fitzpatrick.displayName} (${fitzpatrick.depthDescription})")
                Text("Confidence: ${confidence.displayName}", style = MaterialTheme.typography.bodyMedium)
            }
        }
    }
}

@Composable
private fun SeasonCard(guide: SeasonGuide) {
    CardBox {
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
    CardBox {
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
private fun Swatch(color: Color, size: Dp) {
    Box(
        modifier = Modifier
            .size(size)
            .clip(RoundedCornerShape(8.dp))
            .background(color)
    )
}

@Composable
internal fun CardBox(content: @Composable ColumnScope.() -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant)
            .padding(16.dp),
        content = content
    )
}

internal fun hexToColor(hex: String): Color =
    runCatching { Color(AndroidColor.parseColor(hex)) }.getOrDefault(Color.Gray)
