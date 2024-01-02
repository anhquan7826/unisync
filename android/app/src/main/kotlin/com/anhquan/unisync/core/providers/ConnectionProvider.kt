package com.anhquan.unisync.core.providers

import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.models.DeviceInfo
import io.reactivex.rxjava3.subjects.PublishSubject
import javax.net.ssl.SSLSocket

object ConnectionProvider {
    private val _devices = mutableMapOf<DeviceInfo, DeviceConnection>()
    object Notifier {
        val connectedDeviceNotifier = PublishSubject.create<DeviceInfo>()
        val disconnectedDeviceNotifier = PublishSubject.create<DeviceInfo>()
    }

    fun create(
        info: DeviceInfo,
        socket: SSLSocket
    ) {
        if (!_devices.containsKey(info)) {
            _devices[info] = DeviceConnection(info, socket)
            Notifier.connectedDeviceNotifier.onNext(info)
        }
    }

    fun remove(info: DeviceInfo) {
        _devices.remove(info)
        Notifier.disconnectedDeviceNotifier.onNext(info)
    }
}