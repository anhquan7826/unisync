package com.anhquan.unisync

import android.content.Intent
import androidx.activity.ComponentActivity
import com.anhquan.unisync.ui.screen.home.HomeActivity
import com.anhquan.unisync.ui.screen.pair.PairActivity
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.execute
import com.anhquan.unisync.utils.gson

class UnisyncActivity : ComponentActivity() {
    override fun onStart() {
        super.onStart()
        ConfigUtil.Device.getLastUsedDevice(this).execute {
            if (it.isEmpty()) {
                startActivity(Intent(this, PairActivity::class.java))
            } else {
                startActivity(Intent(
                    this, HomeActivity::class.java
                ).apply {
                    putExtra("device", gson.toJson(it.first().info))
                })
            }
            finish()
        }
    }
}