package com.anhquan.unisync.ui.screen.pair

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.core.device.dependencies.PairingHandler
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
        val pairedDevices: List<DeviceInfo> = listOf(),
        val notPairedDevices: List<DeviceInfo> = listOf(),
        val requestedDevices: List<DeviceInfo> = listOf(),
    )

    private var _state = MutableStateFlow(PairViewState())
    val state = _state.asStateFlow()

    private val disposables = CompositeDisposable()

    init {
        val devices = DeviceProvider.currentConnectedDevices
        _state.update {
            it.copy(
                pairedDevices = devices.filter { info ->
                    DeviceProvider.get(info)!!.pairState == PairingHandler.PairState.PAIRED
                },
                notPairedDevices = devices.filter { info ->
                    DeviceProvider.get(info)!!.pairState == PairingHandler.PairState.NOT_PAIRED
                },
                requestedDevices = devices.filter { info ->
                    DeviceProvider.get(info)!!.pairState == PairingHandler.PairState.REQUESTED
                },
            )
        }

        DeviceProvider.onChangeNotifier.listen(
            subscribeOn = AndroidSchedulers.mainThread(),
            observeOn = AndroidSchedulers.mainThread()
        ) { deviceState ->
            if (deviceState.connected) {
                val pairState = DeviceProvider.get(deviceState.device)!!.pairState
                _state.update {
                    it.copy(
                        pairedDevices = it.pairedDevices.let { list ->
                            if (pairState == PairingHandler.PairState.PAIRED)
                                list.plus(deviceState.device)
                            else
                                list
                        },
                        notPairedDevices = it.notPairedDevices.let { list ->
                            if (pairState == PairingHandler.PairState.NOT_PAIRED)
                                list.plus(deviceState.device)
                            else
                                list
                        },
                        requestedDevices = it.requestedDevices.let { list ->
                            if (pairState == PairingHandler.PairState.REQUESTED)
                                list.plus(deviceState.device)
                            else
                                list
                        }
                    )
                }
            } else {
                _state.update {
                    it.copy(
                        pairedDevices = it.pairedDevices.minus(deviceState.device),
                        notPairedDevices = it.notPairedDevices.minus(deviceState.device),
                        requestedDevices = it.requestedDevices.minus(deviceState.device)
                    )
                }
            }
        }.addTo(disposables)
    }

    fun sendPairRequest(info: DeviceInfo) {
        DeviceProvider.get(info)
    }

    fun getConnected(): DeviceInfo? {
        return DeviceProvider.currentConnectedDevices.firstOrNull()
    }

    override fun onCleared() {
        super.onCleared()
        disposables.dispose()
    }
}