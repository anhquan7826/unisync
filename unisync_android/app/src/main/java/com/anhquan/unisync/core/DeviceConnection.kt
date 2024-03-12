package com.anhquan.unisync.core

import android.content.Context
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.runTask
import com.anhquan.unisync.utils.toJson
import io.reactivex.rxjava3.disposables.Disposable
import java.io.BufferedReader
import java.io.BufferedWriter
import javax.net.ssl.SSLSocket

class DeviceConnection(
    val context: Context,
    private val socket: SSLSocket,
    private val onDisconnected: (() -> Unit)? = null
) {
    interface ConnectionListener {
        fun onMessage(message: DeviceMessage)

        fun onDisconnected()
    }

    private val reader: BufferedReader = socket.inputStream.bufferedReader()
    private var writer: BufferedWriter = socket.outputStream.bufferedWriter()

    var connectionListener: ConnectionListener? = null

    private lateinit var inputStreamDisposable: Disposable
    private var isConnected = true

    val ipAddress: String get() = socket.inetAddress?.hostAddress ?: ""

    init {
        listenInputStream()
    }

    private fun listenInputStream() {
        inputStreamDisposable = runTask(task = {
            while (true) {
                val message = reader.readLine()
                if (message != null) {
                    it.onNext(message)
                } else {
                    disconnect()
                    break
                }
            }
        }, onResult = {
            fromJson(
                it, DeviceMessage::class.java
            )?.let { message ->
                connectionListener?.onMessage(message)
            }
        })
    }

    fun send(message: DeviceMessage) {
        if (isConnected) {
            runSingle(callback = {
                writer.apply {
                    write(toJson(message))
                    flush()
                }
            }, onError = {
                disconnect()
            })
        }
    }

    private fun disconnect() {
        isConnected = false
        try {
            inputStreamDisposable.dispose()
            socket.close()
            onDisconnected?.invoke()
            connectionListener?.onDisconnected()
        } catch (_: Exception) {
        }
    }
}