package com.anhquan.unisync

import android.content.Context
import android.os.Build
import com.anhquan.unisync.constants.DeviceType
import com.anhquan.unisync.models.ClientInfo
import com.anhquan.unisync.utils.IDUtil
import com.google.gson.Gson
import dagger.hilt.android.HiltAndroidApp
import io.flutter.app.FlutterApplication

@HiltAndroidApp
class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        val sharedPreferences =
            applicationContext.getSharedPreferences(packageName, Context.MODE_PRIVATE)
        val clientInfo = sharedPreferences.getString("client_info", null)
        if (clientInfo == null) {
            val info = ClientInfo(
                id = IDUtil.generateId(),
                name = Build.DEVICE,
                deviceType = DeviceType.android,
            )
            sharedPreferences.edit().putString("client_info", Gson().toJson(info)).apply()
        }
    }
}