package com.anhquan.unisync.core

import android.content.Context
import com.anhquan.unisync.models.DeviceInfo
import io.reactivex.rxjava3.subjects.BehaviorSubject
import javax.net.ssl.SSLSocket

object DeviceProvider {
    private val _devices = mutableSetOf<DeviceInfo>()
    val connectedDevices: List<DeviceInfo> get() = _devices.toList()

    fun create(
        context: Context,
        info: DeviceInfo,
        socket: SSLSocket
    ) {
        if (_devices.contains(info)) {
            socket.close()
        } else {
            _devices.add(info)
            val connection = DeviceConnection(socket) {
                _devices.remove(info)
            }
            Device.of(context, info).apply {
                this.connection = connection
            }
        }
    }

    val notifier = BehaviorSubject.create<List<DeviceInfo>>().apply {
        onNext(connectedDevices)
    }

    fun providerNotify() {
        notifier.onNext(connectedDevices)
    }
}