package com.anhquan.unisync

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import com.anhquan.unisync.core.DeviceDiscovery
import com.anhquan.unisync.utils.NotificationUtil
import com.anhquan.unisync.utils.infoLog

class UnisyncService : Service() {
    companion object {
        fun restartDiscovery(context: Context) {
            context.startService(Intent(context, UnisyncService::class.java).apply {
                putExtra("command", "restart_discovery")
            })
        }
    }

    private lateinit var deviceDiscovery: DeviceDiscovery

    override fun onCreate() {
        deviceDiscovery = DeviceDiscovery(applicationContext)
        NotificationUtil.configure(applicationContext)
        startForeground(1, NotificationUtil.buildPersistentNotification(this))
        deviceDiscovery.start()
        super.onCreate()
        infoLog("${this::class.simpleName}: service created.")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent != null) {
            val command = intent.getStringExtra("command")
            when (command) {
                "restart_discovery" -> deviceDiscovery.restart()
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        deviceDiscovery.stop()
        infoLog("${this::class.simpleName}: service destroyed.")
    }
}