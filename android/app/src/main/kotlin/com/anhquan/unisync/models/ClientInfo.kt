package com.anhquan.unisync.models

import com.google.gson.Gson
import com.google.gson.JsonSyntaxException

data class ClientInfo(
    val id: String,
    val name: String,
    val ip: String = "",
    val deviceType: String,
) {
    companion object {
        private val gson = Gson()

        fun fromJson(json: String): ClientInfo? {
            return try {
                gson.fromJson(json, ClientInfo::class.java)
            } catch (_: JsonSyntaxException) {
                null
            }
        }
    }

    fun toJson(): String {
        return gson.toJson(this)
    }
}