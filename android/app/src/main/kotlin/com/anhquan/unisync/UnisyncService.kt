package com.anhquan.unisync

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.anhquan.unisync.core.DeviceDiscovery
import com.anhquan.unisync.plugins.ConnectionPlugin
import com.anhquan.unisync.plugins.UnisyncPlugin
import com.anhquan.unisync.utils.infoLog

class UnisyncService : Service() {
    private val plugin = mutableMapOf<String, UnisyncPlugin>()

    override fun onCreate() {
        super.onCreate()
        configureNotificationChannel()
        startForeground(1, buildPersistentNotification())
        DeviceDiscovery.start(this)
        configurePlugins()
        infoLog("${this::class.simpleName}: service created.")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        DeviceDiscovery.stop()
        infoLog("${this::class.simpleName}: service destroyed.")
    }

    private fun configurePlugins() {
        plugin[UnisyncPlugin.PLUGIN_CONNECTION] = ConnectionPlugin().apply { this.start() }
    }

    private fun configureNotificationChannel() {
        val notificationChannel = NotificationChannel(
            "$packageName.service",
            "Persistent Notification",
            NotificationManager.IMPORTANCE_LOW
        )
        notificationChannel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        getSystemService(NotificationManager::class.java).createNotificationChannel(
            notificationChannel
        )
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