package com.anhquan.unisync.utils

import android.util.Log

private const val TAG = "Unisync@Android"

fun debugLog(message: Any?) {
    Log.d(TAG, message.toString())
}

fun errorLog(message: Any?) {
    Log.e(TAG, message.toString())
}

fun warningLog(message: Any?) {
    Log.w(TAG, message.toString())
}

fun infoLog(message: Any?) {
    Log.i(TAG, message.toString())
}