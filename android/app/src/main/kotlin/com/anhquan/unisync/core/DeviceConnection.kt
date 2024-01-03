package com.anhquan.unisync.core

import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.runTask
import com.anhquan.unisync.utils.toJson
import io.reactivex.rxjava3.disposables.Disposable
import java.io.BufferedReader
import java.io.BufferedWriter
import javax.net.ssl.SSLSocket

class DeviceConnection(private val socket: SSLSocket) {
    interface ConnectionListener {
        fun onMessage(message: DeviceMessage)
    }

    private val reader: BufferedReader = socket.inputStream.bufferedReader()
    private var writer: BufferedWriter = socket.outputStream.bufferedWriter()

    private var listener: ConnectionListener? = null

    private lateinit var inputStreamDisposable: Disposable
    private var isConnected = true

    init {
        listenInputStream()
    }

    fun addMessageListener(listener: ConnectionListener) {
        this.listener = listener
    }

    private fun listenInputStream() {
        inputStreamDisposable = runTask(
            task = {
                while (true) {
                    val message = reader.readLine()
                    if (message != null) {
                        it.onNext(message)
                    } else {
                        disconnect()
                        break
                    }
                }
            },
            onResult = {
                fromJson(
                    it,
                    DeviceMessage::class.java
                )?.let { message -> listener?.onMessage(message) }
            }
        )
    }

    fun send(message: DeviceMessage) {
        if (isConnected) {
            runSingle(
                callback = {
                    writer.apply {
                        write(toJson(message))
                        flush()
                    }
                },
                onError = {
                    disconnect()
                }
            )
        }
    }

    fun disconnect() {
        isConnected = false
        try {
            inputStreamDisposable.dispose()
            socket.close()
        } catch (_: Exception) {}
    }
}