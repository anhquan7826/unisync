package com.anhquan.unisync.entry

import com.anhquan.unisync.features.UnisyncFeature
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.plugins.SocketPlugin
import com.anhquan.unisync.plugins.SocketPlugin.ConnectionState.STATE_CONNECTED
import com.anhquan.unisync.plugins.SocketPlugin.ConnectionState.STATE_DISCONNECTED
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.listen
import com.anhquan.unisync.utils.toJson
import com.anhquan.unisync.utils.warningLog
import io.reactivex.rxjava3.subjects.ReplaySubject

class DeviceEntryPoint private constructor(private val socket: SocketPlugin.SocketConnection) {
    enum class DeviceState {
        ONLINE, OFFLINE, PAIRING, PAIRED
    }

    data class ConnectionNotifierValue(
        val state: DeviceState,
        val deviceInfo: DeviceInfo,
    )

    companion object {
        private val connections = mutableMapOf<String, DeviceEntryPoint>()

        val connectionNotifier = ReplaySubject.create<ConnectionNotifierValue>()

        val pairingNotifier = ReplaySubject.create<UnisyncFeature.FeatureNotifierMessage>()

        fun getConnections(): List<DeviceEntryPoint> {
            return connections.values.toList()
        }

        fun getConnection(id: String): DeviceEntryPoint {
            return connections[id]!!
        }

        fun createConnection(socket: SocketPlugin.SocketConnection) {
            DeviceEntryPoint(socket)
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

    lateinit var info: DeviceInfo
        private set

    private var isOnline: Boolean = false

    var isPaired: Boolean = false
        private set

    fun sendMessage(message: DeviceMessage) {
        if (isOnline) socket.send(toJson(message))
    }

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
            try {
                // TODO: send feature notify message
            } catch (_: Exception) {
                warningLog("${this::class.simpleName}: Invalid message from ${info.name}. Message is '$input'.")
            }
        }
    }

    private fun onDeviceOnline() {
        if (connections.containsKey(info.id)) {
            debugLog("${this::class.simpleName}: Found duplicate connection to device: ${info.name} (${info.ip})")
            socket.disconnect()
        } else {
            connections[info.id] = this
            connectionNotifier.onNext(
                ConnectionNotifierValue(
                    DeviceState.ONLINE,
                    info
                )
            )
            isOnline = true
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
        isOnline = false
    }
}