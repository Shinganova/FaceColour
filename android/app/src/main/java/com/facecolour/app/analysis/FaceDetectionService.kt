package com.facecolour.app.analysis

import android.graphics.Bitmap
import android.graphics.Rect
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import kotlinx.coroutines.tasks.await

/** ML Kit face detection on a [Bitmap]. Returns bounding boxes in pixel coords. */
object FaceDetectionService {
    suspend fun detect(bitmap: Bitmap): List<Rect> {
        val options = FaceDetectorOptions.Builder()
            .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
            .build()
        val detector = FaceDetection.getClient(options)
        return try {
            val image = InputImage.fromBitmap(bitmap, 0)
            detector.process(image).await().map { it.boundingBox }
        } finally {
            detector.close()
        }
    }
}
