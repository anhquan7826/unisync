package com.anhquan.unisync.ui.screen.pair

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.PairingHandler.PairState.NOT_PAIRED
import com.anhquan.unisync.core.PairingHandler.PairState.PAIRED
import com.anhquan.unisync.core.PairingHandler.PairState.REQUESTED
import com.anhquan.unisync.utils.extensions.addTo
import com.anhquan.unisync.utils.listen
import io.reactivex.rxjava3.disposables.CompositeDisposable
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

    private val disposables = CompositeDisposable()

    init {
        Device.getAllDevices {
            it.forEach { device -> listenDeviceChange(device) }
            Device.instanceNotifier.listen { n ->
                if (n.added) {
                    listenDeviceChange(n.instance)
                }
            }
        }
    }

    private fun listenDeviceChange(device: Device) {
        device.notifier.listen {
            _state.update { s ->
                PairViewState(
                    s.availableDevices.minus(device),
                    s.requestedDevices.minus(device),
                    s.pairedDevices.minus(device)
                )
            }
            if (it.connected) {
                when (it.pairState) {
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
                if (it.pairState == PAIRED) {
                    _state.update { s ->
                        s.copy(pairedDevices = s.pairedDevices.plus(device))
                    }
                }
            }
        }.addTo(disposables)
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

    override fun onCleared() {
        super.onCleared()
        disposables.dispose()
    }
}