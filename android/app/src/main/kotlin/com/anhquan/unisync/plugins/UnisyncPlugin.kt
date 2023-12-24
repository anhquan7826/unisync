package com.anhquan.unisync.plugins

import androidx.annotation.CallSuper
import com.anhquan.unisync.core.DeviceEntryPoint
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.ChannelUtil
import com.anhquan.unisync.utils.listen
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers

abstract class UnisyncPlugin {
    protected abstract val channelHandler: ChannelUtil.ChannelHandler
    abstract val plugin: String
    var enabled: Boolean = true

    @CallSuper
    open fun start() {
        addChannelHandler()
        DeviceEntryPoint.Notifier.apply {
            connectedDeviceNotifier.listen(
                subscribeOn = AndroidSchedulers.mainThread(),
                observeOn = AndroidSchedulers.mainThread(),
                onNext = ::onDeviceConnected
            )
            disconnectedDeviceNotifier.listen(
                subscribeOn = AndroidSchedulers.mainThread(),
                observeOn = AndroidSchedulers.mainThread(),
                onNext = ::onDeviceDisconnected
            )
            deviceMessageNotifier.listen(
                subscribeOn = AndroidSchedulers.mainThread(),
                observeOn = AndroidSchedulers.mainThread(),
                onNext = ::onDeviceMessage
            )
        }
    }

    open fun stop() {}

    protected fun send(toDeviceId: String, function: String, extra: Map<String, Any?> = mapOf()) {
        DeviceEntryPoint.send(toDeviceId, plugin, function, extra)
    }

    protected open fun onDeviceConnected(info: DeviceInfo) {}

    protected open fun onDeviceDisconnected(info: DeviceInfo) {}

    protected open fun onDeviceMessage(message: DeviceMessage) {}

    protected abstract fun addChannelHandler()

    companion object {
        const val PLUGIN_CONNECTION = "connection"
        const val PLUGIN_PAIRING = "pairing"
    }
}