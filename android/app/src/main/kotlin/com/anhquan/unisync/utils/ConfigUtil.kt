package com.anhquan.unisync.utils

import android.content.Context
import android.content.SharedPreferences
import com.anhquan.unisync.constants.SPKey
import com.anhquan.unisync.models.DeviceInfo

object ConfigUtil {
    private lateinit var sharedPreferences: SharedPreferences

    fun setup(context: Context) {
        sharedPreferences = context.getSharedPreferences(context.packageName, Context.MODE_PRIVATE)
    }

    fun getDeviceInfo(): DeviceInfo {
        return fromJson(
            sharedPreferences.getString(
                SPKey.deviceInfo,
                ""
            )!!, DeviceInfo::class.java
        )!!
    }

    fun setDeviceInfo(info: DeviceInfo) {
        sharedPreferences.edit().putString(SPKey.deviceInfo, toJson(info)).apply()
    }
}