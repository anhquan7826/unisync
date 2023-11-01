package com.anhquan.unisync

import android.content.Context
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
        val sp = getSharedPreferences(packageName, Context.MODE_PRIVATE)
        ChannelUtil.PreferencesChannel.apply {
            addCallHandler(GET_STRING) { args, emitter ->
                emitter.success(
                    sp.getString(args!!["key"].toString(), null)
                )
            }
            addCallHandler(GET_INT) { args, emitter ->
                if (sp.contains(args!!["key"].toString())) {
                    try {
                        emitter.success(sp.getInt(args["key"].toString(), -1))
                    } catch (_: ClassCastException) {
                        emitter.success(null)                    }
                } else {
                    emitter.success(null)
                }
            }
            addCallHandler(GET_BOOL) { args, emitter ->
                if (sp.contains(args!!["key"].toString())) {
                    try {
                        emitter.success(sp.getBoolean(args["key"].toString(), false))
                    } catch (_: ClassCastException) {
                        emitter.success(null)
                    }
                } else {
                    emitter.success(null)
                }
            }
            addCallHandler(PUT_STRING) { args, emitter ->
                sp.edit().putString(args!!["key"].toString(), args["value"].toString()).apply()
                emitter.success()
            }
            addCallHandler(PUT_INT) { args, emitter ->
                sp.edit().putInt(args!!["key"].toString(), args["value"] as Int).apply()
                emitter.success()
            }
            addCallHandler(PUT_BOOL) { args, emitter ->
                sp.edit().putBoolean(args!!["key"].toString(), args["value"] as Boolean).apply()
                emitter.success()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        ChannelUtil.destroy()
    }
}
