package com.anhquan.unisync.ui.screen.home

import android.content.Context
import android.content.Intent
import androidx.activity.ComponentActivity
import androidx.lifecycle.ViewModel
import com.anhquan.unisync.UnisyncActivity
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.PairingHandler
import com.anhquan.unisync.core.plugins.clipboard.ClipboardPlugin
import com.anhquan.unisync.core.plugins.status.StatusPlugin
import com.anhquan.unisync.core.plugins.volume.VolumePlugin
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.execute
import com.anhquan.unisync.utils.listen
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.Disposable
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class HomeViewModel : ViewModel(), Device.DeviceEventListener {
    private lateinit var _device: Device
    private var volumeDisposable: Disposable? = null

    var device: Device
        get() = _device
        set(value) {
            debugLog("_device is set to $value")
            if (this::_device.isInitialized && _device == value) return
            volumeDisposable?.dispose()
            if (this::_device.isInitialized) {
                _device.removeEventListener(this)
            }
            _device = value
            _device.addEventListener(this)
        }

    val thisDeviceInfo = ConfigUtil.Device.getDeviceInfo()

    var pairedDevices: List<Device> = listOf()
        private set

    data class HomeState(
        val pairedDevices: List<Device> = listOf(),
        val isOnline: Boolean = false,
        val reload: Boolean = false,
        val volume: Float = 0F,
    )

    fun initialize(context: Context) {
        Device.instancesNotifier.listen { devices ->
            val pairedDevices = devices.filter {
                it.pairState == PairingHandler.PairState.PAIRED
            }
            if (devices.isEmpty()) {
                context.startActivity(Intent(context, UnisyncActivity::class.java))
                (context as ComponentActivity).finish()
            } else {
                _state.update { state ->
                    state.copy(
                        pairedDevices = pairedDevices
                    )
                }
            }
        }
        Device.getAllDevices(context).execute {}
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

    fun shutdown() {
        device.getPlugin(StatusPlugin::class.java).shutdown()
    }

    fun restart() {
        device.getPlugin(StatusPlugin::class.java).restart()
    }

    fun lock() {
        device.getPlugin(StatusPlugin::class.java).lock()
    }

    fun unpair() {
        _device.pairOperation.unpair()
    }

    fun renameDevice(name: String) {
        if (name.isEmpty()) return
        ConfigUtil.Device.setDeviceInfo(
            _device.info.copy(
                name = name.trim()
            )
        )
    }

    override fun onCleared() {
        volumeDisposable?.dispose()
        _device.removeEventListener(this)
        super.onCleared()
    }

    override fun onDeviceEvent(event: Device.DeviceEvent) {
        _state.update { state ->
            state.copy(
                isOnline = event.connected,
            )
        }
        if (event.connected && event.pairState == PairingHandler.PairState.PAIRED) {
            volumeDisposable =
                volumeDisposable ?: _device.getPlugin(VolumePlugin::class.java).notifier.listen(
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
            volumeDisposable = null
            if (event.pairState != PairingHandler.PairState.PAIRED) {
                Device.getConnectedDevices().firstOrNull {
                    it.pairState == PairingHandler.PairState.PAIRED
                }.let {
                    if (it != null) {
                        device = it
                    } else {
                        _state.update { s ->
                            s.copy(reload = true)
                        }
                    }
                }
            }
        }
    }
}