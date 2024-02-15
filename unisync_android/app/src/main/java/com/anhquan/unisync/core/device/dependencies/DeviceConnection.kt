package com.anhquan.unisync.core.device.dependencies

import com.anhquan.unisync.core.providers.DeviceProvider
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.infoLog
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.runTask
import com.anhquan.unisync.utils.toJson
import io.reactivex.rxjava3.disposables.Disposable
import java.io.BufferedReader
import java.io.BufferedWriter
import javax.net.ssl.SSLSocket

class DeviceConnection(private val socket: SSLSocket) {
    interface ConnectionListener {
        fun onConnection()

        fun onMessage(message: DeviceMessage)

        fun onDisconnection()
    }

    interface ConnectionEmitter {
        fun sendMessage(message: DeviceMessage)
    }

    private val reader: BufferedReader = socket.inputStream.bufferedReader()
    private var writer: BufferedWriter = socket.outputStream.bufferedWriter()

    lateinit var deviceInfo: DeviceInfo
    private var listener: ConnectionListener? = null

    private lateinit var inputStreamDisposable: Disposable
    private var isConnected = true

    init {
        listenInputStream()
    }

    fun addMessageListener(listener: ConnectionListener) {
        this.listener = listener
        this.listener!!.onConnection()
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
                infoLog("${deviceInfo.name}@${deviceInfo.ip}: Message received:\n$it")
                fromJson(
                    it,
                    DeviceMessage::class.java
                )?.let { message ->
                    listener?.onMessage(message)
                }
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
                    infoLog("${deviceInfo.name}@${deviceInfo.ip}: Message sent:\n${toJson(message)}")
                },
                onError = {
                    disconnect()
                }
            )
        }
    }

    private fun disconnect() {
        isConnected = false
        try {
            inputStreamDisposable.dispose()
            socket.close()
            listener?.onDisconnection()
            DeviceProvider.remove(deviceInfo)
        } catch (_: Exception) {
        }
    }
}