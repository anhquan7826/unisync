package com.anhquan.unisync.ui.screen.home

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.clipboard.ClipboardPlugin
import com.anhquan.unisync.core.plugins.volume.VolumePlugin
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.listen
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.Disposable
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class HomeViewModel : ViewModel() {
    private lateinit var _device: Device
    private var disposable: Disposable? = null
    private var volumeDisposable: Disposable? = null

    var device: Device
        get() = _device
        set(value) {
            if (this::_device.isInitialized && _device == value) return
            volumeDisposable?.dispose()
            disposable?.dispose()
            _device = value
            disposable = value.eventNotifier.listen(
                observeOn = AndroidSchedulers.mainThread()
            ) {
                debugLog("Event from device ${value.info.name}:\n${it.connected}\n${it.pairState}")
                _state.update { state ->
                    state.copy(
                        isOnline = it.connected,
                    )
                }
                if (it.connected) {
                    volumeDisposable = volumeDisposable ?: value.getPlugin(VolumePlugin::class.java).notifier.listen(
                        observeOn = AndroidSchedulers.mainThread()
                    ) {
                        _state.update { state ->
                            state.copy(
                                volume = it["volume"].toString().toFloat()
                            )
                        }
                    }
                } else {
                    volumeDisposable?.dispose()
                }
            }
        }

    val thisDeviceInfo = ConfigUtil.Device.getDeviceInfo()

    var pairedDevices: List<Device> = listOf()
        private set

    data class HomeState(
        val isOnline: Boolean = false,
        val volume: Float = 0F,
    )

    init {
        ConfigUtil.Device.getAllPairedDevices {
            pairedDevices = it.map { info ->
                Device.of(info)
            }
        }
    }
    private var _state = MutableStateFlow(HomeState())

    val state = _state.asStateFlow()

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

    fun unpair() {
        _device.pairOperation.unpair()
    }

    fun renameDevice(name: String) {
        if (name.isEmpty()) return
        ConfigUtil.Device.setDeviceInfo(_device.info.copy(
            name = name.trim()
        ))
    }

    override fun onCleared() {
        volumeDisposable?.dispose()
        disposable?.dispose()
        super.onCleared()
    }
}