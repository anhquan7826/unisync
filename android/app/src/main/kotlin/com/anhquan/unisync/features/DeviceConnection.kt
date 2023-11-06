package com.anhquan.unisync.features

import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.plugins.SocketPlugin
import com.anhquan.unisync.plugins.SocketPlugin.ConnectionState.STATE_CONNECTED
import com.anhquan.unisync.plugins.SocketPlugin.ConnectionState.STATE_DISCONNECTED
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.listen
import com.anhquan.unisync.utils.toJson
import io.reactivex.rxjava3.subjects.ReplaySubject

class DeviceConnection private constructor(private val socket: SocketPlugin.SocketConnection) {
    enum class DeviceState {
        ONLINE, OFFLINE, MESSAGE_RECEIVED, MESSAGE_SENT
    }

    data class ConnectionNotifierValue(
        val state: DeviceState,
        val deviceInfo: DeviceInfo,
    )

    companion object {
        private val connections = mutableMapOf<String, DeviceConnection>()
        val connectionNotifier = ReplaySubject.create<ConnectionNotifierValue>()

        fun getConnections(): List<DeviceConnection> {
            return connections.values.toList()
        }

        fun createConnection(socket: SocketPlugin.SocketConnection) {
            DeviceConnection(socket)
        }
    }

    init {
        socket.connect()
        socket.connectionState.listen {
            when (it) {
                STATE_CONNECTED -> {
                    socket.send(toJson(ConfigUtil.Device.getDeviceInfo()))
                    socket.inputStream.listen(onNext = ::onInputData)
                }

                STATE_DISCONNECTED -> {
                    if (::info.isInitialized) {
                        onDeviceOffline()
                    }
                }

                else -> {}
            }
        }
    }

    private val messageNotifier = ReplaySubject.create<String>()
    lateinit var info: DeviceInfo
        private set

    private fun onInputData(input: String) {
        if (!this::info.isInitialized) {
            try {
                info = fromJson(input, DeviceInfo::class.java)!!.copy(
                    ip = socket.address
                )
                onDeviceOnline()
            } catch (e: Exception) {
                socket.disconnect()
            }
        } else {
            messageNotifier.onNext(input)
        }
    }

    private fun onDeviceOnline() {
        if (connections.containsKey(info.id)) {
            debugLog("Found duplicate connection to device: ${info.name} (${info.ip})")
            socket.disconnect()
        } else {
            connections[info.id] = this
            connectionNotifier.onNext(
                ConnectionNotifierValue(
                    DeviceState.ONLINE,
                    info
                )
            )
        }
    }

    private fun onDeviceOffline() {
        connections.remove(info.id)
        connectionNotifier.onNext(
            ConnectionNotifierValue(
                DeviceState.OFFLINE,
                info
            )
        )
    }
}