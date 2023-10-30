package com.anhquan.unisync

import android.content.Intent
import android.os.Bundle
import com.anhquan.unisync.utils.ChannelUtil
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.infoLog
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class UnisyncActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        infoLog("${this::class.simpleName}: starting app service.")
        ConfigUtil.Authentication.generateKeypair()
        startForegroundService(Intent(this, UnisyncService::class.java))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ChannelUtil.setup(flutterEngine)
    }

    override fun onDestroy() {
        super.onDestroy()
        ChannelUtil.destroy()
    }
}
