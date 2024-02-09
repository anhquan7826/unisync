package com.anhquan.unisync.core.plugins.notification

import android.app.Notification
import android.content.Context
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class NotificationPlugin(
    private val context: Context, private val emitter: DeviceConnection.ConnectionEmitter
) : UnisyncPlugin(context, emitter), NotificationReceiver.NotificationListener {
    init {
        NotificationReceiver.run(context) {
            it.addListener(this)
        }
    }

    override fun onMessageReceived(message: DeviceMessage) {

    }

    override fun isPluginMessage(message: DeviceMessage): Boolean {
        return message.type == DeviceMessage.Type.NOTIFICATION
    }

    override fun dispose() {
        NotificationReceiver.run(context) {
            it.removeListener(this)
        }
    }

    override fun onNotificationReceived(notification: Notification) {
        notification.extras.run {
            val title = getString(Notification.EXTRA_TITLE)
            val text = getString(Notification.EXTRA_TEXT)
            emitter.sendMessage(
                DeviceMessage(
                    type = DeviceMessage.Type.NOTIFICATION,
                    body = mapOf(
                        "title" to title,
                        "text" to text
                    )
                )
            )
        }
    }
}