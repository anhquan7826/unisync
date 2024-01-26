package com.anhquan.unisync.utils

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.anhquan.unisync.UnisyncActivity

object NotificationUtil {
    abstract class NotificationHandler(private val channel: String) {
        fun showNotification(
            context: Context,
            id: Int = 1,
            scope: Notification.Builder.() -> Unit
        ) {
            val notification = buildNotification(context, channel, scope)
            notiManager.notify(id, notification)
        }
    }

    lateinit var CHANNEL_ID_PERSISTENCE: String
        private set
    lateinit var CHANNEL_ID_PAIR: String
        private set

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
                )
            )
        }
    }

//    fun buildNotification(
//        context: Context,
//        channel: String,
//        title: String? = null,
//        content: String? = null,
//        view: RemoteViews? = null,
//        expandedView: RemoteViews? = null,
//        ongoing: Boolean = false,
//        requestCode: Int,
//        intentExtras: Bundle? = null
//    ): Notification {
//        return Notification.Builder(context, channel).apply {
//            if (title != null) setContentTitle(title)
//            if (content != null) setContentText(content)
//            if (view != null) setCustomContentView(view)
//            if (expandedView != null) setCustomBigContentView(expandedView)
//            setSmallIcon(R.drawable.launch_background)
//            setOngoing(ongoing)
//            setContentIntent(
//                PendingIntent.getActivity(
//                    context,
//                    requestCode,
//                    Intent(context, com.anhquan.unisync.UnisyncActivity::class.java).apply {
//                        if (intentExtras != null) putExtras(intentExtras)
//                    },
//                    PendingIntent.FLAG_IMMUTABLE
//                )
//            )
//        }.build()
//    }

    private fun buildNotification(
        context: Context,
        channel: String,
        scope: Notification.Builder.() -> Unit
    ): Notification {
        return Notification.Builder(context, channel).apply(scope).build()
    }

    fun buildPersistentNotification(context: Context): Notification {
        return Notification.Builder(context, CHANNEL_ID_PERSISTENCE)
            .setOngoing(true)
            .setContentTitle("Unisync")
            .setContentText("Unisync is running in the background.")
            .setContentIntent(
                PendingIntent.getActivity(
                    context,
                    0,
                    Intent(context, UnisyncActivity::class.java),
                    PendingIntent.FLAG_IMMUTABLE
                )
            )
            .build()
    }
}