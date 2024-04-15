package com.anhquan.unisync.utils

import java.io.InputStream
import java.net.Socket

fun getPayloadStream(address: String, port: Int, callback: (InputStream) -> Unit) {
    ThreadHelper.run {
        val socket = Socket(address, port)
        callback(socket.getInputStream())
    }
}

fun getPayloadData(stream: InputStream, size: Int, onReceive: (Int, ByteArray?) -> Unit) {
    ThreadHelper.run {
        try {
            infoLog("Start getting payload data of size $size...")
            val buffer = ByteArray(4096)
            var progress = 0
            while (true) {
                val byteRead = stream.read(buffer, progress, buffer.size)
                progress += byteRead
                infoLog("Progress: ${String.format("%.2f", (progress / size) * 100)}%")
                if (progress >= size) break
            }
            infoLog("Payload data of size $size got!")
        } catch (e: Exception) {
            errorLog("Failed to get payload data!")
            e.printStackTrace()
        }
    }
}