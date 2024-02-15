package com.anhquan.unisync.models

import com.google.gson.annotations.SerializedName

data class DeviceMessage(
    val time: Long = System.currentTimeMillis(),
    val type: Type,
    val body: Map<String, Any?> = mapOf()
) {
    enum class Type {
        @SerializedName("pair")
        PAIR,
        @SerializedName("battery")
        BATTERY,
        @SerializedName("clipboard")
        CLIPBOARD,
        @SerializedName("notification")
        NOTIFICATION,
        @SerializedName("volume")
        VOLUME,
    }
}
