package com.anhquan.unisync.core.plugins.notification

import android.app.Notification
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.provider.Settings
import android.service.notification.StatusBarNotification
import androidx.core.content.res.ResourcesCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.extensions.addTo
import com.anhquan.unisync.utils.runTask
import io.reactivex.rxjava3.disposables.CompositeDisposable
import io.reactivex.rxjava3.schedulers.Schedulers
import java.io.ByteArrayOutputStream
import java.io.IOException


class NotificationPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.NOTIFICATION), NotificationReceiver.NotificationListener {
    init {
        NotificationReceiver.apply {
            addListener(this@NotificationPlugin)
            startService(context)
        }
    }

    private val packageManager = context.packageManager

    private val disposables = CompositeDisposable()

    override val hasPermission: Boolean
        get() {
            val notificationListenerList =
                Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")
            return notificationListenerList.contains(context.packageName)
        }

    override fun requestPermission(callback: (Boolean) -> Unit) {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        context.startActivity(intent)
    }

    override fun onReceive(data: Map<String, Any?>) {}

    override fun onDispose() {
        NotificationReceiver.removeListener(this)
        disposables.dispose()
        super.onDispose()
    }

    override fun onNotificationReceived(sbn: StatusBarNotification) {
        val notification = sbn.notification
        notification.extras.apply {
            val appName = packageManager.getApplicationInfo(sbn.packageName, 0).let {
                packageManager.getApplicationLabel(it).toString()
            }
            val title = getString(Notification.EXTRA_TITLE)
            val text = getString(Notification.EXTRA_TEXT)
            runTask(task = {
                val icon = extractIcon(sbn)
                val picture = extractPicture(sbn)
                it.onNext(
                    mapOf(
                        "icon" to icon, "picture" to picture
                    )
                )
            }, subscribeOn = Schedulers.computation(), onResult = {
                send(
                    mapOf(
                        "timestamp" to sbn.postTime,
                        "app_name" to appName,
                        "title" to title,
                        "text" to text,
//                        "icon" to it["icon"],
//                        "picture" to it["picture"],
                    )
                )
            }).addTo(disposables)
        }
    }

    private fun extractPicture(statusBarNotification: StatusBarNotification): ByteArray? {
        val drawable = statusBarNotification.notification.getLargeIcon().loadDrawable(context)
        if (drawable != null) {
            return convertBitmapToByteArray(drawableToBitmap(drawable))
        }
        return null
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