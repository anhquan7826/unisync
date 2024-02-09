package com.anhquan.unisync.core.plugins.clipboard

import android.content.ClipData
import android.content.ClipboardManager
import android.content.ClipboardManager.OnPrimaryClipChangedListener
import android.content.Context
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class ClipboardPlugin(
    private val context: Context,
    private val emitter: DeviceConnection.ConnectionEmitter
) : UnisyncPlugin(context, emitter), OnPrimaryClipChangedListener {

    private val clipboardManager = context.getSystemService(ClipboardManager::class.java)
    private var latestClipboard = ""

    init {
        clipboardManager.addPrimaryClipChangedListener(this)
    }

    override fun onMessageReceived(message: DeviceMessage) {
        message.body["clipboard"]?.toString()?.let {
            if (latestClipboard == it) return
            latestClipboard = it
            clipboardManager.setPrimaryClip(ClipData.newPlainText(it, it))
        }
    }

    override fun isPluginMessage(message: DeviceMessage): Boolean {
        return message.type == DeviceMessage.Type.CLIPBOARD
    }

    override fun dispose() {
        clipboardManager.removePrimaryClipChangedListener(this)
    }

    override fun onPrimaryClipChanged() {
        clipboardManager.primaryClip?.getItemAt(0)?.let {
            val content = it.coerceToText(context).toString()
            if (latestClipboard == content) return
            latestClipboard = content
            emitter.sendMessage(
                DeviceMessage(
                    type = DeviceMessage.Type.CLIPBOARD, body = mapOf(
                        "clipboard" to content
                    )
                )
            )
        }
    }

    fun sendLatestClipboard() {
        clipboardManager.primaryClip?.getItemAt(0)?.let {
            val content = it.coerceToText(context).toString()
            latestClipboard = content
            emitter.sendMessage(
                DeviceMessage(
                    type = DeviceMessage.Type.CLIPBOARD, body = mapOf(
                        "clipboard" to content
                    )
                )
            )
        }
    }
}