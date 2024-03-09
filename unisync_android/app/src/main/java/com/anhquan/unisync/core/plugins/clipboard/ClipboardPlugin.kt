package com.anhquan.unisync.core.plugins.clipboard

import android.content.ClipData
import android.content.ClipboardManager
import android.content.ClipboardManager.OnPrimaryClipChangedListener
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class ClipboardPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.CLIPBOARD), OnPrimaryClipChangedListener {

    private val clipboardManager = device.context.getSystemService(ClipboardManager::class.java)
    private var latestClipboard = ""

    init {
        clipboardManager.addPrimaryClipChangedListener(this)
    }

    override fun onReceive(data: Map<String, Any?>) {
        data["clipboard"]?.toString()?.let {
            if (latestClipboard == it) return
            latestClipboard = it
            clipboardManager.setPrimaryClip(ClipData.newPlainText(it, it))
        }
    }

    override fun dispose() {
        super.dispose()
        clipboardManager.removePrimaryClipChangedListener(this)
    }

    override fun onPrimaryClipChanged() {
        clipboardManager.primaryClip?.getItemAt(0)?.let {
            val content = it.coerceToText(device.context).toString()
            if (latestClipboard == content) return
            latestClipboard = content
            send(
                mapOf(
                    "clipboard" to content
                )
            )
        }
    }

    fun sendLatestClipboard() {
        clipboardManager.primaryClip?.getItemAt(0)?.let {
            val content = it.coerceToText(device.context).toString()
            latestClipboard = content
            send(
                mapOf(
                    "clipboard" to content
                )
            )
        }
    }
}