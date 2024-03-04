package com.anhquan.unisync.ui.screen.pair

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.core.device.dependencies.PairingHandler.PairState.NOT_PAIRED
import com.anhquan.unisync.core.device.dependencies.PairingHandler.PairState.PAIRED
import com.anhquan.unisync.core.device.dependencies.PairingHandler.PairState.REQUESTED
import com.anhquan.unisync.core.providers.DeviceProvider
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.extensions.addTo
import com.anhquan.unisync.utils.listen
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.CompositeDisposable
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class PairViewModel : ViewModel() {
    data class PairViewState(
        val availableDevices: Set<DeviceInfo> = setOf(),
        val requestedDevices: Set<DeviceInfo> = setOf(),
        val pairedDevices: Set<DeviceInfo> = setOf()
    )

    private var _state = MutableStateFlow(PairViewState())
    val state = _state.asStateFlow()

    private val disposables = CompositeDisposable()

    init {
        _state.update {
            it.copy(
                availableDevices = DeviceProvider.devices.filter { info ->
                    val device = DeviceProvider.get(info)
                    device?.pairState != PAIRED
                }.toSet()
            )
        }

        DeviceProvider.deviceNotifier.listen(
            subscribeOn = AndroidSchedulers.mainThread(),
            observeOn = AndroidSchedulers.mainThread()
        ) { value ->
            if (value.connected) {
                when (value.pairState!!) {
                    NOT_PAIRED -> {
                        _state.update {
                            it.copy(
                                availableDevices = it.availableDevices.plus(value.device),
                                requestedDevices = it.availableDevices.minus(value.device),
                            )
                        }
                    }
                    PAIRED -> {
                        _state.update {
                            it.copy(
                                availableDevices = it.availableDevices.minus(value.device),
                                requestedDevices = it.availableDevices.minus(value.device),
                            )
                        }
                    }
                    REQUESTED -> {
                        _state.update {
                            it.copy(
                                availableDevices = it.availableDevices.minus(value.device),
                                requestedDevices = it.availableDevices.plus(value.device),
                            )
                        }
                    }
                }
            } else {
                _state.update {
                    it.copy(
                        availableDevices = it.availableDevices.minus(value.device),
                        requestedDevices = it.requestedDevices.minus(value.device)
                    )
                }
            }
        }.addTo(disposables)
    }

    fun sendPairRequest(info: DeviceInfo) {
        DeviceProvider.get(info)?.apply {
            pairOperation.requestPair()
        }
    }

    override fun onCleared() {
        super.onCleared()
        disposables.dispose()
    }
}