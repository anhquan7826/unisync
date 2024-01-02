package com.anhquan.unisync.utils

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.RemoteViews
import com.anhquan.unisync.R
import com.anhquan.unisync.UnisyncActivity

object NotificationUtil {
    abstract class NotificationHandler(protected val channel: String) {
        fun showNotification(id: Int, notification: Notification) {
            notiManager.notify(
                id,
                notification,
            )
        }
    }

    private lateinit var CHANNEL_ID_PERSISTENCE: String
    private lateinit var CHANNEL_ID_PAIR: String

    private lateinit var notiManager: NotificationManager

    fun configure(context: Context) {
        notiManager = context.getSystemService(NotificationManager::class.java)
        generateChannelIds()
        registerChannels()
    }

    private fun generateChannelIds() {
        CHANNEL_ID_PERSISTENCE = "unisync.channel_persistence"
        CHANNEL_ID_PAIR = "unisync.channel_pair"
    }

    private fun registerChannels() {
        notiManager.apply {
            createNotificationChannels(listOf(
                NotificationChannel(
                    CHANNEL_ID_PERSISTENCE,
                    "Persistent Notification",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "This channel is used for Unisync background service."
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                },
                NotificationChannel(
                    CHANNEL_ID_PAIR,
                    "Location Update Notification",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "This channel is used for pairing notification."
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                },
            ))
        }
    }

    private fun buildNotification(
        context: Context,
        channel: String,
        title: String? = null,
        content: String? = null,
        view: RemoteViews? = null,
        expandedView: RemoteViews? = null,
        ongoing: Boolean = false,
        requestCode: Int,
        intentExtras: Bundle? = null
    ): Notification {
        return Notification.Builder(context, channel).apply {
            if (title != null) setContentTitle(title)
            if (content != null) setContentText(content)
            if (view != null) setCustomContentView(view)
            if (expandedView != null) setCustomBigContentView(expandedView)
            setSmallIcon(R.drawable.launch_background)
            setOngoing(ongoing)
            setContentIntent(
                PendingIntent.getActivity(
                    context,
                    requestCode,
                    Intent(context, UnisyncActivity::class.java).apply {
                        if (intentExtras != null) putExtras(intentExtras)
                    },
                    PendingIntent.FLAG_IMMUTABLE
                )
            )
        }.build()
    }

//    private fun buildNotification(scope: Notification.Builder.() -> Unit): Notification {
//        return Notification.Builder
//    }

    fun showDeviceLocationNotification(context: Context, deviceName: String, lat: Double, lon: Double) {
        val warningNotification = buildNotification(
            context,
            CHANNEL_ID_PAIR,
            title = "$deviceName thay đổi vị trí!",
            content = "$lat, $lon",
            requestCode = 1,
        )
        context.getSystemService(NotificationManager::class.java).notify(
            2,
            warningNotification
        )
    }
}