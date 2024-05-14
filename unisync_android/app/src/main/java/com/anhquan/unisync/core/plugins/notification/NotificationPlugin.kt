package com.anhquan.unisync.core.plugins.notification

import android.app.Notification
import android.content.pm.PackageManager
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.provider.Settings
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import androidx.core.content.res.ResourcesCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.runTask
import com.anhquan.unisync.utils.warningLog
import io.reactivex.rxjava3.schedulers.Schedulers
import java.io.ByteArrayOutputStream
import java.io.IOException


class NotificationPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.NOTIFICATION),
    NotificationReceiver.NotificationListener {
    private object Method {
        const val NEW_NOTIFICATION = "new_notification"
    }

    private val packageManager = context.packageManager

    init {
        NotificationReceiver.apply {
            addListener(this@NotificationPlugin)
            startService(context)
        }
    }

    override val requiredPermission: List<String>
        get() {
            val notificationListenerList = Settings.Secure.getString(
                context.contentResolver, "enabled_notification_listeners"
            )
            return listOf("enabled_notification_listeners").filterNot {
                notificationListenerList.contains(context.packageName)
            }
        }

    override fun onDispose() {
        NotificationReceiver.removeListener(this)
        super.onDispose()
    }

    override fun onNotificationReceived(sbn: StatusBarNotification) {
        try {
            val notification = sbn.notification
            val packageName = sbn.packageName

            if (notification.flags and Notification.FLAG_FOREGROUND_SERVICE != 0 || notification.flags and Notification.FLAG_ONGOING_EVENT != 0 || notification.flags and Notification.FLAG_LOCAL_ONLY != 0 || notification.flags and NotificationCompat.FLAG_GROUP_SUMMARY != 0) {
                return
            }

            if (context.packageName == packageName) {
                // Don't send our own notifications
                return
            }

            if (notification?.category != Notification.CATEGORY_TRANSPORT) {
                onNormalNotification(sbn)
            }

        } catch (e: Exception) {
            warningLog("Something went wrong at ${this::class.simpleName}:\n${e.message}")
        }
    }

    private fun onNormalNotification(sbn: StatusBarNotification) {
        val notification = sbn.notification
        val appName = packageManager.getApplicationInfo(sbn.packageName, 0).let {
            packageManager.getApplicationLabel(it).toString()
        }
        notification.extras.apply {
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
                sendNotification(Method.NEW_NOTIFICATION, mapOf(
                    "timestamp" to sbn.postTime,
                    "app_name" to appName,
                    "title" to title,
                    "text" to text,
                    "sub_text" to subText,
                    "big_text" to if (text == bigText) null else bigText
                ), payload = picture?.let { p ->
                    DeviceConnection.Payload(
                        size = p.size, stream = p.inputStream()
                    )
                })
            })
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
}