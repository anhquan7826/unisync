package com.anhquan.unisync

import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.anhquan.unisync.models.ChannelResult
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.UnisyncChannel
import com.anhquan.unisync.utils.infoLog
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class UnisyncActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        infoLog("${this::class.simpleName}: starting app service.")
        ConfigUtil.Authentication.generateKeypair()
    }

    override fun onStart() {
        super.onStart()
        startForegroundService(Intent(this, UnisyncService::class.java))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        UnisyncChannel.setup(flutterEngine)
        val sp = getSharedPreferences(packageName, Context.MODE_PRIVATE)
        UnisyncChannel.get("shared_preferences").apply {
            addCallHandler("get_string") { args, emitter ->
                emitter.emit(
                    ChannelResult.SUCCESS,
                    result = sp.getString(args!!["key"].toString(), null)
                )
            }
            addCallHandler("get_int") { args, emitter ->
                if (sp.contains(args!!["key"].toString())) {
                    try {
                        emitter.emit(
                            ChannelResult.SUCCESS,
                            result = sp.getInt(args["key"].toString(), -1)
                        )
                    } catch (_: ClassCastException) {
                        emitter.emit(
                            ChannelResult.SUCCESS,
                        )
                    }
                } else {
                    emitter.emit(
                        ChannelResult.SUCCESS,
                    )
                }
            }
            addCallHandler("get_bool") { args, emitter ->
                if (sp.contains(args!!["key"].toString())) {
                    try {
                        emitter.emit(
                            ChannelResult.SUCCESS,
                            result = sp.getBoolean(args["key"].toString(), false)
                        )
                    } catch (_: ClassCastException) {
                        emitter.emit(
                            ChannelResult.SUCCESS
                        )
                    }
                } else {
                    emitter.emit(
                        ChannelResult.SUCCESS
                    )
                }
            }
            addCallHandler("put_string") { args, emitter ->
                sp.edit().putString(args!!["key"].toString(), args["value"].toString()).apply()
                emitter.emit(
                    ChannelResult.SUCCESS
                )
            }
            addCallHandler("put_int") { args, emitter ->
                sp.edit().putInt(args!!["key"].toString(), args["value"] as Int).apply()
                emitter.emit(
                    ChannelResult.SUCCESS
                )
            }
            addCallHandler("put_bool") { args, emitter ->
                sp.edit().putBoolean(args!!["key"].toString(), args["value"] as Boolean).apply()
                emitter.emit(
                    ChannelResult.SUCCESS
                )
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        UnisyncChannel.destroy()
    }
}
