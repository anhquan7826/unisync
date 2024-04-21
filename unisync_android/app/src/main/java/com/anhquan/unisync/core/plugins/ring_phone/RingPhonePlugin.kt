package com.anhquan.unisync.core.plugins.ring_phone

import android.app.NotificationManager
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.NotificationUtil

class RingPhonePlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.RING_PHONE) {
    private val notificationManager = context.getSystemService(NotificationManager::class.java)
    private object Method {
        const val RING = "ring"
    }

    override fun listen(
        header: DeviceMessage.DeviceMessageHeader,
        data: Map<String, Any?>,
        payload: DeviceConnection.Payload?
    ) {
        super.listen(header, data, payload)
        notificationManager.notify(1, NotificationUtil.buildFindMyPhoneNotification(context))
    }
}