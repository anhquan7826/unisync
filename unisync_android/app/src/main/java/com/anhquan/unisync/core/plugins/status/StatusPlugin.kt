package com.anhquan.unisync.core.plugins.status

import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage


class StatusPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.STATUS), StatusReceiver.StatusDataListener {
    init {
        StatusReceiver.registerBroadcast(context)
        StatusReceiver.addListener(this)
    }

    override fun onDispose() {
        StatusReceiver.removeListener(this)
        super.onDispose()
    }

    override fun onReceive(data: Map<String, Any?>) {}

    override fun onStatusChanged(batteryLevel: Int, isCharging: Boolean) {
        send(
            mapOf(
                "level" to batteryLevel,
                "isCharging" to isCharging,
            )
        )
    }
}