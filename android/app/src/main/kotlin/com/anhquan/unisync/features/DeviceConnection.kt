package com.anhquan.unisync.features

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
import javax.crypto.SecretKey

class DeviceConnection private constructor(private val socket: SocketPlugin.SocketConnection) {
    enum class DeviceState {
        ONLINE, OFFLINE, PAIRING, PAIRED
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

        fun getConnection(id: String): DeviceConnection {
            return connections[id]!!
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

    val messageNotifier = ReplaySubject.create<DeviceMessage>()
    lateinit var info: DeviceInfo
        private set

    lateinit var secretKey: SecretKey

    private var isOnline: Boolean = false

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
                messageNotifier.onNext(fromJson(input, DeviceMessage::class.java)!!)
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