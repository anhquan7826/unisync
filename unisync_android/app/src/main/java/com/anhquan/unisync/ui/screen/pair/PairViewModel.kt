package com.anhquan.unisync.ui.screen.pair

import android.content.Context
import androidx.lifecycle.ViewModel
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.PairingHandler.PairState.NOT_PAIRED
import com.anhquan.unisync.core.PairingHandler.PairState.PAIRED
import com.anhquan.unisync.core.PairingHandler.PairState.REQUESTED
import com.anhquan.unisync.utils.listen
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class PairViewModel : ViewModel() {
    data class PairViewState(
        val availableDevices: List<Device> = listOf(),
        val requestedDevices: List<Device> = listOf(),
        val pairedDevices: List<Device> = listOf()
    )

    private var _state = MutableStateFlow(PairViewState())
    val state = _state.asStateFlow()

    fun initialize(context: Context) {
        Device.getAllDevices(context) {
            it.forEach { device -> listenDeviceChange(device) }
            Device.instanceNotifier.listen { n ->
                if (n.added) {
                    listenDeviceChange(n.instance)
                }
            }
        }
    }

    private fun listenDeviceChange(device: Device) {
        _state.update { s ->
            PairViewState(
                s.availableDevices.minus(device),
                s.requestedDevices.minus(device),
                s.pairedDevices.minus(device)
            )
        }
        device.addEventListener(object: Device.DeviceEventListener {
            override fun onDeviceEvent(event: Device.DeviceEvent) {
                if (event.connected) {
                    when (event.pairState) {
                        NOT_PAIRED -> _state.update { s ->
                            s.copy(availableDevices = s.availableDevices.plus(device))
                        }

                        PAIRED -> _state.update { s ->
                            s.copy(pairedDevices = s.pairedDevices.plus(device))
                        }

                        REQUESTED -> _state.update { s ->
                            s.copy(requestedDevices = s.requestedDevices.plus(device))
                        }

                        else -> {}
                    }
                } else {
                    if (event.pairState == PAIRED) {
                        _state.update { s ->
                            s.copy(pairedDevices = s.pairedDevices.plus(device))
                        }
                    }
                }
            }
        })
    }

    fun sendPairRequest(device: Device) {
        device.pairOperation.requestPair()
    }

    fun unpair(device: Device) {
        device.pairOperation.unpair()
    }

//    fun getLastConnected(): Single<DeviceInfo> {
//        return Database.pairedDevice.getLastUsed().map {
//            DeviceInfo(
//                id = it.id, name = it.name, deviceType = it.type
//            )
//        }
//    }
}