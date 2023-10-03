package com.anhquan.unisync.utils

import android.util.Log

fun debugLog(message: Any?) {
    Log.d("Unisync", message.toString())
}

fun errorLog(message: Any?) {
    Log.e("Unisync", message.toString())
}