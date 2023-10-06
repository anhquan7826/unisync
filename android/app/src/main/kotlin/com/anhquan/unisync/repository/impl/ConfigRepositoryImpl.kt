package com.anhquan.unisync.repository.impl

import android.content.Context
import android.content.SharedPreferences
import com.anhquan.unisync.constants.SPKey
import com.anhquan.unisync.models.ClientInfo
import com.anhquan.unisync.repository.ConfigRepository
import com.google.gson.Gson

class ConfigRepositoryImpl(
    private val context: Context,
    private val sp: SharedPreferences,
    private val gson: Gson
) :
    ConfigRepository {
    override val clientInfo: ClientInfo
        get() {
            return gson.fromJson(
                sp.getString(
                    SPKey.clientInfo,
                    ""
                ), ClientInfo::class.java
            )
        }
    override val packageName: String
        get() = context.packageName
}