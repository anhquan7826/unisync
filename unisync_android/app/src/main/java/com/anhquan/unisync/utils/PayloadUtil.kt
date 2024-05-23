package com.anhquan.unisync.utils

import com.anhquan.unisync.core.DeviceConnection
import java.io.InputStream
import java.net.Socket
import kotlin.math.min

fun getPayloadStream(address: String, port: Int, callback: (InputStream) -> Unit) {
    ThreadHelper.run {
        val socket = Socket(address, port)
        infoLog("Connected to payload socket $address:$port.")
        callback(socket.getInputStream())
    }
}

fun getPayloadData(
    payload: DeviceConnection.Payload,
    onProgress: ((Float) -> Unit)? = null,
    onDone: (() -> Unit)? = null,
    onReceive: (ByteArray) -> Unit
) {
    ThreadHelper.run {
        try {
            infoLog("Start getting payload data of size ${payload.size}...")
            var progress = 0L
            var prevProgress = 0L
            while (true) {
                val buffer = ByteArray(min(4096L, payload.size - progress).toInt())
                val byteRead = payload.stream.read(buffer)
                progress += byteRead
                onReceive(buffer)
                if (progress - prevProgress > (payload.size * 0.05) || progress == payload.size) {
                    onProgress?.invoke(progress.toFloat() / payload.size)
                    prevProgress = progress
                }
                if (progress >= payload.size) break
            }
            payload.stream.close()
            infoLog("Payload data of size ${payload.size} got!")
            onDone?.invoke()
        } catch (e: Exception) {
            errorLog("Failed to get payload data!")
            e.printStackTrace()
        }
    }
}