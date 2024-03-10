package com.anhquan.unisync.core.plugins

import androidx.annotation.CallSuper
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.models.DeviceMessage
import io.reactivex.rxjava3.subjects.BehaviorSubject

abstract class UnisyncPlugin(private val device: Device, val type: DeviceMessage.Type) {
    val notifier = BehaviorSubject.create<Map<String, Any?>>()
    var isClosed: Boolean = false
        private set

    open val hasPermission: Boolean = true

    open fun requestPermission() {}

    abstract fun onReceive(data: Map<String, Any?>)

    fun send(data: Map<String, Any?>) {
        device.sendMessage(DeviceMessage(type = type, body = data))
    }

    @CallSuper
    open fun dispose() {
        isClosed = true
    }
}