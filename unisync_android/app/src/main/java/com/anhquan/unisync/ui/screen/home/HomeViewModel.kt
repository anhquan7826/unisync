package com.anhquan.unisync.ui.screen.home

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.constants.Status
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.clipboard.ClipboardPlugin
import com.anhquan.unisync.core.plugins.volume.VolumePlugin
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.listen
import io.reactivex.rxjava3.disposables.Disposable
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class HomeViewModel : ViewModel() {
    private lateinit var deviceInfo: DeviceInfo
    private lateinit var device: Device

    data class HomeState(
        val status: Status = Status.Loading,
        val volume: Float = 0F,
    )

    private var _state = MutableStateFlow(HomeState())
    val state = _state.asStateFlow()

    private lateinit var disposable: Disposable

    fun setDevice(deviceInfo: DeviceInfo) {
        this.deviceInfo = deviceInfo
        this.device = Device.of(deviceInfo)
        disposable = device.getPlugin(VolumePlugin::class.java).notifier.listen {
            _state.update { state ->
                state.copy(
                    volume = it["volume"].toString().toFloat()
                )
            }
        }
    }

    fun load() {
        _state.update { state ->
            state.copy(
                status = Status.Loaded,
                volume = device.getPlugin(VolumePlugin::class.java).currentVolume.toFloat()
            )
        }
    }

    fun setVolume(value: Float) {
        device.getPlugin(VolumePlugin::class.java).apply {
            changeVolume(value)
        }
    }

    fun sendClipboard() {
        device.getPlugin(ClipboardPlugin::class.java).apply {
            sendLatestClipboard()
        }
    }

    override fun onCleared() {
        disposable.dispose()
        super.onCleared()
    }
}