package com.anhquan.unisync.core

import android.content.Context
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage

class Device(val context: Context, val connection: DeviceConnection, val info: DeviceInfo) :
    DeviceConnection.ConnectionListener {
    init {
        connection.addMessageListener(this)
    }

    private val pairingHandler = PairingHandler(this)

    override fun onMessage(message: DeviceMessage) {
        pairingHandler.onMessageReceived(message)
        if (pairingHandler.state == PairingHandler.PairState.PAIRED) {

        }
    }
}