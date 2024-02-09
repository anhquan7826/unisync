package com.anhquan.unisync.core.plugins

import android.content.Context
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.models.DeviceMessage
import io.reactivex.rxjava3.subjects.BehaviorSubject

abstract class UnisyncPlugin(private val context: Context, private val emitter: DeviceConnection.ConnectionEmitter) {
    val notifier = BehaviorSubject.create<Map<String, Any?>>()

    abstract fun onMessageReceived(message: DeviceMessage)

    abstract fun isPluginMessage(message: DeviceMessage): Boolean

    abstract fun dispose()
}