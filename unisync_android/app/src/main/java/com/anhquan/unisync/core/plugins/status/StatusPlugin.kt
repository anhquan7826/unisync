package com.anhquan.unisync.core.plugins.status

import android.Manifest
import android.app.WallpaperManager
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.os.Build
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.toBitmap
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.toMap
import java.io.ByteArrayOutputStream
import java.io.IOException


class StatusPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.STATUS), StatusReceiver.StatusDataListener {
    private object Method {
        const val GET_STATUS = "get_status"
        const val STATUS_CHANGED = "status_changed"
        const val SHUT_DOWN = "shut_down"
        const val RESTART = "restart"
        const val LOCK = "lock"
    }

    private val wallpaperManager = context.getSystemService(WallpaperManager::class.java)

    data class Status(
        val level: Int,
        val isCharging: Boolean
    )

    init {
        StatusReceiver.registerBroadcast(context)
        StatusReceiver.addListener(this)
    }

    private var latestStatus: Status? = null

    override fun onDispose() {
        StatusReceiver.removeListener(this)
        super.onDispose()
    }

    override val requiredPermission: List<String>
        get() {
            val permissions = mutableListOf<String>()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                if (ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.POST_NOTIFICATIONS
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    permissions.add(Manifest.permission.POST_NOTIFICATIONS)
                }
            } else if (ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.READ_EXTERNAL_STORAGE
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
            return permissions
        }

    override fun listen(
        header: DeviceMessage.DeviceMessageHeader,
        data: Map<String, Any?>,
        payload: DeviceConnection.Payload?
    ) {
        super.listen(header, data, payload)
        latestStatus?.let {
            sendNotification(
                Method.STATUS_CHANGED,
                toMap(it),
                wallpaper?.let { w ->
                    DeviceConnection.Payload(
                        w.inputStream(),
                        w.size
                    )
                }
            )
        }
    }

    private val wallpaper: ByteArray?
        get() {
            return if (hasPermission) {
                convertBitmapToByteArray(wallpaperManager.drawable?.toBitmap())
            } else {
                null
            }
        }

    override fun onStatusChanged(batteryLevel: Int, isCharging: Boolean) {
        latestStatus = Status(
            level = batteryLevel,
            isCharging = isCharging
        )
        sendNotification(
            Method.STATUS_CHANGED,
            toMap(latestStatus!!),
            wallpaper?.let {
                DeviceConnection.Payload(
                    it.inputStream(),
                    it.size
                )
            }
        )
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

    fun shutdown() {
        sendRequest(Method.SHUT_DOWN)
    }

    fun restart() {
        sendRequest(Method.RESTART)
    }

    fun lock() {
        sendRequest(Method.LOCK)
    }
}