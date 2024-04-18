package com.anhquan.unisync.core.plugins.status

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.toMap


class StatusPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.STATUS), StatusReceiver.StatusDataListener {
    private object Method {
        const val GET_STATUS = "get_status"
        const val STATUS_CHANGED = "status_changed"
    }

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

    override fun listen(
        header: DeviceMessage.DeviceMessageHeader,
        data: Map<String, Any?>,
        payload: DeviceConnection.Payload?
    ) {
        latestStatus?.let {
            sendNotification(
                Method.STATUS_CHANGED,
                toMap(it)
            )
        }
    }

    override fun onStatusChanged(batteryLevel: Int, isCharging: Boolean) {
        latestStatus = Status(
            level = batteryLevel,
            isCharging = isCharging
        )
        sendNotification(
            Method.STATUS_CHANGED,
            toMap(latestStatus!!)
        )
    }
}