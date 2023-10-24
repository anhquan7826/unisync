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

class DeviceConnection private constructor(private val socket: SocketPlugin.SocketConnection) {
    companion object {
        private val connectedDevices = mutableListOf<DeviceConnection>()

        fun getConnectedDevices(): List<DeviceInfo> {
            return connectedDevices.map { it.info }
        }

        fun getUnpairedDevices(): List<DeviceInfo> {
            return connectedDevices.filter { !it.isPaired }.map { it.info }
        }

        fun createConnection(socket: SocketPlugin.SocketConnection) {
            connectedDevices.add(DeviceConnection(socket))
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

                }
                else -> {}
            }
        }
    }

    private lateinit var info: DeviceInfo
    var isPaired: Boolean = false
        private set

    private fun onInputData(input: String) {
        if (!this::info.isInitialized) {
            try {
                info = fromJson(input, DeviceInfo::class.java)!!.copy(
                    ip = socket.address
                )
                infoLog("Connected:")
                infoLog(info)
            } catch (e: Exception) {
                errorLog("${this::class.simpleName}@${socket.address}: Invalid initial message.")
                socket.disconnect()
                connectedDevices.remove(this)
            }
        } else {

        }
    }
}