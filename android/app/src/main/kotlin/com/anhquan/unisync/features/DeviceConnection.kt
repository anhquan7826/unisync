package com.anhquan.unisync.features

import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.plugins.SocketPlugin
import com.anhquan.unisync.plugins.SocketPlugin.ConnectionState.STATE_CONNECTED
import com.anhquan.unisync.plugins.SocketPlugin.ConnectionState.STATE_DISCONNECTED
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.errorLog
import com.anhquan.unisync.utils.fromJson
import com.anhquan.unisync.utils.infoLog
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
        private val connections = mutableListOf<DeviceConnection>()
        val connectionNotifier = ReplaySubject.create<ConnectionNotifierValue>()

        fun getConnections(): List<DeviceConnection> {
            return connections.filter { it::info.isInitialized }.toList()
        }

        fun createConnection(socket: SocketPlugin.SocketConnection) {
            connections.add(DeviceConnection(socket))
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
                    if (::info.isInitialized) connectionNotifier.onNext(
                        ConnectionNotifierValue(
                            DeviceState.OFFLINE,
                            info
                        )
                    )
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
                connectionNotifier.onNext(
                    ConnectionNotifierValue(
                        DeviceState.ONLINE,
                        info
                    )
                )
                infoLog("Connected:")
                infoLog(info)
            } catch (e: Exception) {
                errorLog("${this::class.simpleName}@${socket.address}: Invalid initial message.")
                socket.disconnect()
                connections.remove(this)
            }
        } else {
            messageNotifier.onNext(input)
//            if (input.contains("\"type\":\"${MessageType.request}\"")) {
//                val request = fromJson(input, DeviceRequest::class.java)
//            }
//            if (input.contains("\"type\":\"${MessageType.response}\"")) {
//                val response = fromJson(input, DeviceResponse::class.java)
//            }
        }
    }
}