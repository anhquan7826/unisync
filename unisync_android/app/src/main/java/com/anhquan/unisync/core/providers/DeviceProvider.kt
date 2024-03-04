package com.anhquan.unisync.core.providers

import android.content.Context
import com.anhquan.unisync.core.device.Device
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.core.device.dependencies.PairingHandler
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.infoLog
import io.reactivex.rxjava3.subjects.PublishSubject
import javax.net.ssl.SSLSocket

object DeviceProvider {
    private val _devices = mutableMapOf<DeviceInfo, Device>()
    val devices: List<DeviceInfo> get() = _devices.keys.toList()

    data class DeviceNotification(
        val device: DeviceInfo,
        val connected: Boolean = true,
        val pairState: PairingHandler.PairState? = null
    )

    val deviceNotifier = PublishSubject.create<DeviceNotification>()

    fun create(
        context: Context,
        info: DeviceInfo,
        socket: SSLSocket
    ) {
        if (!_devices.containsKey(info)) {
            _devices[info] = Device(context, DeviceConnection(socket), info)
            infoLog("${this::class.simpleName}: Connected to ${info.name}@${info.ip}.")
        } else {
            socket.close()
            infoLog("${this::class.simpleName}: Duplicate connection to ${info.name}@${info.ip}. Closing connection...")
        }
    }

    fun remove(info: DeviceInfo) {
        _devices.remove(info)
        deviceNotifier.onNext(
            DeviceNotification(info, false)
        )
    }

    fun get(info: DeviceInfo): Device? {
        return _devices[info]
    }

    fun get(deviceId: String): Device? {
        val key = _devices.keys.firstOrNull {
            it.id == deviceId
        }
        return if (key == null) null else _devices[key]
    }
}