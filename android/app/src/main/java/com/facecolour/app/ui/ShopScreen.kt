package com.facecolour.app.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.background
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.unit.dp
import com.facecolour.app.engine.Product
import com.facecolour.app.engine.Season
import com.facecolour.app.shop.ProductService
import com.facecolour.app.shop.ProductServiceFactory

private sealed interface ShopPhase {
    data object Loading : ShopPhase
    data object Empty : ShopPhase
    data class Failed(val message: String) : ShopPhase
    data class Loaded(val products: List<Product>) : ShopPhase
}

@Composable
fun ShopScreen(
    season: Season?,
    monkTone: Int?,
    onClose: () -> Unit,
    service: ProductService = remember { ProductServiceFactory.make() }
) {
    var phase by remember { mutableStateOf<ShopPhase>(ShopPhase.Loading) }
    val uriHandler = LocalUriHandler.current

    LaunchedEffect(season, monkTone) {
        phase = ShopPhase.Loading
        phase = try {
            val items = service.products(season, monkTone)
            if (items.isEmpty()) ShopPhase.Empty else ShopPhase.Loaded(items)
        } catch (e: Exception) {
            ShopPhase.Failed(e.message ?: "Couldn't load the shop.")
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text("Shop your colors", style = MaterialTheme.typography.headlineMedium)
            Spacer(Modifier.weight(1f))
            TextButton(onClick = onClose) { Text("Done") }
        }

        when (val p = phase) {
            ShopPhase.Loading -> CircularProgressIndicator()
            ShopPhase.Empty -> Text("No matching products yet.", style = MaterialTheme.typography.bodyMedium)
            is ShopPhase.Failed -> Text(p.message, color = MaterialTheme.colorScheme.error)
            is ShopPhase.Loaded -> LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                items(p.products, key = { it.id }) { product ->
                    ProductRow(product) { uriHandler.openUri(product.productUrl) }
                }
            }
        }
    }
}

@Composable
private fun ProductRow(product: Product, onOpen: () -> Unit) {
    CardBox(modifier = Modifier.clickable(onClick = onOpen)) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Box(
                Modifier.size(48.dp).clip(RoundedCornerShape(8.dp))
                    .background(product.colorHex?.let { hexToColor(it) } ?: Color.Gray)
            )
            Column(Modifier.weight(1f)) {
                Text(product.title, style = MaterialTheme.typography.titleMedium)
                product.brand?.let { Text(it, style = MaterialTheme.typography.bodySmall) }
            }
            product.price?.let { Text(it, style = MaterialTheme.typography.titleSmall) }
        }
    }
}
