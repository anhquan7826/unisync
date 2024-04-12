package com.anhquan.unisync.core.plugins.sharing

import android.content.Intent
import android.os.Bundle
import android.util.Patterns
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class SharingPlugin(device: Device) :
    UnisyncPlugin(device, DeviceMessage.Type.SHARING) {
    override fun onReceive(data: Map<String, Any?>) {}

    fun handleExtras(bundle: Bundle) {
        val text = bundle.getString(Intent.EXTRA_TEXT)
        if (text != null) {
            if (isUrl(text)) {
                handleUrl(text)
            } else {
                handleText(text)
            }
        }
    }

    private fun handleUrl(url: String) {
        send(mapOf(
            "url" to url
        ))
    }

    private fun handleText(text: String) {
        send(
            mapOf(
                "text" to text
            )
        )
    }

    private fun isUrl(url: String): Boolean {
        val urlPattern = Patterns.WEB_URL
        val matcher = urlPattern.matcher(url)
        return matcher.matches()
    }
}