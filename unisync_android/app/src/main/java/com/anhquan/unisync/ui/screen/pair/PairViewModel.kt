package com.anhquan.unisync.ui.screen.pair

import android.content.Context
import androidx.lifecycle.ViewModel
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.PairingHandler.PairState.NOT_PAIRED
import com.anhquan.unisync.core.PairingHandler.PairState.PAIRED
import com.anhquan.unisync.core.PairingHandler.PairState.REQUESTED
import com.anhquan.unisync.utils.execute
import com.anhquan.unisync.utils.listen
import io.reactivex.rxjava3.disposables.Disposable
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

    private lateinit var instancesNotifierDisposable: Disposable

    fun initialize(context: Context) {
        instancesNotifierDisposable = Device.instancesNotifier.listen {
            updateList(it)
        }
        Device.getAllDevices(context).execute {
            updateList(it)
        }
    }

    override fun onCleared() {
        instancesNotifierDisposable.dispose()
        super.onCleared()
    }

    fun sendPairRequest(device: Device) {
        device.pairOperation.requestPair()
    }

    fun unpair(device: Device) {
        device.pairOperation.unpair()
    }
    
    private fun updateList(devices: List<Device>) {
        val availableDevices = mutableListOf<Device>()
        val pairedDevices = mutableListOf<Device>()
        val requestedDevices = mutableListOf<Device>()
        for (device in devices) {
            if (device.isOnline) {
                when (device.pairState) {
                    NOT_PAIRED -> availableDevices.add(device)
                    PAIRED -> pairedDevices.add(device)
                    REQUESTED -> requestedDevices.add(device)
                    else -> {}
                }
            } else {
                if (device.pairState == PAIRED) {
                    pairedDevices.add(device)
                }
            }
        }
        _state.update { 
            PairViewState(
                availableDevices = availableDevices,
                pairedDevices = pairedDevices,
                requestedDevices = requestedDevices,
            )
        }
    }

//    fun getLastConnected(): Single<DeviceInfo> {
//        return Database.pairedDevice.getLastUsed().map {
//            DeviceInfo(
//                id = it.id, name = it.name, deviceType = it.type
//            )
//        }
//    }
}