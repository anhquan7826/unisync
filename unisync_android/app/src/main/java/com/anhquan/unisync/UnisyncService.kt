package com.anhquan.unisync

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
        startForeground(1, NotificationUtil.buildPersistentNotification(this))
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
}