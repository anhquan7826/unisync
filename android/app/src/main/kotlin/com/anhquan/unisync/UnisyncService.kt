package com.anhquan.unisync

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.anhquan.unisync.features.PairingFeature
import com.anhquan.unisync.features.UnisyncFeature
import com.anhquan.unisync.plugins.MdnsPlugin
import com.anhquan.unisync.plugins.SocketPlugin
import com.anhquan.unisync.plugins.UnisyncPlugin
import com.anhquan.unisync.utils.infoLog

class UnisyncService : Service() {
    private val plugins = mutableMapOf<String, UnisyncPlugin>()
    private val features = mutableMapOf<String, UnisyncFeature>()

    override fun onCreate() {
        super.onCreate()
        configureNotificationChannel()
        initiateFeatures()
        initiatePlugins()
        infoLog("${this::class.simpleName}: service created.")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startPlugins()
        startForeground(1, buildPersistentNotification())
        infoLog("${this::class.simpleName}: service started.")
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        stopPlugins()
        infoLog("${this::class.simpleName}: service destroyed.")
    }

    /**
     * Creates plugin instances and add handlers to features.
     */
    private fun initiatePlugins() {
        plugins[UnisyncPlugin.PLUGIN_MDNS] = UnisyncPlugin.Builder.buildPlugin(
            MdnsPlugin::class.java,
            onStart = {
                features[UnisyncFeature.FEATURE_PAIRING]!!.addHandler(UnisyncPlugin.PLUGIN_MDNS, it)
            }
        )
        plugins[UnisyncPlugin.PLUGIN_SOCKET] = UnisyncPlugin.Builder.buildPlugin(
            SocketPlugin::class.java,
            onStart = {
                features[UnisyncFeature.FEATURE_PAIRING]!!.addHandler(
                    UnisyncPlugin.PLUGIN_SOCKET,
                    it
                )
            }
        )
    }

    private fun startPlugins() {
        plugins.values.forEach {
            it.start(this)
        }
    }

    private fun stopPlugins() {
        plugins.values.forEach {
            it.stop()
        }
    }

    private fun initiateFeatures() {
        features[UnisyncFeature.FEATURE_PAIRING] = PairingFeature()
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