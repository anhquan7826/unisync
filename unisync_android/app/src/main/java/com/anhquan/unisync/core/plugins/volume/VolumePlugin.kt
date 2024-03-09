package com.anhquan.unisync.core.plugins.volume

import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class VolumePlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.VOLUME) {
    private var _currentVolume: Double = 0.0
    val currentVolume get() = _currentVolume

    init {
        send(
            mapOf(
                "get_volume" to "request"
            )
        )
    }

    override fun onReceive(data: Map<String, Any?>) {
        _currentVolume = data["volume"].toString().toDouble()
        notifier.onNext(
            mapOf(
                "volume" to data["volume"]
            )
        )
    }

    fun changeVolume(value: Float) {
        send(
            mapOf(
                "set_volume" to value
            )
        )
    }
}