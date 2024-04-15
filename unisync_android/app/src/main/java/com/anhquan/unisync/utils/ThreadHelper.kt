package com.anhquan.unisync.utils

import java.lang.Exception
import java.util.concurrent.Executors

object ThreadHelper {
    fun run(onError: ((Exception) -> Unit)? = null, callback: () -> Unit) {
        Executors.newCachedThreadPool().execute {
            try {
                callback.invoke()
            } catch (e: Exception) {
                onError?.invoke(e)
            }
        }
    }
}