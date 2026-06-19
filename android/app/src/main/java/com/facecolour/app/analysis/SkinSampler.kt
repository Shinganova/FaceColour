package com.facecolour.app.analysis

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Rect
import com.facecolour.app.engine.RgbColor

/**
 * Geometric cheek/forehead patch sampling from a face bounding box — Kotlin port
 * of the iOS `SkinSampler` (same patch placement). Pixels stepped to bound work.
 */
object SkinSampler {
    fun sample(bitmap: Bitmap, faceBox: Rect, resolution: Int = 24): List<RgbColor> {
        val w = faceBox.width()
        val h = faceBox.height()
        val side = (w * 0.16).toInt().coerceAtLeast(2)

        val centers = listOf(
            faceBox.centerX() to faceBox.top + (h * 0.18).toInt(),               // forehead
            faceBox.left + (w * 0.27).toInt() to faceBox.top + (h * 0.62).toInt(), // left cheek
            faceBox.left + (w * 0.73).toInt() to faceBox.top + (h * 0.62).toInt()  // right cheek
        )

        val samples = mutableListOf<RgbColor>()
        for ((cx, cy) in centers) {
            samples += patch(bitmap, cx, cy, side, resolution)
        }
        return samples
    }

    private fun patch(bitmap: Bitmap, cx: Int, cy: Int, side: Int, resolution: Int): List<RgbColor> {
        val half = side / 2
        val left = (cx - half).coerceIn(0, bitmap.width - 1)
        val top = (cy - half).coerceIn(0, bitmap.height - 1)
        val right = (cx + half).coerceIn(0, bitmap.width)
        val bottom = (cy + half).coerceIn(0, bitmap.height)
        val pw = right - left
        val ph = bottom - top
        if (pw < 2 || ph < 2) return emptyList()

        val stepX = maxOf(1, pw / resolution)
        val stepY = maxOf(1, ph / resolution)
        val out = mutableListOf<RgbColor>()
        var y = top
        while (y < bottom) {
            var x = left
            while (x < right) {
                val p = bitmap.getPixel(x, y)
                out += RgbColor.from8(Color.red(p), Color.green(p), Color.blue(p))
                x += stepX
            }
            y += stepY
        }
        return out
    }
}
