package com.anhquan.unisync.core.plugins.status

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.toMap


class StatusPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.STATUS), StatusReceiver.StatusDataListener {
    data class Status(
        val level: Int,
        val isCharging: Boolean
    )

    init {
        StatusReceiver.registerBroadcast(context)
        StatusReceiver.addListener(this)
    }

    private var latestStatus: Status? = null

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

    override fun onReceive(data: Map<String, Any?>) {
        latestStatus?.let {
            send(
                toMap(it)
            )
        }
    }

    override fun onStatusChanged(batteryLevel: Int, isCharging: Boolean) {
        latestStatus = Status(
            level = batteryLevel,
            isCharging = isCharging
        )
        send(
            toMap(latestStatus!!)
        )
    }
}