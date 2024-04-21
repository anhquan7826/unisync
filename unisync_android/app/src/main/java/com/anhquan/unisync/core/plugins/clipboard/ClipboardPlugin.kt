package com.anhquan.unisync.core.plugins.clipboard

import android.content.ClipData
import android.content.ClipboardManager
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class ClipboardPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.CLIPBOARD) {
    private object Method {
        const val CLIPBOARD_CHANGED = "clipboard_changed"
    }

    private val clipboardManager = context.getSystemService(ClipboardManager::class.java)

    override fun listen(
        header: DeviceMessage.DeviceMessageHeader,
        data: Map<String, Any?>,
        payload: DeviceConnection.Payload?
    ) {
        super.listen(header, data, payload)
        data["clipboard"]?.toString()?.let {
            clipboardManager.setPrimaryClip(ClipData.newPlainText(it, it))
        }
    }

    fun sendLatestClipboard() {
        clipboardManager.primaryClip?.getItemAt(0)?.let {
            val content = it.coerceToText(device.context).toString()
            sendNotification(
                Method.CLIPBOARD_CHANGED,
                mapOf(
                    "clipboard" to content
                )
            )
        }
    }
}