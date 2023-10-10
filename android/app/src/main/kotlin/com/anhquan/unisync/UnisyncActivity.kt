package com.anhquan.unisync

import android.content.Intent
import android.os.Bundle
import com.anhquan.unisync.plugins.MethodChannelPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class UnisyncActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startForegroundService(Intent(this, UnisyncService::class.java))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannelPlugin.setup(flutterEngine)
    }
}
