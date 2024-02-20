package com.anhquan.unisync.utils

import android.content.Context
import android.content.SharedPreferences

class Preferences(private val spf: SharedPreferences) {
    companion object {
        fun get(context: Context, deviceId: String): Preferences {
            return Preferences(
                context.getSharedPreferences(
                    "${context.packageName}/$deviceId",
                    Context.MODE_PRIVATE
                )
            )
        }
    }

    fun putString(key: String, value: String) {
        spf.edit().putString(key, value).apply()
    }

    fun getString(key: String): String? {
        return if (spf.contains(key)) spf.getString(key, "") else null
    }
}