package com.anhquan.unisync.core.plugins.notification

import android.app.Notification
import android.content.Context
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationReceiver : NotificationListenerService() {
    interface NotificationListener {
        fun onNotificationReceived(notification: Notification)
    }

    companion object {
        private val callbacks = mutableListOf<(NotificationReceiver) -> Unit>()
        fun run(context: Context, callback: (NotificationReceiver) -> Unit) {
            callbacks.add(callback)
            context.startService(Intent(context, NotificationReceiver::class.java))
        }
    }

    private val listeners = mutableListOf<NotificationListener>()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val callback = callbacks.removeFirst()
        callback.invoke(this)
        return START_STICKY
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        sbn?.run {
//            if (notification.flags and Notification.FLAG_FOREGROUND_SERVICE != 0) return
//            if (notification.flags and Notification.FLAG_ONGOING_EVENT != 0) return
//            if (notification.flags and Notification.FLAG_LOCAL_ONLY != 0) return
//            if (notification.flags and NotificationCompat.FLAG_GROUP_SUMMARY != 0) return
            listeners.forEach {
                it.onNotificationReceived(notification)
            }
        }
    }

    fun addListener(listener: NotificationListener) {
        listeners.add(listener)
    }

    fun removeListener(listener: NotificationListener) {
        listeners.remove(listener)
    }
}