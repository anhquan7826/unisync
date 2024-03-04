package com.anhquan.unisync

import android.Manifest
import android.content.Intent
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import com.anhquan.unisync.ui.screen.pair.PairActivity

class UnisyncActivity : ComponentActivity() {
    private val perm = registerForActivityResult(ActivityResultContracts.RequestPermission()) {

    }

    override fun onStart() {
        super.onStart()
        perm.launch(Manifest.permission.READ_EXTERNAL_STORAGE)
//        if (DeviceProvider.devices.isNotEmpty())
//            startActivity(Intent(this, HomeActivity::class.java).apply {
//                val device = DeviceProvider.currentConnectedDevices.firstOrNull()
//                if (device != null) {
//                    putExtra("device", gson.toJson(device))
//                }
//            })
//        else
            startActivity(Intent(this, PairActivity::class.java).apply {
                putExtra("isInitial", true)
            })
        finish()
    }
}