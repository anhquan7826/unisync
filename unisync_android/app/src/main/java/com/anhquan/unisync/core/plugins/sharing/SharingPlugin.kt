package com.anhquan.unisync.core.plugins.sharing

import android.content.Intent
import android.os.Bundle
import android.util.Patterns
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class SharingPlugin(device: Device) :
    UnisyncPlugin(device, DeviceMessage.Type.SHARING) {
    private object Method {
        const val OPEN_URL = "open_url"
        const val COPY_TEXT = "copy_text"
    }

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
        sendNotification(
            Method.OPEN_URL,
            mapOf(
                "url" to url
            )
        )
    }

    private fun handleText(text: String) {
        sendNotification(
            Method.COPY_TEXT,
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