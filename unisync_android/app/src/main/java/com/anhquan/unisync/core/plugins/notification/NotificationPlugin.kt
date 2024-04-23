package com.anhquan.unisync.core.plugins.notification

import android.app.Notification
import android.content.ComponentName
import android.content.pm.PackageManager
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.MediaSessionManager.OnActiveSessionsChangedListener
import android.media.session.PlaybackState
import android.provider.Settings
import android.service.notification.StatusBarNotification
import androidx.core.content.getSystemService
import androidx.core.content.res.ResourcesCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.extensions.toPrettyString
import com.anhquan.unisync.utils.runTask
import com.anhquan.unisync.utils.warningLog
import io.reactivex.rxjava3.schedulers.Schedulers
import java.io.ByteArrayOutputStream
import java.io.IOException


class NotificationPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.NOTIFICATION),
    NotificationReceiver.NotificationListener, OnActiveSessionsChangedListener {
    private object Method {
        const val NEW_NOTIFICATION = "new_notification"
    }

    private val packageManager = context.packageManager
    private val mediaManager = context.getSystemService(MediaSessionManager::class.java)

    init {
        NotificationReceiver.apply {
            addListener(this@NotificationPlugin)
            startService(context)
        }
        mediaManager.addOnActiveSessionsChangedListener(
            this, ComponentName(context, NotificationReceiver::class.java)
        )
    }

    override val requiredPermission: List<String>
        get() {
            val notificationListenerList = Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners"
            )
            return listOf("enabled_notification_listeners").filterNot {
                notificationListenerList.contains(context.packageName)
            }
        }

    override fun onDispose() {
        NotificationReceiver.removeListener(this)
        mediaManager.removeOnActiveSessionsChangedListener(this)
        super.onDispose()
    }

    override fun onNotificationReceived(sbn: StatusBarNotification) {
        try {
            val notification = sbn.notification
            notification.extras.apply {
                debugLog(toPrettyString())
                val appName = packageManager.getApplicationInfo(sbn.packageName, 0).let {
                    packageManager.getApplicationLabel(it).toString()
                }
                val title = getCharSequence(Notification.EXTRA_TITLE).toString()
                val text = getCharSequence(Notification.EXTRA_TEXT).toString()
                val subText = getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()
                val bigText = getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
                runTask(task = {
                    try {
                        val icon = extractIcon(sbn)
                        val picture = extractPicture(sbn)
                        it.onNext(
                            mapOf(
                                "icon" to icon, "picture" to picture
                            )
                        )
                        it.onComplete()
                    } catch (e: Exception) {
                        it.onNext(mapOf())
                        it.onComplete()
                    }
                }, subscribeOn = Schedulers.computation(), onResult = {
                    val picture = it["picture"]
                    sendNotification(
                        Method.NEW_NOTIFICATION,
                        mapOf(
                            "timestamp" to sbn.postTime,
                            "app_name" to appName,
                            "title" to title,
                            "text" to text,
                            "sub_text" to subText,
                            "big_text" to if (text == bigText) null else bigText
                        ),
                        payload = picture?.let { p ->
                            DeviceConnection.Payload(
                                size = p.size,
                                stream = p.inputStream()
                            )
                        }
                    )
                })
            }
        } catch (e: Exception) {
            warningLog("Something went wrong at ${this::class.simpleName}:\n${e.message}")
        }
    }

    private fun extractPicture(statusBarNotification: StatusBarNotification): ByteArray? {
        return try {
            val drawable = statusBarNotification.notification.getLargeIcon().loadDrawable(context)
            convertBitmapToByteArray(drawableToBitmap(drawable))
        } catch (_: Exception) {
            null
        }
    }

    private fun extractIcon(statusBarNotification: StatusBarNotification): ByteArray? {
        return try {
            val notification = statusBarNotification.notification
            val manager: PackageManager = context.packageManager
            val resources: Resources =
                manager.getResourcesForApplication(statusBarNotification.packageName)
            val icon = ResourcesCompat.getDrawable(
                resources, notification.smallIcon.resId, resources.newTheme()
            )
            convertBitmapToByteArray(drawableToBitmap(icon))
        } catch (e: Exception) {
            null
        }
    }

    private fun drawableToBitmap(drawable: Drawable?): Bitmap? {
        if (drawable == null) return null
        val res: Bitmap = if (drawable.intrinsicWidth > 128 || drawable.intrinsicHeight > 128) {
            Bitmap.createBitmap(96, 96, Bitmap.Config.ARGB_8888)
        } else if (drawable.intrinsicWidth <= 64 || drawable.intrinsicHeight <= 64) {
            Bitmap.createBitmap(96, 96, Bitmap.Config.ARGB_8888)
        } else {
            Bitmap.createBitmap(
                drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888
            )
        }
        val canvas = Canvas(res)
        drawable.setBounds(0, 0, res.width, res.height)
        drawable.draw(canvas)
        return res
    }

    private fun convertBitmapToByteArray(bitmap: Bitmap?): ByteArray? {
        if (bitmap == null) return null
        var baos: ByteArrayOutputStream? = null
        return try {
            baos = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos)
            baos.toByteArray()
        } finally {
            if (baos != null) {
                try {
                    baos.close()
                } catch (_: IOException) {
                }
            }
        }
    }

    override fun onActiveSessionsChanged(controllers: MutableList<MediaController>?) {
        (controllers ?: listOf()).forEach {
            debugLog(it.packageName)
            debugLog(it.playbackState)
            debugLog(it.extras)
        }
    }
}