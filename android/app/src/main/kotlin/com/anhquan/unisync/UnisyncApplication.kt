package com.anhquan.unisync

import android.os.Build
import android.provider.Settings
import com.anhquan.unisync.constants.DeviceType
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.IDUtil
import io.flutter.app.FlutterApplication

class UnisyncApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        initialSetupClientInfo()
    }

    private fun initialSetupClientInfo() {
        ConfigUtil.setup(applicationContext)
        try {
            ConfigUtil.getDeviceInfo()
        } catch (e: Exception) {
            ConfigUtil.setDeviceInfo(
                DeviceInfo(
                    id = IDUtil.generateId(),
                    name = Settings.System.getString(contentResolver, Settings.Global.DEVICE_NAME)
                        ?: Build.DEVICE,
                    deviceType = DeviceType.android,
                )
            )
        }
    }
}