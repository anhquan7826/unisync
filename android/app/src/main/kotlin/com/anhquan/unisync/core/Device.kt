package com.anhquan.unisync.core

import com.anhquan.unisync.core.interfaces.IDeviceConnection
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.listen

class Device(connection: DeviceConnection) {
    val connection: IDeviceConnection
    val deviceInfo: DeviceInfo

    init {
        this.connection = connection
        deviceInfo = connection.info
        connection.onMessage.listen(onNext = ::onDeviceMessage)
    }

    private val pairingHandler = PairingHandler(this)

    private fun onDeviceMessage(message: DeviceMessage) {
        if (pairingHandler.state == PairingHandler.PairState.PAIRED) {

        } else {
            pairingHandler.onMessageReceived(message)
        }
    }
}