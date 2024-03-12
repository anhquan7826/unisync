package com.anhquan.unisync.core

import android.content.Context
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.infoLog
import javax.net.ssl.SSLSocket

object DeviceProvider {
    private val _devices = mutableSetOf<DeviceInfo>()

    fun create(
        context: Context,
        info: DeviceInfo,
        socket: SSLSocket
    ) {
        if (_devices.contains(info)) {
            infoLog("${this::class.simpleName}: Duplicate connection to ${info.name}. Disconnecting...")
            socket.close()
        } else {
            _devices.add(info)
            val connection = DeviceConnection(
                context,
                socket,
            ) {
                _devices.remove(info)
            }
            Device.of(info).apply {
                this.connection = connection
            }
        }
    }
}