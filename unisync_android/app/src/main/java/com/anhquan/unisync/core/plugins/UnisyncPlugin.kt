package com.anhquan.unisync.core.plugins

import android.content.Context
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.annotation.CallSuper
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.infoLog
import io.reactivex.rxjava3.subjects.BehaviorSubject

abstract class UnisyncPlugin(private val device: Device, val type: DeviceMessage.Type) {
    val notifier = BehaviorSubject.create<Map<String, Any?>>()
    var isClosed: Boolean = false
        private set

    val context: Context get() = device.context!!.applicationContext

    val hasPermission: Boolean get() = requiredPermission.isEmpty()

    open val requiredPermission: List<String> = listOf()

    abstract fun onReceive(data: Map<String, Any?>)

    fun send(data: Map<String, Any?>, payloadData: ByteArray? = null) {
        device.sendMessage(
            DeviceMessage(
                type = type,
                body = data,
                payload = payloadData?.let {
                    DeviceMessage.Payload(size = it.size,)
                }
            ),
            payloadData = payloadData
        )
    }

    @CallSuper
    open fun onDispose() {
        isClosed = true
        infoLog("${this::class.simpleName}@${device.info.name}: Disposed!")
    }
}