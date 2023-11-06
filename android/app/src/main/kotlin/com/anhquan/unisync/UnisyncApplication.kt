package com.anhquan.unisync

import android.os.Build
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
            ConfigUtil.Device.getDeviceInfo()
        } catch (e: Exception) {
            ConfigUtil.Device.setDeviceInfo(
                DeviceInfo(
                    id = IDUtil.generateId(),
                    name = Build.MODEL,
                    deviceType = DeviceType.android,
                )
            )
        }
    }
}