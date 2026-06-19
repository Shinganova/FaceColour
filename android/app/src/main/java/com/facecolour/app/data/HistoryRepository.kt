package com.facecolour.app.data

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.io.File

/** JSON-on-disk persistence for analysis records + thumbnail files. */
class HistoryRepository(context: Context) {
    private val dir = File(context.filesDir, "history").apply { mkdirs() }
    private val file = File(dir, "records.json")
    private val gson = Gson()

    fun load(): List<AnalysisRecord> = runCatching {
        if (!file.exists()) return emptyList()
        val type = object : TypeToken<List<AnalysisRecord>>() {}.type
        gson.fromJson<List<AnalysisRecord>>(file.readText(), type) ?: emptyList()
    }.getOrDefault(emptyList())

    fun save(records: List<AnalysisRecord>) {
        runCatching { file.writeText(gson.toJson(records)) }
    }

    fun saveThumbnail(bitmap: Bitmap, id: String): String? = runCatching {
        val name = "$id.jpg"
        File(dir, name).outputStream().use { bitmap.compress(Bitmap.CompressFormat.JPEG, 70, it) }
        name
    }.getOrNull()

    fun loadThumbnail(name: String): Bitmap? =
        runCatching { BitmapFactory.decodeFile(File(dir, name).absolutePath) }.getOrNull()

    fun deleteThumbnail(name: String) {
        runCatching { File(dir, name).delete() }
    }
}
