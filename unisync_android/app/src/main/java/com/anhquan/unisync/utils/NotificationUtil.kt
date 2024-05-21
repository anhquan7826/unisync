package com.anhquan.unisync.utils

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.anhquan.unisync.R
import com.anhquan.unisync.UnisyncActivity
import com.anhquan.unisync.ui.screen.find_my_phone.FindMyPhoneActivity

object NotificationUtil {
    private const val CHANNEL_ID_PERSISTENCE = "unisync.channel_persistence"
    private const val CHANNEL_ID_PAIR = "unisync.channel_pair"
    private const val CHANNEL_ID_SFTP = "unisync.channel_sftp"
    private const val CHANNEL_ID_RING_PHONE = "unisync.channel_ring_phone"
    private const val CHANNEL_ID_PROGRESS = "unisync.channel_progress"

    private lateinit var notiManager: NotificationManager

    fun configure(context: Context) {
        notiManager = context.getSystemService(NotificationManager::class.java)
        registerChannels()
    }

    fun showNotification(
        id: Int, notification: Notification
    ) {
        notiManager.notify(id, notification)
    }

    private fun registerChannels() {
        notiManager.apply {
            createNotificationChannels(
                listOf(
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
                    NotificationChannel(
                        CHANNEL_ID_RING_PHONE,
                        "Find my phone Notifition",
                        NotificationManager.IMPORTANCE_HIGH
                    ).apply {
                        description = "This channel is used for Find my phone notification."
                        lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    },
                    NotificationChannel(
                        CHANNEL_ID_SFTP,
                        "SFTP Server Notification",
                        NotificationManager.IMPORTANCE_DEFAULT
                    ).apply {
                        description = "This channel is used for SFTP server notification."
                        lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    }, NotificationChannel(
                        CHANNEL_ID_PROGRESS,
                        "File transfer Notification",
                        NotificationManager.IMPORTANCE_LOW,
                    ).apply {
                        description = "This channel is used for File transfer notification."
                        lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    }
                )
            )
        }
    }

    private fun buildNotification(
        context: Context, channel: String, scope: Notification.Builder.() -> Unit
    ): Notification {
        return Notification.Builder(context, channel).apply(scope).build()
    }

    fun buildPersistentNotification(context: Context): Notification {
        return Notification.Builder(context, CHANNEL_ID_PERSISTENCE)
            .setOngoing(true)
            .setSmallIcon(R.drawable.app_icon_monochrome)
            .setContentTitle(context.getString(R.string.app_name))
            .setContentText(context.getString(R.string.persistent_indicator_text))
            .setContentIntent(
                PendingIntent.getActivity(
                    context,
                    0,
                    Intent(context, UnisyncActivity::class.java),
                    PendingIntent.FLAG_IMMUTABLE
                )
            ).build()
    }

    fun buildFindMyPhoneNotification(context: Context): Notification {
        return Notification.Builder(context, CHANNEL_ID_RING_PHONE)
            .setSmallIcon(R.drawable.phone_ring)
            .setContentTitle(context.getString(R.string.found_my_phone))
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setFullScreenIntent(
                PendingIntent.getActivity(
                    context,
                    5,
                    Intent(context, FindMyPhoneActivity::class.java),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                ), true
            )
            .build()
    }

    fun buildSftpNotification(context: Context): Notification {
        return Notification.Builder(context, CHANNEL_ID_SFTP)
            .setOngoing(true)
            .setSmallIcon(R.drawable.app_icon_monochrome)
            .setContentTitle("Unisync SFTP Server")
            .setContentText("Server is running.")
            .setContentIntent(
                PendingIntent.getActivity(
                    context,
                    0,
                    Intent(context, UnisyncActivity::class.java),
                    PendingIntent.FLAG_IMMUTABLE
                )
            ).build()
    }

    fun buildProgressNotification(
        context: Context,
        title: String,
        text: String,
        progress: Float,
        download: Boolean = true,
        actions: Map<String, () -> Unit> = mapOf()
    ): Notification {
        return Notification.Builder(context, CHANNEL_ID_PROGRESS).apply {
            setOngoing(progress < 1)
            setContentTitle(title)
            setContentText(text)
            setSmallIcon(if (download) R.drawable.download else R.drawable.upload)
            if (progress < 1) {
                setProgress(
                    100,
                    (progress * 100).toInt(),
                    false,
                )
            }
        }.build()
    }
}