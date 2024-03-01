package com.anhquan.unisync.utils

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.anhquan.unisync.R
import com.anhquan.unisync.UnisyncActivity
import com.anhquan.unisync.ui.screen.find_my_phone.FindMyPhoneActivity

object NotificationUtil {
    abstract class NotificationHandler(private val channel: String) {
        fun showNotification(
            context: Context, id: Int = 1, scope: Notification.Builder.() -> Unit
        ) {
            val notification = buildNotification(context, channel, scope)
            notiManager.notify(id, notification)
        }
    }

    val CHANNEL_ID_PERSISTENCE = "unisync.channel_persistence"
    val CHANNEL_ID_PAIR = "unisync.channel_pair"
    val CHANNEL_ID_RING_PHONE = "unisync.channel_ring_phone"

    private lateinit var notiManager: NotificationManager

    fun configure(context: Context) {
        notiManager = context.getSystemService(NotificationManager::class.java)
        registerChannels()
    }

    private fun registerChannels() {
        notiManager.apply {
            createNotificationChannels(listOf(NotificationChannel(
                CHANNEL_ID_PERSISTENCE,
                "Persistent Notification",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "This channel is used for Unisync background service."
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }, NotificationChannel(
                CHANNEL_ID_PAIR,
                "Location Update Notification",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "This channel is used for pairing notification."
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }, NotificationChannel(
                CHANNEL_ID_RING_PHONE,
                "Find my phone Notifition",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "This channel is used for Find my phone notification."
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }))
        }
    }

    private fun buildNotification(
        context: Context, channel: String, scope: Notification.Builder.() -> Unit
    ): Notification {
        return Notification.Builder(context, channel).apply(scope).build()
    }

    fun buildPersistentNotification(context: Context): Notification {
        return Notification.Builder(context, CHANNEL_ID_PERSISTENCE).setOngoing(true)
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
            .setAutoCancel(true)
            .setOngoing(true)
            .setFullScreenIntent(
                PendingIntent.getActivity(
                    context,
                    1,
                    Intent(context, FindMyPhoneActivity::class.java).apply {
                        addFlags(Intent.FLAG_RECEIVER_FOREGROUND)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    },
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                ), true
            )
            .build()
    }
}