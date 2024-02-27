package com.anhquan.unisync.core.plugins.volume

import android.content.Context
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class VolumePlugin(
    private val context: Context, private val emitter: DeviceConnection.ConnectionEmitter
) : UnisyncPlugin(context, emitter) {
    override fun onMessageReceived(message: DeviceMessage) {

    }

    override fun isPluginMessage(message: DeviceMessage): Boolean {
        return message.type == DeviceMessage.Type.VOLUME
    }

    override fun dispose() {

    }

    fun changeVolume(value: Float) {
        emitter.sendMessage(
            DeviceMessage(
                type = DeviceMessage.Type.VOLUME,
                body = mapOf(
                    "value" to value
                )
            )
        )
    }
}