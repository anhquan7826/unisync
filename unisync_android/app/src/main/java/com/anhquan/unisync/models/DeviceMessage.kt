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
        @SerializedName("status")
        STATUS,
        @SerializedName("clipboard")
        CLIPBOARD,
        @SerializedName("notification")
        NOTIFICATION,
        @SerializedName("volume")
        VOLUME,
        @SerializedName("run_command")
        RUN_COMMAND,
        @SerializedName("ring_phone")
        RING_PHONE,
    }

    override fun toString(): String {
        return """
            time: $time,
            type: $type,
            body: $body
        """.trimIndent()
    }
}
