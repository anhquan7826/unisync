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

    val currentConnectedDevices: List<DeviceInfo>
        get() {
            return _devices.keys.toList()
        }

    val currentConnectedDevicesUnpaired: List<DeviceInfo>
        get() {
            return _devices.filter { it.value.pairState == PairingHandler.PairState.NOT_PAIRED }.keys.toList()
        }

    val currentConnectedDevicesPaired: List<DeviceInfo>
        get() {
            return _devices.filter { it.value.pairState == PairingHandler.PairState.PAIRED }.keys.toList()
        }

    val currentConnectedDevicesPairing: List<DeviceInfo>
        get() {
            return _devices.filter { it.value.pairState == PairingHandler.PairState.REQUESTED }.keys.toList()
        }

    data class DeviceChangedState(
        val device: DeviceInfo,
        val connected: Boolean
    )

    val onChangeNotifier = PublishSubject.create<DeviceChangedState>()

    fun create(
        context: Context,
        info: DeviceInfo,
        socket: SSLSocket
    ) {
        if (!_devices.containsKey(info)) {
            _devices[info] = Device(context, DeviceConnection(socket), info)
            onChangeNotifier.onNext(
                DeviceChangedState(info, true)
            )
            infoLog("${this::class.simpleName}: Connected to ${info.name}@${info.ip}.")
        } else {
            socket.close()
            infoLog("${this::class.simpleName}: Duplicate connection to ${info.name}@${info.ip}. Closing connection...")
        }
    }

    fun remove(info: DeviceInfo) {
        _devices.remove(info)
        onChangeNotifier.onNext(
            DeviceChangedState(info, false)
        )
    }

    fun get(info: DeviceInfo): Device? {
        return _devices[info]
    }
}