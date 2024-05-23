package com.anhquan.unisync.models

import com.google.gson.annotations.SerializedName

data class DeviceMessage(
    val time: Long = System.currentTimeMillis(),
    val type: Type,
    val header: DeviceMessageHeader,
    val payload: DeviceMessagePayload? = null,
    val body: Map<String, Any?> = mapOf()
) {
    object BodyKey {
        const val ERROR = "error"
    }

    object BodyValue {
        const val NO_PERMISSION = "no_permission"
    }

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
        @SerializedName("telephony")
        TELEPHONY,
        @SerializedName("sharing")
        SHARING,
        @SerializedName("gallery")
        GALLERY,
        @SerializedName("storage")
        STORAGE,
        @SerializedName("ssh")
        SSH,
        @SerializedName("media")
        MEDIA
    }

    override fun toString(): String {
        return """
time: $time,
type: $type,
header: $header,
body: $body,
payload: $payload
        """.trimIndent()
    }

    data class DeviceMessageHeader(
        val type: Type,
        val method: String,
        val status: Status? = null
    ) {
        enum class Type {
            @SerializedName("request")
            REQUEST,
            @SerializedName("response")
            RESPONSE,
            @SerializedName("notification")
            NOTIFICATION,
        }

        enum class Status {
            @SerializedName("success")
            SUCCESS,
            @SerializedName("error")
            ERROR
        }

        override fun toString(): String {
            return """
{
    type: $type,
    method: $method,
    status: $status
}
            """.trimIndent()
        }
    }

    data class DeviceMessagePayload(
        val port: Int = -1,
        val size: Long,
    ) {
        override fun toString(): String {
            return """
{
    port: $port,
    size: $size
}
            """.trimIndent()
        }
    }
}
