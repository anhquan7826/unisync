package com.anhquan.unisync.core.plugins.ring_phone

import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.anhquan.unisync.utils.NotificationUtil

class RingPhoneService : Service() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = NotificationUtil.buildFindMyPhoneNotification(this)
        startForeground(5, notification)
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder?  = null
}