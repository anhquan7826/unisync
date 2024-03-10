package com.anhquan.unisync.core.plugins.volume

import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class VolumePlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.VOLUME) {
    var currentVolume: Float = 0F
        private set

    init {
        send(
            mapOf(
                "get_volume" to "request"
            )
        )
    }

    override fun onReceive(data: Map<String, Any?>) {
        currentVolume = data["volume"].toString().toFloat()
        notifier.onNext(
            mapOf(
                "volume" to data["volume"]
            )
        )
    }

    fun changeVolume(value: Float) {
        currentVolume = value
        send(
            mapOf(
                "set_volume" to value
            )
        )
    }
}