package com.anhquan.unisync.core.plugins.notification

import android.app.Notification
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class NotificationPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.NOTIFICATION), NotificationReceiver.NotificationListener {
    init {
        NotificationReceiver.run(device.context) {
            it.addListener(this)
        }
    }

    override fun onReceive(data: Map<String, Any?>) {}

    override fun dispose() {
        super.dispose()
        NotificationReceiver.run(device.context) {
            it.removeListener(this)
        }
    }

    override fun onNotificationReceived(notification: Notification) {
        notification.extras.run {
            val title = getString(Notification.EXTRA_TITLE)
            val text = getString(Notification.EXTRA_TEXT)
            send(
                mapOf(
                    "title" to title,
                    "text" to text
                )
            )
        }
    }
}