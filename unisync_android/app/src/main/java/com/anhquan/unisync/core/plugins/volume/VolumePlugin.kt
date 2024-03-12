package com.anhquan.unisync.core.plugins.volume

import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class VolumePlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.VOLUME) {

    init {
        send(
            mapOf(
                "get_volume" to "request"
            )
        )
    }

    override fun onReceive(data: Map<String, Any?>) {
        notifier.onNext(data)
    }

    fun changeVolume(value: Float) {
        send(
            mapOf(
                "set_volume" to value
            )
        )
    }
}