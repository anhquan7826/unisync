package com.anhquan.unisync.core.plugins.notification

import android.content.Context
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationReceiver : NotificationListenerService() {
    interface NotificationListener {
        fun onNotificationReceived(sbn: StatusBarNotification)
    }

    companion object {
        private var isStarted: Boolean = false
        private val listeners = mutableListOf<NotificationListener>()

        fun startService(context: Context) {
            if (isStarted) return
            context.startService(Intent(context, NotificationReceiver::class.java))
            isStarted = true
        }

        fun addListener(listener: NotificationListener) {
            if (!listeners.contains(listener)) listeners.add(listener)
        }

        fun removeListener(listener: NotificationListener) {
            listeners.remove(listener)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        // Skip Unisync notifications.
        if (sbn?.packageName == packageName) return
        sbn?.apply {
            listeners.forEach {
                it.onNotificationReceived(this)
            }
        }
    }
}