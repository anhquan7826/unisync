package com.anhquan.unisync.utils

import android.content.Context
import com.anhquan.unisync.constants.SPKey
import com.anhquan.unisync.models.DeviceInfo

object ConfigUtil {
    fun getDeviceInfo(context: Context): DeviceInfo {
        return gson.fromJson(
            context.getSharedPreferences(context.packageName, Context.MODE_PRIVATE).getString(
                SPKey.deviceInfo,
                ""
            ), DeviceInfo::class.java
        )
    }
}