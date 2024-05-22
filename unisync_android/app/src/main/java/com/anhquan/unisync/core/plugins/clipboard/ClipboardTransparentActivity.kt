package com.anhquan.unisync.core.plugins.clipboard

import android.os.Bundle
import android.view.WindowManager
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.anhquan.unisync.R
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.PairingHandler

class ClipboardTransparentActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val wlp = window.attributes
        wlp.dimAmount = 0f
        wlp.flags = WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
        window.setAttributes(wlp)
        setContentView(R.layout.activity_clipboard_transparent)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            Device.getConnectedDevices().filter {
                it.pairState == PairingHandler.PairState.PAIRED
            }.forEach {
                it.getPlugin(ClipboardPlugin::class.java).sendLatestClipboard()
            }
            Toast.makeText(
                this,
                getString(R.string.clipboard_sent),
                Toast.LENGTH_SHORT
            ).show()
            finish()
        }
    }
}