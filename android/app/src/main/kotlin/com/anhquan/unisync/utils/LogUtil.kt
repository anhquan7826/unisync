package com.anhquan.unisync.utils

import android.util.Log

private const val logTag = "Unisync"

fun debugLog(message: Any?) {
    Log.d(logTag, message.toString())
}

fun errorLog(message: Any?) {
    Log.e(logTag, message.toString())
}

fun warningLog(message: Any?) {
    Log.w(logTag, message.toString())
}

fun infoLog(message: Any?) {
    Log.i(logTag, message.toString())
}