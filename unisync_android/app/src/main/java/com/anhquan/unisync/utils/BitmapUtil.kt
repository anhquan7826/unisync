package com.anhquan.unisync.utils

import android.graphics.Bitmap
import java.io.ByteArrayOutputStream
import java.io.IOException

fun convertBitmapToByteArray(bitmap: Bitmap?): ByteArray? {
    if (bitmap == null) return null
    var baos: ByteArrayOutputStream? = null
    return try {
        baos = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos)
        baos.toByteArray()
    } finally {
        if (baos != null) {
            try {
                baos.close()
            } catch (_: IOException) {
            }
        }
    }
}