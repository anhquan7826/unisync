package com.anhquan.unisync

import android.content.Context
import android.os.Build
import android.provider.Settings
import com.anhquan.unisync.constants.DeviceType
import com.anhquan.unisync.constants.SPKey
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.IDUtil
import com.anhquan.unisync.utils.debugLog
import com.google.gson.Gson
import dagger.hilt.android.HiltAndroidApp
import io.flutter.app.FlutterApplication

@HiltAndroidApp
class UnisyncApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        initialSetupClientInfo()
    }

    private fun initialSetupClientInfo() {
        val sharedPreferences = applicationContext.getSharedPreferences(
            packageName,
            Context.MODE_PRIVATE
        )
        val deviceInfo = sharedPreferences.getString(SPKey.deviceInfo, null)
        debugLog("${this::class.simpleName}: device info: $deviceInfo")
        if (deviceInfo == null) {
            // TODO: generate public key
            val info = DeviceInfo(
                id = IDUtil.generateId(),
                name = Settings.System.getString(contentResolver, Settings.Global.DEVICE_NAME)
                    ?: Build.DEVICE,
                deviceType = DeviceType.android,
            )
            sharedPreferences.edit().putString(SPKey.deviceInfo, Gson().toJson(info)).apply()
        }
    }
}