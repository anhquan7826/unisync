package com.anhquan.unisync

import android.content.Intent
import androidx.activity.ComponentActivity
import com.anhquan.unisync.core.providers.DeviceProvider
import com.anhquan.unisync.ui.screen.home.HomeActivity
import com.anhquan.unisync.ui.screen.pair.PairActivity
import com.anhquan.unisync.utils.gson

class UnisyncActivity : ComponentActivity() {
    override fun onStart() {
        super.onStart()
        if (DeviceProvider.currentConnectedDevices.isNotEmpty())
            startActivity(Intent(this, HomeActivity::class.java).apply {
                val device = DeviceProvider.currentConnectedDevices.firstOrNull()
                if (device != null) {
                    putExtra("device", gson.toJson(device))
                }
            })
        else
            startActivity(Intent(this, PairActivity::class.java).apply {
                putExtra("isInitial", true)
            })
        finish()
    }
}