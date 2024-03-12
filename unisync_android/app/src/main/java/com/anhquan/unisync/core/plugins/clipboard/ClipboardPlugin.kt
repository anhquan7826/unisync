package com.anhquan.unisync.core.plugins.clipboard

import android.content.ClipData
import android.content.ClipboardManager
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class ClipboardPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.CLIPBOARD) {

    private val clipboardManager = context.getSystemService(ClipboardManager::class.java)

    override fun onReceive(data: Map<String, Any?>) {
        data["clipboard"]?.toString()?.let {
            clipboardManager.setPrimaryClip(ClipData.newPlainText(it, it))
        }
    }

    fun sendLatestClipboard() {
        clipboardManager.primaryClip?.getItemAt(0)?.let {
            val content = it.coerceToText(device.context).toString()
            send(
                mapOf(
                    "clipboard" to content
                )
            )
        }
    }
}