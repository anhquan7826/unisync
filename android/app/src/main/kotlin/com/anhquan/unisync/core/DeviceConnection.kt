package com.anhquan.unisync.core

import com.anhquan.unisync.core.interfaces.IDeviceConnection
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.runTask
import com.anhquan.unisync.utils.toJson
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.subjects.ReplaySubject
import java.io.BufferedReader
import java.io.BufferedWriter
import javax.net.ssl.SSLSocket

class DeviceConnection(val info: DeviceInfo, private val socket: SSLSocket) : IDeviceConnection {
    private val reader: BufferedReader = socket.inputStream.bufferedReader()
    private var writer: BufferedWriter = socket.outputStream.bufferedWriter()

    private lateinit var inputStreamDisposable: Disposable
    private var isConnected = true

    val onMessage = ReplaySubject.create<DeviceMessage>()

    init {
        listenInputStream()
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
                debugLog("${this::class.simpleName}@${info.name}: Received message: '$it'.")
                fromJson(
                    it,
                    DeviceMessage::class.java
                )?.let { message -> onMessage.onNext(message) }
            }
        )
    }

    override fun send(message: DeviceMessage) {
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

    private fun disconnect() {
        isConnected = false
        try {
            inputStreamDisposable.dispose()
            socket.close()
        } catch (_: Exception) {}
    }
}