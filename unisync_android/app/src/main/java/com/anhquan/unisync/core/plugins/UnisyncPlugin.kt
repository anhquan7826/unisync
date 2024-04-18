package com.anhquan.unisync.core.plugins

import android.content.Context
import androidx.annotation.CallSuper
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.models.DeviceMessage
import com.anhquan.unisync.utils.infoLog
import io.reactivex.rxjava3.subjects.BehaviorSubject

abstract class UnisyncPlugin(private val device: Device, val type: DeviceMessage.Type) {
    val notifier = BehaviorSubject.create<Map<String, Any?>>()
    var isClosed: Boolean = false
        private set

    val context: Context get() = device.context.applicationContext

    val hasPermission: Boolean get() = requiredPermission.isEmpty()

    open val requiredPermission: List<String> = listOf()

    open fun listen(header: DeviceMessage.DeviceMessageHeader, data: Map<String, Any?>, payload: DeviceConnection.Payload?) {}

    fun onReceive(message: DeviceMessage, payload: DeviceConnection.Payload?) {
        if (!hasPermission) {
            sendError("plugin", DeviceMessage.BodyValue.NO_PERMISSION)
        } else {
            listen(message.header, message.body, payload)
        }
    }

    fun sendRequest(method: String, data: Map<String, Any?> = mapOf(), payloadData: ByteArray? = null) {
        device.sendMessage(
            DeviceMessage(
                type = type,
                header = DeviceMessage.DeviceMessageHeader(
                    type = DeviceMessage.DeviceMessageHeader.Type.REQUEST,
                    method = method,
                ),
                body = data,
            ),
            payloadData = payloadData
        )
    }

    fun sendResponse(method: String, data: Map<String, Any?>, payloadData: ByteArray? = null) {
        device.sendMessage(
            DeviceMessage(
                type = type,
                header = DeviceMessage.DeviceMessageHeader(
                    type = DeviceMessage.DeviceMessageHeader.Type.RESPONSE,
                    method = method,
                    status = DeviceMessage.DeviceMessageHeader.Status.SUCCESS,
                ),
                body = data,
            ),
            payloadData = payloadData
        )
    }

    fun sendNotification(method: String, data: Map<String, Any?>, payloadData: ByteArray? = null) {
        device.sendMessage(
            DeviceMessage(
                type = type,
                header = DeviceMessage.DeviceMessageHeader(
                    type = DeviceMessage.DeviceMessageHeader.Type.NOTIFICATION,
                    method = method,
                ),
                body = data,
            ),
            payloadData = payloadData
        )
    }

    fun sendError(method: String, error: String, data: Map<String, Any?>? = null) {
        device.sendMessage(
            DeviceMessage(
                type = type,
                header = DeviceMessage.DeviceMessageHeader(
                    type = DeviceMessage.DeviceMessageHeader.Type.RESPONSE,
                    method = method,
                    status = DeviceMessage.DeviceMessageHeader.Status.ERROR,
                ),
                body = mapOf(
                    DeviceMessage.BodyKey.ERROR to error,
                ).apply {
                    if (data != null) plus(data)
                }
            )
        )
    }

    @CallSuper
    open fun onDispose() {
        isClosed = true
        infoLog("${this::class.simpleName}@${device.info.name}: Disposed!")
    }
}