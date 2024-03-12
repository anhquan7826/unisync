package com.anhquan.unisync

import android.app.Application
import android.content.Intent
import android.os.Build
import com.anhquan.unisync.constants.DeviceType
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.IDUtil

class UnisyncApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        initialSetupClientInfo()
        startForegroundService(Intent(this, UnisyncService::class.java))
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
//        ConfigUtil.Authentication.generateKeypair()
    }
}