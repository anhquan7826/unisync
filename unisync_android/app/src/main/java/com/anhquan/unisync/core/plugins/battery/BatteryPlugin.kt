package com.anhquan.unisync.core.plugins.battery

import android.Manifest
import android.app.WallpaperManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.os.BatteryManager
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.toBitmap
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import java.io.ByteArrayOutputStream


class BatteryPlugin(
    private val context: Context, private val emitter: DeviceConnection.ConnectionEmitter
) : UnisyncPlugin(context, emitter) {
    private val wallpaperManager = WallpaperManager.getInstance(context)

    override fun onMessageReceived(message: DeviceMessage) {
        IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
            context.registerReceiver(null, ifilter)
        }?.apply {
            val isCharging = getIntExtra(
                BatteryManager.EXTRA_STATUS, -1
            ) == BatteryManager.BATTERY_STATUS_CHARGING
            val level = getIntExtra("level", -1)

            val wallpaper = getWallpaper()

            emitter.sendMessage(
                DeviceMessage(
                    type = DeviceMessage.Type.BATTERY, body = mapOf(
                        "level" to level, "isCharging" to isCharging, "wallpaper" to wallpaper
                    )
                )
            )
        }
    }

    override fun isPluginMessage(message: DeviceMessage): Boolean {
        return message.type == DeviceMessage.Type.BATTERY
    }

    override fun dispose() {

    }

    private fun getWallpaper(): ByteArray? {
        if (ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.READ_EXTERNAL_STORAGE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return null
        }
        return wallpaperManager.fastDrawable?.toBitmap()?.let {
            val stream = ByteArrayOutputStream()
            it.compress(Bitmap.CompressFormat.JPEG, 100, stream)
            stream.toByteArray()
        }
    }
}