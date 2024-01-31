package com.anhquan.unisync.core.plugins

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.models.DeviceMessage

class BatteryPlugin(
    private val context: Context,
    private val emitter: DeviceConnection.ConnectionEmitter
) : UnisyncPlugin(context, emitter) {
    override fun onMessageReceived(message: DeviceMessage) {
        IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
            context.registerReceiver(null, ifilter)
        }?.apply {
            val isCharging = getIntExtra(
                BatteryManager.EXTRA_STATUS,
                -1
            ) == BatteryManager.BATTERY_STATUS_CHARGING
            val level = getIntExtra("level", -1)
            emitter.sendMessage(
                DeviceMessage(
                    type = DeviceMessage.Type.BATTERY,
                    body = mapOf(
                        "level" to level,
                        "isCharging" to isCharging
                    )
                )
            )
        }
    }

    override fun isPluginMessage(message: DeviceMessage): Boolean {
        return message.type == DeviceMessage.Type.BATTERY
    }

    override fun dispose() {

    }
}