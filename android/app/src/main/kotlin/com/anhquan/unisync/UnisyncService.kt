package com.anhquan.unisync

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.anhquan.unisync.plugins.MdnsPlugin
import com.anhquan.unisync.plugins.SocketPlugin
import com.anhquan.unisync.plugins.UnisyncPlugin
import com.anhquan.unisync.utils.infoLog

class UnisyncService : Service() {
    private val plugins = mutableMapOf<String, UnisyncPlugin>()

    override fun onCreate() {
        super.onCreate()
        initiatePlugins()
        configureFeatures()
        infoLog("${this::class.simpleName}: service created.")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        configureNotificationChannel()
        startPlugins()
        startForeground(1, buildPersistentNotification())
        infoLog("${this::class.simpleName}: service started.")
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        stopPlugins()
    }

    private fun initiatePlugins() {
        plugins[UnisyncPlugin.MDNS_PLUGIN] = MdnsPlugin()
        plugins[UnisyncPlugin.SOCKET_PLUGIN] = SocketPlugin()
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

    private fun configureFeatures() {
//        ChannelUtil.ConnectionChannel.apply {
//            addCallHandler(NATIVE_GET_DISCOVERED_DEVICES) { _, result ->
//                runTask(
//                    task = {
//                        it.onNext(pairingRepository.getDiscoveredDevices())
//                    },
//                    onResult = {
//                        result.success(
//                            toMap(
//                                ChannelResult(
//                                    method = NATIVE_GET_DISCOVERED_DEVICES,
//                                    resultCode = ChannelResult.SUCCESS,
//                                    result = it.map { device -> toMap(device) }
//                                )
//                            )
//                        )
//                    }
//                )
//            }
//        }
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