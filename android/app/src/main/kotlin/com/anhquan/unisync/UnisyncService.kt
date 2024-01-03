package com.anhquan.unisync

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.anhquan.unisync.core.DeviceDiscovery
import com.anhquan.unisync.utils.NotificationUtil
import com.anhquan.unisync.utils.infoLog

class UnisyncService : Service() {
    private lateinit var deviceDiscovery: DeviceDiscovery

    override fun onCreate() {
        deviceDiscovery = DeviceDiscovery(applicationContext)
        NotificationUtil.configure(applicationContext)
        startForeground(1, buildPersistentNotification())
        deviceDiscovery.start()
        super.onCreate()
        infoLog("${this::class.simpleName}: service created.")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        deviceDiscovery.stop()
        infoLog("${this::class.simpleName}: service destroyed.")
    }

    private fun buildPersistentNotification(): Notification {
        return Notification.Builder(this, "$packageName.service")
            .setOngoing(true)
            .setContentTitle("Unisync")
            .setContentText("Unisync is running in the background.")
            .setContentIntent(
                PendingIntent.getActivity(
                    this,
                    0,
                    Intent(this, UnisyncActivity::class.java),
                    PendingIntent.FLAG_IMMUTABLE
                )
            )
            .build()
    }
}