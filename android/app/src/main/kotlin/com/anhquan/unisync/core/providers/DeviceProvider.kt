package com.anhquan.unisync.core.providers

import android.content.Context
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.models.DeviceInfo
import io.reactivex.rxjava3.subjects.PublishSubject
import javax.net.ssl.SSLSocket

object DeviceProvider {
    private val _devices = mutableMapOf<DeviceInfo, Device>()

    object Notifier {
        val connectedDeviceNotifier = PublishSubject.create<DeviceInfo>()
        val disconnectedDeviceNotifier = PublishSubject.create<DeviceInfo>()
    }

    fun create(
        context: Context,
        info: DeviceInfo,
        socket: SSLSocket
    ) {
        if (!_devices.containsKey(info)) {
            _devices[info] = Device(context, DeviceConnection(socket), info)
            Notifier.connectedDeviceNotifier.onNext(info)
        }
    }

    fun remove(info: DeviceInfo) {
        _devices.remove(info)
        Notifier.disconnectedDeviceNotifier.onNext(info)
    }
}