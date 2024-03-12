package com.anhquan.unisync.core.plugins.notification

import android.app.Notification
import android.content.Intent
import android.provider.Settings
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage


class NotificationPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.NOTIFICATION), NotificationReceiver.NotificationListener {
    init {
        NotificationReceiver.addListener(this)
    }

    private var _hasPermission = false
    override val hasPermission: Boolean
        get() = _hasPermission

    override fun requestPermission() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        context.startActivity(intent)
    }

    override fun onReceive(data: Map<String, Any?>) {}

    override fun dispose() {
        NotificationReceiver.removeListener(this)
        super.dispose()
    }

    override fun onNotificationReceived(notification: Notification) {
        _hasPermission = true
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