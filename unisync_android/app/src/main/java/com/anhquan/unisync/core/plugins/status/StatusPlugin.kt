package com.anhquan.unisync.core.plugins.status

import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage


class StatusPlugin(
    device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.STATUS), StatusReceiver.StatusDataListener {
    init {
        StatusReceiver.addListener(this)
        device.context?.let { StatusReceiver.registerBroadcast(it) }
    }

    override fun dispose() {
        StatusReceiver.removeListener(this)
        super.dispose()
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