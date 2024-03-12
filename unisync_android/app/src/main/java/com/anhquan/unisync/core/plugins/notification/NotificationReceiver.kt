package com.anhquan.unisync.core.plugins.notification

import android.app.Notification
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationReceiver : NotificationListenerService() {
    interface NotificationListener {
        fun onNotificationReceived(notification: Notification)
    }

    companion object {
        private val listeners = mutableListOf<NotificationListener>()

        fun addListener(listener: NotificationListener) {
            listeners.add(listener)
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
        sbn?.apply {
//            if (notification.flags and Notification.FLAG_FOREGROUND_SERVICE != 0) return
//            if (notification.flags and Notification.FLAG_ONGOING_EVENT != 0) return
//            if (notification.flags and Notification.FLAG_LOCAL_ONLY != 0) return
//            if (notification.flags and NotificationCompat.FLAG_GROUP_SUMMARY != 0) return
            listeners.forEach {
                it.onNotificationReceived(notification)
            }
        }
    }
}