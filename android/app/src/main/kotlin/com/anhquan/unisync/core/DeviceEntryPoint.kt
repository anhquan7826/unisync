package com.anhquan.unisync.core

import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.infoLog
import com.anhquan.unisync.utils.runSingle
import com.anhquan.unisync.utils.runTask
import com.anhquan.unisync.utils.toJson
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.subjects.PublishSubject
import java.io.BufferedReader
import java.io.BufferedWriter
import javax.net.ssl.SSLSocket

object DeviceEntryPoint {
    private val _devices = mutableMapOf<String, DeviceConnection>()
    val devices: List<DeviceInfo> get() = _devices.map { it.value.info }

    object Notifier {
        val connectedDeviceNotifier = PublishSubject.create<DeviceInfo>()
        val disconnectedDeviceNotifier = PublishSubject.create<DeviceInfo>()
        val deviceMessageNotifier = PublishSubject.create<DeviceMessage>()
    }

    fun create(
        info: DeviceInfo,
        socket: SSLSocket
    ) {
        if (!_devices.containsKey(info.id)) {
            _devices[info.id] = DeviceConnection(info, socket)
            Notifier.connectedDeviceNotifier.onNext(info)
        }
    }

    fun remove(info: DeviceInfo) {
        _devices.remove(info.id)
        Notifier.disconnectedDeviceNotifier.onNext(info)
    }

    fun send(
        toDeviceId: String,
        plugin: String,
        function: String,
        extra: Map<String, Any?> = mapOf()
    ) {
        _devices[toDeviceId]?.send(
            toJson(
                DeviceMessage(
                    fromDeviceId = ConfigUtil.Device.getDeviceInfo().id,
                    plugin = plugin,
                    function = function,
                    extra = extra
                )
            )
        )
    }

    private class DeviceConnection(val info: DeviceInfo, val socket: SSLSocket) {
        private val reader: BufferedReader = socket.inputStream.bufferedReader()
        private var writer: BufferedWriter = socket.outputStream.bufferedWriter()

        private lateinit var inputStreamDisposable: Disposable
        private var isConnected = true

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
                    Notifier.deviceMessageNotifier.onNext(fromJson(it, DeviceMessage::class.java)!!)
                }
            )
        }

        fun send(message: String) {
            if (isConnected) {
                runSingle(
                    callback = {
                        writer.apply {
                            write(message)
                            flush()
                        }
                        debugLog("${this::class.simpleName}@${info.name}: Sent message: '$message'.")
                    },
                    onError = {
                        disconnect()
                    }
                )
            } else {
                throw Exception("${this::class.simpleName}@${info.name}: connection has closed!")
            }
        }

        private fun disconnect() {
            isConnected = false
            remove(info)
            try {
                socket.close()
                infoLog("${this::class.simpleName}@${info.name}: Disconnected.")
            } catch (_: Exception) {
            }
        }
    }
}