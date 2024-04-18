package com.anhquan.unisync.core.plugins.volume

import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class VolumePlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.VOLUME) {
    private object Method {
        const val GET_VOLUME = "get_volume"
        const val SET_VOLUME = "set_volume"
        const val VOLUME_CHANGED = "volume_changed"
    }

    init {
        sendRequest(Method.GET_VOLUME)
    }

    override fun listen(
        header: DeviceMessage.DeviceMessageHeader,
        data: Map<String, Any?>,
        payload: DeviceConnection.Payload?
    ) {
        if (header.method == Method.VOLUME_CHANGED) {
            notifier.onNext(data)
        }
    }

    fun changeVolume(value: Float) {
        sendRequest(
            Method.SET_VOLUME,
            mapOf(
                "value" to value
            )
        )
    }
}