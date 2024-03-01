package com.anhquan.unisync.core.plugins.ring_phone

import android.app.NotificationManager
import android.content.Context
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.NotificationUtil

class RingPhonePlugin(
    private val context: Context,
    private val emitter: DeviceConnection.ConnectionEmitter
) : UnisyncPlugin(context, emitter) {
    private val notificationManager = context.getSystemService(NotificationManager::class.java)

    override fun onMessageReceived(message: DeviceMessage) {
        notificationManager.notify(1, NotificationUtil.buildFindMyPhoneNotification(context))
    }

    override fun isPluginMessage(message: DeviceMessage): Boolean {
        return message.type == DeviceMessage.Type.RING_PHONE
    }

    override fun dispose() {

    }
}