package com.anhquan.unisync.core.plugins.storage

import android.Manifest
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.os.IBinder
import androidx.core.content.ContextCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.debugLog

class StoragePlugin(device: Device) : UnisyncPlugin(device, DeviceMessage.Type.STORAGE),
    ServiceConnection {
    private lateinit var serviceBinder: SftpService.SftpServiceBinder

    private object Method {
        const val START_SERVER = "start_server"
    }

    override fun listen(
        header: DeviceMessage.DeviceMessageHeader,
        data: Map<String, Any?>,
        payload: DeviceConnection.Payload?
    ) {
        when (header.method) {
            Method.START_SERVER -> {
                context.bindService(
                    Intent(context, SftpService::class.java),
                    this,
                    Context.BIND_AUTO_CREATE
                )
            }
        }
    }

    override fun onDispose() {
        context.unbindService(this)
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

    override fun onServiceConnected(name: ComponentName, service: IBinder) {
        debugLog("service connected")
        serviceBinder = service as SftpService.SftpServiceBinder
        serviceBinder.informBound()
        sendResponse(
            Method.START_SERVER,
            mapOf(
                "port" to serviceBinder.port,
                "username" to serviceBinder.username,
                "password" to serviceBinder.password
            )
        )
    }

    override fun onServiceDisconnected(name: ComponentName) {
        serviceBinder.informUnbound()
    }
}