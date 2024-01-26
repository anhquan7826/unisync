package com.anhquan.unisync.core.device

import android.content.Context
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.core.device.dependencies.PairingHandler
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage

class Device(val context: Context, val connection: DeviceConnection, val info: DeviceInfo) :
    DeviceConnection.ConnectionListener {
    init {
        connection.addMessageListener(this)
        connection.deviceInfo = info
    }

    private val pairingHandler = PairingHandler(this)

    val pairState: PairingHandler.PairState get() {
        return pairingHandler.state
    }

    override fun onConnection() {
    }

    override fun onMessage(message: DeviceMessage) {
        pairingHandler.onMessageReceived(message)
        if (pairingHandler.state == PairingHandler.PairState.PAIRED) {

        }
    }

    override fun onDisconnection() {
    }
}