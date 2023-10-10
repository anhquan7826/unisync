package com.anhquan.unisync

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import android.os.IBinder
import com.anhquan.unisync.models.ChannelResult
import com.anhquan.unisync.plugins.MethodChannelPlugin
import com.anhquan.unisync.repository.ConfigRepository
import com.anhquan.unisync.repository.PairingRepository
import com.anhquan.unisync.utils.runTask
import com.anhquan.unisync.utils.toMap
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class UnisyncService : Service() {
    @Inject
    lateinit var pairingRepository: PairingRepository

    @Inject
    lateinit var configRepository: ConfigRepository

    @Inject
    lateinit var notificationManager: NotificationManager

    private lateinit var connectivityManager: ConnectivityManager
    private lateinit var wifiManager: WifiManager

    override fun onCreate() {
        super.onCreate()
        connectivityManager = getSystemService(ConnectivityManager::class.java)
        wifiManager = getSystemService(WifiManager::class.java)

        MethodChannelPlugin.ConnectionChannel.apply {
            addCallHandler(NATIVE_START_DISCOVERY_SERVICE) { _, result ->
                runTask<Unit>(
                    task = {
                        try {
                            pairingRepository.startService()
                            it.onComplete()
                        } catch (e: Exception) {
                            it.onError(e)
                        }
                    },
                    onComplete = {
                        result.success(
                            toMap(
                                ChannelResult(
                                    method = NATIVE_START_DISCOVERY_SERVICE,
                                    resultCode = ChannelResult.SUCCESS
                                )
                            )
                        )
                    },
                    onError = {
                        // TODO: Define error codes.
                        result.success(
                            toMap(
                                ChannelResult(
                                    method = NATIVE_START_DISCOVERY_SERVICE,
                                    resultCode = ChannelResult.FAILED,
                                    error = it.message
                                )
                            )
                        )
                    }
                )
            }
            addCallHandler(NATIVE_STOP_DISCOVERY_SERVICE) { _, result ->
                runTask<Unit>(
                    task = {
                        try {
                            pairingRepository.stopService()
                            it.onComplete()
                        } catch (e: Exception) {
                            it.onError(e)
                        }
                    },
                    onComplete = {
                        result.success(
                            toMap(
                                ChannelResult(
                                    method = NATIVE_STOP_DISCOVERY_SERVICE,
                                    resultCode = ChannelResult.SUCCESS
                                )
                            )
                        )
                    },
                    onError = {
                        result.success(
                            toMap(
                                ChannelResult(
                                    method = NATIVE_STOP_DISCOVERY_SERVICE,
                                    resultCode = ChannelResult.FAILED,
                                    error = it.message
                                )
                            )
                        )
                    }
                )
            }
            addCallHandler(NATIVE_GET_DISCOVERED_DEVICES) { _, result ->
                runTask(
                    task = {
                        it.onNext(pairingRepository.getDiscoveredDevices())
                    },
                    onResult = {
                        result.success(
                            toMap(
                                ChannelResult(
                                    method = NATIVE_GET_DISCOVERED_DEVICES,
                                    resultCode = ChannelResult.SUCCESS,
                                    result = it.map { device -> toMap(device) }
                                )
                            )
                        )
                    }
                )
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notificationChannel = NotificationChannel(
            "$packageName.service",
            "Persistent Notification",
            NotificationManager.IMPORTANCE_LOW
        )
        notificationChannel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        notificationManager.createNotificationChannel(notificationChannel)
        val notification = Notification.Builder(this, "$packageName.service")
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
        startForeground(1, notification)
        return START_STICKY
    }
}