package com.anhquan.unisync.core.plugins.status

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
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

    override val requiredPermission: List<String>
        get() {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                listOf(Manifest.permission.POST_NOTIFICATIONS).filterNot {
                    ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.POST_NOTIFICATIONS
                    ) == PackageManager.PERMISSION_GRANTED
                }
            } else {
                listOf()
            }
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