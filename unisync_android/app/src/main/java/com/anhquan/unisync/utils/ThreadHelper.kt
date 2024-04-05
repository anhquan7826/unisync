package com.anhquan.unisync.utils

import java.util.concurrent.Executors

object ThreadHelper {
    fun run(callback: () -> Unit) {
        Executors.newCachedThreadPool().execute {
            callback.invoke();
        }
    }
}