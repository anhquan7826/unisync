package com.anhquan.unisync

import android.content.Intent
import androidx.activity.ComponentActivity
import com.anhquan.unisync.ui.screen.home.HomeActivity
import com.anhquan.unisync.ui.screen.pair.PairActivity
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.gson

class UnisyncActivity : ComponentActivity() {
//    private val perm = registerForActivityResult(ActivityResultContracts.RequestPermission()) {
//
//    }

    override fun onStart() {
        super.onStart()
//        perm.launch(Manifest.permission.READ_EXTERNAL_STORAGE)
//        if (DeviceProvider.devices.isNotEmpty())
//            startActivity(Intent(this, HomeActivity::class.java).apply {
//                val device = DeviceProvider.currentConnectedDevices.firstOrNull()
//                if (device != null) {
//                    putExtra("device", gson.toJson(device))
//                }
//            })
//        else
        ConfigUtil.Device.getLastUsedDevice {
            if (it == null) {
                startActivity(Intent(this, PairActivity::class.java).apply {
                    putExtra("isInitial", true)
                })
            } else {
                startActivity(Intent(
                    this, HomeActivity::class.java
                ).apply {
                    putExtra("device", gson.toJson(it.info))
                })
            }
            finish()
        }
    }
}