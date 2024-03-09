package com.anhquan.unisync.ui.screen.pair

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceProvider
import com.anhquan.unisync.core.PairingHandler.PairState.NOT_PAIRED
import com.anhquan.unisync.core.PairingHandler.PairState.REQUESTED
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.Database
import com.anhquan.unisync.utils.extensions.addTo
import com.anhquan.unisync.utils.listen
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.core.Single
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
        DeviceProvider.notifier.listen(
            subscribeOn = AndroidSchedulers.mainThread(), observeOn = AndroidSchedulers.mainThread()
        ) { value ->
            val available = mutableListOf<Device>()
            val requested = mutableListOf<Device>()
            value.forEach { info ->
                val device = Device.of(info)
                when (device.pairState) {
                    NOT_PAIRED -> {
                        available.add(device)
                    }

                    REQUESTED -> {
                        requested.add(device)
                    }

                    else -> {}
                }
            }
            _state.update {
                PairViewState(
                    availableDevices = available,
                    requestedDevices = requested,
                )
            }
        }.addTo(disposables)
    }

    fun sendPairRequest(device: Device) {
        device.pairOperation.requestPair()
    }

    fun getLastConnected(): Single<DeviceInfo> {
        return Database.pairedDevice.getLastUsed().map {
            DeviceInfo(
                id = it.id, name = it.name, deviceType = it.type
            )
        }
    }

    override fun onCleared() {
        super.onCleared()
        disposables.dispose()
    }
}