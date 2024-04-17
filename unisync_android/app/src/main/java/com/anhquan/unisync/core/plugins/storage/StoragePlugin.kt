package com.anhquan.unisync.core.plugins.storage

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import androidx.core.content.ContextCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class StoragePlugin(device: Device) : UnisyncPlugin(device, DeviceMessage.Type.STORAGE) {


    init {
        context.startService(Intent(context, SftpService::class.java))
    }

    override fun onReceive(data: Map<String, Any?>) {
        if (hasPermission) {

        }
    }

    override fun onDispose() {
        context.stopService(Intent(context, SftpService::class.java))
        super.onDispose()
    }

    override val requiredPermission: List<String>
        get() {
            return listOf<String>().let {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && !Environment.isExternalStorageManager()) {
                    it.plus(Manifest.permission.MANAGE_EXTERNAL_STORAGE)
                } else {
                    it
                }
            }.filterNot {
                ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
            }
        }
}